# STATUS
## 2026-09-09 — 영롱 효과 고해상도 픽셀 에셋 적용
- `effect.polychrome`에 192×288 영롱 플레이 카드 오버레이 PNG master와 24×36 runtime 에셋을 추가했다.
- Asset Studio 실제 `POST /api/pixel-perfect` 변환 보고서의 dimensions/alignment/palette/transparentAlpha/nearestNeighbor 검사를 통과했다.
- 기존 `game/ui/edition_art.lua`에 polychrome overlay 계약을 추가하고 `game/ui/card_effects.lua` 배선을 재사용했다.
- QA 스크립트(`tools/polychrome_effect_qa_main.lua`)와 LÖVE 320×180 캡처 QA를 통과했다.
- `make verify LOVE=/Users/jm/.local/bin/love` GREEN: 전체 unit/font/capture/smoke/bundle 검증이 통과했고 bundle은 815개 파일이다.
- INBOX (27)은 나머지 그래픽 요소가 미완료이므로 처리 대기로 유지한다.
- Next slice: 다음 미완료 그래픽(`gwang.compound_burst`) 고해상도 master를 생성하고 런타임에 적용한다.

## 2026-09-09 — 노란 덱 썸네일 고해상도 픽셀 에셋 적용

- `ui.deck_yellow`에 384×384 옻칠 황토색 화투 뒷면 PNG master와 48×48 runtime 에셋을 추가했다.
- Asset Studio 실제 `POST /api/pixel-perfect` 변환 보고서의 dimensions/alignment/palette/transparentAlpha/nearestNeighbor 검사를 통과했다.
- 기존 `game/ui/deck_art.lua`에 `draw_yellow` 계약을 두고 새 게임 설정의 광대박패 하드코딩 도형을 배선했다.
- 엔진 테스트와 LÖVE 320×180 캡처 QA를 통과했다.
- `make verify LOVE=/Users/jm/.local/bin/love` GREEN: 전체 unit/font/capture/smoke/bundle 검증이 통과했고 bundle은 647개 파일이다.
- INBOX (27)은 나머지 그래픽 요소가 미완료이므로 처리 대기로 유지한다.
- Next slice: `ui.stake_white` 고해상도 master를 실제 Pixel Perfect runtime으로 변환하고 난이도 선택 UI에 적용한다.

## 2026-09-09 — 파란 덱 썸네일 고해상도 픽셀 에셋 적용

- `ui.deck_blue`에 384×384 옻칠 남색 화투 뒷면 PNG master와 48×48 runtime 에셋을 추가했다.
- Asset Studio 실제 `POST /api/pixel-perfect` 변환 보고서의 dimensions/alignment/palette/transparentAlpha/nearestNeighbor 검사를 통과했다.
- 신규 `game/ui/deck_art.lua`에 `draw_blue` 계약을 두고 새 게임 설정의 기본 화투패 하드코딩 도형을 배선했다.
- 엔진 테스트와 LÖVE 320×180 캡처 QA를 통과했다.
- `make verify LOVE=/Users/jm/.local/bin/love` GREEN: 전체 unit/font/capture/smoke/bundle 검증이 통과했고 bundle은 635개 파일이다.
- INBOX (27)은 나머지 그래픽 요소가 미완료이므로 처리 대기로 유지한다.
- Next slice: `ui.deck_red` 고해상도 master를 실제 Pixel Perfect runtime으로 변환하고 덱 선택 UI에 적용한다.

## 2026-09-09 — 패배 효과 고해상도 픽셀 에셋 적용

