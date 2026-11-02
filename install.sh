#!/bin/sh
# BLACK SOULS — install script for Nintendo Switch (run on the Switch via hbmenu, or on PC to prepare the SD card)
# Usage: copy BLACK_SOULS.nro to /switch/, and your legal game files into /switch/black-souls/gamedata/

set -e

SD="${1:-/}"

DEST="$SD/switch/black-souls"
GAME="$DEST/gamedata"

echo "[1/3] Creating directories on $SD"
mkdir -p "$DEST" "$GAME"

echo "[2/3] Checking for game data..."
REQUIRED="Audio Graphics Data Game.rgss3a Game.ini"
MISSING=0
for f in $REQUIRED; do
  if [ ! -e "$GAME/$f" ]; then
    echo "  MISSING: $GAME/$f"
    MISSING=1
  fi
done

if [ "$MISSING" = "1" ]; then
  echo ""
  echo "Game data incomplete. Copy your legal BLACK SOULS copy into:"
  echo "  $GAME/"
  echo "Required: Audio/ Graphics/ Data/ (or Game.rgss3a) Game.ini"
  echo "Leave behind: Game.exe, System/, installscript.vdf (Windows-only)."
  exit 1
fi

echo "[3/3] Game data OK."
echo ""
echo "Done. Launch BLACK SOULS from Homebrew Menu."
echo "Saves are written next to the engine as Save01.rvdata2 ..."
