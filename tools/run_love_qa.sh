#!/bin/sh
# Run LÖVE for automated tests/captures without stealing macOS focus.
# Usage: LOVE_BIN=/path/to/love tools/run_love_qa.sh <gamedir-or-package> [args...]
set -e
export SDL_MAC_BACKGROUND_APP=1
export SDL_HINT_VIDEO_MAC_BACKGROUND_APP=1
export GAME_QA=1
REAL="${LOVE_BIN:-love}"
TARGET="$1"
if [ -n "$TARGET" ] && [ -d "$TARGET" ] && [ ! -f "$TARGET/conf.lua" ]; then
    HERE=$(CDPATH= cd -- "$(dirname "$0")" && pwd)
    cp "$HERE/qa_conf.lua" "$TARGET/conf.lua"
fi
exec "$REAL" "$@"
