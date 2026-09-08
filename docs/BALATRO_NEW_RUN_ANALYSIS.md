# Balatro New Run 실기기 역설계

이 문서는 추측이나 스토어 스크린샷이 아니라 Appium/WebDriverAgent(WDA)로 직접 조작한 결과만 관찰 사실로 기록한다. 관찰되지 않은 UI를 Gostro 구현 근거로 사용하지 않는다.

## 관찰 범위와 증거 규칙

- 기준 기기: 물리 iPhone Air, iOS 26.6.1
- 자동화: Appium 3.7.0 + XCUITest driver 12.10.0 + WDA
- 각 체크포인트는 터치 직전/직후 PNG, Appium page source, 수행한 동작을 한 묶음으로 남긴다.
- 캡처에는 `00-launch`, `01-new-run`, `02-deck-choice`, `03-stake-choice`, `04-blind-select`, `05-play`, `06-score`, `07-cash-out`, `08-shop`, `09-next-blind`처럼 순번을 붙인다.
- 화면에서 직접 확인하지 못한 요소는 아래 표에서 `미관찰`로 유지한다. 기존 `UI_BENCHMARK.md`는 비교 참고일 뿐 실기기 증거가 아니다.

## 2026-09-08 연결 사전 점검

실행 결과:

- macOS에서 USB 연결된 물리 기기를 `xctrace`와 `devicectl` 모두 인식했다.
- 기기는 부팅 완료, 페어링 완료, 잠금 해제 상태이며 암호 입력이 필요하지 않았다.
- 로컬 Appium 서버 `/status`는 `ready: true`를 반환했다.
- XCUITest driver가 설치된 것을 확인했다.
- 그러나 `devicectl device info apps`와 WDA 시작이 동일하게 RSD 할당 실패(`CoreDeviceError 4000`, `mobiledevice -402653181`)로 종료됐다.
- 따라서 이번 점검에서는 Balatro를 실행하거나 터치하거나 캡처하지 못했다. 실기기 UI 관찰 및 기기 QA를 완료했다고 간주하지 않는다.

재개 조건:

1. CoreDevice가 설치 앱 목록을 반환해야 한다.
2. 실제 Balatro bundle identifier를 설치 앱 목록에서 확인한다(추측한 식별자를 사용하지 않는다).
3. WDA 세션을 만든 뒤 스크린샷과 page source를 각각 1회 저장한다.
4. 위 조건이 충족된 뒤에만 `New Run` 터치를 시작한다.

## 체크포인트 관찰표

| 단계 | 확인할 내용 | 상태 | 증거 |
|---|---|---|---|
| 앱 시작 | 첫 화면의 정보 계층, `New Run` 위치와 터치 영역 | 미관찰 | WDA 연결 대기 |
| New Run | 화면 전환, 덱/난이도/시드 선택 순서 | 미관찰 | WDA 연결 대기 |
| 런 확정 | 선택 피드백, 확정/뒤로 버튼, 기본값 | 미관찰 | WDA 연결 대기 |
| 블라인드 선택 | 스몰/빅/보스 정보와 진입 동작 | 미관찰 | WDA 연결 대기 |
| 첫 핸드 | HUD, 카드 선택, 플레이/버리기 피드백 | 미관찰 | WDA 연결 대기 |
| 점수/클리어 | chips×mult 연출과 라운드 정산 전환 | 미관찰 | WDA 연결 대기 |
| 상점 | 상품, 돈, 리롤, 다음 라운드 동선 | 미관찰 | WDA 연결 대기 |

## Gostro 대조 및 구현 큐

실기기 관찰 전에는 품질 차이를 확정하지 않는다. 첫 증거 묶음이 확보되면 각 체크포인트마다 다음 형식으로 한 행씩 추가한다.

| 우선순위 | Balatro 직접 관찰 | Gostro 현재 동작 | 차이 | 담당 모듈 | 검증 |
|---|---|---|---|---|---|
| 미정 | 관찰 대기 | 대조 대기 | 확정하지 않음 | 독립 `game/ui/*` 또는 `game/*.lua` | `game/tests/*` + `make verify` |
