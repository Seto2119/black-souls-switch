# Отчёт об исследовании и статусе

Дата: 2026-11-03. Статус: **движок собран (`.nro`), перенос игры на Switch — не завершён (японские имена файлов).**

## 1. Исследование mkxp-z и Nintendo Switch

1. **mkxp-z официально НЕ поддерживает Switch.** Windows/Linux/macOS — да, Switch — нет.
2. **Порт BLACK SOULS есть на PortMaster (Linux-хендхелды), не на Switch.** Портер `Omka1337`, репо `omka-1337/BlackSouls-PortMaster`. Доказывает: mkxp-z запускает BLACK SOULS на ARM64.
3. **Рабочий прецедент порта mkxp-z под Switch (libnx):** `randygil/pokemon-anil-switch` — `build-deps.sh` собирает зависимости под `devkitA64` с `-D__SWITCH__`, линковка `-lnxcompat -lnx`. Ruby решён как **статический CRuby 3.1.7** (не mruby), 23/23 тестов на реальной Switch.

## 2. Что сделано (завершено)

| Компонент | Статус |
|---|---|
| Исследование | ✅ есть прецедент, Ruby-подход проверен |
| Smoke-test `.nro` (libnx) | ✅ собран, exit 0 |
| Кросс-сборка Ruby 3.1.7 → `libruby-static.a` | ✅ (45.7 МБ) |
| portlibs (iconv, uchardet, SDL_sound, pixman, SDL2, nxcompat) | ✅ собраны |
| Системные portlibs (mesa/EGL, sdl2_image/ttf, openal, physfs, vorbis…) | ✅ 16 пакетов pacman |
| Патчи mkxp-z (24 шт) | ✅ `patches/mkxp-z-switch.diff` |
| Сборка движка | ✅ `mkxp-z.nro` (18.3 МБ), `--no-undefined` чисто |
| Обработчик исключений libnx + трассировка T0–T12 | ✅ `nxcompat.c` |

Итог: движок **собирается без ошибок**, запуск на консоли **не подтверждён**.

## 3. Главные технические открытия

- **libnx в этой версии не имеет API `exceptionHandler`.** Механизм — weak-символ `__libnx_exception_handler` + `__nx_exception_stack[0x4000]` + `__nx_exception_ignoredebug=1`. Без них краш молча убивал процесс (чёрный экран).
- **Ruby под Horizon требует:** BASERUBY 3.1.x, патч `mkmf.rb try_link0`, отключение GC-компактификации, `PTHREAD_STACK_MIN=16384`, shim `pthread_getattr_np`.
- **meson cross-файл:** `-fPIE` в c_args И c_link_args; `DEVKITPRO` в Windows-форме; `pkg_config_path` — один каталог.

## 4. Блокер: перенос игры на Switch

**FTP-серверы Switch (DBI и sys-ftpd) не поддерживают не-ASCII (японские) имена** — `fopen` ломается на символах > U+00FF. MTP-режим DBI — так же. Фундаментальное ограничение.

В игре 1343 файла с японскими именами (BGM/SE, спрайты) — без них RGSS не найдёт ресурсы.

**Решение (проверено):** кардридер ПК + `robocopy` (юникод идеально, 3914/3914). Детали — `docs/TRANSFER.md`.

На Switch уже: `.nro` + `mkxp.json` + 2571 ASCII-файл. Не хватает **1297 японских** (`tools/missing_files.txt`).

## 5. Следующие шаги (завтра)

1. Дозалить 1297 японских файлов через кардридер (robocopy).
2. Запустить на Switch, снять `mkxp-z-boot.log` (T0–T12) и `mkxp-z-error.log`.
3. Точечные правки по логам.
4. Финализировать README/релиз.

## 6. Ограничения

- Движок собран, но **не запущен** — «собирается» ≠ «работает».
- MIDI отключён (FluidSynth не портирован).
- OpenSSL выключен.
- Коммерческие ресурсы в репозиторий не входят.
