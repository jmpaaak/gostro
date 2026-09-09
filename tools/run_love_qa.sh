#!/bin/sh
# Run LÖVE for automated tests/captures without stealing macOS focus.
# Usage: LOVE_BIN=/path/to/love tools/run_love_qa.sh <gamedir-or-package> [args...]
set -e
export GOSTRO_LOOP=1
export GAME_QA=1
export SDL_MAC_BACKGROUND_APP=1
export SDL_HINT_VIDEO_MAC_BACKGROUND_APP=1
REAL="${LOVE_BIN:-love}"
# Never recurse if LOVE_BIN accidentally points at this script or loop/bin/love.
case "$REAL" in
  *run_love_qa.sh|*loop/bin/love)
    REAL="${GOSTRO_LOVE_REAL:-/Users/jm/Applications/love.app/Contents/MacOS/love}"
    ;;
esac
TARGET="$1"
HERE=$(CDPATH= cd -- "$(dirname "$0")" && pwd)
if [ -n "$TARGET" ] && [ -d "$TARGET" ] && [ ! -f "$TARGET/conf.lua" ]; then
  cp "$HERE/qa_conf.lua" "$TARGET/conf.lua"
fi
exec "$REAL" "$@"
