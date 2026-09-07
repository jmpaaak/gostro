# LANE SCOPE — main

This worktree is the only Gostro autonomous loop
(`/Users/jm/orca/workspaces/interactive-story-game-factory/gostro`). Process
`docs/feedback/INBOX.md` pending items from the top. Commit and push to
`main` after tests pass.

---

# Gostro autonomous development brief

## First priority

Build the playable hwatu deckbuilder specified in `docs/feedback/INBOX.md` and `docs/GAME_DESIGN.md`:

`play hand (dan/godori/pi) → score chips×mult → shop gwang jokers → next blind → ante 8`.

Gwang are jokers (slot passives, 1 point base). Play cards have **no month numbers**. Fake poker hands (mae/ppeok/otti) are forbidden.

**중요 — 재감사 방지 규칙:** 이번 사이클에서 처리할 INBOX 항목이 이미 이전 사이클에서 완료됐다고 판단되면, STATUS.md 업데이트 없이 즉시 다음 미완료 항목으로 넘어가라. \"이미 완료됐음을 재확인\"하는 문서 커밋을 반복하지 않는다. 할 일이 없으면 IDLE로 종료한다.
**중요 — FAIL + 미커밋 변경 규칙:** preflight가 FAIL이고 git status에 수정된 파일이 있으면, 이번 사이클의 유일한 작업은 (1) 실패한 테스트를 수정하고 (2) 모든 수정 파일을 커밋하는 것이다. 새 INBOX 항목 작업을 시작하지 않는다. 미커밋 변경을 버리지 않는다 — 이전 사이클이 절반만 완료한 것을 마저 끝낸다.

**중요 — 한 사이클 한 조각:** 큰 INBOX 항목을 한 사이클에 다 끝내려 하지 마라. 사이클당 검증 가능한 최소 단위 하나만 완료하고 커밋한다.
- 큰 기능: (a)/(b)/(c) 중 한 소항목, 또는 한 파일의 한 동작만. GREEN+커밋 전에 다음 소항목을 시작하지 마라.
- 이 사이클 턴 한도 안에 커밋할 수 없으면 범위를 더 줄여라. 미커밋으로 턴을 다 쓰는 것은 금지 — 중간이라도 동작하는 조각을 커밋하라.

**중요 — 거대 단일 파일 금지 + INBOX 최대 병렬 (2026-09-07):** 원본 `docs/MODULE_STRUCTURE.md`.
- 800줄/80KB를 넘는 Lua에 기능을 붙이지 마라. 그 사이클은 모듈 분리만. `play.lua`/`self_test.lua`/`main.lua`를 더 키우지 마라. 슬라이스 = 모듈 1개.
- 처리 대기를 **파일/모듈이 안 겹치는 단위로 최대로** 워크트리 병렬화한다. 겹치면 분리 후 병렬.
- JSON/`tools/`/순수 `game/*.lua`처럼 이미 독립인 항목은 모듈화를 기다리지 말고 즉시 WT.
- INBOX 항목에는 담당 모듈 경로를 적는다. 안 적으면 전부 `play.lua`에 붙어 1레인이 된다.

## Required workflow

1. Read only the pending feedback, game design, and current status needed for this cycle. Do not read `docs/STATUS.md` in full — latest `##` section plus next slice only.
   **TOKEN RULE: Do NOT read `docs/feedback/INBOX.md` in full. The cycle prompt already contains pending item titles. Read only the specific item you are implementing this cycle** (use offset/limit or search).
   **TOKEN RULE (large files):** Never `read_file` a source file ≥80KB without `offset`+`limit`. Use `search_files` then read ≤80 lines around the match.
2. Run `git status --short` before editing. Preserve and finish prior-cycle work; do not overwrite it.
3. If preflight reports FAIL, reproduce and fix that exact failure first.
4. Otherwise choose one small user-visible or state-machine slice from the top pending requirement.
5. Use test-driven development: add a failing engine-hosted test, observe RED, implement, then run focused GREEN tests. New tests live in `game/tests/<topic>.lua` (do not grow `game/self_test.lua`).
6. Run `make verify LOVE=/Users/jm/.local/bin/love` before a checkpoint commit.
7. Update `docs/STATUS.md` with verified facts for this cycle only and the exact next slice. Commit owned changes with a specific message. Push only after tests pass and the worktree is clean.
8. When an INBOX item is fully done, move it from `## 처리 대기` into `## 처리 완료` in the same commit with evidence. Do not move an item to 처리 완료 just because it was written down. Empty 처리 대기 is IDLE.

## Non-negotiable game rules

- Canvas starts at skeleton `320×180` nearest-neighbor. Do not switch to 720×1280 unless an INBOX item asks.
- Play cards: gwang ★ / hongdan red flag / cheongdan blue flag / chodan orchid / godori animal / pi. **No month numbers, no month names.**
- Hands: gwang = 1 point, hongdan, cheongdan, chodan, godori, pi. No mae / ppeok / otti / gwangyeol.
- Gwang = joker slots (shop, max 5). Never call them 고수패.
- Scoring is chips × mult. Antes follow Balatro (small/big/boss, ante 1→8).
- Card faces are type/shape/typo only. No people sprites. No month illustrations.

## Asset generation

- ComfyUI unused. PIL `tools/` ≤50 lines, or LÖVE `love.graphics` → PNG.
- Log applied assets in `docs/GENERATED_ASSET_LOG.md` (`YYYY-MM-DDTHH:MM:SS+0900 | <path> | <desc>`). Create the log file if missing.

## Safety and scope

- Work only in `/Users/jm/orca/workspaces/interactive-story-game-factory/gostro`.
- Do not access credentials or paid actions.
- Do not edit or stop the `spaceship` or `man-of-korea` loops.
- Do not claim device QA without an actual device result.
- One fresh cycle owns the checkout at a time; respect `loop/STOP`.
