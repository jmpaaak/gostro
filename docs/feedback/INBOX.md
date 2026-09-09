# Feedback Inbox

## 처리 대기

(38) **발라트로급 호버 확대·상점 구매 피드백·판 스킵 안내** (msg `1547290362782031952`)
  - 담당: `game/ui/card.lua`, `game/ui/card_art.lua`, `game/ui/shop.lua`, `game/ui/blind_select.lua`, `game/scenes/play.lua`.
  - 호버 시 패가 살짝 확대. 상점 구매 시 슬롯 판매 연출. 판 카드에 스킵 가능/불가 카피.
  - 완료: 확대·구매 피드백·스킵 카피, `make test LOVE=/Users/jm/.local/bin/love` GREEN.


## 처리 중

(없음)

## 처리 완료

(37) **발라트로급 팩·광 슬롯 툴팁·버튼 호버** (msg `1547290362782031952`)
  - 담당: `game/ui/pack.lua`, `game/ui/gwang_slots.lua`, `game/ui/action_buttons.lua`, `game/ui/consumables.lua`, `game/scenes/play.lua`.
  - 팩 선택 카드 호버 리프트. 광 슬롯 호버 시 이름+효과 툴팁. 놓기/버리기 호버 강조. 소모품 호버.
  - `make test LOVE=/Users/jm/.local/bin/love` GREEN. [DONE 2026-09-10]

(36) **발라트로급 상점·판 선택·점수 카운트업 디테일** (msg `1547290362782031952`)
  - 담당: `game/ui/shop.lua`, `game/ui/blind_select.lua`, `game/ui/scoreboard.lua`, `game/scenes/play.lua`.
  - 상점 슬롯 호버 리프트+가격 강조. 판 카드에 목표/보상/지금 도전 카피. 점수판 총점 ease-out 카운트업.
  - `make test LOVE=/Users/jm/.local/bin/love` GREEN. [DONE 2026-09-10]

(35) **발라트로급 플레이 디테일: 호버·점수 연출·고/판/돈 HUD** (msg `1547288119257075793`)
  - 담당: `game/ui/hand.lua`, `game/ui/card.lua`, `game/ui/score_anim.lua`, `game/ui/round_hud.lua`, `game/scenes/play.lua`, `game/scene_stack.lua`, `main.lua`.
  - 호버 시 패가 8px 올라감(선택은 16px이 이김). 놓기 후 칩→×배수→총점 연출을 실제 패 좌표에 연결. 플레이 중 1고/첫판/$/남은 패와 `패를 고르고 놓기`가 우측에 보임. 광 글로우는 실제 슬롯 좌표.
  - `make test LOVE=/Users/jm/.local/bin/love` GREEN. [DONE 2026-09-10]

(34) **플레이 HUD가 발라트로 대비 진행 안내·선택 점수·겹침이 없다** (msg `1547282298062372965`)
  - 담당: `game/ui/scoreboard.lua`, `game/ui/action_buttons.lua`, `game/ui/planets_ui.lua`, `game/ui/seed.lua`, `game/scenes/play.lua`, `game/scoring_pipeline.lua`.
  - 점수판을 좌측으로 옮기고, 놓기/버리기는 손패 좌우로 분리. 패 선택 시 족보+칩×배수 미리보기(광 once/money 비파괴). 시드 필드는 광 슬롯 왼쪽, 족보 레벨은 점수판 아래(레벨 2+만).
  - `make test LOVE=/Users/jm/.local/bin/love` GREEN. [DONE 2026-09-10]

(33) **love . 가 Galmuri 11 배수 assert로 즉시 크래시** (msg `1547279539426689024`)
  - 담당: `game/fonts.lua`, `game/ui/main_menu.lua`, `game/ui/run_setup.lua`, `game/tests/fonts.lua`, `game/tests/main_menu_ui.lua`.
  - `fonts.get`은 `size % 11 == 0`. 기본 본문 33, 제목 66. 메뉴/런 설정이 더 이상 11/22를 호출하지 않는다.
  - `make test LOVE=/Users/jm/.local/bin/love` GREEN. [DONE 2026-09-10]

