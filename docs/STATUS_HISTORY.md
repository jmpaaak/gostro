# STATUS history

Automatically archived by `scripts/compact_status.py`. The autonomous dev
loop does not read this file by default — only search it when tracking a
specific past bug.

## Archived from STATUS.md (2026-09-08 09:45)


Each autonomous dev cycle appends one dated `##` section here describing
only what it verified this cycle (facts, test results, exact next slice).
Do not rewrite older sections.

> Older cycle history lives in `docs/STATUS_HISTORY.md`. Only search it
> when tracking a specific past bug; do not read it by default.

Keep this file small: wire `scripts/compact_status.py` into a frequently
running read-only job (e.g. a progress-report cron) so it archives old
sections into `docs/STATUS_HISTORY.md` automatically once this file grows
past ~16KB. See `docs/TOKEN_OPTIMIZATION.md` for the full pattern.

## Archived from STATUS.md (2026-09-08 09:54)

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

## Archived from STATUS.md (2026-09-08 10:14)

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

## Archived from STATUS.md (2026-09-08 10:22)

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

## Archived from STATUS.md (2026-09-08 10:24)

## 2026-09-08 — 점수판 UI 모듈 (game/ui/scoreboard.lua)

## Archived from STATUS.md (2026-09-08 10:34)

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

## Archived from STATUS.md (2026-09-08 10:44)

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

## Archived from STATUS.md (2026-09-08 11:04)

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

## Archived from STATUS.md (2026-09-08 11:24)

## 2026-09-08 — 덱 정렬 (`game/deck.lua`)

- Added `deck.sort(d, key)` with `key = "kind"` or `"effect"`.
  - Kind: hongdan → cheongdan → chodan → godori → pi (stable within kind by effect).
  - Effect: none → foil → hologram → polychrome (stable within effect by kind).
  - Rejects unknown keys (month/mae), missing key, gwang, month numbers.
- Tests in `game/tests/deck.lua` GREEN (sort kind, sort effect, rejects).
- `make verify LOVE=/Users/jm/.local/bin/love` GREEN: GOSTRO_UNIT_OK, GOSTRO_SMOKE_OK, LOVE_BUNDLE_OK.
- INBOX (20) complete: viewer + enhance/destroy + sort.
- Next slice: INBOX (21) — 광 조커 트리거 조건 다양화 (`game/gwang_catalog.lua`).

## 2026-09-08 — 덱 강화/파괴 (`game/deck.lua`)

- Added `deck.enhance(d, index, effect)`: foil/hologram/polychrome on a play card. Rejects unknown editions, gwang, out-of-range index. Viewer `by_effect` updates.
- Added `deck.destroy(d, index)`: remove one play card (thin-deck). Total/counts drop by 1. Out-of-range errors.
- Tarot `the_chariot` / `the_hanged_man` operate on `d.cards` and stay visible in `deck.view`.
- Tests in `game/tests/deck.lua` GREEN (enhance, reject, destroy, tarot enhance+destroy).
- `make verify LOVE=/Users/jm/.local/bin/love` GREEN: GOSTRO_UNIT_OK, GOSTRO_SMOKE_OK, LOVE_BUNDLE_OK.
- INBOX (20) enhance+destroy slice only. Deck sort (kind / effect) is not in this slice.
- Next slice: INBOX (20) remaining — deck sort by kind / effect on `game/deck.lua`.

## Archived from STATUS.md (2026-09-08 11:34)

## 2026-09-08 — 광 조커 yaku 트리거 (`game/gwang_catalog.lua`)

- `game/data/gwang_jokers.json`: `godori_chips` / `hongdan_chips` (`trigger=yaku`, `yaku_need`, `effect.chips` +100/+50).
- `game/gwang_catalog.lua` `apply(ctx)`: `always` / `contains_kind` unchanged; `yaku` fires when `ctx.yaku` includes `yaku_need` (고도리 치면 +100칩). One godori in hand without the yaku is a no-op.
- `game/hwatu.lua` already passes `yaku` into catalog apply; evaluate reports `gwang_triggers` for the fired identity.
- Tests in `game/tests/gwang_catalog.lua` GREEN (catalog load, apply with/without godori yaku, hwatu evaluate +100 / skip).
- `make verify LOVE=/Users/jm/.local/bin/love` GREEN: GOSTRO_UNIT_OK, GOSTRO_SMOKE_OK, LOVE_BUNDLE_OK.
- INBOX (21) yaku-trigger slice only. Economy/ante/self-destruct/compound and 30-joker catalog are not in this slice.
- Next slice: INBOX (21) remaining — (d) 보유 조건 트리거 (덱 카드 수 ≤30이면 ×3) on `game/gwang_catalog.lua`.

