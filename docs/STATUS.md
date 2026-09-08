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

## 2026-09-07 — run state: blinds, shop, gwang slots

- Added pure `game/run.lua`: ante 1→8 small/big/boss (Balatro-style targets), play score ≥ blind → shop, buy gwang jokers (one identity each, max 5), leave shop to next blind, ante 8 boss clear = won. Gwang is never a play card.
- Tests in `game/tests/run.lua`. `play.lua` requires the module only.
- `make verify LOVE=/Users/jm/.local/bin/love` GREEN: GOSTRO_UNIT_OK, GOSTRO_SMOKE_OK, LOVE_BUNDLE_OK.
- INBOX (1) first-play slice complete (hwatu eval + run blinds/shop). Next: empty 처리 대기 = IDLE unless new feedback.

## 2026-09-08 — 발라트로 UI 벤치마크 문서

- Created `docs/UI_BENCHMARK.md`: 발라트로 UI 레이아웃 5개 화면(메인 플레이, 상점, 블라인드 선택, 게임오버/승리, 시각 스타일) 텍스트 정리.
- 고스트로 적용 변환 메모: 포커→화투 대응표, 320×180 기준 좌표 스케치(광 슬롯, 점수판, 버튼, 핸드 카드 위치), 색상 팔레트 12색.
- 코드 변경 없음. `make verify` GREEN: GOSTRO_UNIT_OK, GOSTRO_SMOKE_OK, LOVE_BUNDLE_OK.
- INBOX (2) → 처리 완료.
- Next slice: INBOX (3) 고스트로 UI 와이어프레임 생성 (`tools/gen_wireframe.py` → `docs/wireframes/*.png`).

## 2026-09-08 — UI 와이어프레임 4장 생성

- Created `tools/gen_wireframe.py` (PIL, 46 lines): 320×180 wireframe 4장 생성.
- Output: `docs/wireframes/{play,shop,blind_select,result}.png` — 회색 박스+레이블.
- Created `docs/WIREFRAME.md`: 각 화면 요소별 실제 구현 좌표(x,y,w,h) 테이블.
- Created `docs/GENERATED_ASSET_LOG.md`: 4개 에셋 타임스탬프 기록.
- `make verify` GREEN: GOSTRO_UNIT_OK, GOSTRO_SMOKE_OK, LOVE_BUNDLE_OK.
- INBOX (3) → 처리 완료.
- Next slice: INBOX (4) 카드 렌더링 모듈 (`game/ui/card.lua`).

## 2026-09-08 — 카드 렌더링 모듈 (game/ui/card.lua)

- Created `game/ui/card.lua`: single hwatu card widget — new/toggle_select/draw_y/symbol/bg_color/hit_test/draw. 24×36px, 8px lift on select, 5 play kinds only (gwang rejected). Background rect + kind symbol + selection border highlight.
- Tests in `game/tests/card_ui.lua`: constants, new, toggle, draw_y, symbol, hit_test (including lifted hitbox), bg_color for all kinds.
- `make verify` GREEN: GOSTRO_UNIT_OK, GOSTRO_SMOKE_OK, LOVE_BUNDLE_OK.
- INBOX (4) → 처리 완료.
- Next slice: INBOX (5) 핸드 디스플레이 모듈 (`game/ui/hand.lua`).

## 2026-09-08 — 핸드 디스플레이 모듈 (game/ui/hand.lua)

- Created `game/ui/hand.lua`: hand display module — deal 8 cards in centred overlapping row (16px gap < 24px card width = Balatro-style fan), max 5 selection with order tracking, toggle/deselect, selection_index, get_selected, hit_test (reverse z-order), draw with selection order number overlay.
- Cards anchor at bottom of 320×180 viewport (y=138, 6px bottom pad).
- Depends on `game/ui/card.lua` for individual card widgets.
- Tests in `game/tests/hand_ui.lua`: deal layout, overlap check, select/deselect/toggle, max 5 limit, selection order, get_selected.
- `make verify LOVE=/Users/jm/.local/bin/love` GREEN: GOSTRO_UNIT_OK, GOSTRO_SMOKE_OK, LOVE_BUNDLE_OK.
- INBOX (5) → 처리 완료.
- Next slice: INBOX (7) 점수판 UI 모듈 (`game/ui/scoreboard.lua`).

