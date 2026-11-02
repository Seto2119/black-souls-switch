#!/bin/bash
# Единое изолированное окружение для сборки под Switch (msys2 bash).
# TMP/TEMP обязательны в Windows-форме: GCC берёт их через GetTempPath(),
# а унаследованный из этой сессии TMP ломается при переходе в нативный процесс.
#
# ВАЖНО (выяснено экспериментально): запуск дочернего bash БЕЗ --noprofile
# --norc бесполезен. /etc/profile в devkitPro-вом msys2 сбрасывает окружение
# (DEVKITPRO, TMP, TEMP, VSINSTALLDIR исчезают), и gcc снова падает на
# 'Cannot create temporary file in C:\WINDOWS\'. Поэтому флаги добавляются
# здесь автоматически, а не в каждой команде вызова.
ENVV=( \
  TMPDIR='C:\Users\user\AppData\Local\Temp' \
  TMP='C:\Users\user\AppData\Local\Temp' \
  TEMP='C:\Users\user\AppData\Local\Temp' \
  DEVKITPRO='C:\devkitPro' \
  'ProgramData=C:\ProgramData' \
  'ProgramFiles(x86)=C:\Program Files (x86)' \
  'ProgramFiles=C:\Program Files' \
  VSINSTALLDIR='C:\devkitPro' \
  SystemRoot='C:\Windows' \
  SystemDrive='C:' \
  USERPROFILE='C:\Users\user' \
  HOMEDRIVE='C:' \
  HOMEPATH='\Users\user' \
  APPDATA='C:\Users\user\AppData\Roaming' \
  LOCALAPPDATA='C:\Users\user\AppData\Local' \
  PATH="/c/Users/user/.local/bin:/c/devkitPro/devkitA64/bin:/c/devkitPro/portlibs/switch/bin:/c/devkitPro/msys2/usr/bin:/c/Windows/system32:/c/Program Files/Git/usr/bin" \
)

if [ "$1" = "bash" ]; then
  shift
  exec env -i "${ENVV[@]}" /usr/bin/bash --noprofile --norc "$@"
fi

exec env -i "${ENVV[@]}" "$@"