(32) **논리 캔버스·화투패를 발라트로급 해상도로 올린다** (msg `1547270254495928380`, `1547273081976914001`)
  - 담당: `game/viewport.lua`, `game/ui/card.lua`, `game/ui/hand.lua`, `game/ui/**` 레이아웃 상수, `conf.lua`, `assets/manifest.json`, `tools/asset_pipeline/pixel_perfect.py`. 스튜디오 `http://127.0.0.1:4176/` `POST /api/pixel-perfect`로 런타임을 다시 뽑는다.
  - 확정: 320×180 UI 유지는 철회. 논리 캔버스 **960×540** (기존 320×180의 3×). 기본 창 960×540(1×), 1920×1080은 정수 2× nearest.
  - 화투패 런타임 **72×108** (발라트로 1x 71×95에 가까운 폭, 화투 2:3). 마스터 192×288 → Pixel Perfect 72×108. 손패 8장이 960 안에 겹침.
  - 배경 런타임은 캔버스와 같은 **960×540** (이미 마스터 960×540). 320 배경을 창에 늘리지 않는다.
  - HUD/슬롯/버튼 좌표도 3×. Galmuri는 11의 배수(22 또는 33).
  - 완료: 캔버스 960×540, 패 72×108, HUD 3×, Galmuri 33, 배경/승패 960×540 Pixel Perfect valid, 기본 창 960×540 (`GAME_SCALE=2` → 1920×1080). `make test LOVE=/Users/jm/.local/bin/love` GREEN. [DONE 2026-09-10]

(31) **플레이 패가 고화질이 아님 — 24×36 런타임이 화면에서 뭉개짐** (msg `1547268256992198666`)
  - 손패 드로우가 24×36이라 192×288 마스터 디테일이 화면에 안 나왔다.
  - 플레이 패 5종 런타임을 48×72로 올리고 손패 간격 28px로 320×180 안에 맞춤. contact sheet는 실제 `/api/pixel-perfect`로 240×72 재변환.
  - `make test LOVE=/Users/jm/.local/bin/love` GREEN, overlap QA 5종 상단 문양 unique. [DONE 2026-09-09]


(30) **GostroLoop 앱이 반복해서 뜸** (msg `1547214891566370817`)
  - 루프 `make verify`가 캡처 QA마다 `love-qa.app`(CFBundleName=GostroLoop)을 띄웠다. 에셋 스튜디오와 무관.
  - 루프 preflight는 이제 `make test status-test asset-inventory-test smoke love`만 돌리고 windowed `*-qa`/`font-test`는 제외. `GAME_HEADLESS=1` + dummy SDL을 루프 자식에 상속.
  - `ensure_love_qa_app.sh`에서 GostroLoop 표시 이름을 제거. 기존 `build/qa_app/love-qa.app` 삭제. `make test` GREEN. [DONE 2026-09-09]

(29) **자동 테스트/캡처 Love2D 창이 켜졌다 꺼졌다를 반복해 다른 작업을 방해함** (msg `1547191717118218281`, follow-up `1547199236742058064`, `1547202068216029215`, `1547211151413088297`)
  - 1×1 오프스크린도 macOS Dock 아이콘이 깜빡임. 게임 `conf.lua`는 `GAME_HEADLESS`/`GAME_QA`/`GOSTRO_LOOP`면 `t.window=false`.
  - 재현: 루프가 `/Users/jm/.local/bin/love build/test`를 직접 실행하면 `conf.lua`가 없어 Love **기본 800×600**이 뜬다. `GOSTRO_LOOP=1`일 때만 `~/.local/bin/love`가 `loop/bin/love`로 위임하고, 대상 디렉터리에 `conf.lua`가 없으면 `tools/qa_conf.lua`를 주입한다.
  - 3차: `qa_conf.lua`가 `t.window.title = "Gostro QA"`라서 Dock/Cmd-Tab에 **Gostro QA 앱**으로 보였다. 창 제목을 비우고 `tools/ensure_love_qa_app.sh`가 `LSUIElement=true`인 `love-qa.app` 복사본으로만 루프 Love를 실행한다. 확인: `W=1 H=1 title=`, `make font-test` GREEN, System Events에 Gostro 프로세스 없음. [DONE 2026-09-09]

