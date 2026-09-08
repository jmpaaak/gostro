# STATUS

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

## 2026-09-08 — Balatro New Run 실기기 관찰 사전 점검

- `docs/BALATRO_NEW_RUN_ANALYSIS.md`에 직접 관찰 증거 규칙과 New Run→상점 체크포인트 표를 추가했다.
- 물리 iPhone Air(iOS 26.6.1), Appium 3.7.0, XCUITest driver 12.10.0 설치 및 연결/잠금 해제 상태를 확인했다.
- Appium 서버는 ready였지만 CoreDevice RSD 할당 실패로 설치 앱 조회와 WDA 시작이 실패했다. Balatro 실행·터치·캡처 및 실기기 QA는 아직 수행하지 못했다.
- `make verify LOVE=/Users/jm/.local/bin/love` GREEN: GOSTRO_UNIT_OK, GOSTRO_FONT_OK, GOSTRO_SMOKE_OK, LOVE_BUNDLE_OK.
- Next slice: CoreDevice RSD 연결을 복구하고 실제 설치 앱 목록에서 Balatro bundle identifier를 확인한 뒤, 앱 시작 화면의 PNG/page-source 증거 묶음을 수집한다 (`docs/BALATRO_NEW_RUN_ANALYSIS.md`).

## 2026-09-08 — Gostro 첫 메뉴/UI 슬라이스

- 직접 관찰된 Balatro 랜딩의 큰 `PLAY`와 PLAY 서브메뉴의 `New Run`(파랑) / `Continue`(빨강) / `Challenges`(주황) 세로 계층만 구현 근거로 사용했다. New Run 이후 덱 화면은 미관찰로 유지했다.
- Gostro는 이제 320×180 네이티브 픽셀 랜딩의 큰 `게임 시작` 버튼으로 시작하고, 탭 즉시 `새 게임` / `계속하기` / `도전` 메뉴로 전환한다.
- `새 게임`은 scene stack을 통해 새 `PlayScene`의 `blind_select`로 전환한다. `계속하기`와 `도전`은 메뉴에 남아 `준비 중` 피드백을 반환하므로 새 런으로 위장하지 않는다.
- `game/ui/main_menu.lua`에 순수 상태/hit-test와 화투 꽃 인장·한글 픽셀 UI를, `game/scenes/menu.lua`에 라우팅만 분리했다. `game/scenes/play.lua`는 변경하지 않았다.
- `game/tests/main_menu_ui.lua`, `game/tests/menu_scene.lua`를 self-test에 등록했다.
- `make verify LOVE=/Users/jm/.local/bin/love` GREEN: `GOSTRO_UNIT_OK`, `GOSTRO_FONT_OK`, `GOSTRO_SMOKE_OK`, `LOVE_BUNDLE_OK`.
- INBOX (26)은 후속 실기기 관찰이 남아 있어 처리 대기로 유지한다.

## 2026-09-08 — Balatro 실기기 연결 복구와 앱 식별

- 사용자 CoreDeviceService를 재시작한 뒤 설치 앱 조회가 정상화됐다.
- 실기기 설치 목록에서 Balatro 1.0.19(50)의 bundle identifier가 `com.playstack.balatropremium`임을 확인했다.
- `devicectl`로 해당 bundle identifier를 실행해 성공 응답을 받았다. 화면 내용은 아직 관찰 사실로 기록하지 않았다.
- WDA 세션은 연결 복구 후 빌드 단계까지 진행했지만 development team 미설정으로 code 65가 발생했다. PNG/page source는 아직 확보하지 못했다.
- Next slice: WDA 서명을 구성하고 앱 시작 화면의 PNG와 page source를 같은 체크포인트 증거 묶음으로 저장한다 (`docs/BALATRO_NEW_RUN_ANALYSIS.md`).

## 2026-09-08 — WDA 서명 빌드 검증

