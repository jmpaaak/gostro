# STATUS
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

## 2026-09-08 — 아르카나 팩 선택 오버레이 (`game/ui/pack.lua`)

- Added a pure render model and shared hit-test bounds for three revealed tarot choices plus `건너뛰기` in a modal 320×180 overlay.
- The play scene draws the overlay above the shop and routes choice/skip through `game/packs.lua`; while open, it consumes all pointer input so reroll, purchases, next-round, and seed controls cannot fire underneath it.
- TDD RED was observed for the missing module. `game/tests/pack_ui.lua` verifies layout/hit-test, selected tarot grant, skip, and modal shop blocking.
- `make verify LOVE=/Users/jm/.local/bin/love` GREEN: `GOSTRO_UNIT_OK`, `GOSTRO_FONT_OK`, `GOSTRO_SMOKE_OK`, `LOVE_BUNDLE_OK` (160 files).
- INBOX (26)은 후속 순차 구현이 남아 있어 처리 중으로 유지한다.
- Next slice: consumable slots are already engine-owned but not playable; add an independent `game/ui/consumables.lua` inventory/selection contract before routing tarot targets in the play scene.

## 2026-09-08 — 타로 소모품 인벤토리 선택 계약 (`game/ui/consumables.lua`)

- Added a headless-safe render model for occupied and empty tarot slots, including Crystal Ball capacity, localized effect labels, and shared 320×180 bounds.
- Occupied slots can be selected and toggled off through pure hit-test/selection APIs; empty slots and out-of-bounds presses are inert. Tarot execution remains owned by `game/tarots.lua`.
- TDD RED was observed for the missing module. `make verify LOVE=/Users/jm/.local/bin/love` is GREEN with `consumables_ui: OK`, `GOSTRO_UNIT_OK`, `GOSTRO_FONT_OK`, `GOSTRO_SMOKE_OK`, and `LOVE_BUNDLE_OK` (162 files).
- Removed two duplicate suite invocations from `game/self_test.lua` while registering the focused `game/tests/consumables_ui.lua`, so the entrypoint did not grow.
- INBOX (26)은 후속 순차 구현이 남아 있어 처리 중으로 유지한다.
- Next slice: add require/delegation-only play-scene wiring to draw the consumable inventory and select a held tarot, then introduce a separate target/options flow before calling `game/tarots.lua`.

## 2026-09-08 — 타로 소모품 인벤토리 씬 배선

- `game/scenes/play.lua`가 `game/ui/consumables.lua`에 그리기와 입력을 위임해 보유 타로 슬롯을 모든 런 화면에 표시하고, 점유 슬롯 터치로 선택/선택 해제를 수행한다.
- 열린 아르카나 팩은 계속 최우선 모달 입력을 가지며, 시드 재적용 시 오래된 소모품 선택도 초기화한다.
- `game/ui/consumables.lua`의 `route_press`가 공유 hit bounds와 선택 규칙을 캡슐화해 play 씬은 require/위임만 유지한다. `play.lua`는 339줄로 줄었다.
- 엔진 호스트 테스트에서 씬 배선 부재 RED를 관찰한 뒤 `game/tests/consumables_ui.lua`의 실제 play-scene 점유 슬롯 선택/토글 회귀 테스트를 GREEN으로 전환했다.
- `make verify LOVE=/Users/jm/.local/bin/love` GREEN: `consumables_ui: OK`, `GOSTRO_UNIT_OK`, `GOSTRO_FONT_OK`, `GOSTRO_SMOKE_OK`, `LOVE_BUNDLE_OK` (162 files).
- INBOX (26)은 후속 순차 구현이 남아 있어 처리 중으로 유지한다.
- Next slice: 선택된 타로의 변환/파괴/효과 부여/복제별 옵션과 대상 패를 고르는 독립 `game/ui/tarot_target.lua` 순수 상태/hit-test 흐름을 추가하되 아직 `play.lua`에서 실행하지 않는다.

## 2026-09-08 — 타로 옵션/대상 선택 UI

- `game/ui/tarot_target.lua`에 독립 모달 상태, 공유 draw/hit-test bounds, 취소/토글 동작, 완료된 사용 요청 데이터 계약을 추가했다. 변환은 5종 패, 효과 부여는 포일/홀로그램/폴리크롬 옵션을 먼저 요구하고, 파괴/복제는 바로 단일 대상 선택으로 진행한다.
- 이 모듈은 `tarots.use`를 호출하거나 대상 패를 변경하지 않는다. `game/tests/tarot_target_ui.lua`와 self-test 등록으로 옵션 게이팅, 네 효과, 요청 인자, 토글/취소, 패 불변성을 검증한다.
- TDD RED: 전체 `make test`에서 `game.ui.tarot_target` 모듈 부재 실패를 확인했다. 구현 후 `make verify LOVE=/Users/jm/.local/bin/love`는 `tarot_target_ui: OK`, `GOSTRO_UNIT_OK`, `GOSTRO_FONT_OK`, `GOSTRO_SMOKE_OK`, `LOVE_BUNDLE_OK` (164 files)로 GREEN이다.
- INBOX (26)은 실제 사용 배선이 남아 있어 처리 중으로 유지한다.
- Next slice: 타로 대상 선택기를 play scene에 모달로 배선하고 완료된 요청을 `tarots.use`로 실행한 뒤 변경된 패를 hand UI에 재동기화하고 소모품/대상 선택을 해제한다. 효과 규칙은 scene glue에 추가하지 않는다.

