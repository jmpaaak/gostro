# Balatro New Run 실기기 역설계

이 문서는 추측이나 스토어 스크린샷이 아니라 직접 조작한 결과만 관찰 사실로 기록한다. 관찰되지 않은 UI를 Gostro 구현 근거로 사용하지 않는다.

## 관찰 범위와 증거 규칙

- 기준 기기: 물리 iPhone Air, iOS 26.6.1
- 자동화 경로: Appium 3.7.0 + XCUITest driver 12.10.0 + WDA
- 각 후속 체크포인트는 터치 직전/직후 PNG, Appium page source, 수행한 동작을 한 묶음으로 남긴다.
- 후속 캡처에는 `00-launch`, `01-new-run`, `02-deck-choice`, `03-stake-choice`, `04-blind-select`, `05-play`, `06-score`, `07-cash-out`, `08-shop`, `09-next-blind`처럼 순번을 붙인다.
- 화면에서 직접 확인하지 못한 요소는 아래 표에서 `미관찰`로 유지한다. 기존 `UI_BENCHMARK.md`는 비교 참고일 뿐 실기기 증거가 아니다.

## 2026-09-08 연결 사전 점검

실행 결과:

- macOS에서 USB 연결된 물리 기기를 `xctrace`와 `devicectl` 모두 인식했다.
- 기기는 부팅 완료, 페어링 완료, 잠금 해제 상태이며 암호 입력이 필요하지 않았다.
- 로컬 Appium 서버 `/status`는 `ready: true`를 반환했다.
- XCUITest driver가 설치된 것을 확인했다.
- 그러나 당시 `devicectl device info apps`와 WDA 시작이 동일하게 RSD 할당 실패(`CoreDeviceError 4000`, `mobiledevice -402653181`)로 종료됐다.
- 따라서 이 사전 점검 자체에서는 Balatro를 실행하거나 터치하거나 캡처하지 못했다.

## 2026-09-08 연결 복구와 앱 식별

- 사용자 CoreDeviceService 재시작 뒤 설치 앱 조회가 정상화됐다.
- 실기기 설치 목록에서 Balatro 1.0.19(50)의 bundle identifier `com.playstack.balatropremium`을 확인했다.
- `devicectl` 앱 실행은 성공했지만 WDA는 development team 미설정(code 65)으로 아직 세션을 열지 못했다. 따라서 PNG/page source 증거 묶음은 후속 과제로 남는다.

## 직접 관찰된 첫 두 체크포인트

### 1. 랜딩

- 첫 화면의 최상위 행동은 크고 독립적인 `PLAY` 버튼이다.
- 작은 보조 동작보다 `PLAY`가 크기와 배치로 먼저 읽히며, 터치로 다음 상태에 진입한다.

### 2. PLAY 서브메뉴

- `PLAY` 터치 직후 같은 흐름에서 메뉴가 즉시 바뀐다.
- 행동은 위에서부터 `New Run`, `Continue`, `Challenges`의 세 버튼으로 세로 배치된다.
- `New Run`은 파랑, `Continue`는 빨강, `Challenges`는 주황으로 구분되며 크기·색 대비가 강하다.

`New Run`을 누른 뒤의 덱 선택 화면은 아직 직접 관찰하지 않았다. 덱 종류, 난이도, 시드, 기본 선택값 또는 확정 동작을 이번 슬라이스의 근거로 주장하지 않는다.

## 체크포인트 관찰표

| 단계 | 직접 확인한 내용 | 상태 | 근거 범위 |
|---|---|---|---|
| 앱 랜딩 | 큰 단일 `PLAY`가 최상위 행동 | 관찰 | 직접 화면 확인 |
| PLAY 서브메뉴 | `New Run`(파랑) / `Continue`(빨강) / `Challenges`(주황), 세로 스택, 즉시 전환 | 관찰 | `PLAY` 직접 터치 전후 확인 |
| New Run 이후 | 덱/난이도/시드 선택 순서 | 미관찰 | 후속 실기기 관찰 필요 |
| 런 확정 | 선택 피드백, 확정/뒤로 버튼, 기본값 | 미관찰 | 후속 실기기 관찰 필요 |
| 블라인드 선택 | 스몰/빅/보스 정보와 진입 동작 | 미관찰 | 후속 실기기 관찰 필요 |
| 첫 핸드 | HUD, 카드 선택, 플레이/버리기 피드백 | 미관찰 | 후속 실기기 관찰 필요 |
| 점수/클리어 | chips×mult 연출과 라운드 정산 전환 | 미관찰 | 후속 실기기 관찰 필요 |
| 상점 | 상품, 돈, 리롤, 다음 라운드 동선 | 미관찰 | 후속 실기기 관찰 필요 |

## Gostro 대조 및 구현 큐

구현 전 Gostro는 앱 시작 시 곧바로 `PlayScene`의 `blind_select`를 표시해, 랜딩과 명시적인 새 런 진입 단계가 없었다.

| 우선순위 | Balatro 직접 관찰 | 기존 Gostro | 구현한 Gostro 대응 | 담당 모듈 | 검증 |
|---|---|---|---|---|---|
| 1 | 큰 단일 `PLAY` | 즉시 블라인드 선택 | 320×180 랜딩의 큰 `게임 시작` 버튼 | `game/ui/main_menu.lua`, `game/scenes/menu.lua`, `main.lua` | 순수 hit-test/state + 씬 라우팅 테스트 |
| 2 | 세로 `New Run` / `Continue` / `Challenges`, 파랑/빨강/주황 | 해당 메뉴 없음 | `새 게임` / `계속하기` / `도전` 세로 버튼과 즉시 상태 전환 | `game/ui/main_menu.lua` | 버튼 순서·크기·비중첩·행동 테스트 |
| 3 | `New Run`으로 새 흐름 진입 | 부팅 자체가 새 런 | `새 게임`만 scene stack을 통해 새 `PlayScene`으로 교체 | `game/scenes/menu.lua` | 실제 `blind_select` 새 씬 확인 |
| 4 | 후속 화면 미관찰 | 기존 블라인드 선택 구현 존재 | `계속하기`와 `도전`은 메뉴에 머물며 `준비 중` 피드백; New Run으로 위장하지 않음 | `game/ui/main_menu.lua` | 명시적 non-transition action 테스트 |

이번 대응은 한글 레이블, 화투 꽃 인장, Galmuri 픽셀 폰트로 Gostro 정체성을 유지한다. hover 상태에 의존하지 않고 모든 행동은 큰 터치 영역의 press로 작동한다. 후속 UI는 직접 관찰한 다음 별도 슬라이스로 추가한다.
