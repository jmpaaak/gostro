#!/bin/sh
# Installed as ~/.local/bin/love on this machine.
# Only wraps when GOSTRO_LOOP=1; otherwise execs the real Love.app binary.
# This is how Gostro-loop absolute-path launches are intercepted without
# changing Man of Korea, Spaceship, or a user `love .` play session.
REAL="/Users/jm/Applications/love.app/Contents/MacOS/love"
if [ "${GOSTRO_LOOP}" = "1" ]; then
  WRAP="/Users/jm/orca/workspaces/interactive-story-game-factory/gostro/loop/bin/love"
  if [ -x "$WRAP" ]; then
    exec "$WRAP" "$@"
  fi
fi
exec "$REAL" "$@"