## 2026-09-08 — 타로 대상 선택·사용 실게임 연결

- `game/tarot_use.lua` 컨트롤러가 보유 타로 선택부터 옵션/대상 모달, `tarots.use` 실행, 성공/취소 정리까지 소유한다. 변환·파괴·강화·복제 규칙은 계속 `game/tarots.lua`에만 있다.
- 플레이 중 점유 소모품 슬롯을 누르면 대상 모달이 열리고, 열린 동안 포인터 및 플레이/버리기 단축키가 하위 UI로 전달되지 않는다.
- 완료된 요청은 엔진의 `round.hand`에 적용되고 hand UI를 다시 deal해 변형/삭제/복제 결과와 선택 초기화를 즉시 반영한다. 성공 시 타로가 소비되며 취소 시 보존된다.
- `game/tests/tarot_use_flow.lua`에서 실제 씬의 옵션 게이팅, 모달 입력 차단, 변환 실행, 인벤토리 소비, hand UI 동기화, 취소 보존을 검증한다. 배선 전 RED를 관찰했고 구현 후 전체 테스트를 GREEN으로 전환했다.
- INBOX (26)은 후속 순차 구현이 남아 있어 처리 중으로 유지한다.
- Next slice: 현재 `game/run.lua`가 계속 소유한 블라인드 전환을 `blind_flow`/`run_rules`로 치환해 play scene의 거대 run 의존성을 한 단계 줄인다.

## 2026-09-08 — 블라인드 시작 전환 모듈화

- `game/blind_flow.lua`의 `begin`이 현재 블라인드 검증, 라운드 점수 초기화, stake 보정 목표와 버리기 횟수 산출을 하나의 전환 계약으로 소유한다. `view`도 동일한 stake 보정 목표를 노출한다.
- `game/scenes/play.lua`는 보스 선택·점수 초기화·목표/버리기 규칙을 직접 조합하지 않고 `blind_flow.begin` 결과로 라운드를 생성한다.
- TDD RED: red stake의 선택 전 목표가 300으로 남는 실패를 확인했다. 구현 후 `game/tests/blind_flow.lua`와 전체 테스트가 GREEN이다.
- `make verify LOVE=/Users/jm/.local/bin/love` GREEN: `blind_flow: OK`, `GOSTRO_UNIT_OK`, `GOSTRO_FONT_OK`, `GOSTRO_SMOKE_OK`, `LOVE_BUNDLE_OK` (166 files).
- INBOX (26)은 후속 순차 구현이 남아 있어 처리 중으로 유지한다.
- Next slice: 블라인드 클리어와 상점 퇴장 후 다음 블라인드 진행을 `blind_flow` 계약으로 감싸 `play.lua`의 직접 `run.clear_blind`/`run.leave_shop` 호출을 제거한다.

## 2026-09-08 — 블라인드 클리어·상점 퇴장 전환 모듈화

- `game/blind_flow.lua`의 `clear`가 stake 보정 목표 충족 여부, 남은 hand 이관, 클리어 후 shop/won phase를 소유하고, `leave_shop`이 다음 ante/blind 선택 상태를 반환한다.
- `game/scenes/play.lua`의 직접 `run.clear_blind`/`run.leave_shop` 호출을 제거하고 두 전환을 `blind_flow`에 위임했다.
- TDD RED: `blind_flow.clear` 미구현 실패를 확인했다. 구현 후 stake 보정 목표 미달 유지, shop 진입, 남은 hand 이관, 다음 big blind 진행 계약이 GREEN이다.
- `make verify LOVE=/Users/jm/.local/bin/love` GREEN: `blind_flow: OK`, `GOSTRO_UNIT_OK`, `GOSTRO_FONT_OK`, `GOSTRO_SMOKE_OK`, `LOVE_BUNDLE_OK` (166 files).
- INBOX (26)은 후속 순차 구현이 남아 있어 처리 중으로 유지한다.
- Next slice: hand 소진 패배 전환을 `blind_flow` 계약으로 감싸 `play.lua`의 직접 `run.lose` 호출을 제거한다.

## 2026-09-08 — hand 소진 패배 전환 모듈화

- `game/blind_flow.lua`의 `lose`가 play phase, hand 완전 소진, 목표 미달을 검증하고 최종 hand 수 이관과 패배 기록 전환을 소유한다.
- `game/scenes/play.lua`의 직접 `run.lose` 호출을 제거하고 round engine의 `lose` 결과를 `blind_flow.lose`에 위임했다.
- TDD RED: `blind_flow.lose` 미구현 실패를 확인했다. 구현 후 남은 hand가 있거나 이미 목표를 달성한 런의 잘못된 패배를 거부하고, 기존 실게임 패배 경로도 GREEN이다.
- `make verify LOVE=/Users/jm/.local/bin/love` GREEN: `blind_flow: OK`, `play_integration: OK`, `GOSTRO_UNIT_OK`, `GOSTRO_FONT_OK`, `GOSTRO_SMOKE_OK`, `LOVE_BUNDLE_OK` (166 files).
- INBOX (26)은 후속 순차 구현이 남아 있어 처리 중으로 유지한다.
- Next slice: 한 hand 득점과 남은 hand 이관을 `blind_flow` 계약으로 감싸 `play.lua`의 직접 `run.add_score` 호출과 `run_state.hands_left` 대입을 제거한다.

> 이전 cycle 이력은 `docs/STATUS_HISTORY.md`에 있다. 특정 과거 버그를 추적할 때만 그 파일을 검색하고, 평소에는 읽지 않는다.