(27) **Gostro 전체 그래픽 고해상도 master 기반 픽셀 에셋 전환** (msg `1546885987525988473`)
  - 담당: `docs/ASSET_PIPELINE.md`, `docs/GENERATED_ASSET_LOG.md`, `assets/manifest.json`, 신규 `assets/masters/**`·`assets/runtime/**`, 신규 `tools/asset_pipeline/**`; 런타임 배선은 기존 `game/ui/card.lua`, `game/ui/gwang_art.lua` 등을 직접 비대화하지 말고 asset loader/draw 모듈을 신규 분리한다.
  - MOK의 승인된 에셋 생성 규칙을 기준으로 삼는다: 고해상도 원본/master를 보존하고 원본 색상을 기본 유지하며, hard alpha·nearest-neighbor·정수 배율·실제 런타임 캡처를 검증한다. 단순 색 사각형·Lua primitive·저해상도 확대·PIL 대체물을 최종 에셋으로 인정하지 않는다.
  - `http://127.0.0.1:4176/index.html` 통합 에셋 스튜디오의 실제 `POST /api/pixel-perfect` 계약을 probe해 고해상도 master에서 runtime 도트 PNG를 생성한다. 가짜 resize나 endpoint 이름만 흉내 낸 파이프라인은 금지한다.
  - 화투 플레이 패 전종, 광 카드 전종, 행성·타로·바우처·태그, Blind/Boss, 덱·Stake, 팩·상점·메뉴·HUD·버튼·아이콘·패널·배경·선택/득점/잠금/승패 효과 등 현재 런타임과 데이터 카탈로그의 **모든 그래픽 인스턴스**를 기계적으로 inventory하고 각 항목을 개별 manifest/checklist로 추적한다.
  - 특수 광, foil/hologram/polychrome, 보스·득점·팩 개봉 등 애니메이션 가치가 있는 항목은 실제 `sprite-gen` provider-backed 생성으로 state/frame row를 만든 뒤 Pixel Perfect 후처리·atlas/manifest를 거친다. 정적 이미지 반복이나 코드 도형을 sprite-gen 결과라고 부르지 않는다.
  - 각 에셋은 master/runtime 크기, alpha bounds, 출력 hash, 변환 설정, frame 수/FPS/loop/origin을 기록하고, 투명도·셀 경계·팔레트/색 보존·nearest filtering을 자동 검사한다. 실제 320×180 LÖVE 캡처에서 카드 식별성, 겹친 카드 상단 표식, UI 비중첩을 확인한 뒤에만 적용 완료 처리한다.
  - **2026-09-08 `play-card.pi` 첫 pilot은 아트 QA 거부:** 192×288 master가 지도 핀으로 오인되고 24×36 runtime의 `PI` 글자가 읽히지 않아 피 카드로 식별되지 않는다. 이를 승인 스타일로 복제하지 말고, 지도 핀/영문 약어가 아닌 한국 화투 계열의 상단 식별 문양과 카드 본체 그림을 가진 고해상도 master로 재생성한다. 플레이 패 5종이 하나의 시각 문법으로 실제 겹침 QA를 통과하기 전에는 어떤 단일 카드도 runtime 완료로 세지 않는다.

(28) **Balatro 직수입 용어를 화투·한국 테마로 전면 교체** (msg `1546892527838302351`)
  - 담당: 신규 `game/terms.lua`를 단일 player-facing 용어 계약으로 두고 `game/ui/**`, `game/scenes/**`, `game/data/**`, 관련 순수 모듈·테스트·`docs/ASSET_INVENTORY.md`·`assets/manifest.json`을 카테고리별 독립 lane으로 마이그레이션한다. 현재 (27) 에셋 작업의 미커밋 파일과 충돌하는 manifest/inventory 변경은 해당 owner가 용어 계약을 읽어 반영한다.
  - 확정 용어: 행성 카드 5종 → **기원패 5종**, 타로 4종 → **부적 4종**, 태그 12종 → **패찰 12종**, 바우처 12종 → **인장 12종**, 아르카나 팩 1종 → **부적 꾸러미 1종**, Blind → **판** (`small/big/boss`는 **첫판/큰판/대장판**), Ante → **고** (`1고`…`8고`).
  - 영문도 Balatro 명칭을 노출하지 않는다: `Wish Card`, `Talisman`, `Plaque`, `Seal`, `Talisman Bundle`, `Round` (`Opening/Main/Final Round`), `Go`. 저장 데이터 호환이 필요한 legacy id/field는 즉시 파괴하지 말고 내부 alias/migration으로만 보존하며 UI·에셋 키·신규 코드에서는 새 도메인명을 사용한다.
  - 각 개별 카드/효과명도 우주·서양 점술·Balatro 원명을 그대로 옮기지 말고 기능을 보존한 한국적 이름과 도상으로 바꾼다. 전체 문자열/카탈로그 검색에서 player-facing `planet/tarot/tag/voucher/arcana/blind/ante` 잔존 0건, 기존 save/seed 결정성 보존, 관련 모듈 테스트와 `make verify LOVE=/Users/jm/.local/bin/love` GREEN을 완료 조건으로 한다.
  - 완료 증빙: 개별 효과명 한국화 및 영문 번역 제공(Final Round Mult 등) 교체 완료, 관련 테스트 수정, `make verify` 통과.

