# STATUS
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

## 2026-09-08 — 보스 선택·블라인드 진입 상태 전환 분리

- `game/blind_flow.lua`가 보스 카탈로그 선택, 가변 run state로의 정의 복사, boss 진입 시 선택, non-boss 진입 시 오래된 보스 정리를 직접 소유한다.
- `game.run.select_boss`와 내부 블라인드 진입 함수는 기존 호출자를 보존하는 호환 delegate로 축소되어 `game.run`은 더 이상 `game.boss_blinds`를 직접 의존하지 않는다.
- TDD RED: `blind_flow.select_boss` 부재 실패를 확인했다. 구현 후 명시적 보스 선택·복사, 진입/정리, 잘못된 blind 비변이 거부와 기존 `run` 호환 경로가 GREEN이다.
- `make verify LOVE=/Users/jm/.local/bin/love` GREEN: `blind_flow: OK`, `boss_blinds: OK`, `GOSTRO_UNIT_OK`, `GOSTRO_FONT_OK`, `GOSTRO_SMOKE_OK`, `LOVE_BUNDLE_OK` (168 files).
- INBOX (26)은 `game/run.lua`의 남은 진행 책임 분리가 필요해 처리 중으로 유지한다.
- Next slice: small/big 블라인드 건너뛰기의 검증·태그 적용·다음 블라인드 진입을 `blind_flow`로 옮기고 `game.run.skip_blind`를 호환 delegate로 축소한다.

## 2026-09-08 — 블라인드 건너뛰기 전환 분리

- `game/blind_flow.skip`이 play phase·현재 small/big blind·명시적 태그를 전부 검증한 뒤 태그 적용, 다음 big/boss 진입, 라운드 점수 초기화를 하나의 전환으로 소유한다.
- `game.run.skip_blind`는 태그를 생략하던 기존 호출까지 보존하는 `blind_flow.skip_current` 호환 delegate로 축소되어 `game.run`의 직접 `game.tags` 의존성이 제거됐다.
- TDD RED: `blind_flow.skip`이 monkey-patched legacy `run.skip_blind`를 호출해 실패하는 것을 확인했다. 구현 후 독립 전환, boss 선택, 잘못된 phase/future blind 비변이 거부와 기존 `run.skip_blind` 경로가 GREEN이다.
- INBOX (26)은 `game/run.lua`의 남은 진행 책임 분리가 필요해 처리 중으로 유지한다.
- Next slice: 블라인드 클리어의 목표 검증 이후 cash-out·승리 기록·상점 준비를 `blind_flow`로 옮기고 `game.run.clear_blind`를 호환 delegate로 축소한다.

## 2026-09-08 — 블라인드 클리어 결과 전환 분리

- `game/blind_flow.clear`가 보정 목표 검증 뒤 남은 손·블라인드 보상·이자를 정산하고, 일반 클리어는 상점 phase와 voucher stock을 준비하며 ante 8 boss 클리어는 승리 기록을 남긴다.
- 최종 ante 정의는 `game/blind_targets.lua`가 목표표와 함께 소유한다. `game.run.clear_blind`와 `game.run.FINAL_ANTE`는 기존 호출자를 위한 호환 delegate/alias로 축소됐다.
- TDD RED: monkey-patched legacy `run.clear_blind` 호출 실패를 확인했다. 구현 후 일반 상점 전환·정산·voucher stock과 최종 승리 기록 회귀 테스트가 GREEN이다.
- `make verify LOVE=/Users/jm/.local/bin/love` GREEN: `blind_flow: OK`, `blind_targets: OK`, `GOSTRO_UNIT_OK`, `GOSTRO_FONT_OK`, `GOSTRO_SMOKE_OK`, `LOVE_BUNDLE_OK` (168 files).
- INBOX (26)은 `game/run.lua`의 남은 진행 책임 분리가 필요해 처리 중으로 유지한다.
- Next slice: 상점 이탈 시 small→big→boss→다음 ante small 진행과 새 라운드 초기화를 `blind_flow.leave_shop`으로 옮기고 `game.run.leave_shop`을 호환 delegate로 축소한다.

## 2026-09-08 — 상점 이탈·다음 블라인드 전환 분리

- `game/blind_flow.leave_shop`이 shop phase 검증, small→big→boss→다음 ante small 진행, 보스 선택/정리, 점수·손 초기화와 임시 바우처 진열 정리를 직접 소유한다.
- `game.run.leave_shop`은 기존 호출자를 보존하는 호환 delegate로 축소됐다.
- TDD RED: monkey-patched legacy `run.leave_shop` 호출 실패를 확인했다. 구현 후 세 블라인드 진행, 영구 추가 손 적용, 바우처 진열 정리와 보스 상태 회귀 테스트가 GREEN이다.
- `make verify LOVE=/Users/jm/.local/bin/love` GREEN: `blind_flow: OK`, `GOSTRO_UNIT_OK`, `GOSTRO_FONT_OK`, `GOSTRO_SMOKE_OK`, `LOVE_BUNDLE_OK`.
- INBOX (26)은 `game/run.lua`의 남은 진행 책임 분리가 필요해 처리 중으로 유지한다.
- Next slice: 손 소진 패배 검증 이후 phase 변경과 패배 기록을 `blind_flow.lose`가 직접 소유하게 하고 `game.run.lose`를 호환 delegate로 축소한다.

## 2026-09-08 — 손 소진 패배 전환 분리

