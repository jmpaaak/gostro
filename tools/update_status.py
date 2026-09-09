from pathlib import Path
import datetime

content = Path("docs/STATUS.md").read_text()

today = datetime.datetime.now().strftime("%Y-%m-%d")

new_status = f"""## {today} — 기본 UI 버튼 고해상도 픽셀 에셋 적용 및 draw 모듈 분리

- `ui.btn_primary`, `ui.btn_secondary`, `ui.btn_danger`, `ui.btn_disabled` 4종 버튼의 400×120 고해상도 PNG master를 생성하고 100×30 runtime 에셋으로 변환(Pixel Perfect 검사 통과)하여 manifest에 추가했다.
- 런타임 배선 시 기존 모듈(`action_buttons.lua`)을 비대화하지 않도록, 9-slice 렌더링을 제공하는 `game/ui/button_art.lua` 모듈을 신규 분리했다.
- 플레이/버리기 버튼의 하드코딩된 도형 렌더링을 신설된 `button_art`로 교체하고 관련 테스트를 추가하여 `make verify`를 통과했다.
- INBOX (27)은 나머지 그래픽 요소가 미완료이므로 처리 대기로 유지한다.
- Next slice: 상점 패널(`ui.panel_wood` 등)이나 팩 등 미완료 UI 요소의 고해상도 master를 생성하고 manifest-backed 모듈로 교체한다.

"""

content = content.replace("# STATUS\n\n", "# STATUS\n\n" + new_status)
Path("docs/STATUS.md").write_text(content)