### Phase F — Balatro New Run 역설계·순차 구현

(26) **Balatro New Run 실기기 관찰 기반 기능·UI 역설계 및 Gostro 순차 구현** (msg `1546786558852726826`)
  - 물리 iPhone에서 랜딩, PLAY 패널의 가로 탭, New Run 덱 캐러셀·잠금 조건·난이도·시드·비활성 PLAY를 직접 관찰하고 `docs/evidence/balatro-new-run/` 및 `docs/BALATRO_NEW_RUN_ANALYSIS.md`에 근거를 남겼다.
  - 미관찰 블라인드 이후는 출처·확실성을 명시한 문헌 조사로 보완했으며 화면 배치를 추측하지 않았다.
  - Gostro에 랜딩→새 게임 설정→원자적 런 생성, 현재 블라인드만 진입 가능한 small→big→boss 진행, 공통 stake/보스 목표 projection을 구현했다.
  - 런 상태, 목표, 진행, 카드 배분, 광 인벤토리, 바우처 구매를 독립 모듈로 분리하고 `game.run`을 단방향 호환 facade로 축소했다.
  - `make verify LOVE=/Users/jm/.local/bin/love` GREEN: unit/font/smoke/bundle 전체 통과, bundle 174 files.

### Phase C — 씬 통합

(25) **마우스·터치 입력 배선 복구** (msg `1546761629079838810`)
  - 담당: `main.lua`, `game/scene_stack.lua`, `game/tests/input_routing.lua`
  - `love.mousepressed`와 `love.touchpressed`가 scene stack을 거쳐 현재 씬의 `mousepressed`로 전달된다.
  - `viewport.toGame()`으로 320×180 게임 좌표를 변환하며 레터박스 바깥 입력은 무시한다.
  - `game/tests/input_routing.lua` 회귀 테스트 및 `make verify LOVE=/Users/jm/.local/bin/love` GREEN.

(24) **게임 전체 한글 깨짐 복구 — Galmuri11 폰트 초기화** (msg `1546749365228535828`)
  - `game/fonts.lua` caches Galmuri11 at positive 11px multiples and `main.lua` installs 11px globally before scene creation.
  - Bundled `assets/fonts/Galmuri11.ttf` and `assets/fonts/Galmuri-OFL.txt`; bundle verification requires both files.
  - `game/tests/fonts.lua` checks installation/caching and real LÖVE glyph support for `상점/다음 라운드/광`.
  - `make verify LOVE=/Users/jm/.local/bin/love` GREEN (`GOSTRO_FONT_OK`, `LOVE_BUNDLE_OK`).

(R1) **상시 모듈화 — 거대 파일에 기능 붙이지 말 것** (msg `1546726613721415681`)
  - 담당: 현재 파일은 한도 안이지만, 새 기능은 `game/ui/*` / `game/*.lua` 모듈만. `play.lua`/`self_test.lua` 금지.
  - INBOX 기능보다 모듈 경로가 없는 항목은 먼저 모듈을 만든다. 원본 `docs/MODULE_STRUCTURE.md`.

### Phase E — 광 카드 에디터 (웹 도구) (msg `1546681659951153252`)

(23) **광 카드 에디터 — 웹 도구** (msg `1546681659951153252`)
  - `tools/gwang-editor/`: JSON File API/FSA load-save, card grid and overlays, edit/new/delete/download, image center-crop persisted as a data URL, and KO|EN toggle.
  - `game/ui/gwang_art.lua`: optional catalog `image` data URL decode, texture cache, centered cover crop, and gwang-slot star fallback.
  - `game/tests/gwang_art.lua` exercises mocked rendering plus LÖVE's real base64/FileData/ImageData decode pipeline.
  - `python3 -m unittest tools.test_gwang_editor -v` GREEN (42 tests); `make verify LOVE=/Users/jm/.local/bin/love` GREEN.

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
