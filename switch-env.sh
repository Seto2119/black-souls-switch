#!/bin/bash
# Единое изолированное окружение для сборки под Switch (msys2 bash).
# TMP/TEMP обязательны в Windows-форме: GCC берёт их через GetTempPath(),
# а унаследованный из этой сессии TMP ломается при переходе в нативный процесс.
exec env -i \
  TMPDIR='C:\Users\user\AppData\Local\Temp' \
  TMP='C:\Users\user\AppData\Local\Temp' \
  TEMP='C:\Users\user\AppData\Local\Temp' \
  DEVKITPRO='C:\devkitPro' \
  'ProgramData=C:\ProgramData' \
  'ProgramFiles(x86)=C:\Program Files (x86)' \
  'ProgramFiles=C:\Program Files' \
  SystemRoot='C:\Windows' \
  SystemDrive='C:' \
  USERPROFILE='C:\Users\user' \
  HOMEDRIVE='C:' \
  HOMEPATH='\Users\user' \
  APPDATA='C:\Users\user\AppData\Roaming' \
  LOCALAPPDATA='C:\Users\user\AppData\Local' \
  PATH="/c/Users/user/.local/bin:/c/devkitPro/devkitA64/bin:/c/devkitPro/portlibs/switch/bin:/c/devkitPro/msys2/usr/bin:/c/Windows/system32:/c/Program Files/Git/usr/bin" \
  "$@"
