# STATUS
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

## 2026-09-08 — 상점 UI 모듈 (game/ui/shop.lua)

- Created `game/ui/shop.lua`: shop screen with 3 gwang joker cards, reroll, next round, money.
  - `new(money)`: generates 3 random gwang cards from pool (chips/mult/yaku_mult) with prices.
  - `buy_card(s, idx)`: purchase card at slot 1-3, deducts price, marks sold. Fails on insufficient money, invalid index, or already-sold.
  - `reroll(s)`: replaces unsold cards with fresh random gwang, costs $5. Fails if money < 5.
  - `can_reroll(s)`: boolean check for reroll affordability.
  - `hit_test(s, px, py)`: returns "reroll", "next", card index (1-3), or nil.
  - `money_text(s)`: "$N" display string.
  - `card_positions()`: 3-slot layout centred in 320×180 viewport.
  - `draw(s)`: gold gwang cards with ★ + name + price tag, reroll button (green), next round button (blue), money display, sold-out slots.
- Layout: 36×52px cards, 10px gap, buttons 60×18px below cards.
- Tests in `game/tests/shop_ui.lua`: new state, buy success/fail (money/index/sold), reroll success/fail, can_reroll, hit_test (reroll/next/cards/miss), money_text.
- `make verify LOVE=/Users/jm/.local/bin/love` GREEN: GOSTRO_UNIT_OK, GOSTRO_SMOKE_OK, LOVE_BUNDLE_OK.
- INBOX (9) → 처리 완료.
- Next slice: INBOX (10) 블라인드 선택 화면 모듈 (`game/ui/blind_select.lua`).

## 2026-09-08 — 블라인드 선택 화면 모듈 (game/ui/blind_select.lua)

- Created `game/ui/blind_select.lua`: blind selection screen with 3 cards (small/big/boss).
  - `new(ante)`: generates 3 blind entries with targets from `run.blind_target`, reward text (+$3/+$5/+$8).
  - `select_blind(s, idx)`: sets `s.selected` to the blind kind. Rejects out-of-range indices.
  - `hit_test(s, px, py)`: returns card index (1-3) or nil.
  - `card_positions()`: 3-slot layout centred in 320×180 viewport (50×70px cards, 14px gap).
  - `display_name(kind)`: Korean blind names (스몰/빅/보스 블라인드).
  - `draw(s)`: colour-coded cards (blue/gold/red) with name, target score, reward text, selection highlight, instruction hint.
- Tests in `game/tests/blind_select_ui.lua`: new state (3 blinds, ante/targets/rewards), targets match run engine, ante 2 scaling, select_blind success/reject, hit_test cards/miss, display_name.
- `make verify LOVE=/Users/jm/.local/bin/love` GREEN: GOSTRO_UNIT_OK, GOSTRO_SMOKE_OK, LOVE_BUNDLE_OK.
- INBOX (10) → 처리 완료.
- Next slice: INBOX (11) play 씬 리빌드: UI 모듈 통합 (`game/scenes/play.lua`).

## 2026-09-08 — play 씬 상태 머신 + 엔진 연동 (game/scenes/play.lua)

- Rebuilt `game/scenes/play.lua`: state machine `blind_select → playing → shop → (next blind_select)` with full engine integration.
  - `new()`: creates run_state (ante 1), blind_select UI, gwang_slots UI. Initial state = `blind_select`.
  - `select_blind(scene, idx)`: picks blind → deals 8 random cards → creates scoreboard + action buttons → state = `playing`.
  - `play_hand(scene)`: evaluates selected cards via `hwatu.evaluate`, applies gwang joker bonuses (chips+30/mult+4/yaku×1.5), adds score via `run.add_score`.
  - `discard_hand(scene)`: removes selected cards, redeals to 8.
  - `check_clear(scene)`: if score ≥ target → `run.clear_blind` → shop (or `won` at ante 8 boss).
  - `leave_shop(scene)`: syncs money, `run.leave_shop` → next blind_select.
  - `buy_shop_card(scene, idx)`: shop purchase → `run.buy_gwang` → gwang_slots sync.
  - `update(dt)`: ticks scoreboard animation, syncs button enabled state.
  - `draw()`: delegates to state-appropriate UI modules only. Gwang slots always visible.
  - `mousepressed(px,py)` + `keypressed(key)`: input routing per state.
