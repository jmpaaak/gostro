# STATUS

## 2026-09-09 — 복합 광 고해상도 픽셀 에셋 적용

- `gwang.compound` 광 슬롯 아이템에 푸른 자개 점수 칩, 붉은 교차 비단 매듭, 네모 구멍 엽전을 하나의 순환 장치로 결합한 448×256 SVG/PNG master 및 56×32 runtime 에셋을 추가했다.
- Asset Studio `POST /api/pixel-perfect` 변환을 거쳐 bounds/alignment/palette 등의 검사를 통과했으며 manifest에 기록했다.
- manifest-backed 로더 회귀 테스트와 복합 광 5칸의 실제 LÖVE 320×180 캡처 QA를 통과했다.
- INBOX (27)은 모든 그래픽 요소의 런타임 에셋 전환을 진행 중이므로 처리 대기로 유지한다.
- `gwang.compound_burst`의 `idle`/`burst` 각 4프레임 실제 sprite-gen 요청을 Asset Studio에 보냈으나 Grok provider가 402(생성 잔액 부족)를 반환해 master/atlas를 적용하지 않았다. 정적 프레임 반복으로 대체하지 않는다.
- manifest에서 이미 `runtime`인 대장판 3종 및 광 5종이 inventory에서 미완료로 남은 불일치를 수정하고, `make verify`가 manifest의 전체 109개 ID와 체크 상태를 자동 대조하도록 했다.
- Next slice: `gwang.compound_burst` 복합 폭주 광 슬롯 아이템의 provider-backed sprite states/frames를 생성하고 Pixel Perfect 후처리·atlas/manifest 및 런타임 적용을 추가한다.
