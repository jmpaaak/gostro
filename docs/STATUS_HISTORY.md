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

## Archived from STATUS.md (2026-09-08 12:27)

## 2026-09-08 — 시드 표시 + 입력 (`game/ui/seed.lua`)

- `game/ui/seed.lua`: Balatro-style seed display + typed input. `new(seed)` shows A-Z0-9 uppercase. Focus field → type A-Z0-9 (max 8) → Return applies (empty generates 8-char). Hit-test on field rect; unfocused keys ignored.
- `play.new(seed)` shows `run_state.seed`. `play.apply_seed` restarts the run from the typed seed (blind_select). Draw + mouse/key route in play scene only.
- Tests in `game/tests/seed_ui.lua` GREEN. `make verify LOVE=/Users/jm/.local/bin/love` GREEN: GOSTRO_UNIT_OK, GOSTRO_SMOKE_OK, LOVE_BUNDLE_OK.
- INBOX (22) seed display/input UI slice only. Run history is not in this slice.
- Next slice: INBOX (22) remaining — run history.

## Archived from STATUS.md (2026-09-08 12:48)

## 2026-09-08 — 광 카드 에디터 이미지 JSON 저장 (`tools/gwang-editor/`)

- `tools/gwang-editor/editor.js`: uploaded, center-cropped PNG art persists on each joker's JSON `image` field as a base64 `data:image/...;base64,...` URL.
  - `isImageDataUrl` rejects non-image and non-base64 image values before Save/Download.
  - `serializePool` explicitly preserves each valid `joker.image` in both FSA direct save and downloaded JSON.
- Tests: `python3 -m unittest tools.test_gwang_editor -v` GREEN (21 tests: schema + File API/FSA + grid + upload + image persistence).
- `make verify LOVE=/Users/jm/.local/bin/love` GREEN: GOSTRO_UNIT_OK, GOSTRO_SMOKE_OK, LOVE_BUNDLE_OK.
- INBOX (23) slice (d) only. Overlays, edit form, New/Delete, locale, runtime image decode remain.
- Next slice: INBOX (23e) 카드 프레임 이름 + 희귀도 띠 + 효과 텍스트 오버레이 on `tools/gwang-editor/`.

## 2026-09-08 — 광 카드 에디터 이미지 업로드 (`tools/gwang-editor/`)

