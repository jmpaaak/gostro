# Feedback Inbox

## 처리 대기

프로세스 (사용자 2026-09-07): Discord 요청은 **코드보다 먼저** 이 섹션에 한 줄+커밋. 빈 처리 대기 = IDLE. 담당 모듈 경로를 적는다 (`docs/MODULE_STRUCTURE.md`).

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

  (10) **블라인드 선택 화면 모듈** (msg `1546674255045992608`)
    - `game/ui/blind_select.lua`: 스몰/빅/보스 3장 카드 레이아웃 (50×70px, 색상 구분), 목표 점수 + 보상 표시, 선택 탭 → 해당 블라인드 진입, hit_test.
    - `game/tests/blind_select_ui.lua` GREEN. `make verify` GREEN.

  (9) **상점 UI 모듈** (msg `1546674255045992608`)
    - `game/ui/shop.lua`: 광 조커 3장 진열 (카드 형태, ★ + 이름 + 가격 태그), 리롤 버튼 ($5), "다음 라운드" 버튼, 소지금 표시, hit_test, buy/reroll 로직.
    - `game/tests/shop_ui.lua` GREEN. `make verify` GREEN.

  (8) **플레이/버리기 버튼 모듈** (msg `1546674255045992608`)
    - `game/ui/action_buttons.lua`: Balatro-style 하단 중앙 2버튼 "놓기"(파란)/"버리기"(빨간), 남은 횟수 표시, 터치 hit_test, space/d 키보드 단축키.
    - `game/tests/action_buttons_ui.lua` GREEN. `make verify` GREEN.

  (7) **점수판 UI 모듈** (msg `1546674255045992608`)
    - `game/ui/scoreboard.lua`: chips×mult=총점 실시간 표시, 블라인드 목표 대비 진행 바(0..1 클램프), 점수 달성 시 Balatro-style 팝업(부유+페이드), format_score_text.
    - `game/tests/scoreboard_ui.lua` GREEN. `make verify` GREEN.

  (6) **광 조커 슬롯 UI 모듈** (msg `1546674255045992608`)
    - `game/ui/gwang_slots.lua`: 상단 5칸 가로줄 (28×16px, 점선 빈 칸, ★+이름+효과 장착 칸), equip/sync_from_run/display_text.
    - `game/tests/gwang_slots_ui.lua` GREEN. `make verify` GREEN.

  (5) **핸드 디스플레이 모듈** (msg `1546674255045992608`)
    - `game/ui/hand.lua`: 8장 겹침 배열 (16px gap, 320×180 중앙), 최대 5장 선택 + 순서 추적, 리프트+테두리 강조, hit_test, draw.
    - `game/tests/hand_ui.lua` GREEN. `make verify` GREEN.

  (4) **카드 렌더링 모듈** (msg `1546674255045992608`)
    - `game/ui/card.lua`: 24×36px 카드 위젯 (5종 심볼, 선택 리프트, hit_test).
    - `game/tests/card_ui.lua` GREEN. `make verify` GREEN.

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
