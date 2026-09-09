# STATUS
## 2026-09-09 — 상점/팩 우드 패널 고해상도 픽셀 에셋 적용

- `ui.panel_wood`에 640×368 옻칠 목재 및 황동 모서리 장식의 9-slice 패널 SVG/PNG master와 80×46 runtime 에셋을 추가했다.
- Asset Studio 실제 `POST /api/pixel-perfect` 변환 보고서의 dimensions/alignment/palette/transparentAlpha/nearestNeighbor 검사를 통과하고 manifest-backed draw 모듈(`game/ui/panel_art.lua`)을 추가했다.
- 기존 부스터 팩 선택 모달(`game/ui/pack.lua`)의 하드코딩된 도형 렌더링을 신규 `panel_art`로 교체했다.
- `make verify`의 pack-panel-qa 독립 화면 캡처 및 전체 테스트를 통과했다.
- INBOX (27)은 나머지 그래픽 요소가 미완료이므로 처리 대기로 유지한다.
- Next slice: `ui.panel_metal`, `ui.panel_glass` 고해상도 master를 실제 Pixel Perfect runtime으로 변환하고 manifest-backed 9-slice 패널 모듈에 통합한다.


## 2026-09-09 — 기본 UI 버튼 고해상도 픽셀 에셋 적용 및 draw 모듈 분리

- `ui.btn_primary`, `ui.btn_secondary`, `ui.btn_danger`, `ui.btn_disabled` 4종 버튼의 400×120 고해상도 PNG master를 생성하고 100×30 runtime 에셋으로 변환(Pixel Perfect 검사 통과)하여 manifest에 추가했다.
- 런타임 배선 시 기존 모듈(`action_buttons.lua`)을 비대화하지 않도록, 9-slice 렌더링을 제공하는 `game/ui/button_art.lua` 모듈을 신규 분리했다.
- 플레이/버리기 버튼의 하드코딩된 도형 렌더링을 신설된 `button_art`로 교체하고 관련 테스트를 추가하여 `make verify`를 통과했다.
- INBOX (27)은 나머지 그래픽 요소가 미완료이므로 처리 대기로 유지한다.
- Next slice: 상점 패널(`ui.panel_wood` 등)이나 팩 등 미완료 UI 요소의 고해상도 master를 생성하고 manifest-backed 모듈로 교체한다.

## 2026-09-09 — 카드 선택 효과 고해상도 픽셀 에셋 적용

- `ui.effect_select`에 208×304 크기의 카드 윤곽선 글로우 효과 SVG/PNG master와 26×38 runtime 에셋을 추가했다.
- Asset Studio 실제 `POST /api/pixel-perfect` 변환 보고서의 dimensions/alignment/palette/transparentAlpha/nearestNeighbor 검사를 모두 통과하고 manifest-backed `effect_art.draw_select` 모듈을 신설했다.
- `game/ui/hand.lua`에 새 effect_art 배선을 연결하여 선택된 카드 위에 글로우를 그리도록 했다.
- INBOX (27)은 나머지 그래픽 요소가 미완료이므로 처리 대기로 유지한다.
- Next slice: `ui.effect_score` 고해상도 master를 실제 Pixel Perfect runtime으로 변환하고 manifest-backed로 적용한다.

## 2026-09-09 — 남은 손 아이콘 고해상도 픽셀 에셋 적용

- `ui.icon_hand`에 세 장의 기하학 화투패를 부채꼴로 쥔 384×384 SVG/PNG master와 12×12 runtime 에셋을 추가했다.
- Asset Studio 실제 `POST /api/pixel-perfect` 변환 보고서의 dimensions/alignment/palette/transparentAlpha/nearestNeighbor 검사를 모두 통과하고 manifest-backed `score_icon_art.draw_hand` 계약을 추가했다.
- 실제 플레이/버리기 버튼에 남은 손/버리기 아이콘을 배선했고 LÖVE 320×180 캡처에서 버튼 배치를 검증했다.
- INBOX (27)은 나머지 그래픽 요소가 미완료이므로 처리 대기로 유지한다.

## 2026-09-09 — 버리기 아이콘 고해상도 픽셀 에셋 적용

- `ui.icon_discard`에 화투패가 대나무 버림패 함으로 떨어지는 384×384 SVG/PNG master와 12×12 runtime 에셋을 추가했다.
- Asset Studio 실제 `POST /api/pixel-perfect` 변환 보고서의 dimensions/alignment/palette/transparentAlpha/nearestNeighbor 검사를 모두 통과하고 manifest-backed draw 모듈(`score_icon_art.draw_discard`)을 추가했다.
- engine-hosted draw 계약과 실제 LÖVE 320×180 HUD 캡처 QA가 버리기 아이콘을 검증한다.
- INBOX (27)은 나머지 그래픽 요소가 미완료이므로 처리 대기로 유지한다.
- Next slice: `ui.icon_hand` 고해상도 master를 실제 Pixel Perfect runtime으로 변환하고 manifest-backed로 적용한다.

## 2026-09-09 — 덱 아이콘 고해상도 픽셀 에셋 적용

- `ui.icon_deck`에 기하학적 화투 뒷면 덱이 쌓여있는 형태의 384×384 SVG/PNG master와 12×12 runtime 에셋을 추가했다.
- Asset Studio 실제 `POST /api/pixel-perfect` 변환 보고서의 dimensions/alignment/palette/transparentAlpha/nearestNeighbor 검사를 모두 통과하고 manifest-backed draw 모듈(`score_icon_art.draw_deck`)을 추가했다.
- `make verify`의 score-icon-qa 화면에 덱 아이콘을 함께 렌더링하도록 QA 스크립트를 갱신했다.
- INBOX (27)은 나머지 그래픽 요소가 미완료이므로 처리 대기로 유지한다.
- Next slice: `ui.icon_discard` 고해상도 master를 실제 Pixel Perfect runtime으로 변환하고 manifest-backed로 적용한다.

