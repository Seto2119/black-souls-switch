# Установка BLACK SOULS на Nintendo Switch

## Что нужно

1. Nintendo Switch с Atmosphère (Homebrew доступен).
2. `BLACK_SOULS.nro` — собранный порт (из этого репозитория).
3. Твоя легальная копия BLACK SOULS (Steam или DLsite).

## Шаги

### 1. Положи порт на microSD

```
microSD/
└── switch/
    ├── BLACK_SOULS.nro
    ├── mkxp.json          (конфиг движка — РЯДОМ с .nro, движок chdir в каталог .nro)
    └── black-souls/
        └── gamedata/
            ├── Audio/
            ├── Graphics/
            ├── Fonts/
            ├── Movies/        (если есть)
            ├── Data/          (распакованная копия — Scripts.rvdata2 внутри)
            └── Game.ini
```

### 2. Скопируй игровые файлы

Из своей папки с игрой скопируй в `gamedata/`:

- `Audio/`
- `Graphics/`
- `Fonts/`
- `Game.ini`
- `Game.rgss3a` — **или** `Data/`, если копия распакованная

**НЕ копируй** (Windows-only, движок их заменяет):

- `Game.exe`
- `System/`
- `installscript.vdf`
- `*.dll`, `*.vdf`, `Game.rvproj2`

### 3. Запусти

Homebrew Menu → BLACK SOULS.

Первый запуск дольше (распаковка Ruby stdlib). Сохранения пишутся рядом с движком: `Save01.rvdata2`, `Save02.rvdata2`, …

## Ограничения порта (текущее состояние)

См. `REPORT.md`. Движок **собран** (`mkxp-z.nro`, exit 0), но запуск на консоли **ещё не проверен**. Точки диагностики: `sdmc:/mkxp-z-boot.log` (до инициализации RGSS) и `sdmc:/mkxp-z-error.log`. MIDI отключён (FluidSynth не портирован).

## Кнопки (целевая раскладка, как в PortMaster-порте)

| Кнопка | Действие |
|---|---|
| B | Подтвердить |
| A | Отмена / меню |
| X | Бег |
| Start | Меню |
