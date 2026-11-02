#!/bin/bash
# Пересборка mkxp-z под Nintendo Switch (meson + ninja + cross-файл).
#
# Все шаги ОБЯЗАНЫ идти через switch-env.sh: он делает env -i с TMP/TEMP в
# Windows-форме (иначе gcc падает 'Cannot create temporary file in C:\WINDOWS\')
# и заново запускает bash с --noprofile --norc (иначе /etc/profile из
# devkitPro-вого msys2 сбрасывает DEVKITPRO/TMP).
set -e
ROOT=/c/Users/user/black-souls-switch
MKXPZ=$ROOT/build/mkxp-z
BUILD=$MKXPZ/build-switch

bash $ROOT/switch-env.sh bash -c "cd $MKXPZ && meson setup $BUILD \
  --cross-file=$ROOT/switch-cross.txt \
  -Dgfx_backend=gles -Ddefault_system=enabled -Dworkdir_current=true \
  -Duse_miniffi=false -Druby_system=enabled -Dopenssl=disabled \
  -Dfluidsynth_system=disabled --wrap-mode=nodownload"

bash $ROOT/switch-env.sh bash -c "cd $MKXPZ && ninja -C $BUILD -j 8"

# elf2nro и nacptool — нативные exe: пути только в форме C:/, MSYS-форму они
# не понимают ('Failed to open input icon!').
cd $BUILD
cp -f mkxp-z.cortex-a57 mkxp-z.elf
/c/devkitPro/devkitA64/bin/aarch64-none-elf-strip.exe --strip-debug mkxp-z.elf
/c/devkitPro/tools/bin/nacptool.exe --create "BLACK SOULS" "black-souls-switch" "1.0.0" mkxp-z.nacp
/c/devkitPro/tools/bin/elf2nro.exe mkxp-z.elf mkxp-z.nro \
  --icon=C:/devkitPro/libnx/default_icon.jpg --nacp=mkxp-z.nacp

echo "OK: $BUILD/mkxp-z.nro"
