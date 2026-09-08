# STATUS
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

## 2026-09-08 — 보스 블라인드 디버프 (`game/boss_blinds.lua`)

- Created `game/boss_blinds.lua`: Balatro-style boss blinds mapped onto hwatu play kinds (no months, gwang never a play target).
  - hook: discard 2 random hand cards
  - wall: double boss target
  - flint: floor-halve chips and mult
  - mark: flip hongdan face-down
  - fish: hide entire hand
  - psychic: require a 5-card hand
  - goad: only godori scores chips
  - plant: cheongdan contributes 0 chips
- `game/run.lua`: `select_boss(state, id)` on boss blinds; wall doubles `blind_target`; entering a boss (shop leave / skip big) auto-picks a boss; leaving boss clears it.
- Tests in `game/tests/boss_blinds.lua` (pool ≥8, hwatu kinds, each effect, run select/apply, forbidden words).
- `make verify LOVE=/Users/jm/.local/bin/love` GREEN: GOSTRO_UNIT_OK, GOSTRO_SMOKE_OK, LOVE_BUNDLE_OK.
- INBOX (15) → 처리 완료.
- Next slice: INBOX (16) 바우처 시스템 (`game/vouchers.lua`).

## 2026-09-08 — 바우처 시스템 (`game/vouchers.lua`)

- Created `game/vouchers.lua`: Balatro-style shop vouchers. Pool of 12 (paint_brush hand+1, wasteful discard+1, grabber hands+1, overstock shop slots+1, reroll_surplus discount, clearance_sale shop discount, seed_money interest cap, antimatter gwang slots+1, crystal_ball consumable slots, hone edition rate, directors_cut boss rerolls, money_tree interest rate). Each identity once.
- `game/run.lua`: shop stocks 1 voucher on `clear_blind`; `buy_voucher` one-per-shop; `leave_shop` clears the slot; `max_gwang` includes antimatter extra slots.
- Tests in `game/tests/vouchers.lua` (pool ≥10, apply effects, shop stock/buy, one-per-shop, leave restocks unowned, gwang cap).
- `make verify LOVE=/Users/jm/.local/bin/love` GREEN: GOSTRO_UNIT_OK, GOSTRO_SMOKE_OK, LOVE_BUNDLE_OK.
- INBOX (16) → 처리 완료.
- Next slice: INBOX (17) 행성 카드 (`game/planets.lua`).

> 이전 cycle 이력은 `docs/STATUS_HISTORY.md`에 있다. 특정 과거 버그를 추적할 때만 그 파일을 검색하고, 평소에는 읽지 않는다.

## 2026-09-08 — 행성 카드 (game/planets.lua)

- Created `game/planets.lua`: Balatro-style planet cards for leveling up yaku (hongdan, cheongdan, chodan, godori, pi).
- Leveling up permanently adds base chips and mult to hands playing that yaku.
- `game/hwatu.lua` `evaluate` updated to accept `state` and call `planets.apply_level_bonus(state, yaku, chips, mult)` to accumulate the level-up bonuses (e.g. +15 chips, +1 mult per level).
- `game/ui/shop.lua` generates planets in the shop (30% chance for random_item) alongside gwang.
- `game/ui/planets_ui.lua`: left-side HUD to display the current levels of all yakus during play.
- `game/scenes/play.lua`: integrated `planets_ui.draw`, handles planet purchases from shop without rejecting non-gwang items.
- Tests in `game/tests/planets.lua` verify levels, buying, and chip/mult calculations. `shop_ui` tests updated to permit planets in the shop.
- `make verify LOVE=/Users/jm/.local/bin/love` GREEN: GOSTRO_UNIT_OK, GOSTRO_SMOKE_OK, LOVE_BUNDLE_OK.
- INBOX (17) → 처리 완료.
- Next slice: INBOX (18) 타로 카드 (카드 변환/파괴) (`game/tarots.lua`).

## 2026-09-08 — 타로 카드 변환/파괴 (`game/tarots.lua`)