## 2026-09-08 — 광 조커 contains_kind 트리거 (`game/gwang_catalog.lua`)

- `game/data/gwang_jokers.json`: `hongdan_x2` / `cheongdan_x2` (`trigger=contains_kind`, `kind_need`, `effect.mult_mul=2`).
- `game/gwang_catalog.lua` `apply(ctx)`: `always` unchanged; `contains_kind` fires when `ctx.hand` includes `kind_need` (홍단 1장만 있어도 ×2). Missing kind = no-op.
- `game/hwatu.lua` already passes `hand` into catalog apply; evaluate reports `gwang_triggers` for the fired identity.
- Tests in `game/tests/gwang_catalog.lua` GREEN (catalog load, apply with/without hongdan, hwatu evaluate ×2 / skip).
- `make verify LOVE=/Users/jm/.local/bin/love` GREEN: GOSTRO_UNIT_OK, GOSTRO_SMOKE_OK, LOVE_BUNDLE_OK.
- INBOX (21) contains-kind slice only. Yaku/economy/ante/self-destruct/compound and 30-joker catalog are not in this slice.
- Next slice: INBOX (21) remaining — (c) 특정 족보 달성 시 트리거 (고도리 치면 +100칩) on `game/gwang_catalog.lua`.

## 2026-09-08 — 광 조커 always 트리거 (`game/gwang_catalog.lua`)

- Created `game/data/gwang_jokers.json` + `game/gwang_catalog.lua`.
  - Catalog load: `all()` / `get(id)`. This slice trigger = `always` only.
  - `chips` +30 chips, `mult` +4 mult every scored hand. Extra always entries: `always_chips_small` (+10), `always_mult_small` (+2).
  - `apply(ctx)` loops equipped `state.gwang` identities; unknown ids are no-ops.
- `game/hwatu.lua` `evaluate(hand, state)` runs the catalog apply loop after edition bonuses. Result includes `gwang_triggers`.
- Tests in `game/tests/gwang_catalog.lua` GREEN (load, get, apply chips/mult, evaluate, no-gwang unchanged, unknown noop).
- `make verify LOVE=/Users/jm/.local/bin/love` GREEN: GOSTRO_UNIT_OK, GOSTRO_SMOKE_OK, LOVE_BUNDLE_OK.
- INBOX (21) always-trigger slice only. Kind/yaku/economy/ante/self-destruct/compound and 30-joker catalog are not in this slice.
- Next slice: INBOX (21) remaining — (b) 특정 종류 포함 시 트리거 (홍단 있으면 ×2) on `game/gwang_catalog.lua`.

## Archived from STATUS.md (2026-09-08 11:44)

## 2026-09-08 — 광 조커 money 트리거 (`game/gwang_catalog.lua`)

- `game/data/gwang_jokers.json`: `rich_mult` (`trigger=money`, `money_min=20`, `effect.mult=4`) / `loaded_chips` (`money_min=50`, `effect.chips=80`).
- `game/gwang_catalog.lua` `apply(ctx)`: previous triggers unchanged; `money` fires when held cash (`ctx.money` or `state.money`) ≥ `money_min` (소지금 $20 이상이면 +배수). Missing/under-min money is a no-op.
- `game/hwatu.lua` already passes `state` into catalog apply; evaluate reports `gwang_triggers` for the fired identity.
- Tests in `game/tests/gwang_catalog.lua` GREEN (catalog load, apply with $20 / skip $19, hwatu evaluate +4 on $20 / skip $19).
- `make verify LOVE=/Users/jm/.local/bin/love` GREEN: GOSTRO_UNIT_OK, GOSTRO_SMOKE_OK, LOVE_BUNDLE_OK.
- INBOX (21) money slice only. Ante/self-destruct/compound and 30-joker catalog are not in this slice.
- Next slice: INBOX (21) remaining — (f) 라운드/앤티 조건 (보스 블라인드에서 ×2) on `game/gwang_catalog.lua`.

