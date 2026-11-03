"""Rebuild Ruby 3.1.7 thread.o with real Horizon pthread stack bounds."""
import argparse
import os
from pathlib import Path
import shutil
import subprocess

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--source', type=Path, required=True, help='Ruby 3.1.7 source directory')
parser.add_argument('--prefix', type=Path, required=True, help='Project portlibs directory')
parser.add_argument('--devkitpro', type=Path, default=Path(os.environ.get('DEVKITPRO', '/opt/devkitpro')))
parser.add_argument('--build-dir', type=Path, required=True)
args = parser.parse_args()
source, prefix, dkp, build = [path.resolve() for path in
                             (args.source, args.prefix, args.devkitpro, args.build_dir)]
build.mkdir(parents=True, exist_ok=True)
if not (source / 'id.h').exists():
    subprocess.run(['ruby', 'tool/generic_erb.rb', '--srcdir=.', '-o', 'id.h', 'template/id.h.tmpl'],
                   cwd=source, check=True)

shutil.copyfile(source / 'thread.c', build / 'thread.c')
pthread_source = (source / 'thread_pthread.c').read_text()
signal_setup = '    posix_signal(SIGVTALRM, null_func);'
if signal_setup not in pthread_source:
    raise SystemExit('Expected Ruby 3.1.7 thread_pthread.c signal setup was not found')
(build / 'thread_pthread.c').write_text(pthread_source.replace(
    signal_setup, '#ifndef __SWITCH__\n' + signal_setup + '\n#endif', 1))
(build / 'pthread-config.h').write_text('''#include <pthread.h>
#define HAVE_PTHREAD_GETATTR_NP 1
#ifndef PTHREAD_STACK_MIN
#define PTHREAD_STACK_MIN 16384
#endif
int pthread_getattr_np(pthread_t, pthread_attr_t *);
''')

toolchain = dkp / 'devkitA64/bin'
suffix = '.exe' if os.name == 'nt' else ''
def tool(name):
    return str(toolchain / ('aarch64-none-elf-' + name + suffix))

includes = [build, source, source / 'include',
            prefix / 'include/ruby-3.1.0/aarch64-elf',
            prefix / 'include/ruby-3.1.0', dkp / 'libnx/include']
subprocess.run([tool('gcc'), '-c', str(build / 'thread.c'), '-o', str(build / 'thread.o'),
                '-O2', '-g', '-std=gnu99', '-fPIE', '-D__SWITCH__',
                '-march=armv8-a+crc+crypto', '-mtune=cortex-a57', '-mtp=soft',
                '-include', str(build / 'pthread-config.h')]
               + ['-I' + str(path) for path in includes], check=True)

library = prefix / 'lib/libruby-static.a'
backup = library.with_name('libruby-static.before-stack-fix.a')
if not backup.exists():
    shutil.copyfile(library, backup)
subprocess.run([tool('ar'), 'r', str(library), str(build / 'thread.o')], check=True)
subprocess.run([tool('ranlib'), str(library)], check=True)
print('Ruby thread.o updated. Rebuild mkxp-z with patches/nxcompat.c, which provides pthread_getattr_np.')
