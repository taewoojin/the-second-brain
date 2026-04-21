---
title: "Claude Code 세션 팀 조율하기"
source: "https://code.claude.com/docs/ko/agent-teams"
author:
published:
created: 2026-04-14
description: "공유 작업, 에이전트 간 메시징, 중앙 집중식 관리를 통해 함께 작동하는 여러 Claude Code 인스턴스를 조율합니다."
tags:
  - "clippings"
---
에이전트 팀은 실험적이며 기본적으로 비활성화되어 있습니다. [settings.json](https://code.claude.com/docs/ko/settings) 이나 환경에 `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` 를 추가하여 활성화합니다. 에이전트 팀은 세션 재개, 작업 조율, 종료 동작 관련 [알려진 제한 사항](#limitations) 이 있습니다.

에이전트 팀을 사용하면 함께 작동하는 여러 Claude Code 인스턴스를 조율할 수 있습니다. 한 세션이 팀 리더 역할을 하여 작업을 조율하고, 작업을 할당하며, 결과를 종합합니다. 팀원들은 독립적으로 작동하며, 각각 자신의 컨텍스트 윈도우에서 작동하고, 서로 직접 통신합니다. 단일 세션 내에서 실행되고 메인 에이전트에게만 보고할 수 있는 [subagents](https://code.claude.com/docs/ko/sub-agents) 와 달리, 리더를 거치지 않고 개별 팀원과 직접 상호작용할 수도 있습니다.

에이전트 팀은 Claude Code v2.1.32 이상이 필요합니다. `claude --version` 으로 버전을 확인합니다.

이 페이지에서 다루는 내용:
- [에이전트 팀을 사용할 때](#when-to-use-agent-teams), 최적의 사용 사례 및 subagents와의 비교 포함
- [팀 시작하기](#start-your-first-agent-team)
- [팀원 제어하기](#control-your-agent-team), 표시 모드, 작업 할당, 위임 포함
- [병렬 작업 모범 사례](#best-practices)

## 에이전트 팀을 사용할 때

에이전트 팀은 병렬 탐색이 실질적인 가치를 더하는 작업에 가장 효과적입니다. 전체 시나리오는 [사용 사례 예시](#use-case-examples) 를 참조합니다. 가장 강력한 사용 사례는 다음과 같습니다:
- **연구 및 검토**: 여러 팀원이 문제의 다양한 측면을 동시에 조사한 후 서로의 발견을 공유하고 도전할 수 있습니다
- **새로운 모듈 또는 기능**: 팀원들이 각각 별도의 부분을 소유하면서 서로 간섭하지 않을 수 있습니다
- **경쟁하는 가설로 디버깅하기**: 팀원들이 다양한 이론을 병렬로 테스트하고 더 빠르게 답에 수렴합니다
- **교차 계층 조율**: 프론트엔드, 백엔드, 테스트에 걸친 변경 사항으로, 각각 다른 팀원이 소유합니다
에이전트 팀은 조율 오버헤드를 추가하고 단일 세션보다 훨씬 더 많은 토큰을 사용합니다. 팀원들이 독립적으로 작동할 수 있을 때 가장 잘 작동합니다. 순차적 작업, 동일 파일 편집, 또는 많은 종속성이 있는 작업의 경우 단일 세션이나 [subagents](https://code.claude.com/docs/ko/sub-agents) 가 더 효과적입니다.

### subagents와 비교

에이전트 팀과 [subagents](https://code.claude.com/docs/ko/sub-agents) 모두 작업을 병렬화할 수 있지만, 다르게 작동합니다. 워커들이 서로 통신해야 하는지 여부에 따라 선택합니다:

Subagents는 결과만 메인 에이전트에게 보고하고 서로 대화하지 않습니다. 에이전트 팀에서는 팀원들이 작업 목록을 공유하고, 작업을 요청하며, 서로 직접 통신합니다.

|  | Subagents | 에이전트 팀 |
| --- | --- | --- |
| **컨텍스트** | 자신의 컨텍스트 윈도우; 결과는 호출자에게 반환됨 | 자신의 컨텍스트 윈도우; 완전히 독립적 |
| **통신** | 메인 에이전트에게만 결과 보고 | 팀원들이 서로 직접 메시지 전송 |
| **조율** | 메인 에이전트가 모든 작업 관리 | 자체 조율을 통한 공유 작업 목록 |
| **최적 용도** | 결과만 중요한 집중된 작업 | 논의와 협업이 필요한 복잡한 작업 |
| **토큰 비용** | 낮음: 결과가 메인 컨텍스트로 요약됨 | 높음: 각 팀원이 별도의 Claude 인스턴스 |

결과를 보고하는 빠르고 집중된 워커가 필요할 때는 subagents를 사용합니다. 팀원들이 발견을 공유하고, 서로 도전하며, 자체적으로 조율해야 할 때는 에이전트 팀을 사용합니다.

## 에이전트 팀 활성화

에이전트 팀은 기본적으로 비활성화되어 있습니다. `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` 환경 변수를 `1` 로 설정하여 활성화합니다. 셸 환경이나 [settings.json](https://code.claude.com/docs/ko/settings) 을 통해 설정할 수 있습니다:

```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

## 첫 번째 에이전트 팀 시작하기

에이전트 팀을 활성화한 후, Claude에게 에이전트 팀을 만들도록 요청하고 자연어로 원하는 작업과 팀 구조를 설명합니다. Claude는 팀을 만들고, 팀원들을 생성하며, 프롬프트에 따라 작업을 조율합니다. 이 예시는 세 가지 역할이 독립적이고 서로를 기다리지 않고 문제를 탐색할 수 있기 때문에 잘 작동합니다:

```text
I'm designing a CLI tool that helps developers track TODO comments across
their codebase. Create an agent team to explore this from different angles: one
teammate on UX, one on technical architecture, one playing devil's advocate.
```

그러면 Claude는 [공유 작업 목록](https://code.claude.com/docs/ko/interactive-mode#task-list) 을 가진 팀을 만들고, 각 관점에 대한 팀원들을 생성하며, 문제를 탐색하고, 발견을 종합하며, 완료되었을 때 [팀을 정리](#clean-up-the-team) 하려고 시도합니다. 리더의 터미널은 모든 팀원과 그들이 작업 중인 내용을 나열합니다. Shift+Down을 사용하여 팀원들을 순환하고 직접 메시지를 보냅니다. 마지막 팀원 이후, Shift+Down은 리더로 돌아갑니다. 각 팀원이 자신의 분할 창에 있기를 원하면 [표시 모드 선택](#choose-a-display-mode) 을 참조합니다.

## 에이전트 팀 제어하기

리더에게 자연어로 원하는 것을 말합니다. 지시에 따라 팀 조율, 작업 할당, 위임을 처리합니다.

### 표시 모드 선택

에이전트 팀은 두 가지 표시 모드를 지원합니다:
- **In-process**: 모든 팀원이 메인 터미널 내에서 실행됩니다. Shift+Down을 사용하여 팀원들을 순환하고 입력하여 직접 메시지를 보냅니다. 모든 터미널에서 작동하며 추가 설정이 필요하지 않습니다.
- **분할 창**: 각 팀원이 자신의 창을 가집니다. 모든 사람의 출력을 한 번에 볼 수 있고 창을 클릭하여 직접 상호작용할 수 있습니다. tmux 또는 iTerm2가 필요합니다.

`tmux` 는 특정 운영 체제에서 알려진 제한 사항이 있으며 전통적으로 macOS에서 가장 잘 작동합니다. iTerm2에서 `tmux -CC` 를 사용하는 것이 `tmux` 로의 권장 진입점입니다.

기본값은 `"auto"` 이며, 이미 tmux 세션 내에서 실행 중이면 분할 창을 사용하고, 그렇지 않으면 in-process를 사용합니다. `"tmux"` 설정은 분할 창 모드를 활성화하고 터미널에 따라 tmux 또는 iTerm2를 사용할지 자동으로 감지합니다. 재정의하려면 [전역 구성](https://code.claude.com/docs/ko/settings#global-config-settings) 에서 `~/.claude.json` 의 `teammateMode` 를 설정합니다:

```json
{
  "teammateMode": "in-process"
}
```

단일 세션에 대해 in-process 모드를 강제하려면 플래그로 전달합니다:

```shellscript
claude --teammate-mode in-process
```

분할 창 모드는 [tmux](https://github.com/tmux/tmux/wiki) 또는 [`it2` CLI](https://github.com/mkusaka/it2) 가 있는 iTerm2가 필요합니다. 수동으로 설치하려면:
- **tmux**: 시스템의 패키지 관리자를 통해 설치합니다. 플랫폼별 지침은 [tmux wiki](https://github.com/tmux/tmux/wiki/Installing) 를 참조합니다.
- **iTerm2**: [`it2` CLI](https://github.com/mkusaka/it2) 를 설치한 후, **iTerm2 → Settings → General → Magic → Enable Python API** 에서 Python API를 활성화합니다.

### 팀원 및 모델 지정

Claude는 작업에 따라 생성할 팀원의 수를 결정하거나, 정확히 원하는 것을 지정할 수 있습니다:

```text
Create a team with 4 teammates to refactor these modules in parallel.
Use Sonnet for each teammate.
```

### 팀원을 위한 계획 승인 요구

복잡하거나 위험한 작업의 경우, 팀원들이 구현하기 전에 계획하도록 요구할 수 있습니다. 팀원은 리더가 접근 방식을 승인할 때까지 읽기 전용 계획 모드에서 작동합니다:

```text
Spawn an architect teammate to refactor the authentication module.
Require plan approval before they make any changes.
```

팀원이 계획을 마치면, 리더에게 계획 승인 요청을 보냅니다. 리더는 계획을 검토하고 승인하거나 피드백과 함께 거부합니다. 거부되면, 팀원은 계획 모드에 머물러 피드백에 따라 수정하고 다시 제출합니다. 승인되면, 팀원은 계획 모드를 종료하고 구현을 시작합니다. 리더는 자율적으로 승인 결정을 내립니다. 리더의 판단에 영향을 미치려면, 프롬프트에 “테스트 커버리지를 포함하는 계획만 승인” 또는 “데이터베이스 스키마를 수정하는 계획 거부”와 같은 기준을 제공합니다.

### 팀원과 직접 대화하기

각 팀원은 완전하고 독립적인 Claude Code 세션입니다. 모든 팀원에게 직접 메시지를 보내 추가 지시를 제공하고, 후속 질문을 하거나, 접근 방식을 재지정할 수 있습니다.
- **In-process 모드**: Shift+Down을 사용하여 팀원들을 순환한 후 입력하여 메시지를 보냅니다. Enter를 눌러 팀원의 세션을 보고, Escape를 눌러 현재 턴을 중단합니다. Ctrl+T를 눌러 작업 목록을 전환합니다.
- **분할 창 모드**: 팀원의 창을 클릭하여 세션과 직접 상호작용합니다. 각 팀원은 자신의 터미널의 전체 보기를 가집니다.

### 작업 할당 및 요청

공유 작업 목록은 팀 전체의 작업을 조율합니다. 리더는 작업을 만들고 팀원들이 이를 처리합니다. 작업은 세 가지 상태를 가집니다: 대기 중, 진행 중, 완료됨. 작업은 다른 작업에 종속될 수도 있습니다: 미해결 종속성이 있는 대기 중인 작업은 해당 종속성이 완료될 때까지 요청할 수 없습니다. 리더는 작업을 명시적으로 할당하거나 팀원들이 자체 요청할 수 있습니다:
- **리더 할당**: 리더에게 어느 작업을 어느 팀원에게 줄지 말합니다
- **자체 요청**: 작업을 마친 후, 팀원은 다음 미할당, 미차단 작업을 자체적으로 선택합니다
작업 요청은 파일 잠금을 사용하여 여러 팀원이 동시에 동일한 작업을 요청하려고 할 때 경합 조건을 방지합니다.

### 팀원 종료하기

팀원의 세션을 우아하게 종료하려면:

```text
Ask the researcher teammate to shut down
```

리더는 종료 요청을 보냅니다. 팀원은 승인하여 우아하게 종료하거나 설명과 함께 거부할 수 있습니다.

### 팀 정리하기

완료되었을 때, 리더에게 정리하도록 요청합니다:

```text
Clean up the team
```

이는 공유 팀 리소스를 제거합니다. 리더가 정리를 실행할 때, 활성 팀원을 확인하고 여전히 실행 중이면 실패하므로 먼저 종료합니다.

항상 리더를 사용하여 정리합니다. 팀원들은 정리를 실행하면 안 됩니다. 팀원의 팀 컨텍스트가 올바르게 해결되지 않아 리소스가 일관성 없는 상태로 남을 수 있기 때문입니다.

### hooks로 품질 게이트 적용

[hooks](https://code.claude.com/docs/ko/hooks) 를 사용하여 팀원들이 작업을 마치거나 작업이 생성되거나 완료될 때 규칙을 적용합니다:
- [`TeammateIdle`](https://code.claude.com/docs/ko/hooks#teammateidle): 팀원이 유휴 상태가 되려고 할 때 실행됩니다. 종료 코드 2로 종료하여 피드백을 보내고 팀원을 계속 작동하게 합니다.
- [`TaskCreated`](https://code.claude.com/docs/ko/hooks#taskcreated): 작업이 생성될 때 실행됩니다. 종료 코드 2로 종료하여 생성을 방지하고 피드백을 보냅니다.
- [`TaskCompleted`](https://code.claude.com/docs/ko/hooks#taskcompleted): 작업이 완료로 표시될 때 실행됩니다. 종료 코드 2로 종료하여 완료를 방지하고 피드백을 보냅니다.

## 에이전트 팀이 어떻게 작동하는지

이 섹션은 에이전트 팀 뒤의 아키텍처와 메커니즘을 다룹니다. 사용을 시작하려면 위의 [에이전트 팀 제어하기](#control-your-agent-team) 를 참조합니다.

### Claude가 에이전트 팀을 시작하는 방법

에이전트 팀이 시작되는 두 가지 방법이 있습니다:
- **팀 요청**: 병렬 작업의 이점이 있는 작업을 제공하고 명시적으로 에이전트 팀을 요청합니다. Claude는 지시에 따라 팀을 만듭니다.
- **Claude가 팀 제안**: Claude가 작업이 병렬 작업의 이점이 있다고 판단하면, 팀 생성을 제안할 수 있습니다. 진행하기 전에 확인합니다.
두 경우 모두 제어 권한을 유지합니다. Claude는 승인 없이 팀을 만들지 않습니다.

### 아키텍처

에이전트 팀은 다음으로 구성됩니다:

| 구성 요소 | 역할 |
| --- | --- |
| **팀 리더** | 팀을 만들고, 팀원들을 생성하며, 작업을 조율하는 메인 Claude Code 세션 |
| **팀원들** | 할당된 작업에서 각각 작동하는 별도의 Claude Code 인스턴스 |
| **작업 목록** | 팀원들이 요청하고 완료하는 공유 작업 항목 목록 |
| **메일박스** | 에이전트 간 통신을 위한 메시징 시스템 |

표시 구성 옵션은 [표시 모드 선택](#choose-a-display-mode) 을 참조합니다. 팀원 메시지는 리더에게 자동으로 도착합니다. 시스템은 작업 종속성을 자동으로 관리합니다. 팀원이 다른 작업이 종속된 작업을 완료하면, 차단된 작업은 수동 개입 없이 차단 해제됩니다. 팀과 작업은 로컬에 저장됩니다:
- **팀 구성**: `~/.claude/teams/{team-name}/config.json`
- **작업 목록**: `~/.claude/tasks/{team-name}/`
Claude Code는 팀을 만들 때 이 둘을 자동으로 생성하고 팀원들이 참여하거나, 유휴 상태가 되거나, 떠날 때 업데이트합니다. 팀 구성은 세션 ID 및 tmux 창 ID와 같은 런타임 상태를 보유하므로, 수동으로 편집하거나 사전 작성하지 마십시오: 다음 상태 업데이트에서 변경 사항이 덮어씌워집니다. 재사용 가능한 팀원 역할을 정의하려면, 대신 [subagent 정의 사용](#use-subagent-definitions-for-teammates) 을 사용합니다. 팀 구성에는 각 팀원의 이름, 에이전트 ID, 에이전트 유형이 있는 `members` 배열이 포함됩니다. 팀원들은 이 파일을 읽어 다른 팀 멤버를 발견할 수 있습니다. 프로젝트 수준의 팀 구성 동등물은 없습니다. 프로젝트 디렉토리의 `.claude/teams/teams.json` 과 같은 파일은 구성으로 인식되지 않습니다. Claude는 이를 일반 파일로 취급합니다.

### 팀원을 위해 subagent 정의 사용

팀원을 생성할 때, 프로젝트, 사용자, 플러그인, 또는 CLI 정의 등 모든 [subagent 범위](https://code.claude.com/docs/ko/sub-agents#choose-the-subagent-scope) 의 [subagent](https://code.claude.com/docs/ko/sub-agents) 유형을 참조할 수 있습니다. 팀원은 해당 subagent의 시스템 프롬프트, 도구, 모델을 상속합니다. 이를 통해 보안 검토자 또는 테스트 실행자와 같은 역할을 한 번 정의하고 위임된 subagent와 에이전트 팀 팀원 모두로 재사용할 수 있습니다. subagent 정의를 사용하려면, Claude에게 팀원을 생성하도록 요청할 때 이름으로 언급합니다:

```text
Spawn a teammate using the security-reviewer agent type to audit the auth module.
```

### 권한

팀원들은 리더의 권한 설정으로 시작합니다. 리더가 `--dangerously-skip-permissions` 로 실행되면, 모든 팀원도 그렇게 합니다. 생성 후, 개별 팀원 모드를 변경할 수 있지만, 생성 시 팀원별 모드를 설정할 수 없습니다.

### 컨텍스트 및 통신

각 팀원은 자신의 컨텍스트 윈도우를 가집니다. 생성될 때, 팀원은 일반 세션과 동일한 프로젝트 컨텍스트를 로드합니다: CLAUDE.md, MCP servers, skills. 또한 리더의 생성 프롬프트를 받습니다. 리더의 대화 기록은 전달되지 않습니다. **팀원들이 정보를 공유하는 방법:**
- **자동 메시지 전달**: 팀원들이 메시지를 보낼 때, 자동으로 수신자에게 전달됩니다. 리더가 업데이트를 폴링할 필요가 없습니다.
- **유휴 알림**: 팀원이 완료되고 중지되면, 자동으로 리더에게 알립니다.
- **공유 작업 목록**: 모든 에이전트는 작업 상태를 보고 사용 가능한 작업을 요청할 수 있습니다.
**팀원 메시징:**
- **message**: 특정 팀원 한 명에게 메시지 보내기
- **broadcast**: 모든 팀원에게 동시에 보내기. 팀 크기에 따라 비용이 증가하므로 드물게 사용합니다.

### 토큰 사용

에이전트 팀은 단일 세션보다 훨씬 더 많은 토큰을 사용합니다. 각 팀원은 자신의 컨텍스트 윈도우를 가지며, 토큰 사용은 활성 팀원의 수에 따라 증가합니다. 연구, 검토, 새로운 기능 작업의 경우, 추가 토큰은 일반적으로 가치가 있습니다. 일상적인 작업의 경우, 단일 세션이 더 비용 효율적입니다. 사용 지침은 [에이전트 팀 토큰 비용](https://code.claude.com/docs/ko/costs#agent-team-token-costs) 을 참조합니다.

## 사용 사례 예시

이 예시들은 병렬 탐색이 가치를 더하는 작업을 에이전트 팀이 어떻게 처리하는지 보여줍니다.

### 병렬 코드 검토 실행

단일 검토자는 한 번에 한 가지 유형의 문제로 기울어지는 경향이 있습니다. 검토 기준을 독립적인 도메인으로 분할하면 보안, 성능, 테스트 커버리지가 모두 동시에 철저한 주의를 받습니다. 프롬프트는 각 팀원에게 고유한 렌즈를 할당하여 겹치지 않도록 합니다:

```text
Create an agent team to review PR #142. Spawn three reviewers:
- One focused on security implications
- One checking performance impact
- One validating test coverage
Have them each review and report findings.
```

각 검토자는 동일한 PR에서 작동하지만 다른 필터를 적용합니다. 리더는 모두 완료된 후 세 명 모두의 발견을 종합합니다.

### 경쟁하는 가설로 조사하기

근본 원인이 불명확할 때, 단일 에이전트는 그럴듯한 설명 하나를 찾고 멈추는 경향이 있습니다. 프롬프트는 팀원들을 명시적으로 적대적으로 만들어 이를 방지합니다: 각 팀원의 일은 자신의 이론을 조사하는 것뿐만 아니라 다른 팀원들에게 도전하는 것입니다.

```text
Users report the app exits after one message instead of staying connected.
Spawn 5 agent teammates to investigate different hypotheses. Have them talk to
each other to try to disprove each other's theories, like a scientific
debate. Update the findings doc with whatever consensus emerges.
```

토론 구조가 여기서 핵심 메커니즘입니다. 순차적 조사는 앵커링으로 인해 고통받습니다: 한 이론이 탐색되면, 후속 조사는 그것에 편향됩니다. 여러 독립적인 조사자가 적극적으로 서로의 이론을 반박하려고 할 때, 생존하는 이론은 실제 근본 원인일 가능성이 훨씬 높습니다.

## 모범 사례

### 팀원에게 충분한 컨텍스트 제공

팀원들은 CLAUDE.md, MCP servers, skills를 포함한 프로젝트 컨텍스트를 자동으로 로드하지만, 리더의 대화 기록을 상속하지 않습니다. 자세한 내용은 [컨텍스트 및 통신](#context-and-communication) 을 참조합니다. 생성 프롬프트에 작업별 세부 사항을 포함합니다:

```text
Spawn a security reviewer teammate with the prompt: "Review the authentication module
at src/auth/ for security vulnerabilities. Focus on token handling, session
management, and input validation. The app uses JWT tokens stored in
httpOnly cookies. Report any issues with severity ratings."
```

### 적절한 팀 크기 선택

팀원의 수에 대한 하드 제한은 없지만, 실질적인 제약이 적용됩니다:
- **토큰 비용이 선형으로 증가**: 각 팀원은 자신의 컨텍스트 윈도우를 가지며 독립적으로 토큰을 소비합니다. 자세한 내용은 [에이전트 팀 토큰 비용](https://code.claude.com/docs/ko/costs#agent-team-token-costs) 을 참조합니다.
- **조율 오버헤드 증가**: 더 많은 팀원은 더 많은 통신, 작업 조율, 충돌 가능성을 의미합니다
- **수익 감소**: 특정 지점을 넘으면, 추가 팀원은 작업 속도를 비례적으로 높이지 않습니다
대부분의 워크플로우에 대해 3-5명의 팀원으로 시작합니다. 이는 병렬 작업과 관리 가능한 조율의 균형을 맞춥니다. 이 가이드의 예시들은 3-5명의 팀원을 사용합니다. 이 범위는 다양한 작업 유형에서 잘 작동하기 때문입니다. 팀원당 5-6개의 [작업](https://code.claude.com/docs/ko/agent-teams#architecture) 을 유지하면 과도한 컨텍스트 전환 없이 모두를 생산적으로 유지합니다. 15개의 독립적인 작업이 있으면, 3명의 팀원이 좋은 시작점입니다. 작업이 실제로 팀원들이 동시에 작동하는 것의 이점이 있을 때만 확장합니다. 세 명의 집중된 팀원은 종종 다섯 명의 산만한 팀원을 능가합니다.

### 작업을 적절히 크기 조정

- **너무 작음**: 조율 오버헤드가 이점을 초과합니다
- **너무 큼**: 팀원들이 체크인 없이 너무 오래 작동하여 낭비된 노력의 위험이 증가합니다
- **적절함**: 함수, 테스트 파일, 검토와 같은 명확한 결과물을 생성하는 자체 포함된 단위

리더는 작업을 작업으로 나누고 팀원들에게 자동으로 할당합니다. 충분한 작업을 만들지 않으면, 작업을 더 작은 조각으로 분할하도록 요청합니다. 팀원당 5-6개의 작업을 유지하면 모두를 생산적으로 유지하고 누군가 막히면 리더가 작업을 재할당할 수 있습니다.

### 팀원들이 완료될 때까지 기다리기

때때로 리더는 팀원들을 기다리지 않고 작업을 자체적으로 구현하기 시작합니다. 이를 알아차리면:

```text
Wait for your teammates to complete their tasks before proceeding
```

### 연구 및 검토로 시작하기

에이전트 팀을 처음 사용하는 경우, 명확한 경계가 있고 코드 작성이 필요하지 않은 작업으로 시작합니다: PR 검토, 라이브러리 연구, 또는 버그 조사. 이러한 작업은 병렬 탐색의 가치를 보여주면서 병렬 구현과 함께 오는 조율 문제 없이 보여줍니다.

### 파일 충돌 피하기

두 팀원이 동일한 파일을 편집하면 덮어쓰기가 발생합니다. 각 팀원이 다른 파일 집합을 소유하도록 작업을 나눕니다.

### 모니터링 및 조율

팀원들의 진행 상황을 확인하고, 작동하지 않는 접근 방식을 재지정하며, 발견이 들어올 때 종합합니다. 팀을 무인으로 너무 오래 실행하면 낭비된 노력의 위험이 증가합니다.

## 문제 해결

### 팀원이 나타나지 않음

Claude에게 팀을 만들도록 요청한 후 팀원이 나타나지 않으면:
- In-process 모드에서, 팀원들이 이미 실행 중이지만 보이지 않을 수 있습니다. Shift+Down을 눌러 활성 팀원들을 순환합니다.
- Claude에게 준 작업이 팀을 보증할 만큼 복잡한지 확인합니다. Claude는 작업에 따라 팀원을 생성할지 결정합니다.
- 분할 창을 명시적으로 요청했으면, tmux가 설치되어 있고 PATH에서 사용 가능한지 확인합니다:
	```shellscript
	which tmux
	```
- iTerm2의 경우, `it2` CLI가 설치되어 있고 Python API가 iTerm2 환경 설정에서 활성화되어 있는지 확인합니다.

### 너무 많은 권한 프롬프트

팀원 권한 요청이 리더로 버블업되어 마찰을 일으킬 수 있습니다. 팀원들을 생성하기 전에 [권한 설정](https://code.claude.com/docs/ko/permissions) 에서 일반적인 작업을 사전 승인하여 중단을 줄입니다.

### 팀원들이 오류에서 중지됨

팀원들은 오류를 만난 후 복구하지 않고 중지할 수 있습니다. In-process 모드에서 Shift+Down을 사용하거나 분할 모드에서 창을 클릭하여 출력을 확인한 후:
- 직접 추가 지시를 제공합니다
- 작업을 계속하기 위해 대체 팀원을 생성합니다

### 리더가 작업 완료 전에 종료됨

리더는 모든 작업이 실제로 완료되기 전에 팀이 완료되었다고 결정할 수 있습니다. 이 경우 계속하도록 말합니다. 또한 리더가 위임하지 않고 작업을 시작하면 팀원들이 완료될 때까지 기다리도록 말할 수 있습니다.

### 고아 tmux 세션

팀이 끝난 후 tmux 세션이 지속되면, 완전히 정리되지 않았을 수 있습니다. 세션을 나열하고 팀에서 만든 세션을 종료합니다:

```shellscript
tmux ls
tmux kill-session -t <session-name>
```

## 제한 사항

에이전트 팀은 실험적입니다. 주의할 현재 제한 사항:
- **In-process 팀원과의 세션 재개 없음**: `/resume` 과 `/rewind` 는 in-process 팀원을 복원하지 않습니다. 세션을 재개한 후, 리더는 더 이상 존재하지 않는 팀원에게 메시지를 보내려고 시도할 수 있습니다. 이 경우 리더에게 새 팀원을 생성하도록 말합니다.
- **작업 상태가 지연될 수 있음**: 팀원들이 때때로 작업을 완료로 표시하지 못하여 종속 작업을 차단합니다. 작업이 막혀 있는 것처럼 보이면, 작업이 실제로 완료되었는지 확인하고 작업 상태를 수동으로 업데이트하거나 리더에게 팀원을 밀도록 말합니다.
- **종료가 느릴 수 있음**: 팀원들은 현재 요청이나 도구 호출을 마친 후 종료되어 시간이 걸릴 수 있습니다.
- **세션당 한 팀**: 리더는 한 번에 한 팀만 관리할 수 있습니다. 새 팀을 시작하기 전에 현재 팀을 정리합니다.
- **중첩된 팀 없음**: 팀원들은 자신의 팀이나 팀원을 생성할 수 없습니다. 리더만 팀을 관리할 수 있습니다.
- **리더가 고정됨**: 팀을 만드는 세션은 수명 동안 리더입니다. 팀원을 리더로 승격하거나 리더십을 이전할 수 없습니다.
- **생성 시 권한 설정**: 모든 팀원은 리더의 권한 모드로 시작합니다. 생성 후 개별 팀원 모드를 변경할 수 있지만, 생성 시 팀원별 모드를 설정할 수 없습니다.
- **분할 창은 tmux 또는 iTerm2 필요**: 기본 in-process 모드는 모든 터미널에서 작동합니다. 분할 창 모드는 VS Code의 통합 터미널, Windows Terminal, Ghostty에서 지원되지 않습니다.

**`CLAUDE.md` 는 정상적으로 작동합니다**: 팀원들은 작업 디렉토리에서 `CLAUDE.md` 파일을 읽습니다. 이를 사용하여 모든 팀원에게 프로젝트별 지침을 제공합니다.

## 다음 단계

병렬 작업 및 위임을 위한 관련 접근 방식을 탐색합니다:
- **경량 위임**: [subagents](https://code.claude.com/docs/ko/sub-agents) 는 세션 내에서 연구 또는 검증을 위해 도우미 에이전트를 생성하며, 에이전트 간 조율이 필요하지 않은 작업에 더 좋습니다
- **수동 병렬 세션**: [Git worktrees](https://code.claude.com/docs/ko/common-workflows#run-parallel-claude-code-sessions-with-git-worktrees) 를 사용하면 자동화된 팀 조율 없이 여러 Claude Code 세션을 직접 실행할 수 있습니다
- **접근 방식 비교**: [subagent vs 에이전트 팀](https://code.claude.com/docs/ko/features-overview#compare-similar-features) 비교를 참조하여 나란히 비교합니다