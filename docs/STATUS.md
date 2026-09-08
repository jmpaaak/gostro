# STATUS

## 2026-09-09 — 초단 칩(Chodan Chips) 광 고해상도 픽셀 에셋 적용

- `gwang.chodan_chips` 광 슬롯 아이템에 짙은 녹색 옻칠, 추상화한 잎사귀 패턴과 3단 에메랄드 칩, 붉은 띠를 그린 448×256 SVG/PNG master 및 56×32 runtime 에셋을 추가했다.
- Asset Studio `POST /api/pixel-perfect` 변환을 거쳐 bounds/alignment/palette 등의 검사를 통과했으며 manifest에 기록했다.
- manifest-backed 로더 회귀 테스트와 초단 칩 광 5칸의 실제 LÖVE 320×180 캡처 QA(`make verify`)를 통과했다.
- INBOX (27)은 모든 그래픽 요소의 런타임 에셋 전환을 진행 중이므로 처리 대기로 유지한다.
- Next slice: `gwang.pi_yaku_mult` 피 족보 광 슬롯 아이템의 고해상도 픽셀 에셋을 생성하고 매니페스트 및 런타임 적용을 추가한다.