- `tools/gwang-editor/`: per-card image upload into the hwatu frame.
  - Hidden `input.card-image-input` (accept image/*) on each card; `wireImageUploads` handles change.
  - `centerCropToCard` canvas-crops to 2:3 (240×360), centered (`sx`/`sy`), then `toDataURL`.
  - Cropped art renders as `.hwatu-art` (`position: absolute`, `object-fit: cover`) inside the rounded card.
- Tests: `python3 -m unittest tools.test_gwang_editor -v` GREEN (17 tests: schema + File API/FSA + grid + image upload).
- INBOX (23) slice (c) only. JSON `image` persist on save, overlays, edit form, New/Delete, locale, runtime image decode are not in this slice.
- Next slice: INBOX (23) remaining — (d) 이미지는 base64 data URL로 JSON `image` 필드에 저장 on `tools/gwang-editor/`.

## 2026-09-08 — 광 카드 에디터 그리드 뷰 (`tools/gwang-editor/`)

- `tools/gwang-editor/`: each loaded joker renders as a hwatu card (`article.hwatu-card`).
  - Vertical 2:3 rectangle, rounded corners (`aspect-ratio: 2 / 3`, `border-radius: 10px`).
  - ★ mark + English name; `data-id` on each card. `renderGrid` maps `pool.jokers`.
- Tests: `python3 -m unittest tools.test_gwang_editor -v` GREEN (13 tests: schema + File API/FSA + grid).
- `make verify LOVE=/Users/jm/.local/bin/love` GREEN: GOSTRO_UNIT_OK, GOSTRO_SMOKE_OK, LOVE_BUNDLE_OK.
- INBOX (23) slice (b) only. Image upload, overlays, edit form, New/Delete, locale, runtime image decode are not in this slice.
- Next slice: INBOX (23) remaining — (c) 이미지 업로드 (카드 프레임 안 중앙 크롭 + 리사이즈) on `tools/gwang-editor/`.

## 2026-09-08 — 광 카드 에디터 로드/저장 (`tools/gwang-editor/`)

- Created `tools/gwang-editor/index.html` + `editor.css` + `editor.js` (gear-editor pattern).
  - File API: Open `gwang_jokers.json` via `<input type=file>` → `readFileAsJson` / `loadDocument`.
  - FSA: Open + enable direct save (`showOpenFilePicker`) and Save to disk (`createWritable`).
  - Download JSON exports `gwang_jokers.json`. `validatePool` checks jokers schema (id, name KO/EN, rarity, trigger, effect chips/mult/mult_mul/money, desc).
- Tests: `python3 -m unittest tools.test_gwang_editor -v` GREEN (10 tests: catalog schema + File API/FSA/serialize).
- `make verify LOVE=/Users/jm/.local/bin/love` GREEN: GOSTRO_UNIT_OK, GOSTRO_SMOKE_OK, LOVE_BUNDLE_OK.
- INBOX (23) slice (a) only. Grid view, image upload, overlays, edit form, New/Delete, locale, runtime image decode are not in this slice.
- Next slice: INBOX (23) remaining — (b) 카드 그리드 뷰 (화투 카드 모양) on `tools/gwang-editor/`.

## 2026-09-08 — 런 히스토리 (`game/run_history.lua`)

- `game/run_history.lua`: Balatro-style finished-run log. `record(state, won|lost)` stores seed (A-Z0-9), outcome, ante, blind, money. Newest-first, cap 8. `reset()` / `list()`.
- `run.clear_blind` records won on ante 8 boss. `run.lose` sets phase lost and records. No month numbers/names.
- Tests in `game/tests/run_history.lua` GREEN. `make verify LOVE=/Users/jm/.local/bin/love` GREEN: GOSTRO_UNIT_OK, GOSTRO_SMOKE_OK, LOVE_BUNDLE_OK.
- INBOX (22) fully done (rng + shop/cards/boss wiring + seed UI + run history).
- Next slice: INBOX (23) 광 카드 에디터 — 웹 도구 (`tools/gwang-editor/`).

## Archived from STATUS.md (2026-09-08 12:53)

## 2026-09-08 — 광 카드 에디터 카드 오버레이 (`tools/gwang-editor/`)

- Each hwatu card now overlays its English name, effect summary, and a rarity ribbon above uploaded art.
  - Effect text formats chips, additive mult, multiplicative mult, and money catalog effects.
  - Common/uncommon/rare/legendary ribbons use gray/green/blue/purple theme colors.
- TDD: new `GwangEditorCardOverlayTests` observed RED (4 failures), then GREEN.
- `python3 -m unittest tools.test_gwang_editor -v` GREEN (25 tests).
- `make verify LOVE=/Users/jm/.local/bin/love` GREEN: GOSTRO_UNIT_OK, GOSTRO_SMOKE_OK, LOVE_BUNDLE_OK.
- INBOX (23) slice (e) only. Edit form, New/Delete, locale toggle, and runtime image decode remain.
- Next slice: INBOX (23f) 카드 편집 폼 on `tools/gwang-editor/`.

## Archived from STATUS.md (2026-09-08 13:02)

## 2026-09-08 — 광 카드 에디터 편집 폼 (`tools/gwang-editor/`)

- Added a selected-card edit panel for ID, KO/EN names, rarity, trigger condition, chips/additive-mult/multiplicative-mult effects, and KO/EN descriptions.
- Trigger-specific controls cover kind, yaku, deck-size, money, and blind conditions; invalid or duplicate edits are rejected before the in-memory catalog changes.
- Applying a valid edit rerenders the card grid; direct-save/download remains explicit.
- TDD: `GwangEditorEditFormTests` observed RED (5 failures), then GREEN.
- `python3 -m unittest tools.test_gwang_editor -v` GREEN (30 tests).
- `make verify LOVE=/Users/jm/.local/bin/love` GREEN: GOSTRO_UNIT_OK, GOSTRO_SMOKE_OK, LOVE_BUNDLE_OK.
- INBOX (23) slice (f) only. New/Delete, locale toggle, and runtime image decode remain.
- Next slice: INBOX (23g) `+ New Card` on `tools/gwang-editor/`.

## Archived from STATUS.md (2026-09-08 13:07)

## 2026-09-08 — 광 카드 에디터 새 카드 (`tools/gwang-editor/`)

- Added `+ New Card`; it enables after loading a catalog and appends a schema-valid common gwang with a collision-free `gwang_new` ID.
- The new card is selected immediately and opens in the existing edit form; grid, validation, direct-save, and download flows use the updated in-memory catalog.
- TDD: `GwangEditorNewCardTests` observed RED (4 failures), then GREEN.
- `python3 -m unittest tools.test_gwang_editor -v` GREEN (34 tests); `node --check tools/gwang-editor/editor.js` GREEN.
- `make verify LOVE=/Users/jm/.local/bin/love` GREEN: GOSTRO_UNIT_OK, GOSTRO_SMOKE_OK, LOVE_BUNDLE_OK.
- INBOX (23g) New Card slice only. Delete remains; Download JSON was already completed in (23a).
- Next slice: INBOX (23g) Delete on `tools/gwang-editor/`.

## Archived from STATUS.md (2026-09-08 13:14)

## 2026-09-08 — 광 카드 에디터 카드 삭제 (`tools/gwang-editor/`)

- Added a disabled-until-selection `Delete` action for the loaded gwang catalog.
- Deletion requires confirmation, removes only the selected card, clears the editor selection, and rerenders the grid; direct-save and download persist the updated catalog.
- TDD: `GwangEditorDeleteCardTests` observed RED (4 failures), then GREEN.
- `python3 -m unittest tools.test_gwang_editor -v` GREEN (38 tests); `node --check tools/gwang-editor/editor.js` GREEN.
- `make verify LOVE=/Users/jm/.local/bin/love` GREEN: GOSTRO_UNIT_OK, GOSTRO_SMOKE_OK, LOVE_BUNDLE_OK.
- INBOX (23g) is complete: Download JSON, New Card, and Delete are implemented.
- Next slice: INBOX (23h) KO|EN locale toggle on `tools/gwang-editor/`.

## Archived from STATUS.md (2026-09-08 13:20)

## 2026-09-08 — 광 카드 에디터 KO/EN 미리보기 (`tools/gwang-editor/`)

- Added a KO | EN locale control that rerenders card names, rarity ribbons, and effect labels in the selected catalog locale.
- The active control exposes `aria-pressed`, updates the document language, and persists across reloads via localStorage (with a safe local-file fallback).
- TDD: `GwangEditorLocaleToggleTests` observed RED (4 failures), then GREEN.
- `python3 -m unittest tools.test_gwang_editor -v` GREEN (42 tests); `node --check tools/gwang-editor/editor.js` GREEN.
- `make verify LOVE=/Users/jm/.local/bin/love` GREEN: GOSTRO_UNIT_OK, GOSTRO_SMOKE_OK, LOVE_BUNDLE_OK.
- INBOX (23h) locale-toggle slice complete. Runtime JSON image loading remains.
- Next slice: INBOX (23i) load an optional catalog `image` data URL for runtime gwang rendering in a dedicated `game/ui/gwang_art.lua` module.

## Archived from STATUS.md (2026-09-08 13:28)

## 2026-09-08 — 광 카드 에디터 런타임 이미지 (`game/ui/gwang_art.lua`)

- Added optional catalog `image` data URL decoding through LÖVE, texture caching, and centered cover-crop rendering in equipped gwang slots.
- Cards without valid embedded art retain the existing star fallback; malformed or unsupported image data fails safely.
- TDD: the dedicated engine-hosted `game/tests/gwang_art.lua` first failed because the module was absent, then passed with mocked draw assertions and LÖVE's real base64/FileData/ImageData pipeline.
- `python3 -m unittest tools.test_gwang_editor -v` GREEN (42 tests).
- `make verify LOVE=/Users/jm/.local/bin/love` GREEN: GOSTRO_UNIT_OK, GOSTRO_SMOKE_OK, LOVE_BUNDLE_OK (114 files).
- INBOX (23) is fully complete and moved to 처리 완료.
- Next slice: no feature item remains in 처리 대기; IDLE until new feedback (R1 remains the standing module-boundary rule).

## Archived from STATUS.md (2026-09-08 13:36)

## 2026-09-08 — 덱 뷰어 (`game/deck.lua`)

- Created `game/deck.lua`: starter play-card deck + viewer (kinds / counts / editions).
  - `new()`: 5 hongdan / 5 cheongdan / 5 chodan / 5 godori / 20 pi. No gwang, no months.
  - `counts(d)` / `total(d)`: kind tallies. `view(d)`: `{total, by_kind, by_effect}` (none/foil/hologram/polychrome).
  - Viewer rejects gwang (joker slot) and month numbers/names.
- Tests in `game/tests/deck.lua` GREEN (starter kinds, counts, view, editions, rejects).
- `make verify LOVE=/Users/jm/.local/bin/love` GREEN: GOSTRO_UNIT_OK, GOSTRO_SMOKE_OK, LOVE_BUNDLE_OK.
- INBOX (20) deck viewer slice only. Enhance/destroy (thin deck) and sort are not in this slice.
- Next slice: INBOX (20) remaining — tarot enhance + destroy on `game/deck.lua`.

## Archived from STATUS.md (2026-09-08 13:52)

## 2026-09-08 — 모듈 구조 정책 자동화 (loop/module_policy.py)

## Archived from STATUS.md (2026-09-08 13:54)

- Implemented `loop/module_policy.py` to enforce the rule: "INBOX 기능보다 모듈 경로가 없는 항목은 먼저 모듈을 만든다" and `(R1) 상시 모듈화`.
- `parse_pending_items` extracts pending tasks without grabbing indented details.
- `pending_module_issues` validates that every pending task has an explicit `- 담당: <module_path>` assigned.
- Updated `loop/preflight.py` to use `module_policy`. It now outputs `MODULE_SETUP_REQUIRED` instead of a PASS if an item lacks a module assignment.
- Tests in `loop/test_module_policy.py` GREEN.
- INBOX (R1) → 처리 완료 (policy check automated in loop script).
- Next slice: IDLE (No pending tasks).

## Archived from STATUS.md (2026-09-08 14:20)

## 2026-09-08 — Galmuri11 한글 폰트 초기화 (`game/fonts.lua`)

## Archived from STATUS.md (2026-09-08 14:21)

- Added Galmuri11 TTF + OFL under `assets/fonts/`; `fonts.install()` sets the global 11px font before scene creation and `fonts.get` caches positive 11px multiples.
- Added `game/tests/fonts.lua`: mocked cache/install contract plus a real LÖVE graphics check proving width and glyph support for `상점`, `다음 라운드`, and `광`.
- Bundle verification now requires both the font and license.
- `make verify LOVE=/Users/jm/.local/bin/love` GREEN: GOSTRO_UNIT_OK, GOSTRO_FONT_OK, GOSTRO_SMOKE_OK, LOVE_BUNDLE_OK.
- INBOX (24) complete. Next slice: IDLE (no pending feedback items).

## Archived from STATUS.md (2026-09-08 15:04)

## 2026-09-08 — 마우스·터치 입력 배선 복구 (`game/scene_stack.lua`)

- `love.mousepressed` and `love.touchpressed` now route through the scene stack to the current scene's `mousepressed` handler.
- Window-space presses are converted through `viewport.toGame`; presses in letterbox bars are rejected before scene delivery.
- Added `game/tests/input_routing.lua` covering coordinate conversion, mouse/touch metadata delivery, letterbox rejection, and scenes without a handler.
- `make verify LOVE=/Users/jm/.local/bin/love` GREEN: GOSTRO_UNIT_OK, GOSTRO_FONT_OK, GOSTRO_SMOKE_OK, LOVE_BUNDLE_OK.
- INBOX (25) complete. Next slice: IDLE (no pending feedback items).

## Archived from STATUS.md (2026-09-08 16:45)


## 2026-09-08 — play 씬 상태 머신 + 엔진 연동 (game/scenes/play.lua)

## Archived from STATUS.md (2026-09-08 16:47)

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

## Archived from STATUS.md (2026-09-08 17:00)

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

## Archived from STATUS.md (2026-09-08 17:18)

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
