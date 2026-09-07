# STATUS

Each autonomous dev cycle appends one dated `##` section here describing
only what it verified this cycle (facts, test results, exact next slice).
Do not rewrite older sections.

> Older cycle history lives in `docs/STATUS_HISTORY.md`. Only search it
> when tracking a specific past bug; do not read it by default.

Keep this file small: wire `scripts/compact_status.py` into a frequently
running read-only job (e.g. a progress-report cron) so it archives old
sections into `docs/STATUS_HISTORY.md` automatically once this file grows
past ~16KB. See `docs/TOKEN_OPTIMIZATION.md` for the full pattern.

## 2026-09-07 — repo from skeleton

- Generated `jmpaaak/gostro` from `jmpaaak/love2d-game-skeleton` (`fe75ea6667e33147bfa83a403a2fe02b155b2c1e`) via GitHub template API (same-account fork is not allowed). First created as `gostop`, renamed to `gostro`.
- Identity: `conf.lua` `t.identity = "gostro"`, window title Gostro.
- Locked design in `docs/GAME_DESIGN.md`: gwang = jokers (1 point base); play cards = hongdan red flag / cheongdan blue flag / chodan orchid / godori animals / pi; no month numbers; no fake poker hands.
- Next slice: INBOX (1) pure `game/hwatu.lua` + shop joker slots. Do not grow `play.lua`.

## 2026-09-07 — hwatu hand evaluator (dan / godori / pi)

- Added pure `game/hwatu.lua`: play cards are hongdan / cheongdan / chodan / godori / pi only. No month numbers or names. `gwang` is rejected as a play card (joker slot, base 1 via `GWANG_BASE`). Named yaku 3-of-kind (hongdan / cheongdan / chodan / godori) score chips×2; five pi is the pi yaku; no mae / ppeok / otti.
- Tests in `game/tests/hwatu.lua` (self_test requires the topic file). `play.lua` requires the module only.
- `make verify LOVE=/Users/jm/.local/bin/love` GREEN: GOSTRO_UNIT_OK, GOSTRO_SMOKE_OK, LOVE_BUNDLE_OK.
- Next slice: INBOX (1) `game/run.lua` ante 1 small/big/boss blinds + shop gwang joker slots (max 5). Do not grow `play.lua`.