- `ui.effect_loss`에 960×540 한국 화투 패배 베일 PNG master와 320×180 runtime 에셋을 추가했다.
- Asset Studio 실제 `POST /api/pixel-perfect` 변환 보고서의 dimensions/alignment/palette/transparentAlpha/nearestNeighbor 검사를 통과했다.
- 기존 `game/ui/effect_art.lua`에 `draw_loss` 계약을 추가하고 플레이 씬 패배 상태의 하드코딩된 텍스트를 배선했다.
- 엔진 테스트와 LÖVE 320×180 캡처 QA를 통과했다.
- `make verify LOVE=/Users/jm/.local/bin/love` GREEN: 전체 unit/font/capture/smoke/bundle 검증이 통과했고 bundle은 627개 파일이다.
- INBOX (27)은 나머지 그래픽 요소가 미완료이므로 처리 대기로 유지한다.
- Next slice: `ui.deck_blue` 고해상도 master를 실제 Pixel Perfect runtime으로 변환하고 덱 선택 UI에 적용한다.

## 2026-09-09 — 승리 효과 고해상도 픽셀 에셋 적용
- `ui.effect_win`에 960×540 한국 화투 승리 광선 PNG master와 320×180 runtime 에셋을 추가했다.
- Asset Studio 실제 `POST /api/pixel-perfect` 변환 보고서의 dimensions/alignment/palette/transparentAlpha/nearestNeighbor 검사를 통과했다.
- 기존 `game/ui/effect_art.lua`에 `draw_win` 계약을 추가하고 플레이 씬 승리 상태의 하드코딩된 텍스트를 배선했다.
- 엔진 테스트와 LÖVE 320×180 캡처 QA를 통과했다.
- `make verify LOVE=/Users/jm/.local/bin/love` GREEN: 전체 unit/font/capture/smoke/bundle 검증이 통과했고 bundle은 621개 파일이다.
- INBOX (27)은 나머지 그래픽 요소가 미완료이므로 처리 대기로 유지한다.
- Next slice: `ui.effect_loss` 고해상도 master를 실제 Pixel Perfect runtime으로 변환하고 패배 효과에 적용한다.

## 2026-09-09 — 잠금 효과 고해상도 픽셀 에셋 적용
- `ui.effect_lock`에 384×480 황동 자물쇠 PNG master와 16×20 runtime 에셋을 추가했다.
- Asset Studio 실제 `POST /api/pixel-perfect` 변환 보고서의 dimensions/alignment/palette/transparentAlpha/nearestNeighbor 검사를 통과했다.
- 기존 `game/ui/effect_art.lua`에 `draw_lock` 계약을 추가하고 새 게임 설정(`game/ui/run_setup.lua`)의 하드코딩된 자물쇠 도형을 배선했다.
- 엔진 테스트와 LÖVE 320×180 잠긴 덱 캡처 QA를 통과했다.
- `make verify LOVE=/Users/jm/.local/bin/love` GREEN: 전체 unit/font/capture/smoke/bundle 검증이 통과했고 bundle은 615개 파일이다.
- INBOX (27)은 나머지 그래픽 요소가 미완료이므로 처리 대기로 유지한다.
- Next slice: `ui.effect_win` 고해상도 master를 실제 Pixel Perfect runtime으로 변환하고 승패 효과에 적용한다.

## 2026-09-09 — 상점 씬 배경 고해상도 픽셀 에셋 적용

- `ui.shop_bg`에 960×540 옻칠 상점 테이블과 황동 모서리·선반 선·동전 문양의 PNG master와 320×180 runtime 에셋을 추가했다.
- Asset Studio 실제 `POST /api/pixel-perfect` 변환 보고서의 dimensions/alignment/palette/transparentAlpha/nearestNeighbor 검사를 통과했다.
- 기존 `game/ui/scene_bg.lua`에 shop kind를 추가하고 상점 상태일 때만 `ui.shop_bg`를 그리도록 `game/scenes/play.lua`를 배선했다.
- 엔진 테스트와 LÖVE 320×180 캡처 QA를 통과했다.
- `make verify LOVE=/Users/jm/.local/bin/love` GREEN: 전체 unit/font/capture/smoke/bundle 검증이 통과했고 bundle은 608개 파일이다.
- INBOX (27)은 나머지 그래픽 요소가 미완료이므로 처리 대기로 유지한다.
- Next slice: `ui.effect_lock` 고해상도 master를 실제 Pixel Perfect runtime으로 변환하고 잠금 효과에 적용한다.