- Appium 3.7.0 + XCUITest driver 12.11.0을 저장소의 무시된 `build/` 경로에 격리 설치했다.
- development team `2JQN8PNHSY`와 `com.jmpaxk.WebDriverAgentRunner` bundle id로 WDA가 `TEST BUILD SUCCEEDED`를 통과했고, 서명된 runner 1.0이 실기기에 설치된 것을 확인했다.
- WDA 실행은 실기기에서 Developer App 인증서가 신뢰되지 않아 CoreDevice 10002로 차단됐다. PNG/page source와 추가 UI 관찰은 아직 없다.
- `make verify LOVE=/Users/jm/.local/bin/love` GREEN: `GOSTRO_UNIT_OK`, `GOSTRO_FONT_OK`, `GOSTRO_SMOKE_OK`, `LOVE_BUNDLE_OK`.
- Next slice: 실기기 설정에서 개발자 인증서를 신뢰한 뒤 WDA 세션을 열고 앱 시작 화면 PNG와 page source를 같은 `00-launch` 증거 묶음으로 저장한다 (`docs/BALATRO_NEW_RUN_ANALYSIS.md`).

## 2026-09-08 — 엔진 모듈 분리 및 테스트 통합 완료

- 이전 사이클에서 작성된 `round_engine.lua`, `run_rules.lua`, `scoring_pipeline.lua`의 독립 실행 테스트를 완료했다.
- 미완성이었던 `game/blind_flow.lua`의 `view`, `select`, `skip` 구현을 보완하여 스몰/빅/보스 순차 제한 및 태그 연동 스킵 로직을 확립했다.
- 새롭게 분리된 모든 엔진 모듈들의 테스트(`blind_flow`, `round_engine`, `run_rules`, `scoring_pipeline`, `shop_engine`)를 `game/self_test.lua`에 통합하고 GREEN을 확인했다.
- `make verify LOVE=/Users/jm/.local/bin/love` GREEN: `GOSTRO_UNIT_OK`, `GOSTRO_FONT_OK`, `GOSTRO_SMOKE_OK`, `LOVE_BUNDLE_OK`.
- Next slice: `play.lua` 및 기존 UI가 여전히 거대 모듈 `run.lua`에 의존하고 있으므로, 이를 새로 작성된 개별 모듈(`blind_flow` 등)로 안전하게 교체하고 `run.lua`를 해체한다.

## 2026-09-08 — 유한 덱 라운드·득점 파이프라인 실게임 연결

- `game/scenes/play.lua`가 New Run 선택을 `run_rules`로 적용하고, 블라인드 진입 시 40장/32장 시작 패의 유한 덱을 `round_engine`으로 생성한다.
- 놓기·버리기는 더 이상 `math.random`으로 카드를 무한 생성하거나 UI가 횟수를 소유하지 않는다. `round_engine`이 패/드로우/버림 더미와 hands/discards를 소유하고 UI는 상태를 반영한다.
- 실제 놓기 경로가 `scoring_pipeline`을 사용해 행성·카드 이펙트·광·보스 효과를 한 번씩 적용하며, 마지막 hand로 목표 미달 시 `lost`로 전환한다.
- 메뉴에서 고른 시작 패가 메타데이터에만 저장되지 않고 실제 덱에 적용된다. `얇은 패` 선택은 32장 덱으로 시작한다.
- `game/tests/play_integration.lua`와 `game/tests/menu_scene.lua`에 결정적 셔플, 카드 보존, 자원 동기화, 패배 전이, 선택 덱 적용 회귀 테스트를 추가했다.
- `make verify LOVE=/Users/jm/.local/bin/love` GREEN: `GOSTRO_UNIT_OK`, `GOSTRO_FONT_OK`, `GOSTRO_SMOKE_OK`, `LOVE_BUNDLE_OK` (bundle 154 files).
- Next slice: `game/scenes/play.lua`의 상점 생성·구매·리롤을 `game/shop_engine.lua`에 위임해 시드 재현성과 voucher/tag 효과를 실제 상점 경로에 연결한다.

## 2026-09-08 — 시드 기반 랜덤 상점 실게임 연결

