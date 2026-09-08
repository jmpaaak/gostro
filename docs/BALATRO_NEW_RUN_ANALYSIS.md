# Balatro New Run 실기기 역설계

이 문서는 스토어 스크린샷이나 추측이 아니라 물리 iPhone에서 Appium/WebDriverAgent(WDA)로 직접 조작해 확인한 내용만 기록한다. 관찰하지 않은 화면은 Gostro 구현 근거로 사용하지 않는다.

## 관찰 환경과 범위

- 기기: 물리 iPhone Air, iOS 26.6.1
- 앱: Balatro Premium 1.0.19(50), bundle id `com.playstack.balatropremium`
- 자동화: Appium 3.7.0 + XCUITest driver 12.10/12.11 + 서명된 preinstalled WDA
- WDA viewport: 874×402 logical points, screenshot: 2736×1260 pixels
- 검증 방식: W3C `pointerType: touch` action의 성공 응답과 터치 전후 화면 변화를 함께 확인
- 사용자 요청으로 iPhone 연결은 New Run 덱 선택 관찰 뒤 종료했다. 블라인드 이후는 미관찰 상태다.

## 연결 교훈

- 초기 `CoreDeviceError 4000` / `mobiledevice -402653181`은 USB 재연결과 RemoteXPC 터널 재생성 후 복구됐다.
- iOS Developer App 신뢰 뒤 preinstalled WDA 세션과 실제 터치가 성공했다.
- Gostro 자동 루프가 동일 Appium 서버에 두 번째 세션을 만들며 WDA를 덮어설치·종료해 신뢰 확인이 반복됐다. 항목을 `처리 중`으로 옮기고 경쟁 루프를 중단한 뒤 단일 WDA 세션을 유지했다.
- 사용자 요청 이후 Appium, WDA keepalive, RemoteXPC tunnel/registry를 모두 종료했다.

## 직접 관찰

### 1. 앱 랜딩

- 중앙의 큰 `PLAY`가 최상위 행동이다.
- `Collection`, `Options`, `Quit`은 더 작은 보조 버튼이다.
- 프로필과 언어는 화면 가장자리의 작은 유틸리티 컨트롤로 분리된다.
- 즉시 게임에 들어가지 않고 명시적인 진입 단계를 한 번 둔다.

### 2. PLAY 패널

- `PLAY` 터치 후 중앙 패널로 전환된다.
- 상단에는 `New Run`, `Continue`, `Challenges`가 **가로 탭**으로 배치된다. 세로 버튼 스택이 아니다.
- 선택된 탭 위에는 작은 빨간 삼각형 표시가 있다.
- 활성 런이 있는 관찰 기기에서는 `Continue`가 기본 선택됐다.
- Continue 콘텐츠에는 `Blue Deck`, `White Stake`, 현재 진행 정보, 큰 `PLAY`, 넓은 `Back`이 보였다.
- 탭은 상단 내비게이션이고, 선택한 탭에 따라 아래 콘텐츠 패널이 교체되는 구조다.

### 3. New Run — 덱·난이도·시드 설정

- `New Run` 탭을 누르면 같은 패널 안에서 설정 콘텐츠가 교체된다.
- 상단 덱 영역은 큰 카드/덱 아트, 설명 영역, 좌우의 큰 빨간 화살표, 하단 페이지 점으로 구성된다.
- 잠긴 덱은 카드 위 자물쇠와 `Locked` 제목을 표시하고, `Win a run with any deck on at least Blue Stake difficulty`처럼 해금 조건을 명시한다.
- 덱 화살표를 누르면 페이지 점과 잠금 조건이 함께 바뀌었다. 다른 잠금 덱에서는 조건이 `Black Stake`로 바뀌어 선택 상태 변화가 즉시 읽혔다.
- 난이도 행에는 `White Stake`와 `Base Difficulty`, 좌우 화살표가 있다. 관찰된 상태에서는 기본 난이도였다.
- 하단에는 `Seeded Run` 토글, 중앙 `PLAY`, 넓은 주황색 `Back`이 있다.
- 선택 덱이 잠겨 있으면 `PLAY`가 회색으로 비활성화된다. 잠금 조건 자체가 선택 실패 사유를 설명하므로 별도 추측이 필요 없다.
- New Run은 즉시 블라인드로 들어가지 않는다. 덱/난이도/시드 확인 후 활성화된 `PLAY`가 런 확정 행동이다.