- `game/blind_flow.lose`가 play phase·손 소진·미달 점수를 검증한 뒤 exhausted hand state와 lost phase를 설정하고 패배 런 히스토리를 직접 기록한다.
- `game.run.lose`는 기존 호출자를 보존하는 호환 delegate로 축소되어 `game.run`의 직접 `game.run_history` 의존성이 제거됐다.
- TDD RED: monkey-patched legacy `run.lose` 호출 실패를 확인했다. 구현 후 독립 패배 전환·히스토리 기록, 남은 손/클리어 점수 비변이 거부와 기존 `run.lose` 경로가 GREEN이다.
- INBOX (26)은 `game/run.lua`의 남은 진행 책임 분리가 필요해 처리 중으로 유지한다.
- Next slice: 라운드 엔진 결과의 점수·남은 손 반영을 `blind_flow.score`가 직접 소유하게 하고 `game.run.add_score`를 호환 delegate로 축소한다.

## 2026-09-08 — hand 득점 상태 전환 소유권 분리

- `game/blind_flow.score`가 play phase 검증, 점수 누적, round engine의 남은 hand 이관을 직접 소유하고 `game.run.add_score`는 기존 호출자를 위한 호환 delegate로 축소됐다.
- TDD RED: monkey-patched legacy `run.add_score` 호출 실패를 확인했다. 구현 후 독립 점수 전환, 비-play phase 비변이 거부와 기존 `run.add_score` 호환 경로가 GREEN이다.
- `make verify LOVE=/Users/jm/.local/bin/love` GREEN: `blind_flow: OK`, `GOSTRO_UNIT_OK`, `GOSTRO_FONT_OK`, `GOSTRO_SMOKE_OK`, `LOVE_BUNDLE_OK` (168 files).
- INBOX (26)은 `game/run.lua`의 남은 책임 분리가 필요해 처리 중으로 유지한다.
- Next slice: play-card 종류와 cards RNG 기반 배분을 독립 `game/card_deal.lua`로 옮기고 `game.run.deal_kinds`는 호환 delegate로 축소한다.

## 2026-09-08 — 카드 종류·배분 규칙 모듈화

- `game/card_deal.lua`가 월 숫자·이름 없는 5종 play-card 목록과 run의 전용 cards RNG를 이용한 배분을 독립적으로 소유한다.
- `game.run.deal_kinds`는 기존 호출자를 보존하는 호환 delegate로 축소됐다. 기본 8장, RNG 호출 범위·횟수와 delegate 경계를 `game/tests/card_deal.lua`에서 검증한다.
- TDD RED: 전체 `make test`에서 `game.card_deal` 모듈 부재 실패를 확인했다. 구현 후 `make verify LOVE=/Users/jm/.local/bin/love`는 `card_deal: OK`, `GOSTRO_UNIT_OK`, `GOSTRO_FONT_OK`, `GOSTRO_SMOKE_OK`, `LOVE_BUNDLE_OK` (170 files)로 GREEN이다.
- INBOX (26)은 `game/run.lua`의 남은 책임 분리가 필요해 처리 중으로 유지한다.
- Next slice: 광 슬롯 한도와 구매 검증·삽입을 독립 `game/gwang_inventory.lua`로 옮기고 `game.run.max_gwang`/`buy_gwang`은 호환 delegate로 축소한다.

## 2026-09-08 — 광 슬롯 인벤토리 규칙 모듈화

- 신규 `game/gwang_inventory.lua`가 기본 광 슬롯 5개와 바우처 추가 슬롯 계산, 상점 phase·광 identity·play-card 배제·수용량 검증 및 정규화된 슬롯 삽입을 독립적으로 소유한다.
- `game.run.MAX_GWANG`은 호환 상수로 유지하고 `max_gwang`/`buy_gwang`은 새 모듈로 위임한다. 잘못된 구매와 수용량 초과는 인벤토리를 변경하지 않는다.
- TDD RED: 전체 `make test`에서 `game.gwang_inventory` 모듈 부재 실패를 확인했다. 구현 후 `make verify LOVE=/Users/jm/.local/bin/love`는 `gwang_inventory: OK`, `GOSTRO_UNIT_OK`, `GOSTRO_FONT_OK`, `GOSTRO_SMOKE_OK`, `LOVE_BUNDLE_OK` (172 files)로 GREEN이다.
- INBOX (26)은 `game/run.lua`의 남은 책임 분리가 필요해 처리 중으로 유지한다.
- Next slice: 상점 바우처 구매의 phase·진열 일치·방문당 1회 검증과 적용을 `game.vouchers` 계약으로 옮기고 `game.run.buy_voucher`를 호환 delegate로 축소한다.

## 2026-09-08 — 상점 바우처 구매 규칙 분리

- `game.vouchers.buy`가 shop phase, 현재 진열 id 일치, 방문당 1회 구매를 검증한 뒤 바우처 적용과 구매 완료 표시를 하나의 계약으로 소유한다. 거부된 잘못된 진열 구매는 보유 목록을 변경하지 않는다.
- `game.run.buy_voucher`는 기존 호출자를 보존하는 호환 delegate로 축소됐다.
- TDD RED: 전체 `make test`에서 `game.vouchers.buy` 부재 실패를 확인했다. 구현 후 독립 구매 계약과 monkey-patched delegate 경계 회귀 테스트가 GREEN이다.
- INBOX (26)은 `game/run.lua`의 남은 책임 분리가 필요해 처리 중으로 유지한다.
- Next slice: seed RNG와 기본 run state 조립을 독립 `game/run_state.lua`로 옮기고 `game.run.new`를 호환 delegate로 축소해 `game.run_rules.create`의 거대 run 역의존을 제거한다.

> 이전 cycle 이력은 `docs/STATUS_HISTORY.md`에 있다. 특정 과거 버그를 추적할 때만 그 파일을 검색하고, 평소에는 읽지 않는다.
