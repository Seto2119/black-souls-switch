"""Use Ruby 3.1.7 ARM64 coroutines instead of pthread-backed Fibers on Switch."""
import argparse
import os
from pathlib import Path
import shutil
import subprocess

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--source', type=Path, required=True)
parser.add_argument('--prefix', type=Path, required=True)
parser.add_argument('--devkitpro', type=Path, default=Path(os.environ.get('DEVKITPRO', '/opt/devkitpro')))
parser.add_argument('--build-dir', type=Path, required=True)
args = parser.parse_args()
source, prefix, dkp, build = [path.resolve() for path in
                             (args.source, args.prefix, args.devkitpro, args.build_dir)]
build.mkdir(parents=True, exist_ok=True)
shim = Path(__file__).resolve().parent.parent / 'patches/ruby/include'
if not (source / 'id.h').exists():
    subprocess.run(['ruby', 'tool/generic_erb.rb', '--srcdir=.', '-o', 'id.h', 'template/id.h.tmpl'],
                   cwd=source, check=True)
(build / 'native-config.h').write_text('''#include "ruby/internal/config.h"
#undef COROUTINE_H
#define COROUTINE_H "coroutine/arm64/Context.h"
''')
toolchain = dkp / 'devkitA64/bin'
suffix = '.exe' if os.name == 'nt' else ''
def tool(name):
    return str(toolchain / ('aarch64-none-elf-' + name + suffix))

arch = ['-fPIE', '-D__SWITCH__', '-march=armv8-a+crc+crypto', '-mtune=cortex-a57', '-mtp=soft']
includes = [shim, source, source / 'include', prefix / 'include/ruby-3.1.0/aarch64-elf',
            prefix / 'include/ruby-3.1.0', dkp / 'libnx/include']
subprocess.run([tool('gcc'), '-c', str(source / 'cont.c'), '-o', str(build / 'cont.o'),
                '-O2', '-g', '-std=gnu99', '-include', str(build / 'native-config.h')]
               + arch + ['-I' + str(path) for path in includes], check=True)
subprocess.run([tool('gcc'), '-c', str(source / 'coroutine/arm64/Context.S'),
                '-o', str(build / 'Context.o'), '-DSYMBOL_PREFIX='] + arch, check=True)

library = prefix / 'lib/libruby-static.a'
backup = library.with_name('libruby-static.before-fiber-fix.a')
if not backup.exists():
    shutil.copyfile(library, backup)
subprocess.run([tool('ar'), 'r', str(library), str(build / 'cont.o'), str(build / 'Context.o')], check=True)
subprocess.run([tool('ranlib'), str(library)], check=True)
print('Ruby ARM64 Fiber support installed. Rebuild mkxp-z before deploying.')
