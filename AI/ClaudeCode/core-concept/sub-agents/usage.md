# Sub-agent 사용하기

> 출처: https://code.claude.com/docs/en/sub-agents

## 한 눈에 보기

Claude는 작업 설명과 Sub-agent의 `description` 필드를 비교해 자동으로 위임을 결정한다. 명시적으로 호출할 때는 자연어, @-멘션, `--agent` 플래그 3가지 방법이 있다. Sub-agent는 포그라운드(차단) 또는 백그라운드(병렬) 중 하나로 실행된다.

## 자동 위임

Claude는 다음을 분석해 위임 여부를 결정한다:

- 사용자 요청의 작업 설명
- Sub-agent의 `description` 필드
- 현재 대화 컨텍스트

Sub-agent가 적극적으로 사용되기를 원한다면 `description`에 `"Use proactively"` 같은 표현을 포함시킨다.

## 명시적 호출

자동 위임이 충분하지 않을 때 직접 Sub-agent를 지정할 수 있다.

### 자연어

Sub-agent 이름을 요청에 포함하면 Claude가 위임 여부를 판단한다.

```
Use the test-runner subagent to fix failing tests
Have the code-reviewer subagent look at my recent changes
```

### @-멘션

`@`를 입력해 타입어헤드에서 Sub-agent를 선택하거나 직접 입력한다. 이 방법은 Claude의 판단 없이 지정한 Sub-agent가 반드시 실행된다.

```
@"code-reviewer (agent)" look at the auth changes
```

전체 메시지는 Claude에게 전달되고, Claude가 그 내용을 바탕으로 Sub-agent에 전달할 프롬프트를 작성한다. @-멘션은 Claude가 어떤 Sub-agent를 호출할지를 결정할 뿐, Sub-agent가 받는 프롬프트 내용을 직접 제어하지는 않는다.

- 플러그인이 제공하는 Sub-agent: `@agent-<plugin-name>:<agent-name>`
- 현재 세션에서 백그라운드로 실행 중인 Sub-agent도 타입어헤드에 상태와 함께 표시됨

### 세션 전체 적용 (`--agent` 플래그)

`--agent <name>` 플래그로 세션 전체를 특정 Sub-agent의 시스템 프롬프트, 도구 제한, 모델로 실행한다.

```bash
claude --agent code-reviewer
```

이 모드에서는 Sub-agent의 시스템 프롬프트가 기본 Claude Code 시스템 프롬프트를 완전히 대체한다. `CLAUDE.md`와 프로젝트 메모리는 정상적으로 로드된다. 시작 헤더에 `@<name>` 형식으로 활성 에이전트가 표시된다.

프로젝트 기본값으로 설정하려면 `.claude/settings.json`에 추가한다:

```json
{
  "agent": "code-reviewer"
}
```

CLI 플래그가 설정 파일보다 우선 적용된다.

## 포그라운드 vs 백그라운드

### 포그라운드

- 완료될 때까지 메인 대화를 차단
- 권한 요청과 질문(`AskUserQuestion`)이 사용자에게 전달됨

### 백그라운드

- 사용자가 계속 작업하는 동안 병렬로 실행
- 시작 전에 필요한 도구 권한을 미리 승인
- 실행 중 추가 권한이 필요하면 자동 거부 (미리 승인된 도구만 사용 가능)
- `AskUserQuestion` 같은 질문 도구는 실패하지만 Sub-agent는 계속 실행됨

백그라운드 Sub-agent가 권한 부족으로 실패하면, 동일 작업을 포그라운드로 다시 시작해 대화형 승인을 받을 수 있다.

백그라운드 실행 방법:
- 요청에 "run this in the background" 포함
- 실행 중인 작업에서 **Ctrl+B** 단축키

백그라운드 작업 기능 전체를 비활성화하려면: `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS=1` 환경변수 설정.

## 공통 패턴

### 대용량 출력 격리

테스트 실행, 로그 처리, 문서 조회 등 출력이 많은 작업은 Sub-agent에 위임해 메인 대화 컨텍스트를 보호한다.

```
Use a subagent to run the test suite and report only the failing tests with their error messages
```

Sub-agent의 장황한 출력은 Sub-agent 컨텍스트에만 남고, 메인 대화에는 요약만 반환된다.

### 병렬 리서치

