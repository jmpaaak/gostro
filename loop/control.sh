#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
LABEL="com.jm.gostro.autodev-loop"
DOMAIN="gui/$(id -u)"
TARGET="${DOMAIN}/${LABEL}"
PLIST="${HOME}/Library/LaunchAgents/${LABEL}.plist"
STOP_FILE="${SCRIPT_DIR}/STOP"

is_loaded() {
  launchctl print "${TARGET}" >/dev/null 2>&1
}

is_running() {
  launchctl print "${TARGET}" 2>/dev/null | grep -q 'state = running'
}

case "${1:-}" in
  start|on)
    rm -f "${STOP_FILE}"
    if [[ ! -f "${PLIST}" ]]; then
      printf 'LaunchAgent is not installed: %s\n' "${PLIST}" >&2
      exit 1
    fi
    if ! is_loaded; then
      launchctl bootstrap "${DOMAIN}" "${PLIST}"
    elif ! is_running; then
      launchctl kickstart "${TARGET}"
    fi
    printf 'Start requested.\n'
    "${BASH_SOURCE[0]}" status
    ;;
  stop|off)
    touch "${STOP_FILE}"
    if is_running; then
      printf 'STOP requested; the current cycle will finish before normal exit.\n'
    else
      printf 'STOP set; the loop is not currently running.\n'
    fi
    ;;
  status)
    if [[ ! -f "${PLIST}" ]]; then
      printf 'not installed (%s)\n' "${PLIST}"
      exit 1
    fi
    if ! is_loaded; then
      printf 'installed, not loaded, not running\n'
      exit 0
    fi
    if is_running; then
      printf 'loaded and running\n'
    else
      printf 'loaded, not running\n'
    fi
    if [[ -f "${STOP_FILE}" ]]; then
      printf 'STOP is set\n'
    fi
    ;;
  *)
    printf 'Usage: %s {start|stop|status}\n' "$0" >&2
    exit 2
    ;;
esac
