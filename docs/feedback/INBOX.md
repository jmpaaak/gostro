# Feedback Inbox

## 처리 대기

프로세스 (사용자 2026-09-07): Discord 요청은 **코드보다 먼저** 이 섹션에 한 줄+커밋. 빈 처리 대기 = IDLE. 담당 모듈 경로를 적는다 (`docs/MODULE_STRUCTURE.md`).

### Phase B — 핵심 UI 모듈 개발

(4) **카드 렌더링 모듈** (msg `1546674255045992608`)
  - 담당: `game/ui/card.lua` (새 모듈)
  - 화투 카드 한 장 그리기: 배경 직사각형 + 종류 심볼(★/깃발/난초/동물/점)
  - 카드 크기: 24×36px (320×180 기준). 선택 시 위로 8px 올림.
  - hover 없음 (터치 전용). 탭으로 선택/해제 토글.
  - 테스트: `game/tests/card_ui.lua`

(5) **핸드 디스플레이 모듈** (msg `1546674255045992608`)
  - 담당: `game/ui/hand.lua` (새 모듈)
  - 핸드 카드 8장을 하단에 가로 배치 (발라트로 스타일 겹침 배열)
  - 선택된 카드 강조 (위로 올림 + 테두리 색)
  - 최대 5장 선택 제한, 선택 순서 표시
  - `game/ui/card.lua` 의존
  - 테스트: `game/tests/hand_ui.lua`

(6) **광 조커 슬롯 UI 모듈** (msg `1546674255045992608`)
  - 담당: `game/ui/gwang_slots.lua` (새 모듈)
  - 상단 가로줄 최대 5칸, 빈 칸은 점선 테두리
  - 장착된 광은 ★ 심볼 + 이름 + 효과 한 줄
  - 테스트: `game/tests/gwang_slots_ui.lua`

(7) **점수판 UI 모듈** (msg `1546674255045992608`)
  - 담당: `game/ui/scoreboard.lua` (새 모듈)
  - 칩 × 배수 = 총점 실시간 표시
  - 블라인드 목표 대비 현재 점수 바
  - 점수 달성 시 팝업 숫자 연출 (발라트로 스타일 chips×mult 표시)
  - 테스트: `game/tests/scoreboard_ui.lua`

(8) **플레이/버리기 버튼 모듈** (msg `1546674255045992608`)
  - 담당: `game/ui/action_buttons.lua` (새 모듈)
  - 발라트로 스타일 하단 중앙 2버튼: "놓기" (파란) / "버리기" (빨간)
  - 남은 핸드/버리기 횟수 표시
  - 터치 탭 + 키보드 단축키 (space/d)
  - 테스트: `game/tests/action_buttons_ui.lua`

(9) **상점 UI 모듈** (msg `1546674255045992608`)
  - 담당: `game/ui/shop.lua` (새 모듈)
  - 광 조커 3장 진열 (카드 형태, 가격 태그)
  - 리롤 버튼 ($5) + "다음 라운드" 버튼
  - 소지금 표시. 구매 시 카드 날아가는 연출은 후속.
  - `game/run.lua`의 상점 로직 연동
  - 테스트: `game/tests/shop_ui.lua`

(10) **블라인드 선택 화면 모듈** (msg `1546674255045992608`)
  - 담당: `game/ui/blind_select.lua` (새 모듈)
  - 스몰/빅/보스 블라인드 3장 카드 레이아웃
  - 각 카드에 목표 점수 + 보상/패널티 표시
  - 선택 탭 → 해당 블라인드로 진입
  - 테스트: `game/tests/blind_select_ui.lua`

### Phase C — 씬 통합

(11) **play 씬 리빌드: UI 모듈 통합** (msg `1546674255045992608`)
  - 담당: `game/scenes/play.lua` (기존 파일 교체, 모든 UI 모듈 require)
  - 게임 상태 머신: `blind_select → playing → scoring → shop → next_blind`
  - 각 상태에서 해당 UI 모듈만 draw/update
  - `game/run.lua` + `game/hwatu.lua` 엔진 연동
  - `play.lua`는 위임만, 800줄 한도 엄수
  - 테스트: `game/tests/play_integration.lua`

(12) **점수 연출 모듈** (msg `1546674255045992608`)
  - 담당: `game/ui/score_anim.lua` (새 모듈)
  - 발라트로 스타일: 각 카드에서 칩 팝업 → 배수 적용 → 최종 합산 카운트업
  - 광 조커 트리거 시 슬롯에서 빛나는 이펙트
  - 테스트: `game/tests/score_anim_ui.lua`

## 처리 완료

  (3) **고스트로 UI 와이어프레임 생성** (msg `1546674255045992608`)
    - `tools/gen_wireframe.py` PIL 스크립트로 320×180 와이어프레임 4장 생성 (play/shop/blind_select/result).
    - `docs/WIREFRAME.md` 좌표 주석 포함. `docs/GENERATED_ASSET_LOG.md` 기록.
    - `make verify` GREEN.

  (2) **발라트로 UI 벤치마크 문서 작성** (msg `1546674255045992608`)
    - `docs/UI_BENCHMARK.md` 생성: 메인 플레이/상점/블라인드 선택/게임오버 화면 + 시각 스타일 + 320×180 좌표 스케치 + 색상 팔레트.
    - 코드 변경 없음. `make verify` GREEN.

  (1) **첫 플레이 슬라이스: 단·고도리·피 핸드 + 광 조커 슬롯** (기획 2026-09-07)
    - 담당: `game/hwatu.lua` (순수 평가) + `game/run.lua` (앤티/블라인드/상점) + `game/scenes/play.lua` require만.
    - 패: 광★ / 홍단 빨간깃발 / 청단 파란깃발 / 초단 난초 / 고도리 동물 / 피. **월 숫자 없음.**
    - 족보: 광 1점, 홍단, 청단, 초단, 고도리, 피. 매·뻑·오띠 금지.
    - 광 = 조커 슬롯 (상점 구매, 한 장 한 정체성). "고수패" 말 쓰지 말 것.
    - 검증: `game/tests/hwatu.lua` + `game/tests/run.lua` + `GAME_HEADLESS=1 GAME_UNIT=1 love .` → GOSTRO_UNIT_OK; `make verify LOVE=/Users/jm/.local/bin/love` GREEN.
