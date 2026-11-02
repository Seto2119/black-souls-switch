import ftplib, os, sys, time

HOST = "192.168.0.100"
PORT = 5000
USER = "19ilka19"
PASS = ""
LOCAL_ROOT = r"C:\Users\user\black-souls-switch\sd\switch\black-souls\gamedata"
REMOTE_ROOT = "/switch/black-souls/gamedata"

ftp = ftplib.FTP()
ftp.connect(HOST, PORT, timeout=30)
ftp.login(USER, PASS)
ftp.set_pasv(True)

# count total files
total = 0
for dirpath, dirs, files in os.walk(LOCAL_ROOT):
    total += len(files)

done = 0
failed = []
t0 = time.time()

def ensure_dir(relpath):
    parts = [p for p in relpath.replace("\\", "/").split("/") if p]
    cur = REMOTE_ROOT
    for p in parts:
        cur = cur + "/" + p
        try:
            ftp.mkd(cur)
        except ftplib.error_perm:
            pass  # already exists

for dirpath, dirs, files in os.walk(LOCAL_ROOT):
    rel = os.path.relpath(dirpath, LOCAL_ROOT)
    if rel == ".":
        rel = ""
    ensure_dir(rel)
    for fn in files:
        local = os.path.join(dirpath, fn)
        remote = REMOTE_ROOT + (("/" + rel.replace("\\", "/")) if rel else "") + "/" + fn
        remote = remote.replace("\\", "/")
        try:
            with open(local, "rb") as f:
                ftp.storbinary("STOR " + remote, f)
            done += 1
        except Exception as e:
            failed.append((remote, str(e)))
        if done % 100 == 0:
            el = time.time() - t0
            rate = done / el if el > 0 else 0
            print(f"progress {done}/{total} ({rate:.1f} files/s)", flush=True)

el = time.time() - t0
print(f"DONE {done}/{total} in {el:.0f}s; failed={len(failed)}", flush=True)
for r, e in failed[:20]:
    print(f"  FAIL {r}: {e}", flush=True)

ftp.quit()
