# Feedback Inbox

## 처리 대기

프로세스 (사용자 2026-09-07): Discord 요청은 **코드보다 먼저** 이 섹션에 한 줄+커밋. 빈 처리 대기 = IDLE. 담당 모듈 경로를 적는다 (`docs/MODULE_STRUCTURE.md`).

(R1) **상시 모듈화 — 거대 파일에 기능 붙이지 말 것** (msg `1546726613721415681`)
  - 담당: 현재 파일은 한도 안이지만, 새 기능은 `game/ui/*` / `game/*.lua` 모듈만. `play.lua`/`self_test.lua` 금지.
  - INBOX 기능보다 모듈 경로가 없는 항목은 먼저 모듈을 만든다. 원본 `docs/MODULE_STRUCTURE.md`.

### Phase C — 씬 통합

### Phase D — 발라트로 게임 이펙트 구현 (msg `1546681659951153252`)

### Phase E — 광 카드 에디터 (웹 도구) (msg `1546681659951153252`)

(23) **광 카드 에디터 — 웹 도구** (msg `1546681659951153252`)
  - 담당: `tools/gwang-editor/index.html` + `editor.css` + `editor.js` (새 디렉터리)
  - spaceship gear-editor 패턴 참고 (`tools/gear-editor/`)
  - 기능:
    (a) `game/data/gwang_jokers.json` 로드/저장 (File API + FSA direct save)
    (b) 카드 그리드 뷰: 각 광 조커를 화투 카드 모양(세로 직사각형, 둥근 모서리)으로 표시
    (c) **이미지 업로드**: 사용자가 카드별 이미지를 업로드하면 카드 프레임 안에 자동 배치 (중앙 크롭 + 리사이즈, 카드 비율 유지)
    (d) 이미지는 base64 data URL로 JSON `image` 필드에 저장 (별도 서버 불필요)
    (e) 카드 프레임 위에 이름 + 희귀도 띠(커먼 회색/언커먼 초록/레어 파랑/전설 보라) + 효과 텍스트 오버레이
    (f) 카드 편집 폼: ID, 이름(KO/EN), 희귀도, 트리거 조건, 효과(칩+/배수+/배수×), 설명 텍스트
    (g) + New Card / Delete / Download JSON
    (h) KO|EN 로케일 토글 (gear-editor 패턴)
  - 게임 런타임: `game/gwang_catalog.lua`가 JSON에서 `image` 필드를 읽어 LÖVE 텍스처로 디코드 → 광 슬롯 UI에 표시
  - 테스트: `python3 -m unittest tools.test_gwang_editor -v` (JSON 스키마 검증)

## 처리 완료
(22) **시드 기반 랜덤 + 런 히스토리** (msg `1546681659951153252`)
  - `game/rng.lua`: seed-string RNG, independent shop/cards/boss streams. `run.new` plans sequences. Same seed reproduces shop/deal/boss.
  - `game/ui/seed.lua`: seed display + typed A-Z0-9 input on play scene.
  - `game/run_history.lua`: won/lost log (seed, ante, blind, money), newest-first, cap 8. `run.clear_blind` win + `run.lose` record.
  - `game/tests/rng.lua` + `game/tests/seed_ui.lua` + `game/tests/run_history.lua` GREEN. `make verify` GREEN.

(21) **광 조커 트리거 조건 다양화** (msg `1546681659951153252`)
  - `game/gwang_catalog.lua` + `game/data/gwang_jokers.json`: 30 unique gwang jokers.
  - Triggers: always / contains_kind / yaku / deck_size / money / blind / once / compound (chips+mult+money).
  - `game/hwatu.lua` evaluate applies the catalog loop. No month numbers/names, no mae/ppeok/otti.
  - `game/tests/gwang_catalog.lua` GREEN. `make verify` GREEN.

(20) **덱 편집 + 카드 강화** (msg `1546681659951153252`)
  - `game/deck.lua`: starter viewer (kinds/counts/editions), enhance (foil/hologram/polychrome), destroy (thin deck), sort by kind / effect.
  - Gwang rejected (joker slot). No month numbers/names. Tarot chariot/hanged_man stay visible in `deck.view`.
  - `game/tests/deck.lua` GREEN. `make verify` GREEN.

(19) **이자 시스템 + 경제** (msg `1546681659951153252`)
  - `game/economy.lua`: 이자 $1/$5 (기본 한도 $5, seed_money로 상향), 블라인드 보상 small $3/big $5/boss $8, 남은 핸드 $1장. 소지금 상한 없음.
  - `game/run.lua` `clear_blind`가 `economy.cash_out` 호출. 이자는 정산 전 소지금 기준.
  - `game/tests/economy.lua` GREEN. `make verify` GREEN.