## 체크포인트 관찰표

| 단계 | 직접 확인한 내용 | 상태 |
|---|---|---|
| 앱 랜딩 | 큰 `PLAY`, 작은 Collection/Options/Quit, 가장자리 프로필·언어 | 관찰 |
| PLAY 패널 | 가로 New Run/Continue/Challenges 탭, 선택 삼각형, 탭별 콘텐츠 | 관찰 |
| Continue | Blue Deck, White Stake, 진행 정보, PLAY, Back | 관찰 |
| New Run | 덱 캐러셀, 잠금 조건, 페이지 점, 난이도 행, Seeded Run, PLAY/Back | 관찰 |
| 덱 변경 | 화살표 입력에 따라 페이지 점·잠금 조건 즉시 변경 | 관찰 |
| 런 확정 | 잠긴 덱에서 PLAY 비활성 | 부분 관찰 |
| 해금 덱 PLAY | 활성 PLAY와 전환 피드백 | 미관찰 |
| 블라인드 선택 이후 | 스몰/빅/보스 정보와 진입 | 미관찰 |
| 첫 핸드 | HUD, 카드 선택, 플레이/버리기 | 미관찰 |
| 점수/클리어 | 점수 연출과 정산 | 미관찰 |
| 상점 | 상품, 돈, 리롤, 다음 라운드 | 미관찰 |

## Gostro 대조 및 순차 구현 큐

| 우선순위 | 관찰된 구조 | 기존/초기 Gostro | Gostro 대응 | 상태 |
|---|---|---|---|---|
| 1 | 랜딩의 큰 PLAY | 실행 즉시 블라인드 선택 | 큰 `게임 시작` 랜딩과 메뉴 씬 | 구현·테스트 GREEN |
| 2 | 가로 3탭 + 선택 표시 | 세로 3버튼으로 잘못 구현 | `새 게임/계속하기/도전` 가로 탭과 탭 콘텐츠 셸 | 구현 중 |
| 3 | New Run 덱 캐러셀 | 새 게임이 즉시 블라인드로 이동 | 화투 시작 패 캐러셀, 좌우 화살표, 페이지 점 | 구현 중 |
| 4 | 잠금 카드 + 해금 조건 + PLAY 비활성 | 없음 | 잠금 사유 명시, 잠금 상태에서 시작 차단 | 구현 중 |
| 5 | 난이도 행 + Seeded Run | 시드 UI는 게임 HUD에만 존재 | 기본 난이도 행, 시드 토글/입력, 런 생성 시 시드 전달 | 구현 중 |
| 6 | Continue 탭 콘텐츠 | 활성 런 저장 없음 | 실제 저장 모델이 생길 때까지 명시적 준비 중 상태 | 보류 |
| 7 | Challenges 탭 콘텐츠 | 도전 모드 없음 | 새 런으로 위장하지 않고 준비 중 상태 | 보류 |
| 8 | 블라인드 이후 | 미관찰 | 기존 구현 유지, 새 관찰 전 추측 변경 금지 | 보류 |

## 구현 원칙

- Balatro의 정보 계층과 피드백 구조만 참고하고, 비주얼은 화투·한글·Galmuri 픽셀 스타일로 Gostro 정체성을 유지한다.
- hover에 의존하지 않고 큰 press/touch 영역을 사용한다.
- `game/scenes/play.lua`에 새 UI를 붙이지 않고 `game/ui/*`와 별도 씬으로 분리한다.
- 각 슬라이스는 순수 상태/hit-test 테스트, 씬 라우팅 테스트, 전체 `make verify LOVE=/Users/jm/.local/bin/love`를 통과해야 완료된다.