- All UI modules (`hand`, `scoreboard`, `action_buttons`, `shop`, `blind_select`, `gwang_slots`) are required and delegated; play.lua is pure glue (< 250 lines).
- Tests in `game/tests/play_integration.lua`: state transitions (blind_select→playing→shop→blind_select), play/discard with engine scoring, full ante cycle (small→big→boss→ante 2), gwang_slots existence.
- `make verify LOVE=/Users/jm/.local/bin/love` GREEN: GOSTRO_UNIT_OK, GOSTRO_SMOKE_OK, LOVE_BUNDLE_OK.
- INBOX (11) → 처리 완료 (state machine + engine integration slice).
- Next slice: INBOX (12) 점수 연출 모듈 (`game/ui/score_anim.lua`).

## 2026-09-08 — 점수 연출 모듈 (game/ui/score_anim.lua)

- Created `game/ui/score_anim.lua`: Balatro-style score animation with phase-based state machine (idle→cards→mult→total→done).
  - Cards phase: per-card chip popup with CARD_DELAY (0.3s), fade-in, accumulated chips display.
  - Mult phase: shows final_chips × final_mult (0.5s).
  - Total phase: ease-out countup to final score (0.8s).
  - Gwang joker glow: triggered slots glow with identity-based colors (chips=blue, mult=red, yaku_mult=gold), pulsing, 2s duration with fade-out.
  - `draw()` and `draw_gwang_glow()` for love.graphics rendering. `dismiss()` to return to idle.
  - Cascading update: large dt correctly advances through all phases.
- Tests in `game/tests/score_anim_ui.lua`: 7 tests (new, start, card_popups, mult, total, gwang_glow, idle_after_finish).
- `make verify LOVE=/Users/jm/.local/bin/love` GREEN: GOSTRO_UNIT_OK, GOSTRO_SMOKE_OK, LOVE_BUNDLE_OK.
- INBOX (12) → 처리 완료.
- Next slice: INBOX (13) 카드 홀로그램/포일/폴리크롬 이펙트 시스템 (`game/ui/card_effects.lua`).

## 2026-09-08 — 카드 홀로그램/포일/폴리크롬 이펙트 (`game/ui/card_effects.lua`)

- Created `game/ui/card_effects.lua`: Balatro-style editions.
  - hologram: rainbow translucent overlay, +10 mult
  - foil: sparkle overlay, +50 chips
  - polychrome: color-shift overlay, ×1.5 mult
  - `bonus` / `visual` / `overlay_color` / `apply` / `apply_bonuses` / `draw_overlay` (love.graphics optional).
- `game/hwatu.lua` `card()` accepts `{ effect = ... }`; `evaluate()` applies edition bonuses (chips += foil; mult = (mult + hologram) × polychrome product) and reports `effect_chips` / `effect_mult_add` / `effect_mult_mul`.
- `game/ui/card.lua` draws the overlay when `c.effect` is set.
- Tests in `game/tests/card_effects.lua` (known effects, bonuses, visual/overlay, apply, hwatu hologram/foil/polychrome/mixed/reject).
- `make verify LOVE=/Users/jm/.local/bin/love` GREEN: GOSTRO_UNIT_OK, GOSTRO_SMOKE_OK, LOVE_BUNDLE_OK.
- INBOX (13) → 처리 완료.
- Next slice: INBOX (14) 태그 시스템 (`game/tags.lua`).

## 2026-09-08 — 태그 시스템 (스몰/빅 블라인드 스킵 보상)

- Created `game/tags.lua`: Balatro-style skip tags. Pool of 12 (coupon, investment, handy, economy, mega, foil, hologram, polychrome, charm, uncommon, juggle, d6).
  - coupon/d6 = free shop reroll; investment/handy/economy = pending money; mega = duplicate next gwang; foil/hologram/polychrome = next gwang edition; charm = extra shop slot; uncommon = uncommon shop; juggle = hand size +1.
- `game/run.lua`: `skip_blind(state, tag_id)` skips small→big or big→boss, applies tag, stays in play. Boss / non-play phase rejected.
- Tests in `game/tests/tags.lua` (pool ≥10, by_id, random, apply effects, skip small/big, cannot skip boss, cannot skip outside play).
- `make verify LOVE=/Users/jm/.local/bin/love` GREEN: GOSTRO_UNIT_OK, GOSTRO_SMOKE_OK, LOVE_BUNDLE_OK.
- INBOX (14) → 처리 완료.
- Next slice: INBOX (15) 보스 블라인드 디버프 (`game/boss_blinds.lua`).

> 이전 cycle 이력은 `docs/STATUS_HISTORY.md`에 있다. 특정 과거 버그를 추적할 때만 그 파일을 검색하고, 평소에는 읽지 않는다.
