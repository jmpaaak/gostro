#!/usr/bin/env bash

HERMES_BIN="${HERMES_BIN:-/Users/jm/.hermes/hermes-agent/venv/bin/hermes}"
PROVIDER="${PROVIDER:-anthropic}"
MODEL="${MODEL:-claude-sonnet-4-6}"
REASONING="${REASONING:-high}"
FALLBACK_AGY_BIN="${FALLBACK_AGY_BIN:-/Users/jm/.local/bin/agy}"
FALLBACK_MODEL="${FALLBACK_MODEL:-gemini-3.1-pro-high}"
FALLBACK_PRINT_TIMEOUT="${FALLBACK_PRINT_TIMEOUT:-20m}"
MAX_TURNS="${MAX_TURNS:-60}"
RUN_BUDGET_SECONDS="${RUN_BUDGET_SECONDS:-1200}"
MAX_IDLE_SECONDS="${MAX_IDLE_SECONDS:-600}"
WAIT_SECONDS="${WAIT_SECONDS:-10}"
MAX_LOOPS="${MAX_LOOPS:-0}"

# Inherited by every loop child, including absolute-path `love` invocations.
export GOSTRO_LOOP=1
export GAME_QA=1
export GAME_HEADLESS=1
export SDL_MAC_BACKGROUND_APP=1
export SDL_HINT_VIDEO_MAC_BACKGROUND_APP=1
export SDL_VIDEODRIVER=dummy
export SDL_AUDIODRIVER=dummy