## 2026-09-09 — 플레이 씬 배경 고해상도 픽셀 에셋 적용

- `ui.play_bg`에 960×540 짙은 남색 화투 테이블과 황동 모서리 장식 PNG master와 320×180 runtime 에셋을 추가했다.
- Asset Studio 실제 `POST /api/pixel-perfect` 변환 보고서의 dimensions/alignment/palette/transparentAlpha/nearestNeighbor 검사를 통과했다.
- 플레이 씬(`game/scenes/play.lua`)의 단색 `clear`를 신규 `game/ui/scene_bg.lua` 에셋 렌더링으로 교체했고, 엔진 테스트와 LÖVE 320×180 캡처 QA를 통과했다.
- `make verify LOVE=/Users/jm/.local/bin/love` GREEN: 전체 unit/font/capture/smoke/bundle 검증이 통과했고 bundle은 602개 파일이다.
- INBOX (27)은 나머지 그래픽 요소가 미완료이므로 처리 대기로 유지한다.
- Next slice: `ui.shop_bg` 고해상도 master를 실제 Pixel Perfect runtime으로 변환하고 상점 씬 배경에 적용한다.

## 2026-09-09 — 부적 선택 유리 패널 고해상도 픽셀 에셋 적용

- `ui.panel_glass`에 640×368 청자 유리와 나전 매화 모서리 장식의 9-slice 패널 SVG/PNG master와 80×46 runtime 에셋을 추가했다.
- Asset Studio 실제 `POST /api/pixel-perfect` 변환 보고서의 dimensions/alignment/palette/transparentAlpha/nearestNeighbor 검사를 통과하고 기존 `panel_art` 9-slice 모듈에 glass kind를 추가했다.
- 부적 대상 선택 오버레이(`game/ui/tarot_target.lua`)의 하드코딩된 도형 렌더링을 신규 glass 패널로 교체했고, 엔진 테스트와 LÖVE 320×180 캡처 QA를 통과했다.
- INBOX (27)은 나머지 그래픽 요소가 미완료이므로 처리 대기로 유지한다.
- Next slice: `ui.menu_bg` 고해상도 master를 실제 Pixel Perfect runtime으로 변환하고 메인 메뉴 배경에 적용한다.

## 2026-09-09 — 점수판 금속 패널 고해상도 픽셀 에셋 적용

- `ui.panel_metal`에 640×368 녹청 청동 패와 태극 모서리 장식의 9-slice 패널 SVG/PNG master와 80×46 runtime 에셋을 추가했다.
- Asset Studio 실제 `POST /api/pixel-perfect` 변환 보고서의 dimensions/alignment/palette/transparentAlpha/nearestNeighbor 검사를 통과하고 기존 `panel_art` 9-slice 모듈에 metal kind를 추가했다.
- 점수판 배경의 하드코딩된 도형 렌더링을 신규 metal 패널로 교체했고, 엔진 테스트와 LÖVE 320×180 캡처 QA를 통과했다.
- INBOX (27)은 나머지 그래픽 요소가 미완료이므로 처리 대기로 유지한다.
- Next slice: `ui.panel_glass` 고해상도 master를 실제 Pixel Perfect runtime으로 변환하고 manifest-backed 9-slice 패널 모듈에 통합한다.

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

> Older cycle history lives in `docs/STATUS_HISTORY.md`. Only search it when tracking a specific past bug; do not read it by default.

> 이전 cycle 이력은 `docs/STATUS_HISTORY.md`에 있다. 특정 과거 버그를 추적할 때만 그 파일을 검색하고, 평소에는 읽지 않는다.