## 2026-09-08 — 광 조커 deck_size 트리거 (`game/gwang_catalog.lua`)

- `game/data/gwang_jokers.json`: `thin_deck_x3` (`trigger=deck_size`, `deck_max=30`, `effect.mult_mul=3`) / `tiny_deck_chips` (`deck_max=20`, `effect.chips=50`).
- `game/gwang_catalog.lua` `apply(ctx)`: `always` / `contains_kind` / `yaku` unchanged; `deck_size` fires when play-card count (`ctx.deck_size` or `#state.deck.cards`) ≤ `deck_max` (덱 카드 수 ≤30이면 ×3). Missing/over-max deck is a no-op.
- `game/hwatu.lua` already passes `state` into catalog apply; evaluate reports `gwang_triggers` for the fired identity.
- Tests in `game/tests/gwang_catalog.lua` GREEN (catalog load, apply with deck=30 / skip deck=31, hwatu evaluate ×3 on 30-card deck / skip starter 40).
- `make verify LOVE=/Users/jm/.local/bin/love` GREEN: GOSTRO_UNIT_OK, GOSTRO_SMOKE_OK, LOVE_BUNDLE_OK.
- INBOX (21) deck-size slice only. Economy/ante/self-destruct/compound and 30-joker catalog are not in this slice.
- Next slice: INBOX (21) remaining — (e) 경제 트리거 (소지금 $20 이상이면 +배수) on `game/gwang_catalog.lua`.

## Archived from STATUS.md (2026-09-08 11:54)

## 2026-09-08 — 광 조커 복합 트리거 (`game/gwang_catalog.lua`)

- `game/data/gwang_jokers.json`: `compound` (`trigger=always`, `effect.chips=20` + `mult=2` + `money=1`).
- `game/gwang_catalog.lua` `apply_effect`: one fire can add chips, add mult, and grant money on `state.money` together. Previous triggers unchanged.
- `game/hwatu.lua` already passes `state` into catalog apply; evaluate reports `gwang_triggers` and mutates held money.
- Tests in `game/tests/gwang_catalog.lua` GREEN (catalog load, apply +20 chips/+2 mult/+$1, hwatu evaluate same).
- `make verify LOVE=/Users/jm/.local/bin/love` GREEN: GOSTRO_UNIT_OK, GOSTRO_SMOKE_OK, LOVE_BUNDLE_OK.
- INBOX (21) compound (h) slice only. 30-joker catalog is not in this slice.
- Next slice: INBOX (21) remaining — 최소 30종 광 조커 JSON 카탈로그 on `game/data/gwang_jokers.json`.

## 2026-09-08 — 광 조커 once 트리거 (`game/gwang_catalog.lua`)

- `game/data/gwang_jokers.json`: `once_x20` (`trigger=once`, `effect.mult_mul=20`).
- `game/gwang_catalog.lua` `apply(ctx)`: previous triggers unchanged; `once` fires every equipped hand (1회 ×20) then `table.remove`s that slot. Neighbors keep their slots.
- `game/hwatu.lua` already passes `state` into catalog apply; evaluate reports `gwang_triggers` then the identity is gone on the next hand.
- Tests in `game/tests/gwang_catalog.lua` GREEN (catalog load, apply ×20 then destroy / second hand noop, hwatu evaluate ×20 then skip).
- `make verify LOVE=/Users/jm/.local/bin/love` GREEN: GOSTRO_UNIT_OK, GOSTRO_SMOKE_OK, LOVE_BUNDLE_OK.
- INBOX (21) once slice only. Compound (chips+mult+money) and 30-joker catalog are not in this slice.
- Next slice: INBOX (21) remaining — (h) 복합 (칩+배수+돈 동시) on `game/gwang_catalog.lua`.

## 2026-09-08 — 광 조커 blind 트리거 (`game/gwang_catalog.lua`)

