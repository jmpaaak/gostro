# STATUS

## 2026-09-09 — 피 족보(Pi Yaku) 광 고해상도 픽셀 에셋 적용

- `gwang.pi_yaku_mult` 광 슬롯 아이템에 자주색 옻칠, 화투형 피 패 3장과 배수 봉인 3개를 그린 448×256 SVG/PNG master 및 56×32 runtime 에셋을 추가했다.
- Asset Studio `POST /api/pixel-perfect` 변환을 거쳐 bounds/alignment/palette 등의 검사를 통과했으며 manifest에 기록했다.
- manifest-backed 로더 회귀 테스트와 피 족보 광 5칸의 실제 LÖVE 320×180 캡처 QA를 통과했다.
- 광 QA 번들에서 누락됐던 기존 `chodan-chips-v1.png` 복사 항목도 보완해 초단 칩 캡처가 실제 manifest 에셋을 그리도록 수정했다.
- INBOX (27)은 모든 그래픽 요소의 런타임 에셋 전환을 진행 중이므로 처리 대기로 유지한다.
- Next slice: `gwang.thin_deck_x3` 얇은 덱 광 슬롯 아이템의 고해상도 픽셀 에셋을 생성하고 매니페스트 및 런타임 적용을 추가한다.