독립적인 조사 작업을 여러 Sub-agent에 동시에 위임한다.

```
Research the authentication, database, and API modules in parallel using separate subagents
```

각 Sub-agent가 독립적으로 영역을 탐색한 뒤 Claude가 결과를 종합한다. 조사 경로가 서로 의존하지 않을 때 효과적이다.

> Sub-agent 결과가 모두 메인 대화로 돌아오므로, 각각의 결과가 상세할수록 컨텍스트 소비가 크다. 지속적인 병렬 작업이나 컨텍스트 한계를 초과하는 경우에는 [Agent Teams](https://code.claude.com/docs/en/agent-teams) 사용을 고려한다.

### Sub-agent 체이닝

순차적 다단계 작업에서 각 Sub-agent가 결과를 반환하면 Claude가 다음 Sub-agent에 전달한다.

```
Use the code-reviewer subagent to find performance issues, then use the optimizer subagent to fix them
```

## 메인 대화 vs Sub-agent 선택 기준

**메인 대화를 사용할 때:**

- 잦은 질의응답이나 반복적인 수정이 필요한 작업
- 여러 단계가 컨텍스트를 공유해야 할 때 (계획 → 구현 → 테스트)
- 빠르고 간단한 변경
- 응답 속도가 중요할 때 (Sub-agent는 컨텍스트를 새로 구성하므로 느릴 수 있음)

**Sub-agent를 사용할 때:**

- 장황한 출력이 메인 컨텍스트에 필요 없을 때
- 특정 도구 제한이나 권한을 강제해야 할 때
- 독립적으로 처리하고 요약만 반환하면 될 때

메인 대화 컨텍스트에서 재사용 가능한 프롬프트나 워크플로를 원한다면 [Skills](https://code.claude.com/docs/en/skills)를 고려한다. 대화에 이미 있는 내용에 대한 빠른 질문이라면 [`/btw`](https://code.claude.com/docs/en/interactive-mode#side-questions-with-btw)를 사용한다 (도구 접근 없이 전체 컨텍스트를 볼 수 있고, 대화 기록에 남지 않음).

> Sub-agent는 다른 Sub-agent를 생성할 수 없다. 중첩 위임이 필요한 워크플로는 Skills 또는 메인 대화에서의 체이닝으로 구성한다.

## 컨텍스트 관리

### Sub-agent 재개(Resume)

각 Sub-agent 호출은 새로운 인스턴스를 생성하는 것이 기본이다. 이전 작업을 이어받으려면 Claude에게 재개를 요청한다.

```
Use the code-reviewer subagent to review the authentication module
[Sub-agent 완료]

Continue that code review and now analyze the authorization logic
[Claude가 이전 전체 대화 기록을 가진 Sub-agent를 재개]
```

재개된 Sub-agent는 이전의 도구 호출, 결과, 추론 과정을 포함한 전체 대화 기록을 유지한 채로 정확히 멈춘 지점부터 계속한다.

Sub-agent 트랜스크립트 위치: `~/.claude/projects/{project}/{sessionId}/subagents/agent-{agentId}.jsonl`

트랜스크립트 특성:
- **메인 대화 컴팩션과 독립적**: 메인 대화가 압축되어도 Sub-agent 트랜스크립트는 영향받지 않음
- **세션 내 지속**: 세션을 재시작해도 동일 세션을 재개하면 Sub-agent를 다시 불러올 수 있음
- **자동 정리**: `cleanupPeriodDays` 설정에 따라 자동 삭제 (기본값: 30일)

> Sub-agent 재개는 `SendMessage` 도구를 통해 이루어지며, 이 도구는 `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` 환경변수로 Agent Teams가 활성화된 경우에만 사용 가능하다.

### 자동 컴팩션(Auto-compaction)

Sub-agent는 메인 대화와 동일한 자동 컴팩션 로직을 지원한다. 기본값으로 컨텍스트의 약 95%에 도달하면 컴팩션이 시작된다. `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` 환경변수로 더 낮은 임계값을 설정할 수 있다.

컴팩션 이벤트는 트랜스크립트 파일에 기록된다:

```json
{
  "type": "system",
  "subtype": "compact_boundary",
  "compactMetadata": {
    "trigger": "auto",
    "preTokens": 167189
  }
}
```

`preTokens` 값으로 컴팩션 전 사용된 토큰 수를 확인할 수 있다.
