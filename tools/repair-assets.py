import argparse
import concurrent.futures
import ftplib
import hashlib
import io
import json
from pathlib import Path
import threading
import time
import unicodedata

parser = argparse.ArgumentParser(description='Repair Switch game resources using ASCII aliases and SHA-256 read-back verification.')
parser.add_argument('--source', type=Path, required=True, help='Original game directory')
parser.add_argument('--host', required=True, help='Switch FTP address')
parser.add_argument('--port', type=int, default=5000)
parser.add_argument('--remote', default='/switch/black-souls/gamedata')
parser.add_argument('--report', type=Path, default=Path('asset-repair-report.json'))
args = parser.parse_args()
SOURCE = args.source
REMOTE = args.remote
lock = threading.Lock()
counts = dict(checked=0, repaired=0, bytes=0, errors=0)
results = []

def alias_name(name):
    data = unicodedata.normalize('NFC', name).encode('utf-8')
    value = 14695981039346656037
    for byte in data:
        if 65 <= byte <= 90:
            byte += 32
        value = ((value ^ byte) * 1099511628211) & ((1 << 64) - 1)
    return f'{value:016x}'

def connect():
    ftp = ftplib.FTP()
    ftp.connect(args.host, args.port, timeout=40)
    ftp.login()
    ftp.cwd(REMOTE)
    ftp.voidcmd('TYPE I')
    return ftp

def worker(files):
    ftp = connect()
    try:
        try:
            ftp.mkd('nx-assets')
        except ftplib.error_perm:
            pass
        for source in files:
            relative = unicodedata.normalize('NFC', source.relative_to(SOURCE).as_posix())
            size = source.stat().st_size
            repaired = False
            try:
                try:
                    existing = ftp.size(relative)
                except ftplib.all_errors:
                    existing = None
                if existing != size:
                    target = 'nx-assets/' + alias_name(relative)
                    try:
                        alias_size = ftp.size(target)
                    except ftplib.all_errors:
                        alias_size = None
                    if alias_size != size:
                        with source.open('rb') as stream:
                            ftp.storbinary('STOR ' + target, stream, blocksize=262144)
                    digest = hashlib.sha256()
                    ftp.retrbinary('RETR ' + target, digest.update, blocksize=262144)
                    assert digest.digest() == hashlib.sha256(source.read_bytes()).digest(), target
                    repaired = True
                with lock:
                    counts['checked'] += 1
                    if repaired:
                        counts['repaired'] += 1
                        counts['bytes'] += size
                    results.append(dict(path=relative, alias=alias_name(relative), size=size, repaired=repaired))
            except Exception as error:
                with lock:
                    counts['errors'] += 1
                    results.append(dict(path=relative, error=str(error)))
                try:
                    ftp.close()
                except Exception:
                    pass
                ftp = connect()
    finally:
        ftp.close()

files = [file for folder in ['Audio', 'Graphics', 'Data', 'Fonts', 'Movies']
         for file in (SOURCE / folder).rglob('*')
         if file.is_file() and not file.name.startswith('._')]
print('Checking', len(files), 'resources', flush=True)
with concurrent.futures.ThreadPoolExecutor(max_workers=2) as pool:
    futures = [pool.submit(worker, files[i::2]) for i in range(2)]
    while any(not future.done() for future in futures):
        with lock:
            print(json.dumps(counts), flush=True)
        time.sleep(5)
    for future in futures:
        future.result()
args.report.write_text(json.dumps(dict(counts=counts, files=results), ensure_ascii=False, indent=2))
print('FINAL', json.dumps(counts), flush=True)
if counts['errors']:
    raise SystemExit(1)