## 2026-09-08 — 광 조커 슬롯 UI 모듈 (game/ui/gwang_slots.lua)

- Created `game/ui/gwang_slots.lua`: gwang joker slot bar at top of 320×180 viewport.
  - 5 slots in centred horizontal row (28×16px each, 4px gap, 4px top pad).
  - Empty slots: dashed border. Equipped slots: dark bg + gold border + ★ symbol.
  - `new()`, `equip()`, `is_empty()`, `sync_from_run()`, `display_text()`, `draw()`.
  - `display_text()` returns "★ name effect" (e.g. "★ 칩 +30 칩", "★ 배수 +4 배수").
  - `slot_positions()` returns layout rects for external hit-testing.
- Tests in `game/tests/gwang_slots_ui.lua`: 5-slot init, equip fill order, max 5 rejection, display text ★/name, is_empty, sync_from_run.
- `make verify LOVE=/Users/jm/.local/bin/love` GREEN: GOSTRO_UNIT_OK, GOSTRO_SMOKE_OK, LOVE_BUNDLE_OK.
- INBOX (6) → 처리 완료.
- Next slice: INBOX (7) 점수판 UI 모듈 (`game/ui/scoreboard.lua`).

## 2026-09-08 — 점수판 UI 모듈 (game/ui/scoreboard.lua)

- Created `game/ui/scoreboard.lua`: scoreboard UI module for chips × mult = total score.
  - `new()`: initial state (chips=0, mult=1, displayed_score=0, target=0, popup=nil).
  - `set_target(sb, target)`: bind blind target for progress bar.
  - `set_hand_result(sb, chips, mult)`: accumulates chips×mult to displayed_score, creates Balatro-style popup with floating text + fade.
  - `progress_ratio(sb)`: 0..1 clamped ratio of score vs blind target.
  - `reset(sb)`: clear between rounds.
  - `update(sb, dt)`: tick popup timer, auto-clear expired popup.
  - `format_score_text(chips, mult)`: returns "42 × 3 = 126" string.
  - `draw(sb)`: right-side panel with chips×mult line, total/target, progress bar (blue→green on clear), floating popup with shadow+fade.
- Tests in `game/tests/scoreboard_ui.lua`: new defaults, set_target, set_hand_result accumulation, progress_ratio clamping, reset, popup timer tick+expiry, format_score_text.
- `make verify LOVE=/Users/jm/.local/bin/love` GREEN: GOSTRO_UNIT_OK, GOSTRO_SMOKE_OK, LOVE_BUNDLE_OK.
- INBOX (7) → 처리 완료.
- Next slice: INBOX (8) 플레이/버리기 버튼 모듈 (`game/ui/action_buttons.lua`).

## 2026-09-08 — 플레이/버리기 버튼 모듈 (game/ui/action_buttons.lua)

- Created `game/ui/action_buttons.lua`: Balatro-style bottom-center 2-button UI.
  - `new(hands, discards)`: initial state (default 4 hands, 3 discards), play/discard disabled.
  - `set_selection(ab, count)`: enables/disables buttons based on card selection count and remaining uses.
  - `use_hand(ab)`: decrements hands_left, returns true/false. Fails if disabled or no selection.
  - `use_discard(ab)`: decrements discards_left, returns true/false. Fails if disabled or no selection.
  - `reset(ab, hands, discards)`: restore counts for new round.
  - `hit_test(ab, px, py)`: returns "play"/"discard"/nil for touch tap support.
  - `display_text(ab, which)`: "놓기 (N)" / "버리기 (N)" with remaining count.
  - `keypressed(ab, key)`: space → play, d → discard keyboard shortcuts.
  - `draw(ab)`: blue play button (left) + red discard button (right), dimmed when disabled, centred text with count.
- Layout: 52×18px buttons, 8px gap, centred at bottom of 320×180 viewport.
- Tests in `game/tests/action_buttons_ui.lua`: new defaults, custom counts, set_selection enable/disable, use_hand/use_discard success/fail/no-selection, reset, hit_test play/discard/miss, display_text content.
- `make verify LOVE=/Users/jm/.local/bin/love` GREEN: GOSTRO_UNIT_OK, GOSTRO_SMOKE_OK, LOVE_BUNDLE_OK.
- INBOX (8) → 처리 완료.
- Next slice: INBOX (9) 상점 UI 모듈 (`game/ui/shop.lua`).
