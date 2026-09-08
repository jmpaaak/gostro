# STATUS
- 피·홍단·청단·초단·고도리를 같은 카드 틀과 한지 질감으로 묶은 960×288 SVG/PNG master contact sheet를 만들었다. 피는 지도 핀/영문 약어 대신 매화와 가지, 나머지는 색 띠·난초·제비 날개 상단 문양을 사용한다.
- 실제 Asset Studio `POST /api/pixel-perfect`로 120×36(카드당 24×36) 후보 sheet를 생성했고 dimensions/palette/alpha/nearest 검사 5/5가 통과했다.
- 신규 `card_overlap_qa.py`가 후보 셀을 10px 간격으로 겹친 64×40 캡처와 hash 보고서를 생성한다. 5개 상단 문양 fingerprint가 모두 고유함을 검증했다.
- 5종 manifest는 공유 sheet를 가리키는 `candidate`로 함께 격리했다. 자동 검사는 사람의 아트 승인과 실제 320×180 LÖVE 캡처를 대신하지 않으므로 어느 패도 runtime으로 승격하지 않았다.
- TDD RED: 청단·초단·고도리가 pending이고 5종이 공유 master를 가리키지 않아 실패함을 확인했다. 구현 후 5종 묶음 격리와 기존 runtime loader 계약이 GREEN이다.
- `make verify LOVE=/Users/jm/.local/bin/love` GREEN: `asset_loader: OK`, `card_art: OK`, `GOSTRO_UNIT_OK`, `GOSTRO_FONT_OK`, `GOSTRO_SMOKE_OK`, `LOVE_BUNDLE_OK` (207 files).
- INBOX (27)은 전체 그래픽 전환과 플레이 패 실런타임 승인이 남아 있어 처리 대기로 유지한다.
- Next slice: 후보 sheet를 QA 전용 320×180 LÖVE 화면에 nearest로 그려 실제 겹침 캡처를 만들고, 사람의 식별성·화투 아트 승인 결과를 manifest에 기록한다.

## 2026-09-09 — 한국 테마 용어 계약 신설 및 일부 적용 (판/고)

- `game/terms.lua`를 신설하여 player-facing 용어(기원패, 부적, 판, 고 등) 단일 계약을 마련했다.
- UI 모듈(`blind_select.lua`, `shop.lua`)과 데이터(`gwang_jokers.json`)에서 '스몰/빅/보스 블라인드' 및 '앤티' 하드코딩 문자열을 `terms` 모듈과 한국어('첫판/큰판/대장판', 'n고')로 교체했다.
- TDD RED: `terms` 모듈 부재를 확인했다. 구현 후 `game/tests/terms.lua` 단위 테스트와 UI 텍스트 출력 검증이 GREEN이다.
- `make verify LOVE=/Users/jm/.local/bin/love` GREEN (209 files).
- INBOX (28)은 전체 도메인 적용이 남아 있어 처리 대기로 유지한다.
- Next slice: 나머지 player-facing Balatro 용어(Planet, Tarot, Tag, Voucher 등)를 `terms.lua`를 사용하여 기원패, 부적, 패찰, 인장으로 교체한다.

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

## 2026-09-08 — 기본 run state 조립 모듈화

- 신규 `game/run_state.lua`가 정규화된 seed와 독립 shop/cards/boss RNG 스트림, 블라인드·경제·태그·바우처 기본 상태 조립을 소유한다. 각 호출은 중첩 컬렉션을 공유하지 않는다.
- `game.run.new`는 호환 delegate로 축소됐고 `game.run_rules.create`는 더 이상 `game.run`을 역참조하지 않고 base state를 직접 구성·검증한다.
- TDD RED: 전체 `make test`에서 `game.run_state` 모듈 부재 실패를 확인했다. 구현 후 `run_state: OK`와 전체 엔진 테스트가 GREEN이다.
- `make verify LOVE=/Users/jm/.local/bin/love` GREEN: `GOSTRO_UNIT_OK`, `GOSTRO_FONT_OK`, `GOSTRO_SMOKE_OK`, `LOVE_BUNDLE_OK` (174 files).
- INBOX (26)은 `game.run` facade와 `game.blind_flow` 사이의 남은 역의존 정리가 필요해 처리 중으로 유지한다.
- Next slice: `game/blind_flow.lua`의 사용되지 않는 `game.run` import를 제거하고 flow 테스트 fixture를 `game/run_state.lua`와 직접 계약으로 전환해 순환 의존을 끊는다.

> 이전 cycle 이력은 `docs/STATUS_HISTORY.md`에 있다. 특정 과거 버그를 추적할 때만 그 파일을 검색하고, 평소에는 읽지 않는다.
