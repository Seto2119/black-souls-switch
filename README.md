# BLACK SOULS — Native Nintendo Switch Port

Нативный порт [BLACK SOULS](https://www.dlsite.com/) (RPG Maker VX Ace / RGSS3) для Nintendo Switch (Tegra X1, ARM64), работающий через Atmosphère и Homebrew Menu.

**Движок:** [mkxp-z](https://github.com/mkxp-z/mkxp-z) (форк mkxp с поддержкой RGSS3).
**Toolchain:** devkitPro / devkitA64 / libnx.
**Формат:** `BLACK_SOULS.nro`.

> ⚠️ **Статус: исследование + минимальный smoke-test.** Ничто здесь не считается «работающим портом», пока не подтверждено запуском на реальной консоли. См. `REPORT.md`.

## Требования

- devkitPro с `devkitA64`, `libnx`, `switch-portlibs`
- macOS / Linux / Windows хост (сборка под ARM64 через devkitA64)
- Легальная копия игры BLACK SOULS (файлы `Audio/`, `Graphics/`, `Data/`, `Game.rgss3a`, `Game.ini`)

## Сборка минимального .nro (smoke-test)

```bash
export DEVKITPRO=/opt/devkitpro
export DEVKITA64=$DEVKITPRO/devkitA64
export PORTLIBS=$DEVKITPRO/portlibs/switch
export LIBNX=$DEVKITPRO/libnx
make -j$(nproc)
```

Результат: `black-souls-switch.nro` + `black-souls-switch.nacp`.

## Установка на Switch

1. Скопируй `.nro` в `/switch/` на microSD.
2. Запусти через Homebrew Menu (hbmenu).

## Игровые данные

Коммерческие ресурсы BLACK SOULS в этот репозиторий **не входят**. Положи свою копию в `gamedata/` (не коммитится, см. `.gitignore`).

## Лицензия

Код порта — GPLv2+ (наследует mkxp-z). Игровые ресурсы — собственность правообладателя, не распространяются.