- `game/data/gwang_jokers.json`: `boss_x2` (`trigger=blind`, `blind_need=boss`, `effect.mult_mul=2`) / `boss_chips` (`blind_need=boss`, `effect.chips=40`).
- `game/gwang_catalog.lua` `apply(ctx)`: previous triggers unchanged; `blind` fires when current blind (`ctx.blind` or `state.blind`) == `blind_need` (보스 블라인드에서 ×2). Small/big/missing blind is a no-op.
- `game/hwatu.lua` already passes `state` into catalog apply; evaluate reports `gwang_triggers` for the fired identity.
- Tests in `game/tests/gwang_catalog.lua` GREEN (catalog load, apply on boss / skip small, hwatu evaluate ×2 on boss / skip small+big).
- `make verify LOVE=/Users/jm/.local/bin/love` GREEN: GOSTRO_UNIT_OK, GOSTRO_SMOKE_OK, LOVE_BUNDLE_OK.
- INBOX (21) blind slice only. Self-destruct/compound and 30-joker catalog are not in this slice.
- Next slice: INBOX (21) remaining — (g) 셀프 파괴형 (1회 ×20 후 소멸) on `game/gwang_catalog.lua`.

## Archived from STATUS.md (2026-09-08 12:05)

## 2026-09-08 — 광 조커 30종 JSON 카탈로그 (`game/data/gwang_jokers.json`)

- `game/data/gwang_jokers.json`: 30 unique gwang jokers covering always / contains_kind / yaku / deck_size / money / blind / once / compound (chips+mult+money). No month numbers/names, no mae/ppeok/otti.
- Existing apply loop in `game/gwang_catalog.lua` + `game/hwatu.lua` evaluate already fires these identities; this slice is catalog size only.
- Tests in `game/tests/gwang_catalog.lua` GREEN (prior a–h plus ≥30 unique ids, all trigger families, compound present).
- `make verify LOVE=/Users/jm/.local/bin/love` GREEN: GOSTRO_UNIT_OK, GOSTRO_SMOKE_OK, LOVE_BUNDLE_OK.
- INBOX (21) fully done: trigger patterns (a)–(h) + 30-joker catalog + hwatu apply loop.
- Next slice: INBOX (22) 시드 기반 랜덤 + 런 히스토리 on `game/rng.lua`.

## Archived from STATUS.md (2026-09-08 12:16)

## 2026-09-08 — 런 시작 시드→상점/카드/보스 (`game/run.lua`)

- `run.new(seed)` calls `rng.plan`: stores `state.seed` (A-Z0-9 display) and independent `state.rng.shop` / `cards` / `boss` streams.
- Empty/nil seed generates 8-char seed. Same seed string (case-insensitive) → same shop voucher, deal kinds, boss sequence; different seed diverges.
- `clear_blind` stocks shop via shop stream. `deal_kinds` deals hongdan/cheongdan/chodan/godori/pi from cards stream (no months). `select_boss` uses boss stream when id omitted.
- Tests in `game/tests/rng.lua` GREEN. `make verify LOVE=/Users/jm/.local/bin/love` GREEN: GOSTRO_UNIT_OK, GOSTRO_SMOKE_OK, LOVE_BUNDLE_OK.
- INBOX (22) run-start wiring only. Seed display/input UI and run history are not in this slice.
- Next slice: INBOX (22) remaining — seed display + input UI.

## 2026-09-08 — 시드 문자열 RNG (`game/rng.lua`)

- `game/rng.lua`: Balatro-style seed-string RNG. Display + input via `new(seed)` (normalize A-Z0-9 uppercase). Empty/nil generates 8-char seed.
- `random()` matches `math.random` (`()`, `(n)`, `(a,b)`). Named streams `shop` / `cards` / `boss` are independent; `plan(seed)` decides those sequences at run start.
- Same seed → same sequences; different seed diverges. No month numbers/names. Shop/play wiring and seed UI not in this slice.
- Tests in `game/tests/rng.lua` GREEN. `make verify LOVE=/Users/jm/.local/bin/love` GREEN: GOSTRO_UNIT_OK, GOSTRO_SMOKE_OK, LOVE_BUNDLE_OK.
- INBOX (22) RNG module slice only. Run history + seed display/input UI + shop/card/boss consumers are not in this slice.
- Next slice: INBOX (22) remaining — wire `rng.plan` into run start so shop/cards/boss consume the seeded streams.
