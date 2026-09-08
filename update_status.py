import sys
import datetime

now = datetime.datetime.now().strftime("%Y-%m-%d %H:%M")
date_str = datetime.datetime.now().strftime("%Y-%m-%d")

new_status = f"""## {date_str} — 한국 테마 용어 계약 신설 및 일부 적용 (판/고)

- `game/terms.lua`를 신설하여 player-facing 용어(기원패, 부적, 판, 고 등) 단일 계약을 마련했다.
- UI 모듈(`blind_select.lua`, `shop.lua`)과 데이터(`gwang_jokers.json`)에서 '스몰/빅/보스 블라인드' 및 '앤티' 하드코딩 문자열을 `terms` 모듈과 한국어('첫판/큰판/대장판', 'n고')로 교체했다.
- TDD RED: `terms` 모듈 부재를 확인했다. 구현 후 `game/tests/terms.lua` 단위 테스트와 UI 텍스트 출력 검증이 GREEN이다.
- `make verify LOVE=/Users/jm/.local/bin/love` GREEN (209 files).
- INBOX (28)은 전체 도메인 적용이 남아 있어 처리 대기로 유지한다.
- Next slice: 나머지 player-facing Balatro 용어(Planet, Tarot, Tag, Voucher 등)를 `terms.lua`를 사용하여 기원패, 부적, 패찰, 인장으로 교체한다.

"""

with open("docs/STATUS.md", "r") as f:
    content = f.read()

# find the first ## 
parts = content.split("## ", 1)
if len(parts) > 1:
    new_content = parts[0] + new_status + "## " + parts[1]
else:
    new_content = content + "\n" + new_status

with open("docs/STATUS.md", "w") as f:
    f.write(new_content)

