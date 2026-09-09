# STATUS

## 2026-09-09 — 갑부(Wealthy) 광 고해상도 픽셀 에셋 적용

- `gwang.wealthy_x2` 광 슬롯 아이템에 자색 옻칠, 동전이 가득 찬 쌍둥이 기와 창고와 두 개의 비취 행운 인장을 그린 448×256 SVG/PNG master 및 56×32 runtime 에셋을 추가했다.
- Asset Studio `POST /api/pixel-perfect` 변환을 거쳐 bounds/alignment/palette 등의 검사를 통과했으며 manifest에 기록했다.
- manifest-backed 로더 회귀 테스트와 갑부 광 5칸의 실제 LÖVE 320×180 캡처 QA를 통과했다.
- INBOX (27)은 모든 그래픽 요소의 런타임 에셋 전환을 진행 중이므로 처리 대기로 유지한다.
- Next slice: `gwang.boss_x2` 보스 배수 광 슬롯 아이템의 고해상도 픽셀 에셋을 생성하고 매니페스트 및 런타임 적용을 추가한다.