- Created `game/tarots.lua`: Balatro-style tarot consumables.
  - Pool: `the_magician` (convert play-card kind) + `the_hanged_man` (destroy a card).
  - Consumable slots max 2; `crystal_ball` voucher raises max to 3.
  - `gain(state, id, source)` from shop or boss reward; `use` converts or destroys then consumes the slot.
  - Convert keeps play-card contract: no month numbers/names, no gwang, no mae/ppeok/otti.
- Tests in `game/tests/tarots.lua` GREEN (pool, slots, shop/boss gain, convert, destroy, consume).
- `make verify LOVE=/Users/jm/.local/bin/love` GREEN: GOSTRO_UNIT_OK, GOSTRO_SMOKE_OK, LOVE_BUNDLE_OK.
- Enhance (edition grant) and copy are not in this slice.
- Next slice: INBOX (18) remaining — tarot enhance + copy (`game/tarots.lua`).

## 2026-09-08 — 타로 이펙트 부여 (`game/tarots.lua`)

- `the_chariot` (전차) enhance tarot grants foil/hologram/polychrome via `card_effects.apply`.
- Failed enhance (unknown edition / gwang) errors and does not consume the slot.
- Convert / destroy / slots unchanged. Copy not in this slice.
- Tests in `game/tests/tarots.lua` GREEN (pool includes enhance, grant foil, reject unknown).
- `make verify LOVE=/Users/jm/.local/bin/love` GREEN: GOSTRO_UNIT_OK, GOSTRO_SMOKE_OK, LOVE_BUNDLE_OK.
- Next slice: INBOX (18) remaining — tarot copy (`game/tarots.lua`).

## 2026-09-08 — 타로 카드 복제 (`game/tarots.lua`)

- `the_lovers` (연인) copy tarot appends an independent play-card clone (kind + edition).
- Clone is a new table via `hwatu.card`; no month numbers/names. Failed copy of gwang does not consume the slot.
- Convert / destroy / enhance / slots unchanged. INBOX (18) convert/destroy/enhance/copy complete.
- Tests in `game/tests/tarots.lua` GREEN (pool includes copy, clone, preserve hologram, reject gwang).
- `make verify LOVE=/Users/jm/.local/bin/love` GREEN: GOSTRO_UNIT_OK, GOSTRO_SMOKE_OK, LOVE_BUNDLE_OK.
- Next slice: INBOX (19) 이자 시스템 + 경제 (`game/economy.lua`).

## 2026-09-08 — 이자 계산 (`game/economy.lua`)

- Created `game/economy.lua`: Balatro-style interest $1 per $5 held.
  - Default cap $5. No money cap.
  - `seed_money` voucher raises `vouchers.interest_cap` (default 5 → 10).
  - Negative / nil money yields $0 interest.
- Tests in `game/tests/economy.lua` GREEN (per-$5, default cap, floor, uncapped money, seed_money cap).
- `make verify LOVE=/Users/jm/.local/bin/love` GREEN: GOSTRO_UNIT_OK, GOSTRO_SMOKE_OK, LOVE_BUNDLE_OK.
- Round cash-out (blind reward + leftover-hand bonus) and `run.clear_blind` integration are not in this slice.
- Next slice: INBOX (19) remaining — round payout into `game/run.lua` via `economy`.

## 2026-09-08 — 라운드 정산 (`game/economy.lua` + `game/run.lua`)

- `economy.cash_out(state)` pays interest on held money, then blind reward + leftover-hand $1 each. No money cap.
  - Blind: small $3 / big $5 / boss $8. Interest still $1 per $5, cap via `seed_money`.
- `run.clear_blind` calls `cash_out` before shop/won. `run.new` starts with money $4, hands_left 4. `leave_shop` resets hands (grabber extra).
- Play scene reads engine money after clear (no duplicate blind reward). Shop spend syncs back to `run_state.money`.
- Tests in `game/tests/economy.lua` GREEN (reward, hand bonus, cash-out components, interest-before-payout, clear_blind shop + win).
- `make verify LOVE=/Users/jm/.local/bin/love` GREEN: GOSTRO_UNIT_OK, GOSTRO_SMOKE_OK, LOVE_BUNDLE_OK.
- INBOX (19) complete. Next slice: INBOX (20) 덱 편집 + 카드 강화 (`game/deck.lua`).
