# Balatro 핵심 기능 조사와 Gostro 적용 우선순위

> 갱신: 2026-09-08
>
> 목적: Balatro 실기기 화면을 사용할 수 없는 동안에도 핵심 게임 규칙 구현을 계속하기 위한 근거 문서다. 화면 좌표·애니메이션·세부 배치는 직접 관찰 전에는 확정하지 않는다.

## 근거 수준

- **규칙 확인:** Balatro Wiki의 관련 항목을 서로 대조한 메커니즘. 커뮤니티 문서이며 공식 사양서는 아니다.
- **직접 관찰:** `docs/BALATRO_NEW_RUN_ANALYSIS.md`와 `docs/evidence/`에 보존된 실제 앱 체크포인트.
- **미확정 UI:** 라이브 화면 없이 확인할 수 없는 위치·크기·애니메이션. 기능 모델과 분리한다.

## 검증된 핵심 런 루프

```text
새 런(덱 + Stake + 선택적 Seed)
→ Small Blind / Big Blind / Boss Blind
→ 라운드(hand·discard·유한 덱·목표 점수)
→ 승리 정산(보상 + 남은 hand + 이자)
→ 상점(상품·팩·바우처·리롤)
→ 다음 Blind
→ Boss 승리 후 다음 Ante
→ Ante 8 승리 / Endless 선택
```

- 한 Ante는 Small, Big, Boss 순서다.
- Small/Big은 Tag를 받고 건너뛸 수 있으나 Boss는 건너뛸 수 없다.
- Skip하면 해당 Blind의 플레이·정산·상점 방문을 모두 포기한다.
- 기본 라운드는 제한된 hands/discards와 유한한 draw/discard pile을 사용한다.
- 목표 미달 상태에서 hands가 0이 되면 런 패배다.
- 정산은 Blind 보상, 남은 hand 보상, 조건부 보상, 이자를 명시적으로 계산해야 한다.
- 상점 리롤은 랜덤 상품만 바꾸며 팩과 바우처는 유지된다. 같은 상점에서 리롤 비용이 증가한다.
- Boss 승리 시 Ante 진행과 바우처 보충이 원자적으로 처리돼야 한다.
- Ante 8의 최종 Boss 승리 후 승리를 기록하고 Endless 여부를 선택한다.

## New Run과 메타 진행

- 일반 런은 덱과 Stake를 각각 선택한다.
- Stake는 덱별로 독립 해금되며 상위 난이도는 하위 제약을 누적한다.
- Seed는 카드·상점·보스 등 런의 무작위 결과를 재현해야 한다.
- Seeded Run은 일반 해금·도전과제·대부분의 기록 진행 대상이 아니다.
- Challenge는 고정된 시작 조건과 금지/제약을 가진 별도 규칙 세트이며 일반 Stake 진행과 분리된다.
- Gostro는 우선 3개 패 구성과 확장 가능한 난이도 데이터 모델만 제공하고, 실제 효과와 메타 저장을 먼저 연결한다.

## Gostro 실제 연결 격차

| 우선순위 | 격차 | 현재 상태 | 구현 경로 |
|---|---|---|---|
| P0 | 유한 덱·draw/discard·hands 소진 패배 | `play.lua`가 `math.random`으로 패를 무한 보충 | `game/round_engine.lua` |
| P0 | 광 30종·행성·카드 에디션 득점 연결 | 규칙 모듈은 있으나 플레이 경로가 일부 보너스를 하드코딩 | `game/scoring_pipeline.lua` |
| P0 | 선택한 패 구성·Stake의 실제 효과 | 메뉴가 ID만 저장 | `game/run_rules.lua` |
| P1 | 시드 기반 통합 상점 | UI가 상품 생성과 `math.random`을 소유 | `game/shop_engine.lua` |
| P1 | Blind 순서·Skip·Tag | 세 Blind를 임의 선택 가능, Skip UI 없음 | `game/blind_flow.lua`, `game/tag_resolver.lua` |
| P1 | Voucher 효과 소비 | 여러 상태 필드가 라운드/상점/경제에서 미사용 | `game/voucher_effects.lua` |
| P2 | 저장/Continue/메타 해금 | Continue가 빈 상태, 잠금이 정적 | `game/run_snapshot.lua`, `game/profile_progress.lua` |
| P2 | 승리 후 Endless | 승리 텍스트만 존재 | 승리 선택 상태 모듈 |

## 구현 순서

1. `round_engine` + `scoring_pipeline` + `run_rules`를 독립 순수 모듈로 만든다.
2. `play.lua`는 require와 상태 위임만 추가해 실제 플레이 경로에 연결한다.
3. 한 Blind에서 실제 draw/discard/score/loss와 clear/shop 전이를 통합 테스트한다.
4. 다음으로 `shop_engine`을 연결해 Seed가 카드와 상점 모두를 재현하게 한다.
5. `blind_flow`와 Tag 이벤트 큐를 추가한다.
6. 저장·Continue·덱별 난이도 해금을 연결한다.
7. 기능 루프가 검증된 뒤에만 직접 관찰한 UI 세부를 다듬는다.

## UI 미확정 항목

다음은 실기기 또는 신뢰 가능한 영상 프레임을 직접 확인하기 전에는 Balatro와 동일하다고 주장하지 않는다.

- 플랫폼별 New Run 탭·카드·Stake 토큰의 정확한 좌표
- Seed 입력 필드의 정확한 전환 애니메이션
- 상점 카드/팩/바우처의 화면 배치와 드래그 피드백
- Cash Out 및 승리/Endless 화면의 애니메이션과 버튼 배치

## Sources

- [Gameplay rules](https://balatrowiki.org/w/Gameplay_rules)
- [Blinds and Antes](https://balatrowiki.org/w/Blinds_and_Antes)
- [Hands](https://balatrowiki.org/w/Hands)
- [Discards](https://balatrowiki.org/w/Discards)
- [Scoring / activation sequence](https://balatrowiki.org/w/Scoring)
- [Cash Out](https://balatrowiki.org/w/Cash_Out)
- [Interest](https://balatrowiki.org/w/Interest)
- [The Shop](https://balatrowiki.org/w/The_Shop)
- [Booster Packs](https://balatrowiki.org/w/Booster_Packs)
- [Vouchers](https://balatrowiki.org/w/Vouchers)
- [Tags](https://balatrowiki.org/w/Tags)
- [Decks](https://balatrowiki.org/w/Decks)
- [Stakes](https://balatrowiki.org/w/Stakes)
- [Seed](https://balatrowiki.org/w/Seed)
- [Challenge Decks](https://balatrowiki.org/w/Challenge_Decks)
