# Передача файлов на Switch (status)

Последний проверенный рабочий путь переноса игры на Switch — через
**кардридер ПК** (буква `D:`), командой `robocopy`. FTP-серверы Switch
(DBI и sys-ftpd) **не поддерживают не-ASCII (японские) имена файлов** —
это их фундаментальное ограничение, обхода нет. MTP-режим DBI ломает
юникод так же.

## Что уже на Switch

- `switch/BLACK_SOULS.nro` (движок, 18.3 МБ) — залит
- `switch/mkxp.json` — залит
- `switch/black-souls/gamedata/` — 2571 файл с ASCII-именами залит
  (через FTP, до выявления ограничения)

## Что НЕ хватает (завтра дозалить)

**1297 файлов с японскими именами** — список в `tools/missing_files.txt`.
Это вся музыка BGM/SE (ogg/mp3/wav) и спрайты персонажей/врагов (png),
на которые ссылаются RGSS-скрипты. Без них игра не найдёт ресурсы.

## Как дозалить (проверено, 100%)

1. Вынуть microSD из Switch, вставить в кардридер ПК (буква `D:`).
2. `robocopy` из `C:\Users\user\Downloads\BLACKSOULS 2 (+3 DLC) (purge only english)`
   в `D:\switch\black-souls\gamedata\` — юникод-имена ложатся корректно.
3. Карту обратно в Switch.

Команда (PowerShell, заменяя пути под свою папку с игрой):

```powershell
$SRC='C:\Users\user\Downloads\BLACKSOULS 2 (+3 DLC) (purge only english)'
$DST='D:\switch\black-souls\gamedata'
robocopy "$SRC\Audio"    "$DST\Audio"    /E /R:1 /W:1
robocopy "$SRC\Graphics" "$DST\Graphics" /E /R:1 /W:1
robocopy "$SRC\Data"     "$DST\Data"     /E /R:1 /W:1
robocopy "$SRC\Fonts"    "$DST\Fonts"    /E /R:1 /W:1
robocopy "$SRC\Movies"   "$DST\Movies"   /E /R:1 /W:1
Copy-Item "$SRC\Game.ini" "$DST\Game.ini"
```

## Проверка целостности

Целевые числа файлов в `gamedata/` (сверять после копирования):

| Папка | Файлов |
|---|---|
| Audio | 883 |
| Graphics | 2592 |
| Data | 425 |
| Fonts | 11 |
| Movies | 2 |

`Game.ini` — рядом с папками.

## Утилиты переноса (для истории)

- `tools/ftp_upload.py` — FTP-заливка (работает только с ASCII-именами)
- `tools/mtp_copy.ps1` — MTP-заливка через Shell COM (медленная, асинхронная)
- `tools/missing_files.txt` — точный список 1297 недостающих файлов