## 2026-09-09 — 상점 재화 아이콘 고해상도 픽셀 에셋 적용

- `ui.icon_money`에 비취 메달 위 세 개의 사각 구멍 황동 엽전을 표현한 384×384 SVG/PNG master와 12×12 runtime 에셋을 추가했다.
- Asset Studio 실제 `POST /api/pixel-perfect` 변환 보고서의 dimensions/alignment/palette/transparentAlpha/nearestNeighbor 검사를 모두 통과하고 manifest-backed draw 경로로 상점 보유 재화 표시 옆에 적용했다.
- engine-hosted draw 계약과 실제 LÖVE 320×180 HUD 캡처 QA가 재화 아이콘을 검증하도록 갱신했다.
- INBOX (27)은 나머지 그래픽 요소가 미완료이므로 처리 대기로 유지한다.

## 2026-09-09 — 점수판 배수 아이콘 고해상도 픽셀 에셋 적용

- `ui.icon_mult`에 384×384 붉은 화염 형상의 중심에 황금 윤곽이 있는 십자 모양의 SVG/PNG master와 12×12 runtime 에셋을 추가했다.
- Asset Studio 실제 `POST /api/pixel-perfect` 변환 보고서의 dimensions/alignment/palette/transparentAlpha/nearestNeighbor 검사를 모두 통과하고 manifest-backed 전용 draw 모듈로 점수판 배수 값 옆에 적용했다.
- 독립 engine-hosted draw 계약 테스트와 실제 LÖVE 320×180 점수판 캡처 QA를 추가하고 `Makefile`을 갱신했다.
- INBOX (27)은 나머지 그래픽 요소가 미완료이므로 처리 대기로 유지한다.
- Next slice: `ui.icon_money` 고해상도 master를 실제 Pixel Perfect runtime으로 변환하고 manifest-backed로 적용한다.
## 2026-09-09 — 점수판 칩 아이콘 고해상도 픽셀 에셋 적용

- `ui.icon_chip`에 384×384 청색 자개 칩·팔방 황동 상감·네모 구멍 엽전 중심의 SVG/PNG master와 12×12 runtime 에셋을 추가했다.
- Asset Studio 실제 `POST /api/pixel-perfect` 변환 보고서의 dimensions/alignment/palette/transparentAlpha/nearestNeighbor 검사를 모두 통과하고 manifest-backed 전용 draw 모듈로 점수판에 적용했다.
- 독립 engine-hosted draw 계약 테스트와 실제 LÖVE 320×180 점수판 캡처 QA를 추가했다.
- `gwang.compound_burst` sprite-gen은 재시도했으나 이번에는 Codex provider 인증 401로 생성되지 않았으며 정적 반복 프레임으로 대체하지 않았다.
- INBOX (27)은 나머지 그래픽 요소가 미완료이므로 처리 대기로 유지한다.
- Next slice: `ui.icon_mult` 고해상도 master를 실제 Pixel Perfect runtime으로 변환하고 점수판 배수 값 옆에 manifest-backed로 적용한다.

## 2026-09-09 — 플레이 카드 공유 시트 전환 복구

- 승인된 5종 플레이 카드 후보를 개별 중복 runtime 대신 `play-card.contact-sheet-v1` 단일 runtime atlas와 셀 영역으로 승격했다.
- manifest-backed loader가 카드 ID에서 공유 시트 경로를 해석하도록 보완하고, 셀 순서·master/runtime 영역·alpha bounds 계약을 유지했다.
- 적용 스크립트의 반복 실행이 같은 manifest를 생성함을 확인했으며 `make verify LOVE=/Users/jm/.local/bin/love` 전체 검증을 통과했다.
- Next slice: `gwang.compound_burst` 복합 폭주 광 슬롯 아이템의 provider-backed sprite states/frames를 생성하고 Pixel Perfect 후처리·atlas/manifest 및 런타임 적용을 추가한다.

## 2026-09-09 — 복합 광 고해상도 픽셀 에셋 적용

- `gwang.compound` 광 슬롯 아이템에 푸른 자개 점수 칩, 붉은 교차 비단 매듭, 네모 구멍 엽전을 하나의 순환 장치로 결합한 448×256 SVG/PNG master 및 56×32 runtime 에셋을 추가했다.
- Asset Studio `POST /api/pixel-perfect` 변환을 거쳐 bounds/alignment/palette 등의 검사를 통과했으며 manifest에 기록했다.
- manifest-backed 로더 회귀 테스트와 복합 광 5칸의 실제 LÖVE 320×180 캡처 QA를 통과했다.
- INBOX (27)은 모든 그래픽 요소의 런타임 에셋 전환을 진행 중이므로 처리 대기로 유지한다.
- `gwang.compound_burst`의 `idle`/`burst` 각 4프레임 실제 sprite-gen 요청을 Asset Studio에 보냈으나 Grok provider가 402(생성 잔액 부족)를 반환해 master/atlas를 적용하지 않았다. 정적 프레임 반복으로 대체하지 않는다.
- manifest에서 이미 `runtime`인 대장판 3종 및 광 5종이 inventory에서 미완료로 남은 불일치를 수정하고, `make verify`가 manifest의 전체 109개 ID와 체크 상태를 자동 대조하도록 했다.
- Next slice: `gwang.compound_burst` 복합 폭주 광 슬롯 아이템의 provider-backed sprite states/frames를 생성하고 Pixel Perfect 후처리·atlas/manifest 및 런타임 적용을 추가한다.
