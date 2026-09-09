#!/bin/sh
# Print the Love binary to use for Gostro-loop QA.
# On macOS, copy Love.app once into build/qa_app/love-qa.app with LSUIElement
# so it never appears in Dock / Cmd-Tab. Do not modify the user's Love.app.
set -e
REAL="${1:-${GOSTRO_LOVE_REAL:-/Users/jm/Applications/love.app/Contents/MacOS/love}}"
if [ "$(uname)" != "Darwin" ]; then
  printf '%s\n' "$REAL"
  exit 0
fi
# Resolve to the .app bundle if REAL is .../Something.app/Contents/MacOS/love
APP_DIR="$(CDPATH= cd -- "$(dirname "$REAL")/../.." && pwd)"
case "$APP_DIR" in
  *.app) ;;
  *) printf '%s\n' "$REAL"; exit 0 ;;
esac
HERE=$(CDPATH= cd -- "$(dirname "$0")" && pwd)
QA_APP="$HERE/../build/qa_app/love-qa.app"
PLIST="$QA_APP/Contents/Info.plist"
NEED_BUILD=0
if [ ! -x "$QA_APP/Contents/MacOS/love" ]; then
  NEED_BUILD=1
else
  if ! /usr/libexec/PlistBuddy -c "Print :LSUIElement" "$PLIST" >/dev/null 2>&1; then
    NEED_BUILD=1
  fi
fi
if [ "$NEED_BUILD" = "1" ]; then
  mkdir -p "$HERE/../build/qa_app"
  rm -rf "$QA_APP"
  cp -R "$APP_DIR" "$QA_APP"
  /usr/libexec/PlistBuddy -c "Add :LSUIElement bool true" "$PLIST" 2>/dev/null \
    || /usr/libexec/PlistBuddy -c "Set :LSUIElement true" "$PLIST"
  /usr/libexec/PlistBuddy -c "Set :CFBundleName GostroLoop" "$PLIST" 2>/dev/null || true
  /usr/libexec/PlistBuddy -c "Set :CFBundleDisplayName GostroLoop" "$PLIST" 2>/dev/null || true
  codesign --force --sign - "$QA_APP" >/dev/null 2>&1 || true
fi
printf '%s\n' "$QA_APP/Contents/MacOS/love"
