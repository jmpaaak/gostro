# STATUS
## 2026-09-10 — Full card-ratio gwang row and shared play layout
- Added pure `game/ui/play_layout.lua` as the geometry owner for gwang slots, scoreboard, consumables, origin cards, and run HUD; `play.lua` is unchanged.
- Gwang slots now match play cards at 72×108, with all persistent HUD chrome shifted below the taller row.
- Added engine-hosted cross-region geometry coverage; `make test LOVE=/Users/jm/.local/bin/love` GREEN.
- INBOX (45) moved to 처리 완료.
- Next slice: 처리 대기 empty -> IDLE

## 2026-09-10 — Scoreboard and center popup share one timeline
- `scoreboard.sync_anim` derives both the running blind tally and center popup value from `score_anim.displayed_total`.
- The popup remains live throughout the total phase and starts its fade timer only after the animation reaches done.
- `make test LOVE=/Users/jm/.local/bin/love` GREEN.
- INBOX (43) moved to 처리 완료.
- Next slice: 처리 대기 empty -> IDLE

## 2026-09-10 — Discarded cards slide off to the right
- Selected discards slide off-screen to the right (`hand.start_discard_slide`) before the engine redeals.
- Play scene waits for the slide, then consumes the discard and refills the fan.
- `make test LOVE=/Users/jm/.local/bin/love` GREEN.
- INBOX (42) moved to 처리 완료.
- Next slice: 처리 대기 empty -> IDLE

## 2026-09-10 — Score sync, shop money tween, gwang slot size
- Scoreboard chips/mult follow score_anim phases; popup and countup wait until total/done.
- Shop $ readout tweens on buy via `sync_money`; gwang slots are 72×96 and HUD chrome shifted below.
- `make test LOVE=/Users/jm/.local/bin/love` GREEN.
- INBOX (39) moved to 처리 완료.
- Next slice: 처리 대기 empty -> IDLE

## 2026-09-10 — Shop hover ignores sold slots
- Unsold shop slots still lift 8px and gold-emphasize price on hover.
- Buying a slot (or pointing at a sold one) now clears hover so the empty card does not keep floating.
- `make test LOVE=/Users/jm/.local/bin/love` GREEN.
- Next slice: 처리 대기 empty -> IDLE

## 2026-09-10 — Hover lift, chips-to-mult anim, and round HUD
- Added hover states to hand cards (`M.HOVER_LIFT` in `card.lua`) via `mousemoved`.
- Bound `scoring_pipeline` results to `score_anim.lua`, rendering chips, mult, and total floating over actual card coordinates.
- Added Run Info (Round HUD) to the right side of the play screen showing Ante, Blind, Money, and Remaining Deck.
- `make test LOVE=/Users/jm/.local/bin/love` GREEN.
- INBOX (35) completion: Hover lift, scoring animation, and round HUD implemented.
- Next slice: 처리 대기 empty -> IDLE

## 2026-09-10 — Balatro-style play HUD preview and unclip overlapping chrome
- Scoreboard moved to the left, Play/Discard buttons split around the hand, Seed field moved left of Gwang slots.
- Hand selection now previews the level name, chip, and multiplier (non-destructive test of `scoring_pipeline`).
- Level UI displays under the scoreboard (only if level >= 2).
- `make test LOVE=/Users/jm/.local/bin/love` GREEN.
- INBOX (34) completion: Play HUD spacing and preview alignment implemented.
- Next slice: INBOX (35) - 발라트로급 플레이 디테일: 호버·점수 연출·고/판/돈 HUD

## 2026-09-09 — Batch capture QA so verify finishes under 120s
- Preflight FAIL was `make verify LOVE=/Users/jm/.local/bin/love` timing out after 120s, not a unit assertion.
- Sequential Love launches for shop-pack, gwang-slot, tag, and blind-card captures exceeded the cycle preflight budget.
- Refactored `tools/run_verify.sh` to run `qa/batch_capture.lua` (one LÖVE launch) instead of individual scripts.
- Batch launch drops `make verify` time from 140s to ~20s.
- `make test LOVE=/Users/jm/.local/bin/love` GREEN.
- Next slice: INBOX (34) - 발라트로급 플레이 디테일: 진행 안내·선택 점수·겹침 방지 (HUD 배치)

## 2026-09-09 — 상점 배경 고해상도 픽셀 에셋 적용
- `ui.shop_bg`에 1920×1080 목재 텍스처 배경 PNG master와 960×540 runtime 에셋을 추가했다.
- Asset Studio 실제 `POST /api/pixel-perfect` 변환 보고서의 dimensions/alignment/palette/transparentAlpha/nearestNeighbor 검사를 모두 통과했다.
- 상점 씬(`game/scenes/shop.lua`) 배경 렌더링에 적용하고 LÖVE 960×540 창 모드 확인과 단위 테스트를 통과했다.
- INBOX (27) 고해상도 에셋 전환 작업 중 배경(bg) 파트를 완료했다.
- Next slice: 메인 메뉴 배경(`ui.menu_bg`) 고해상도 master를 실제 Pixel Perfect runtime으로 변환하고 적용한다.

## 2026-09-09 — 메인 메뉴 배경 고해상도 픽셀 에셋 적용
- `ui.menu_bg`에 1920×1080 청색 그라데이션 및 문양 배경 PNG master와 960×540 runtime 에셋을 추가했다.
- Asset Studio 실제 `POST /api/pixel-perfect` 변환 보고서의 dimensions/alignment/palette/transparentAlpha/nearestNeighbor 검사를 모두 통과했다.
- 메인 메뉴 씬(`game/ui/main_menu.lua`, `game/ui/run_setup.lua` 포함) 배경 렌더링에 적용하고 엔진 테스트를 통과했다.
- INBOX (27) 고해상도 에셋 전환 작업 중 배경(bg) 파트를 완료했다.
- Next slice: 부적 대상 선택 오버레이 등 기타 패널의 고해상도 픽셀 에셋 전환 작업을 진행한다.

> Older cycle history lives in `docs/STATUS_HISTORY.md`. Only search it when tracking a specific past bug; do not read it by default.
