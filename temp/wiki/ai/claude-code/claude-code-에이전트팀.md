# Claude Code 에이전트 팀 (Agent Teams)

**출처**: https://code.claude.com/docs/ko/agent-teams | **날짜**: 2026-04-14

## 요약
에이전트 팀은 여러 Claude Code 인스턴스를 조율하는 실험적 기능으로, 팀원들이 공유 작업 목록을 가지고 서로 직접 메시지를 주고받으며 독립적으로 작동한다. Subagents가 결과만 메인에 보고하는 것과 달리, 팀원들은 peer-to-peer 통신이 가능하다.

> 기본 비활성화. `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` 환경변수로 활성화.
> Claude Code v2.1.32 이상 필요.

## Subagents vs 에이전트 팀 비교

|  | Subagents | 에이전트 팀 |
| --- | --- | --- |
| **컨텍스트** | 자신의 컨텍스트; 결과는 호출자에게 반환 | 자신의 컨텍스트; 완전히 독립적 |
| **통신** | 메인 에이전트에게만 결과 보고 | 팀원들이 서로 직접 메시지 전송 |
| **조율** | 메인 에이전트가 모든 작업 관리 | 자체 조율, 공유 작업 목록 |
| **최적 용도** | 결과만 중요한 집중 작업 | 논의와 협업이 필요한 복잡한 작업 |
| **토큰 비용** | 낮음 | 높음: 각 팀원이 별도 Claude 인스턴스 |

## 최적 사용 사례
- **연구 및 검토**: 여러 팀원이 동시에 다양한 측면 조사 후 결과 공유/토론
- **새 모듈/기능 개발**: 팀원들이 각각 별도 파트 담당 (서로 간섭 없음)
- **경쟁 가설로 디버깅**: 다양한 이론을 병렬로 테스트해 빠르게 수렴
- **교차 계층 조율**: 프론트엔드/백엔드/테스트 변경, 각각 다른 팀원 담당

> 순차적 작업, 동일 파일 편집, 많은 종속성이 있는 작업은 단일 세션 또는 Subagents가 더 효과적.

## 팀 활성화 및 시작

```json
// settings.json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

팀 생성 예시 (자연어로 요청):
```text
I'm designing a CLI tool that helps developers track TODO comments across
their codebase. Create an agent team to explore this from different angles:
one teammate on UX, one on technical architecture, one playing devil's advocate.
```

## 팀 제어

### 표시 모드
- **In-process**: 메인 터미널에서 모든 팀원 실행. `Shift+Down`으로 순환, 직접 타이핑으로 메시지 전송
- **분할 창**: 각 팀원이 별도 창. tmux 또는 iTerm2 필요

기본값 `"auto"` — tmux 세션 내에서 실행 중이면 분할 창, 아니면 in-process.

```json
// ~/.claude.json
{
  "teammateMode": "in-process"
}
```

### 팀원 및 모델 지정
```text
Create a team with 4 teammates to refactor these modules in parallel.
Use Sonnet for each teammate.
```

### 계획 승인 요구
복잡하거나 위험한 작업에서 구현 전 계획 검토:
```text
Spawn an architect teammate to refactor the authentication module.
Require plan approval before they make any changes.
```

### 작업 할당
공유 작업 목록으로 조율. 작업 상태: 대기 중 → 진행 중 → 완료.
- **리더 할당**: 특정 팀원에게 작업 지정
- **자체 요청**: 작업 완료 후 팀원이 다음 미할당 작업 자체 선택

파일 잠금으로 경합 조건 방지.

### 팀 정리
```text
Clean up the team
```

## 알려진 제한 사항

실험적 기능이므로 실사용 전 반드시 확인:

- **In-process 팀원과의 세션 재개 없음**: `/resume`과 `/rewind`는 in-process 팀원을 복원하지 않는다. 세션 재개 후 리더가 더 이상 존재하지 않는 팀원에게 메시지를 보내려 할 수 있음 → 리더에게 새 팀원 생성 지시 필요.
- **작업 상태 지연**: 팀원이 때때로 작업을 완료로 표시하지 못해 종속 작업이 차단될 수 있음. 막혀 있으면 실제 완료 여부 확인 후 수동으로 상태 업데이트.
- **종료 지연**: 팀원은 현재 요청이나 도구 호출을 마친 후에야 종료되므로 즉시 종료되지 않을 수 있음.
- **세션당 한 팀**: 리더는 한 번에 한 팀만 관리 가능. 새 팀 시작 전 현재 팀 정리 필요.
- **중첩된 팀 불가**: 팀원은 자신의 팀이나 팀원을 생성할 수 없음. 리더만 팀 관리 가능.
- **리더 고정**: 팀을 만든 세션이 수명 동안 리더. 팀원을 리더로 승격하거나 리더십 이전 불가.
- **고아 tmux 세션**: 팀 종료 후 tmux 세션이 지속되면 수동 정리 필요 (`tmux ls` → `tmux kill-session -t <name>`).

## 관련 항목
- [[wiki/ai/claude-code/claude-code-서브에이전트-커스텀]]
- [[wiki/ai/claude-code/claude-code-확장기능-개요]]
- [[wiki/ai/claude-code/claude-code-작동원리-에이전틱루프]]
- [[wiki/ai/claude-code/claude-code-권한모드]]
