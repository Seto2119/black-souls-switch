# BLACK SOULS II — Native Nintendo Switch Port

Нативный порт **BLACK SOULS II** (RPG Maker VX Ace / RGSS3) для Nintendo Switch (Tegra X1, ARM64), работающий через Atmosphère и Homebrew Menu.

**Движок:** [mkxp-z](https://github.com/mkxp-z/mkxp-z) (форк mkxp с поддержкой RGSS3).
**Toolchain:** devkitPro / devkitA64 / libnx.
**Формат:** `BLACK_SOULS.nro`.

> ⚠️ **Статус: портирование движка (Этап 3).** Ничто здесь не считается «работающим портом», пока не подтверждено запуском на реальной консоли. См. `REPORT.md`.

## Требования

- devkitPro с `devkitA64`, `libnx`, `switch-portlibs`
- macOS / Linux / Windows хост (сборка под ARM64 через devkitA64)
- Легальная копия игры BLACK SOULS II (файлы `Audio/`, `Graphics/`, `Data/`, `Fonts/`, `Game.ini`)

## Прогресс портирования

| Этап | Статус |
|---|---|
| Исследование mkxp-z/Switch | ✅ есть прецедент `randygil/pokemon-anil-switch` |
| Smoke-test `.nro` (libnx) | ✅ собран, exit 0 |
| Cross-сборка Ruby (MRI 3.1.7) | ✅ `libruby-static.a` + `hello-ruby-nx.nro` |
| Статические portlibs (iconv/uchardet/SDL_sound/pixman/SDL2/nxcompat) | ✅ собраны в `portlibs/` |
| Системные portlibs (mesa/EGL, sdl2_image/ttf, openal, physfs, vorbis…) | ✅ установлены (pacman) |
| Патчи mkxp-z + сборка `.nro` | ⏳ в работе |

## Сборка

```bash
# 1. Клонировать и подготовить зависимости (см. build/)
# 2. Собрать движок:
bash switch-env.sh bash -c 'cd build/mkxp-z && \
  meson setup build-switch --cross-file=../../switch-cross.txt --wipe \
    -Dgfx_backend=gles -Ddefault_system=enabled \
    -Dworkdir_current=true -Duse_miniffi=false -Druby_system=enabled \
    --wrap-mode=nodownload && ninja -C build-switch'
```

## Установка на Switch

См. `docs/INSTALL-SWITCH.md`. Кратко:

```
microSD/switch/
├── BLACK_SOULS.nro
└── black-souls/
    ├── mkxp.json
    └── gamedata/  (Audio/ Graphics/ Data/ Fonts/ Game.ini — твоя копия)
```

## Игровые данные

Коммерческие ресурсы BLACK SOULS II в репозиторий **не входят**. Свою копию положи в `gamedata/` (см. `.gitignore`).

## Лицензия

Код порта — GPLv2+ (наследует mkxp-z). Игровые ресурсы — собственность правообладателя.
