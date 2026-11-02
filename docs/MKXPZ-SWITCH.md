# mkxp-z → Nintendo Switch: сборка через meson + ninja

Статус: **собирается**. `mkxp-z.nro` (18.3 МБ) получен, ссылка проходит с
`-Wl,--no-undefined`, NRO структурно совпадает с эталонным рабочим
`black-souls-switch.nro` (NRO0, text@0, ASET сразу за полем size).

Артефакты:

- `build/mkxp-z/build-switch/mkxp-z.elf` — ELF64 AArch64, DYN, `_start`@0
- `build/mkxp-z/build-switch/mkxp-z.nro` — NRO с ASET (иконка + nacp)
- `mkxp-z-switch.nro`, `mkxp-z-switch.nacp` — копии в корне проекта
- `patches/mkxp-z-switch.diff`, `patches/nxcompat.c` — все правки одним diff
- `switch-build.sh` — воспроизводимая пересборка

## Окружение (что пришлось починить)

1. **`switch-env.sh` не работал как задумано.** `env -i ... bash -c` бесполезен:
   `/etc/profile` в devkitPro-вом msys2 сбрасывает окружение, и `DEVKITPRO`,
   `TMP`, `TEMP` до gcc не доходят. Теперь скрипт сам добавляет
   `--noprofile --norc` (и `VSINSTALLDIR`, иначе meson 1.12 лезет искать
   vswhere.exe и падает с `TypeError: ... not 'NoneType'`).
2. **pkg-config.** `C:/devkitPro/msys2/usr/bin/pkg-config.exe` (pkgconf 2.4.3)
   резолвит только собственный корень — `PKG_CONFIG_PATH` и `pkg_config_path`
   в cross-файле бесполезны (плюс `:` в `C:/...` режется как разделитель).
   Решение: все `.pc` (devkitPro + собранные локально ruby-3.1/pixman/uchardet/
   SDL2_sound/iconv) скопированы в его штатный каталог
   `C:/devkitPro/msys2/usr/lib/pkgconfig`, `pkg_config_path` убран из cross-файла.
3. **`sys_root` в cross-файле ломал пути из `.pc`**: meson приписывал sysroot к
   абсолютным `-I`, получалось
   `C:/devkitPro/devkitA64/aarch64-none-elf/c/Users/.../include/SDL2`.
   `sys_root` удалён, пути заданы явными `-I/-L` (в т.ч. в наш префикс).
4. В `.pc` devkitPro переписан `prefix=/opt/devkitpro` → `C:/devkitPro`
   (бэкап: `pc-backup/`).
5. `theoraplay` тянется wrap-файлом — тарбол положен в
   `subprojects/packagecache/` (sha256 совпал), сборка идёт с `--wrap-mode=nodownload`.

## meson-правки (src/meson.build)

- `gl` → `dependency('egl') + dependency('glesv2')`, subproject mesa не собирается.
- FluidSynth: subproject и `-DSHARED_FLUID` отключены, `MKXPZ_FLUIDSYNTH_SONAME`
  задан строкой → MIDI отваливается в рантайме через `SDL_LoadObject`.
- `ruby_system=enabled` → `-lruby-static` через `ruby-3.1.pc`.
- `MKXPZ_TTF_FONT=_TTF_Font` (SDL_ttf ≥ 2.0.18 делает `TTF_Font` typedef, а
  `font.h` объявляет `struct MKXPZ_TTF_FONT;`).
- SDL2_image: явные `-ljpeg -lpng16 -lwebp` (Requires.private не пробрасывается).
- link_args: `-static-libstdc++ -static-libgcc -lnxcompat -lnx`,
  `-Wl,--wrap=fcntl -Wl,--wrap=realpath`, `-DAL_LIBTYPE_STATIC`.
- `src/nxcompat.c` добавлен в источники.

## Правки C++

| файл | что |
|---|---|
| `src/system/system.h` | ветка `__SWITCH__` → `MKXPZ_PLATFORM_SWITCH` |
| `src/system/systemImpl.cpp` | язык через сервис `set` (newlib без локалей), `getUserName` → "Player" |
| `src/filesystem/ghc/filesystem.hpp` | `__SWITCH__` → `GHC_OS_LINUX` |
| `src/net/httplib.h` | нет `ifaddrs.h`/`sys/mman.h`/`sys/un.h`, `USE_IF2IP` off, mmap-загрузка файлов → false |
| `src/main.cpp` | chdir в каталог `.nro` из argv[0]; EGL/GLES2-атрибуты окна, без RESIZABLE/HIGHDPI; `showInitError` → `sdmc:/mkxp-z-error.log`; WAYLAND/X11-автовыбор отключён |
| `src/eventthread.cpp` | `SDL_SetWindowSize/Position/GetDesktopDisplayMode/SetWindowFullscreen` не вызываются (fatalThrow 2345-0007), `rqWindowAdjust.clear()` сохранён |
| `src/input/keybindings.cpp` | A/B и X/Y под раскладку Nintendo |
| `src/audio/vorbissource.cpp` | `OV_HOLE` — до 8 повторов вместо смерти потока |
| `src/audio/alstream.cpp` | музыкальный поток на предпочтительное ядро 2 (`svcSetThreadCoreMask`) |
| `src/util/rapidcsv.h` | `std::stold` → `strtold` (newlib не объявляет char-перегрузку) |

## Не сделано / ограничения

- MIDI отключён (нет fluidsynth в devkitPro) — `fluid-fun.cpp` попытается
  `SDL_LoadObject("libfluidsynth-2.so")` и тихо отключит MIDI.
- Не применены оптимизации из эталона: `pathCache` через `readdir`
  (`filesystem.cpp`), обработка отказа аллокации текстур (`texpool.cpp`),
  отключение клавиатурного меню по F1 (`settingsmenu.cpp`).
- OpenSSL отключён (`-Dopenssl=disabled`) → HTTPS в net-binding недоступен.
- Иконка — стандартная devkitPro; NACP создан `nacptool`.
- **На железе/эмуляторе не запускалось.** Стартовые точки для отладки:
  `sdmc:/mkxp-z-boot.log` (следы до инициализации RGSS) и
  `sdmc:/mkxp-z-error.log`.
