# Отчёт об исследовании и статусе

Дата: 2026-11-02. Статус: **Этап 1 (исследование) завершён, Этап 2 (smoke-test) завершён.**

## 1. Исследование mkxp-z и Nintendo Switch

### Выводы

1. **mkxp-z официально НЕ поддерживает Switch.** Поддерживаемые платформы: Windows, Linux (x86/ARM/POWER), macOS (Intel + Apple Silicon). В README upstream Switch не упомянут.
2. **Официальный порт BLACK SOULS существует — но для PortMaster (Linux-хендхелды), а не для Switch.** Портер `Omka1337`, репозиторий `omka-1337/BlackSouls-PortMaster`. Движок — mkxp-z, собранный под ARM/Linux. Это прямое доказательство: **mkxp-z способен запускать BLACK SOULS на ARM64** — вопрос только в слое ОС.
3. **Есть прецедент порта mkxp-z именно под Switch (libnx):** репозиторий `randygil/pokemon-anil-switch` содержит `build-deps.sh`, где mkxp-z-зависимости (libiconv, uchardet, SDL_sound, pixman) собираются под `devkitA64` с `-D__SWITCH__` и линкуются с `-lnxcompat -lnx`. Это рабочий образец сборки mkxp-z под Horizon OS.
4. **devkitPro/libnx полностью поддерживают Switch:** `devkitA64` (gcc 16.1.0, binutils 2.46.0, newlib), `libnx 4.12.0`, `switch-cmake 1.5.2`, `switch-pkg-config`, `switch-zlib`, `switch-curl`. Графика: deko3d + OpenGL (EGL) — оба есть в examples.

### Таблица совместимости с devkitPro/libnx

| Компонент mkxp-z | Зависимость | В devkitPro? | Примечание |
|---|---|---|---|
| SDL2 (ядро) | SDL2 | ⚠️ через `switch-sdl2` | есть пакет `switch-sdl2` в dkp-pacman |
| Графика (GL) | OpenGL/EGL | ✅ | libnx `deko3d.h` + `switch-mesa`/EGL |
| Графика (программ.) | pixman | ❌ | собрать самому (см. pokemon-anil-switch) |
| Аудио | SDL2_mixer / SDL_sound | ⚠️ | SDL_sound собрать самому |
| MIDI | fluidsynth | ❌ | собрать самому или отключить |
| Шрифты/текст | SDL_ttf / shader | ⚠️ | зависит от конфигурации |
| Ruby (RGSS3) | MRI Ruby | ❌ | главный порог — нужна кросс-сборка Ruby под ARM64 |
| Кодировки | libiconv, uchardet | ❌ | собрать самому |
| ФС (microSD) | libnx `fs` | ✅ | нативно |

### Ключевой риск

**MRI Ruby (интерпретатор RGSS3).** mkxp-z использует MRI, а не mruby (в upstream mruby/nul привязки удалены). Кросс-компиляция полноценного MRI под `aarch64-none-elf` — нетривиальна: нужны configure-флаги под newlib, `--disable-shared`, возможно `miniruby` для кодогенерации. Это основной блокер Этапа 3, а не SDL2/графика.

Проверяемое решение: собрать Ruby как статическую библиотеку тем же методом, что libiconv/pixman в `pokemon-anil-switch` (configure `--host=aarch64-none-elf`), либо использовать mruby-привязку, если версия игры совместима.

## 2. Подготовка (Этап 2)

- [x] devkitPro установлен (проверено: devkitA64, libnx 4.12.0, switch-cmake).
- [x] Минимальный `.nro` собран: `black-souls-switch.nro` (166 КБ) + `.nacp`. Команда `make` завершилась exit 0.
- [ ] Отсутствующие portlibs для mkxp-z: SDL2, SDL_sound, fluidsynth, Ruby, pixman, libiconv, uchardet — **не собраны** (Этап 3).

## 3. Следующие шаги (Этап 3)

1. Установить/собрать `switch-sdl2` и прочие portlibs.
2. Кросс-сборка Ruby под ARM64 (ключевой блокер).
3. Сборка mkxp-z с `-D__SWITCH__` по образцу `randygil/pokemon-anil-switch`.
4. Запуск на консоли, проверка по чек-листу Этапа 4.

## 4. Ограничения

- Сборка `.nro` на этой машине подтверждена; **запуск на консоли ещё не выполнялся**.
- Коммерческие ресурсы BLACK SOULS в репозиторий не входят.