(18) **타로 카드 (카드 변환/파괴)** (msg `1546681659951153252`)
  - `game/tarots.lua`: 마법사=변환, 매달린자=파괴, 전차=이펙트 부여, 연인=복제. 소비 슬롯 최대 2, crystal_ball 바우처로 +1. 상점/보스 보상에서 획득.
  - 변환/복제는 화투 플레이 카드만 (gwang/mae/ppeok/otti/month 금지). 실패 시 슬롯 유지.
  - `game/tests/tarots.lua` GREEN. `make verify` GREEN.

(17) **행성 카드 (핸드 레벨업)** (msg `1546681659951153252`)
  - 담당: `game/planets.lua` (새 모듈)
  - 발라트로 행성 카드: 각 족보(홍단/청단/초단/고도리/피)에 대응하는 행성 카드
  - 상점에서 구매 → 해당 족보의 기본 칩/배수 영구 +
  - 족보 레벨 표시 (Lv.1, Lv.2 …)
  - 테스트: `game/tests/planets.lua`

  (16) **바우처 시스템** (msg `1546681659951153252`)
    - `game/vouchers.lua`: 12종 영구 업그레이드 (핸드/버리기/핸드횟수/상점슬롯/리롤할인/상점할인/이한도/광슬롯/소비슬롯/에디션확률/보스리롤/이자율). 각 정체성 1회.
    - `game/run.lua`: 상점 진입 시 바우처 1장 진열, `buy_voucher` 상점당 1장, 퇴장 시 슬롯 클리어, antimatter가 `max_gwang` +1.
    - `game/tests/vouchers.lua` GREEN. `make verify` GREEN.

  (15) **보스 블라인드 디버프** (msg `1546681659951153252`)
    - `game/boss_blinds.lua`: 8종 보스 (갈고리=핸드 2장 제거, 성벽=목표 2배, 부싯돌=칩·배수 반감, 낙인=홍단 뒤집기, 물고기=핸드 비공개, 영매=5장 풀핸드, 몰이=고도리만 점수, 초목=청단 디버프). 화투 종류만 대상.
    - `game/run.lua` `select_boss` / `blind_target`(성벽 배수) / 보스 진입 시 자동 선택, 비보스에서 클리어.
    - `game/tests/boss_blinds.lua` GREEN. `make verify` GREEN.

  (14) **태그 시스템 (블라인드 스킵 보상)** (msg `1546681659951153252`)
    - `game/tags.lua`: 12종 태그 풀 (쿠폰 무료 리롤, 투자/Handy/이코노미 돈, 메가=다음 광 복제, 포일/홀로그램/폴리크롬 에디션, 참 상점 슬롯, 언커먼 상점, 저글 핸드 크기, D6 리롤×2).
    - `game/run.lua` `skip_blind`: 스몰→빅 / 빅→보스, 태그 적용, play 유지. 보스 스킵 금지.
    - `game/tests/tags.lua` GREEN. `make verify` GREEN.

  (13) **카드 홀로그램/포일/폴리크롬 이펙트 시스템** (msg `1546681659951153252`)
    - `game/ui/card_effects.lua`: 홀로그램(무지개빛 반투명, +10 mult), 포일(반짝임, +50 chips), 폴리크롬(색상 시프트, ×1.5 mult). `apply_bonuses`가 핸드 합산.
    - `game/hwatu.lua` evaluate에 이펙트 보너스 반영. `game/ui/card.lua` overlay 드로우.
    - `game/tests/card_effects.lua` GREEN. `make verify` GREEN.

  (12) **점수 연출 모듈** (msg `1546674255045992608`)
    - `game/ui/score_anim.lua`: 발라트로 스타일 점수 연출. 페이즈 기반 (cards→mult→total→done). 카드별 칩 팝업, 배수 적용, 최종 합산 카운트업 (ease-out), 광 조커 트리거 시 슬롯 글로우 이펙트 (종류별 색상: chips=파랑, mult=빨강, yaku_mult=금색).
    - `game/tests/score_anim_ui.lua` GREEN (7 tests). `make verify` GREEN.

  (11) **play 씬 리빌드: UI 모듈 통합** (msg `1546674255045992608`)
    - `game/scenes/play.lua`: 상태 머신 `blind_select → playing → shop → next blind_select`. 모든 UI 모듈 require + 위임. `game/run.lua` + `game/hwatu.lua` 엔진 연동. 광 조커 보너스 적용. < 250줄 순수 글루.
    - `game/tests/play_integration.lua` GREEN. `make verify` GREEN.

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
