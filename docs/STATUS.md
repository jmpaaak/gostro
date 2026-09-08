# STATUS

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

## 2026-09-08 — hand 득점·잔여 hand 이관 모듈화

- `game/blind_flow.lua`의 `score`가 한 hand의 점수 누적과 round engine 잔여 hand 이관을 하나의 전환 계약으로 소유한다.
- `game/scenes/play.lua`의 직접 `run.add_score` 호출과 `run_state.hands_left` 대입을 제거하고 `blind_flow.score`에 위임했다.
- TDD RED: `blind_flow.score` 미구현 실패를 확인했다. 구현 후 `game/tests/blind_flow.lua`와 전체 엔진 테스트가 GREEN이다.
- INBOX (26)은 후속 순차 구현이 남아 있어 처리 중으로 유지한다.
- Next slice: 설정된 run 생성을 독립 계약으로 감싸 `game/scenes/play.lua`의 마지막 직접 `game.run` 의존성(`run.new`)을 제거한다.

## 2026-09-08 — 설정 런 생성·블라인드 목표 투영 경계

- `game/run_rules.lua`의 `create`가 New Run 선택을 먼저 검증한 뒤 seed RNG, 시작 덱·자금, stake 규칙과 진행 가능 여부가 모두 적용된 런만 반환한다. 잘못된 선택은 부분 런을 노출하지 않는다.
- `game/scenes/play.lua`는 마지막 직접 `game.run` 의존성을 제거하고 모든 신규/시드 재시작 런 생성을 `run_rules.create`에 위임한다.
- `game/ui/blind_select.lua`는 더 이상 임시 기본 런을 생성해 목표를 재계산하지 않고 `blind_flow.view`의 gameplay projection만 렌더링한다. 따라서 red stake 선택 화면도 실제 라운드와 같은 보정 목표 375를 표시한다.
- TDD RED: `run_rules.create` 부재와 red stake UI 목표 300 불일치를 각각 확인했다. 구현 후 생성 결정성·실패 계약, 순수 UI 투영, 실제 scene 목표 일치 회귀 테스트가 GREEN이다.
- `make verify LOVE=/Users/jm/.local/bin/love` GREEN: `run_rules: OK`, `blind_select_ui: OK`, `play_integration: OK`, `GOSTRO_UNIT_OK`, `GOSTRO_FONT_OK`, `GOSTRO_SMOKE_OK`, `LOVE_BUNDLE_OK` (166 files).
- INBOX (26)은 `game/run.lua`의 남은 진행 책임 분리가 필요해 처리 중으로 유지한다.
- Next slice: `game/round_engine.lua`가 fallback 목표 계산을 위해 직접 호출하는 `game.run.blind_target`을 gameplay projection 계약으로 옮겨 라운드 생성 경계를 더 작게 만든다.

## 2026-09-08 — 라운드 기본 목표 gameplay projection 통합

- `game/blind_flow.lua`가 비변이 `target(state, kind)` gameplay projection을 공개하고 블라인드 선택 UI, 시작, 클리어, 패배 검증이 같은 stake·보스 보정 목표를 공유한다.
- `game/round_engine.lua`의 명시적 target 없는 생성 경로가 `game.run.blind_target`을 직접 호출하지 않고 이 projection에 위임한다. 따라서 red stake 라운드 기본 목표도 선택 화면과 같은 375이며, scene의 명시적 target 전달 여부에 따라 규칙이 달라지지 않는다.
- TDD RED: red stake round fallback이 300을 반환하는 실패를 확인했다. 구현 후 `game/tests/round_engine.lua` 회귀 테스트와 전체 `make test`가 GREEN이다.
- INBOX (26)은 `game/run.lua`의 남은 진행 책임 분리가 필요해 처리 중으로 유지한다.
- Next slice: base ante/blind 및 보스 목표 계산의 소유권을 독립 모듈로 옮기고 `game.run.blind_target`은 호환 delegate로 축소해 gameplay projection이 거대 run 모듈을 경유하지 않게 한다.

## 2026-09-08 — 블라인드 기본·보스 목표 규칙 분리

- 신규 `game/blind_targets.lua`가 8개 ante 기본값, small/big/boss 배수, Wall 보스의 목표 2배 적용을 독립적으로 소유한다.
- `game.run.blind_target`은 기존 호출자를 보존하는 호환 delegate로 축소했고, `blind_flow.target` gameplay projection은 거대 `game.run`을 경유하지 않고 새 목표 모듈을 직접 사용한다.
- TDD RED: `game.blind_targets` 모듈 부재 실패를 확인했다. 구현 후 기본 목표표·잘못된 입력·보스 적용 범위·호환 delegate 회귀 테스트가 GREEN이다.
- `make verify LOVE=/Users/jm/.local/bin/love` GREEN: `blind_targets: OK`, `blind_flow: OK`, `round_engine: OK`, `GOSTRO_UNIT_OK`, `GOSTRO_FONT_OK`, `GOSTRO_SMOKE_OK`, `LOVE_BUNDLE_OK` (168 files).
- INBOX (26)은 `game/run.lua`의 남은 진행 책임 분리가 필요해 처리 중으로 유지한다.
- Next slice: 보스 선택/복사와 블라인드 진입 상태 전환을 `blind_flow` 계약으로 옮기고 `game.run.select_boss`는 호환 delegate로 축소한다.

> 이전 cycle 이력은 `docs/STATUS_HISTORY.md`에 있다. 특정 과거 버그를 추적할 때만 그 파일을 검색하고, 평소에는 읽지 않는다.