- 블라인드 클리어 후 `game/scenes/play.lua`가 기존 UI 난수 상점 대신 `game/shop_engine.lua`로 랜덤 제안 3개를 생성한다.
- 실제 리롤은 shop RNG, 증가 비용, 무료 리롤 태그와 바우처 할인을 사용하며 돈을 `run_state`에서 단일 소유한다.
- 랜덤 광·행성·타로 구매는 shop engine에서 원자적으로 결제한 뒤 런에 적용하고, 적용 실패 시 결제와 sold 상태를 롤백한다.
- `game/tests/play_integration.lua`에서 실게임 상점 엔진 상태, 무료 리롤 태그 소비, 광 구매 적용을 회귀 검증했다.
- `make verify LOVE=/Users/jm/.local/bin/love` GREEN: `GOSTRO_UNIT_OK`, `GOSTRO_FONT_OK`, `GOSTRO_SMOKE_OK`, `LOVE_BUNDLE_OK` (bundle 154 files).
- Next slice: `game/ui/shop.lua`가 engine의 추가 랜덤 슬롯·팩·바우처 슬롯을 모두 표시하고 hit-test하도록 순수 UI 계약을 확장한다.

## 2026-09-08 — 엔진 상점 전체 슬롯 UI 연결

- `game/ui/shop.lua`가 legacy `cards`뿐 아니라 `shop_engine`의 통합 `slots`를 순수 `slot_views` 계약으로 변환한다.
- 바우처/태그로 늘어난 랜덤 상품과 팩·바우처 슬롯 전체를 320×180 안에 동적으로 배치하고, 그 동일한 bounds로 draw와 hit-test를 수행한다.
- 엔진 소유 money와 동적 리롤 가격을 표시하며 광·행성·타로·팩·바우처에 구분된 이름/표현을 제공한다.
- `game/tests/shop_ui.lua`가 4개 랜덤 슬롯 + 팩 + 바우처의 6개 위치, 각 hit-test, 팩/바우처 view, 엔진 money 표시를 검증한다.
- `make verify LOVE=/Users/jm/.local/bin/love` GREEN: `GOSTRO_UNIT_OK`, `GOSTRO_FONT_OK`, `GOSTRO_SMOKE_OK`, `LOVE_BUNDLE_OK` (bundle 154 files).
- Next slice: 신규 `game/shop_purchases.lua`가 바우처 슬롯 구매 적용/롤백을 소유하게 하고 `game/scenes/play.lua`는 해당 모듈로 위임한다. 팩 구매는 후속 독립 슬라이스로 유지한다.

## 2026-09-08 — 상점 구매 위임 및 바우처 적용 (`game/shop_purchases.lua`)

- Created `game/shop_purchases.lua` to manage shop transaction application and rollback, supporting planets, tarots, gwang, and newly vouchers.
- `game/scenes/play.lua` delegates `buy_shop_card` entirely to `shop_purchases.buy(scene.shop, idx)`, removing inline purchase logic.
- Pack purchase is mocked to throw an error for now ("pack purchase not implemented in this slice"), rolling back successfully.
- Tests in `game/tests/shop_purchases.lua` verify successful voucher purchase and rollback on failure.
- `make verify LOVE=/Users/jm/.local/bin/love` GREEN.
- Next slice: `play.lua` 및 기존 UI가 여전히 거대 모듈 `run.lua`에 의존하고 있으므로, 이를 새로 작성된 개별 모듈(`blind_flow` 등)로 교체하고 `run.lua`를 해체하는 남은 작업(또는 팩 개봉 기능 추가)을 진행한다.

## 2026-09-08 — 아르카나 팩 개봉 상태 (`game/packs.lua`)

- Created pure `game/packs.lua`: buying an Arcana Pack reveals three tarot choices from the seeded shop RNG and allows one choice or skip; opening does not silently grant a consumable.
- `game/shop_purchases.lua` now applies pack purchases and preserves its transaction rollback when another pack is already open.
- Tests in `game/tests/packs.lua` cover deterministic choices, one pending pack, choose, and skip; `game/tests/shop_purchases.lua` covers successful pack payment and failed-open rollback.
- TDD RED was observed from the prior pack placeholder; `make verify LOVE=/Users/jm/.local/bin/love` is GREEN (`GOSTRO_UNIT_OK`, `GOSTRO_FONT_OK`, `GOSTRO_SMOKE_OK`, `LOVE_BUNDLE_OK`, 158 files).
- Next slice: add an independent `game/ui/pack.lua` choice/skip overlay and route the pending-pack input from the play scene with require/delegation only.
