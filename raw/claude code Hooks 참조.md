---
title: "Hooks 참조"
source: "https://code.claude.com/docs/ko/hooks"
author:
published:
created: 2026-04-21
description: "Claude Code hook 이벤트, 구성 스키마, JSON 입출력 형식, 종료 코드, 비동기 hook, HTTP hook, 프롬프트 hook, MCP 도구 hook에 대한 참조입니다."
tags:
  - "clippings"
---
예제가 포함된 빠른 시작 가이드는 [hook으로 워크플로우 자동화](https://code.claude.com/docs/ko/hooks-guide) 를 참조하세요.

Hook은 Claude Code의 수명 주기에서 특정 지점에 자동으로 실행되는 사용자 정의 셸 명령, HTTP 엔드포인트 또는 LLM 프롬프트입니다. 이 참조를 사용하여 이벤트 스키마, 구성 옵션, JSON 입출력 형식, 비동기 hook, HTTP hook, MCP 도구 hook과 같은 고급 기능을 조회할 수 있습니다. 처음으로 hook을 설정하는 경우 대신 [가이드](https://code.claude.com/docs/ko/hooks-guide) 부터 시작하세요.

## Hook 수명 주기

Hook은 Claude Code 세션 중 특정 지점에서 실행됩니다. 이벤트가 발생하고 matcher가 일치하면 Claude Code는 이벤트에 대한 JSON 컨텍스트를 hook 핸들러에 전달합니다. 명령 hook의 경우 입력은 stdin에 도착합니다. HTTP hook의 경우 POST 요청 본문으로 도착합니다. 그러면 핸들러는 입력을 검사하고 조치를 취한 후 선택적으로 결정을 반환할 수 있습니다. 이벤트는 세 가지 주기로 발생합니다: 세션당 한 번 (`SessionStart`, `SessionEnd`), 턴당 한 번 (`UserPromptSubmit`, `Stop`, `StopFailure`), 에이전트 루프 내의 모든 도구 호출에서 (`PreToolUse`, `PostToolUse`):

![SessionStart에서 시작하여 턴당 루프 (UserPromptSubmit, 중첩된 에이전트 루프 (PreToolUse, PermissionRequest, PostToolUse, SubagentStart/Stop, TaskCreated, TaskCompleted), Stop 또는 StopFailure), TeammateIdle, PreCompact, PostCompact, SessionEnd를 거쳐 진행되는 hook 수명 주기 다이어그램. Elicitation 및 ElicitationResult는 MCP 도구 실행 내에 중첩되고, PermissionDenied는 PermissionRequest의 부분 분기이며, WorktreeCreate, WorktreeRemove, Notification, ConfigChange, InstructionsLoaded, CwdChanged, FileChanged는 독립적인 비동기 이벤트](https://mintcdn.com/claude-code/UMJp-WgTWngzO609/images/hooks-lifecycle.svg?w=2500&fit=max&auto=format&n=UMJp-WgTWngzO609&q=85&s=d60b639994ddeb15ba2eb5315f33725d)

SessionStart에서 시작하여 턴당 루프 (UserPromptSubmit, 중첩된 에이전트 루프 (PreToolUse, PermissionRequest, PostToolUse, SubagentStart/Stop, TaskCreated, TaskCompleted), Stop 또는 StopFailure), TeammateIdle, PreCompact, PostCompact, SessionEnd를 거쳐 진행되는 hook 수명 주기 다이어그램. Elicitation 및 ElicitationResult는 MCP 도구 실행 내에 중첩되고, PermissionDenied는 PermissionRequest의 부분 분기이며, WorktreeCreate, WorktreeRemove, Notification, ConfigChange, InstructionsLoaded, CwdChanged, FileChanged는 독립적인 비동기 이벤트

아래 표는 각 이벤트가 언제 발생하는지 요약합니다. [Hook 이벤트](#hook-events) 섹션에서는 각 이벤트의 전체 입력 스키마와 결정 제어 옵션을 문서화합니다.

| Event | When it fires |
| --- | --- |
| `SessionStart` | When a session begins or resumes |
| `UserPromptSubmit` | When you submit a prompt, before Claude processes it |
| `PreToolUse` | Before a tool call executes. Can block it |
| `PermissionRequest` | When a permission dialog appears |
| `PermissionDenied` | When a tool call is denied by the auto mode classifier. Return `{retry: true}` to tell the model it may retry the denied tool call |
| `PostToolUse` | After a tool call succeeds |
| `PostToolUseFailure` | After a tool call fails |
| `Notification` | When Claude Code sends a notification |
| `SubagentStart` | When a subagent is spawned |
| `SubagentStop` | When a subagent finishes |
| `TaskCreated` | When a task is being created via `TaskCreate` |
| `TaskCompleted` | When a task is being marked as completed |
| `Stop` | When Claude finishes responding |
| `StopFailure` | When the turn ends due to an API error. Output and exit code are ignored |
| `TeammateIdle` | When an [agent team](https://code.claude.com/docs/en/agent-teams) teammate is about to go idle |
| `InstructionsLoaded` | When a CLAUDE.md or `.claude/rules/*.md` file is loaded into context. Fires at session start and when files are lazily loaded during a session |
| `ConfigChange` | When a configuration file changes during a session |
| `CwdChanged` | When the working directory changes, for example when Claude executes a `cd` command. Useful for reactive environment management with tools like direnv |
| `FileChanged` | When a watched file changes on disk. The `matcher` field specifies which filenames to watch |
| `WorktreeCreate` | When a worktree is being created via `--worktree` or `isolation: "worktree"`. Replaces default git behavior |
| `WorktreeRemove` | When a worktree is being removed, either at session exit or when a subagent finishes |
| `PreCompact` | Before context compaction |
| `PostCompact` | After context compaction completes |
| `Elicitation` | When an MCP server requests user input during a tool call |
| `ElicitationResult` | After a user responds to an MCP elicitation, before the response is sent back to the server |
| `SessionEnd` | When a session terminates |

### Hook이 어떻게 해결되는지

이러한 부분들이 어떻게 함께 작동하는지 보려면 파괴적인 셸 명령을 차단하는 이 `PreToolUse` hook을 고려하세요. `matcher` 는 Bash 도구 호출로 좁혀지고 `if` 조건은 `rm *` 과 일치하는 Bash 부명령으로 더 좁혀지므로 `block-rm.sh` 는 두 필터가 모두 일치할 때만 생성됩니다:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "if": "Bash(rm *)",
            "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/block-rm.sh"
          }
        ]
      }
    ]
  }
}
```

스크립트는 stdin에서 JSON 입력을 읽고 명령을 추출한 후 `rm -rf` 를 포함하면 `permissionDecision` 을 `"deny"` 로 반환합니다:

```shellscript
#!/bin/bash
# .claude/hooks/block-rm.sh
COMMAND=$(jq -r '.tool_input.command')

if echo "$COMMAND" | grep -q 'rm -rf'; then
  jq -n '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: "Destructive command blocked by hook"
    }
  }'
else
  exit 0  # allow the command
fi
```

이제 Claude Code가 `Bash "rm -rf /tmp/build"` 를 실행하기로 결정했다고 가정합니다. 다음은 발생하는 일입니다:

![Hook 해결 흐름: PreToolUse 이벤트 발생, matcher가 Bash 일치 확인, if 조건이 Bash(rm *) 일치 확인, hook 핸들러 실행, 결과가 Claude Code로 반환](https://mintcdn.com/claude-code/-tYw1BD_DEqfyyOZ/images/hook-resolution.svg?w=2500&fit=max&auto=format&n=-tYw1BD_DEqfyyOZ&q=85&s=a91d1baecae1e39c6292a174b8242898)

Hook 해결 흐름: PreToolUse 이벤트 발생, matcher가 Bash 일치 확인, if 조건이 Bash(rm \*) 일치 확인, hook 핸들러 실행, 결과가 Claude Code로 반환

아래 [구성](#configuration) 섹션에서는 전체 스키마를 문서화하고, 각 [hook 이벤트](#hook-events) 섹션에서는 명령이 받는 입력과 반환할 수 있는 출력을 문서화합니다.

## 구성

Hook은 JSON 설정 파일에서 정의됩니다. 구성에는 세 가지 중첩 수준이 있습니다:

1. 응답할 [hook 이벤트](#hook-events) 를 선택합니다 (예: `PreToolUse` 또는 `Stop`)
2. 발생 시기를 필터링할 [matcher 그룹](#matcher-patterns) 을 추가합니다 (예: “Bash 도구에만”)
3. 일치할 때 실행할 하나 이상의 [hook 핸들러](#hook-handler-fields) 를 정의합니다

주석이 달린 예제를 포함한 완전한 설명은 위의 [Hook이 어떻게 해결되는지](#how-a-hook-resolves) 를 참조하세요.

이 페이지는 각 수준에 대해 특정 용어를 사용합니다: 수명 주기 지점에 대해 **hook 이벤트**, 필터에 대해 **matcher 그룹**, 실행되는 셸 명령, HTTP 엔드포인트, 프롬프트 또는 에이전트에 대해 **hook 핸들러**. “Hook”은 일반 기능을 나타냅니다.

### Hook 위치

hook을 정의하는 위치는 그 범위를 결정합니다:

| 위치 | 범위 | 공유 가능 |
| --- | --- | --- |
| `~/.claude/settings.json` | 모든 프로젝트 | 아니오, 머신에 로컬 |
| `.claude/settings.json` | 단일 프로젝트 | 예, 리포지토리에 커밋 가능 |
| `.claude/settings.local.json` | 단일 프로젝트 | 아니오, gitignored |
| 관리형 정책 설정 | 조직 전체 | 예, 관리자 제어 |
| [Plugin](https://code.claude.com/docs/ko/plugins) `hooks/hooks.json` | plugin이 활성화되었을 때 | 예, plugin과 함께 번들됨 |
| [Skill](https://code.claude.com/docs/ko/skills) 또는 [agent](https://code.claude.com/docs/ko/sub-agents) frontmatter | 컴포넌트가 활성화되어 있는 동안 | 예, 컴포넌트 파일에서 정의됨 |

설정 파일 해결에 대한 자세한 내용은 [설정](https://code.claude.com/docs/ko/settings) 을 참조하세요. 엔터프라이즈 관리자는 `allowManagedHooksOnly` 를 사용하여 사용자, 프로젝트 및 plugin hook을 차단할 수 있습니다. 관리형 설정 `enabledPlugins` 에서 강제 활성화된 plugin의 hook은 면제되므로 관리자는 조직 마켓플레이스를 통해 검증된 hook을 배포할 수 있습니다. [Hook 구성](https://code.claude.com/docs/ko/settings#hook-configuration) 을 참조하세요.

### Matcher 패턴

`matcher` 필드는 hook이 발생할 때를 필터링합니다. matcher가 평가되는 방식은 포함된 문자에 따라 다릅니다:

| Matcher 값 | 평가 대상 | 예제 |
| --- | --- | --- |
| `"*"`, `""` 또는 생략됨 | 모두 일치 | 이벤트의 모든 발생에서 발생 |
| 문자, 숫자, `_`, `\|` 만 포함 | 정확한 문자열 또는 `\|` 로 구분된 정확한 문자열 목록 | `Bash` 는 Bash 도구만 일치; `Edit\|Write` 는 두 도구 중 하나와 정확히 일치 |
| 다른 문자 포함 | JavaScript 정규식 | `^Notebook` 은 Notebook으로 시작하는 모든 도구와 일치; `mcp__memory__.*` 는 `memory` 서버의 모든 도구와 일치 |

`FileChanged` 이벤트는 감시 목록을 구축할 때 이러한 규칙을 따르지 않습니다. [FileChanged](#filechanged) 를 참조하세요.

각 이벤트 유형은 다른 필드에서 일치합니다:

| 이벤트 | Matcher가 필터링하는 것 | 예제 matcher 값 |
| --- | --- | --- |
| `PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `PermissionRequest`, `PermissionDenied` | 도구 이름 | `Bash`, `Edit\|Write`, `mcp__.*` |
| `SessionStart` | 세션이 시작된 방식 | `startup`, `resume`, `clear`, `compact` |
| `SessionEnd` | 세션이 종료된 이유 | `clear`, `resume`, `logout`, `prompt_input_exit`, `bypass_permissions_disabled`, `other` |
| `Notification` | 알림 유형 | `permission_prompt`, `idle_prompt`, `auth_success`, `elicitation_dialog` |
| `SubagentStart` | 에이전트 유형 | `Bash`, `Explore`, `Plan` 또는 사용자 정의 에이전트 이름 |
| `PreCompact`, `PostCompact` | 압축을 트리거한 것 | `manual`, `auto` |
| `SubagentStop` | 에이전트 유형 | `SubagentStart` 와 동일한 값 |
| `ConfigChange` | 구성 소스 | `user_settings`, `project_settings`, `local_settings`, `policy_settings`, `skills` |
| `CwdChanged` | matcher 지원 없음 | 모든 디렉토리 변경에서 항상 발생 |
| `FileChanged` | 감시할 리터럴 파일명 ([FileChanged](#filechanged) 참조) | `.envrc\|.env` |
| `StopFailure` | 오류 유형 | `rate_limit`, `authentication_failed`, `billing_error`, `invalid_request`, `server_error`, `max_output_tokens`, `unknown` |
| `InstructionsLoaded` | 로드 이유 | `session_start`, `nested_traversal`, `path_glob_match`, `include`, `compact` |
| `Elicitation` | MCP 서버 이름 | 구성된 MCP 서버 이름 |
| `ElicitationResult` | MCP 서버 이름 | `Elicitation` 과 동일한 값 |
| `UserPromptSubmit`, `Stop`, `TeammateIdle`, `TaskCreated`, `TaskCompleted`, `WorktreeCreate`, `WorktreeRemove` | matcher 지원 없음 | 모든 발생에서 항상 발생 |

matcher는 Claude Code가 stdin의 hook에 전송하는 [JSON 입력](#hook-input-and-output) 의 필드에 대해 실행됩니다. 도구 이벤트의 경우 해당 필드는 `tool_name` 입니다. 각 [hook 이벤트](#hook-events) 섹션에서는 해당 이벤트의 전체 matcher 값 집합과 입력 스키마를 나열합니다.

이 예제는 Claude가 파일을 쓰거나 편집할 때만 linting 스크립트를 실행합니다:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "/path/to/lint-check.sh"
          }
        ]
      }
    ]
  }
}
```

`UserPromptSubmit`, `Stop`, `TeammateIdle`, `TaskCreated`, `TaskCompleted`, `WorktreeCreate`, `WorktreeRemove`, `CwdChanged` 는 matcher를 지원하지 않으며 모든 발생에서 항상 발생합니다. 이러한 이벤트에 `matcher` 필드를 추가하면 자동으로 무시됩니다.

도구 이벤트의 경우 개별 hook 핸들러에서 [`if` 필드](#common-fields) 를 설정하여 더 좁게 필터링할 수 있습니다. `if` 는 [권한 규칙 구문](https://code.claude.com/docs/ko/permissions) 을 사용하여 도구 이름과 인수를 함께 일치시키므로 `"Bash(git *)"` 는 `git` 명령에만 실행되고 `"Edit(*.ts)"` 는 TypeScript 파일에만 실행됩니다.

#### MCP 도구 일치

[MCP](https://code.claude.com/docs/ko/mcp) 서버 도구는 도구 이벤트 (`PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `PermissionRequest`, `PermissionDenied`)에서 일반 도구로 나타나므로 다른 도구 이름과 동일한 방식으로 일치시킬 수 있습니다.

MCP 도구는 `mcp__<server>__<tool>` 명명 패턴을 따릅니다. 예를 들어:

- `mcp__memory__create_entities`: Memory 서버의 create entities 도구
- `mcp__filesystem__read_file`: Filesystem 서버의 read file 도구
- `mcp__github__search_repositories`: GitHub 서버의 search 도구

서버의 모든 도구와 일치하려면 서버 접두사에 `.*` 를 추가합니다. `.*` 는 필수입니다: `mcp__memory` 와 같은 matcher는 문자와 밑줄만 포함하므로 정확한 문자열로 비교되고 도구와 일치하지 않습니다.

- `mcp__memory__.*` 는 `memory` 서버의 모든 도구와 일치합니다
- `mcp__.*__write.*` 는 모든 서버의 이름이 `write` 로 시작하는 모든 도구와 일치합니다

이 예제는 모든 memory 서버 작업을 기록하고 모든 MCP 서버의 쓰기 작업을 검증합니다:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "mcp__memory__.*",
        "hooks": [
          {
            "type": "command",
            "command": "echo 'Memory operation initiated' >> ~/mcp-operations.log"
          }
        ]
      },
      {
        "matcher": "mcp__.*__write.*",
        "hooks": [
          {
            "type": "command",
            "command": "/home/user/scripts/validate-mcp-write.py"
          }
        ]
      }
    ]
  }
}
```

### Hook 핸들러 필드

내부 `hooks` 배열의 각 객체는 hook 핸들러입니다: matcher가 일치할 때 실행되는 셸 명령, HTTP 엔드포인트, LLM 프롬프트 또는 에이전트입니다. 네 가지 유형이 있습니다:

- **[명령 hook](#command-hook-fields)** (`type: "command"`): 셸 명령을 실행합니다. 스크립트는 이벤트의 [JSON 입력](#hook-input-and-output) 을 stdin에서 받고 종료 코드와 stdout을 통해 결과를 다시 전달합니다.
- **[HTTP hook](#http-hook-fields)** (`type: "http"`): 이벤트의 JSON 입력을 HTTP POST 요청으로 URL에 전송합니다. 엔드포인트는 명령 hook과 동일한 [JSON 출력 형식](#json-output) 을 사용하여 응답 본문을 통해 결과를 다시 전달합니다.
- **[프롬프트 hook](#prompt-and-agent-hook-fields)** (`type: "prompt"`): Claude 모델에 단일 턴 평가를 위한 프롬프트를 전송합니다. 모델은 yes/no 결정을 JSON으로 반환합니다. [프롬프트 기반 hook](#prompt-based-hooks) 을 참조하세요.
- **[에이전트 hook](#prompt-and-agent-hook-fields)** (`type: "agent"`): Read, Grep, Glob과 같은 도구를 사용하여 결정을 반환하기 전에 조건을 확인할 수 있는 subagent를 생성합니다. 에이전트 hook은 실험적이며 변경될 수 있습니다. [에이전트 기반 hook](#agent-based-hooks) 을 참조하세요.

#### 공통 필드

이러한 필드는 모든 hook 유형에 적용됩니다:

| 필드 | 필수 | 설명 |
| --- | --- | --- |
| `type` | 예 | `"command"`, `"http"`, `"prompt"` 또는 `"agent"` |
| `if` | 아니오 | `"Bash(git *)"` 또는 `"Edit(*.ts)"` 와 같은 권한 규칙 구문을 사용하여 이 hook이 실행될 때를 필터링합니다. hook은 도구 호출이 패턴과 일치할 때만 생성됩니다. 도구 이벤트에서만 평가됩니다: `PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `PermissionRequest`. 다른 이벤트에서는 `if` 가 설정된 hook이 절대 실행되지 않습니다. [권한 규칙](https://code.claude.com/docs/ko/permissions) 과 동일한 구문을 사용합니다 |
| `timeout` | 아니오 | 취소하기 전 초 단위. 기본값: 명령의 경우 600, 프롬프트의 경우 30, 에이전트의 경우 60 |
| `statusMessage` | 아니오 | hook이 실행되는 동안 표시되는 사용자 정의 스피너 메시지 |
| `once` | 아니오 | `true` 인 경우 세션당 한 번만 실행된 후 제거됩니다. [Skill 및 에이전트의 Hook](#hooks-in-skills-and-agents) 에서만 적용됨; 설정 파일 및 에이전트 frontmatter에서는 무시됨 |

`if` 필드는 정확히 하나의 권한 규칙을 보유합니다. 규칙을 결합하기 위한 `&&`, `||` 또는 목록 구문이 없습니다. 여러 조건을 적용하려면 각각에 대해 별도의 hook 핸들러를 정의합니다. Bash의 경우 규칙은 선행 `VAR=value` 할당이 제거된 후 도구 입력의 각 하위 명령에 대해 일치하므로 `if: "Bash(git push *)"` 는 `FOO=bar git push` 및 `npm test && git push` 모두와 일치합니다. hook은 모든 하위 명령이 일치할 때 실행되며 명령이 너무 복잡하여 구문 분석할 수 없을 때 항상 실행됩니다.

#### 명령 hook 필드

[공통 필드](#common-fields) 외에도 명령 hook은 이러한 필드를 허용합니다:

| 필드 | 필수 | 설명 |
| --- | --- | --- |
| `command` | 예 | 실행할 셸 명령 |
| `async` | 아니오 | `true` 인 경우 차단하지 않고 백그라운드에서 실행됩니다. [백그라운드에서 hook 실행](#run-hooks-in-the-background) 참조 |
| `asyncRewake` | 아니오 | `true` 인 경우 백그라운드에서 실행되고 종료 코드 2에서 Claude를 깨웁니다. `async` 를 의미합니다. hook의 stderr 또는 stderr이 비어 있으면 stdout이 Claude에 시스템 알림으로 표시되므로 장기 실행 백그라운드 실패에 반응할 수 있습니다 |
| `shell` | 아니오 | 이 hook에 사용할 셸. `"bash"` (기본값) 또는 `"powershell"` 을 허용합니다. `"powershell"` 을 설정하면 Windows에서 PowerShell을 통해 명령을 실행합니다. `CLAUDE_CODE_USE_POWERSHELL_TOOL` 이 필요하지 않습니다. hook이 PowerShell을 직접 생성하기 때문입니다 |

#### HTTP hook 필드

[공통 필드](#common-fields) 외에도 HTTP hook은 이러한 필드를 허용합니다:

| 필드 | 필수 | 설명 |
| --- | --- | --- |
| `url` | 예 | POST 요청을 전송할 URL |
| `headers` | 아니오 | 키-값 쌍으로 된 추가 HTTP 헤더. 값은 `$VAR_NAME` 또는 `${VAR_NAME}` 구문을 사용한 환경 변수 보간을 지원합니다. `allowedEnvVars` 에 나열된 변수만 해결됩니다 |
| `allowedEnvVars` | 아니오 | 헤더 값으로 보간될 수 있는 환경 변수 이름 목록. 나열되지 않은 변수에 대한 참조는 빈 문자열로 바뀝니다. 환경 변수 보간이 작동하려면 필수입니다 |

Claude Code는 hook의 [JSON 입력](#hook-input-and-output) 을 `Content-Type: application/json` 과 함께 POST 요청 본문으로 전송합니다. 응답 본문은 명령 hook과 동일한 [JSON 출력 형식](#json-output) 을 사용합니다.

오류 처리는 명령 hook과 다릅니다: 2xx가 아닌 응답, 연결 실패, 시간 초과는 모두 실행을 계속하도록 허용하는 차단하지 않는 오류를 생성합니다. 도구 호출을 차단하거나 권한을 거부하려면 `decision: "block"` 또는 `permissionDecision: "deny"` 를 포함하는 JSON 본문이 있는 2xx 응답을 반환합니다.

이 예제는 `PreToolUse` 이벤트를 로컬 검증 서비스로 전송하고 `MY_TOKEN` 환경 변수의 토큰으로 인증합니다:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "http",
            "url": "http://localhost:8080/hooks/pre-tool-use",
            "timeout": 30,
            "headers": {
              "Authorization": "Bearer $MY_TOKEN"
            },
            "allowedEnvVars": ["MY_TOKEN"]
          }
        ]
      }
    ]
  }
}
```

#### 프롬프트 및 에이전트 hook 필드

[공통 필드](#common-fields) 외에도 프롬프트 및 에이전트 hook은 이러한 필드를 허용합니다:

| 필드 | 필수 | 설명 |
| --- | --- | --- |
| `prompt` | 예 | 모델에 전송할 프롬프트 텍스트. hook 입력 JSON에 대한 자리 표시자로 `$ARGUMENTS` 사용 |
| `model` | 아니오 | 평가에 사용할 모델. 기본값은 빠른 모델 |

일치하는 모든 hook은 병렬로 실행되며 동일한 핸들러는 자동으로 중복 제거됩니다. 명령 hook은 명령 문자열로 중복 제거되고 HTTP hook은 URL로 중복 제거됩니다. 핸들러는 현재 디렉토리에서 Claude Code의 환경으로 실행됩니다. `$CLAUDE_CODE_REMOTE` 환경 변수는 원격 웹 환경에서 `"true"` 로 설정되고 로컬 CLI에서는 설정되지 않습니다.

### 경로별로 스크립트 참조

프로젝트 또는 plugin 루트를 기준으로 hook 스크립트를 참조하려면 환경 변수를 사용하세요. hook이 실행될 때의 작업 디렉토리와 관계없이:

- `$CLAUDE_PROJECT_DIR`: 프로젝트 루트. 공백이 있는 경로를 처리하려면 따옴표로 감싸세요.
- `${CLAUDE_PLUGIN_ROOT}`: plugin의 설치 디렉토리, [plugin](https://code.claude.com/docs/ko/plugins) 과 함께 번들된 스크립트의 경우. plugin 업데이트 시마다 변경됩니다.
- `${CLAUDE_PLUGIN_DATA}`: plugin의 [지속적 데이터 디렉토리](https://code.claude.com/docs/ko/plugins-reference#persistent-data-directory), plugin 업데이트를 거쳐 유지되어야 하는 종속성 및 상태의 경우.

- 프로젝트 스크립트
- Plugin 스크립트

이 예제는 `$CLAUDE_PROJECT_DIR` 을 사용하여 `Write` 또는 `Edit` 도구 호출 후 프로젝트의 `.claude/hooks/` 디렉토리에서 스타일 검사기를 실행합니다:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/check-style.sh"
          }
        ]
      }
    ]
  }
}
```

### Skill 및 에이전트의 Hook

설정 파일 및 plugin 외에도 hook은 frontmatter를 사용하여 [skill](https://code.claude.com/docs/ko/skills) 및 [subagent](https://code.claude.com/docs/ko/sub-agents) 에서 직접 정의할 수 있습니다. 이러한 hook은 컴포넌트의 수명 주기로 범위가 지정되며 해당 컴포넌트가 활성화되어 있을 때만 실행됩니다.

모든 hook 이벤트가 지원됩니다. subagent의 경우 `Stop` hook은 subagent가 완료될 때 발생하는 이벤트이므로 자동으로 `SubagentStop` 으로 변환됩니다.

Hook은 설정 기반 hook과 동일한 구성 형식을 사용하지만 컴포넌트의 수명으로 범위가 지정되고 완료될 때 정리됩니다.

이 skill은 각 `Bash` 명령 전에 보안 검증 스크립트를 실행하는 `PreToolUse` hook을 정의합니다:

```yaml
---
name: secure-operations
description: Perform operations with security checks
hooks:
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "./scripts/security-check.sh"
---
```

에이전트는 YAML frontmatter에서 동일한 형식을 사용합니다.

### /hooks 메뉴

Claude Code에서 `/hooks` 를 입력하여 구성된 hook의 읽기 전용 브라우저를 엽니다. 메뉴는 구성된 hook 수가 있는 모든 hook 이벤트를 표시하고, matcher로 드릴다운할 수 있으며, 각 hook 핸들러의 전체 세부 정보를 표시합니다. 구성을 확인하거나, hook이 어느 설정 파일에서 왔는지 확인하거나, hook의 명령, 프롬프트 또는 URL을 검사하는 데 사용합니다.

메뉴는 네 가지 hook 유형을 표시합니다: `command`, `prompt`, `agent`, `http`. 각 hook은 소스를 나타내는 `[type]` 접두사와 레이블이 지정됩니다:

- `User`: `~/.claude/settings.json` 에서
- `Project`: `.claude/settings.json` 에서
- `Local`: `.claude/settings.local.json` 에서
- `Plugin`: plugin의 `hooks/hooks.json` 에서
- `Session`: 현재 세션을 위해 메모리에 등록됨
- `Built-in`: Claude Code에 의해 내부적으로 등록됨

hook을 선택하면 이벤트, matcher, 유형, 소스 파일, 전체 명령, 프롬프트 또는 URL을 표시하는 세부 정보 보기가 열립니다. 메뉴는 읽기 전용입니다: hook을 추가, 수정 또는 제거하려면 설정 JSON을 직접 편집하세요.

### Hook 비활성화 또는 제거

hook을 제거하려면 설정 JSON 파일에서 해당 항목을 삭제합니다.

모든 hook을 제거하지 않고 임시로 비활성화하려면 설정 파일에서 `"disableAllHooks": true` 를 설정합니다. 구성에 유지하면서 개별 hook을 비활성화할 수 있는 방법은 없습니다.

`disableAllHooks` 설정은 관리형 설정 계층을 준수합니다. 관리자가 관리형 정책 설정을 통해 hook을 구성한 경우 사용자, 프로젝트 또는 로컬 설정에서 설정된 `disableAllHooks` 는 해당 관리형 hook을 비활성화할 수 없습니다. 관리형 설정 수준에서 설정된 `disableAllHooks` 만 관리형 hook을 비활성화할 수 있습니다.

설정 파일의 hook에 대한 직접 편집은 일반적으로 파일 감시자에 의해 자동으로 선택됩니다.

## Hook 입출력

명령 hook은 stdin을 통해 JSON 데이터를 받고 종료 코드, stdout, stderr를 통해 결과를 전달합니다. HTTP hook은 POST 요청 본문으로 동일한 JSON을 받고 HTTP 응답 본문을 통해 결과를 전달합니다. 이 섹션에서는 모든 이벤트에 공통적인 필드와 동작을 다룹니다. [Hook 이벤트](#hook-events) 아래의 각 이벤트 섹션에는 특정 입력 스키마와 결정 제어 옵션이 포함됩니다.

### 공통 입력 필드

Hook 이벤트는 각 [hook 이벤트](#hook-events) 섹션에서 문서화된 이벤트 특정 필드 외에 이러한 필드를 JSON으로 받습니다. 명령 hook의 경우 이 JSON은 stdin을 통해 도착합니다. HTTP hook의 경우 POST 요청 본문으로 도착합니다.

| 필드 | 설명 |
| --- | --- |
| `session_id` | 현재 세션 식별자 |
| `transcript_path` | 대화 JSON 경로 |
| `cwd` | hook이 호출될 때의 현재 작업 디렉토리 |
| `permission_mode` | 현재 [권한 모드](https://code.claude.com/docs/ko/permissions#permission-modes): `"default"`, `"plan"`, `"acceptEdits"`, `"auto"`, `"dontAsk"` 또는 `"bypassPermissions"`. 모든 이벤트가 이 필드를 받는 것은 아닙니다: 각 이벤트의 JSON 예제를 확인하세요 |
| `hook_event_name` | 발생한 이벤트의 이름 |

`--agent` 로 실행하거나 subagent 내부에서 실행할 때 두 개의 추가 필드가 포함됩니다:

| 필드 | 설명 |
| --- | --- |
| `agent_id` | subagent의 고유 식별자. hook이 subagent 호출 내부에서 발생할 때만 존재합니다. 이를 사용하여 subagent hook 호출을 메인 스레드 호출과 구별합니다. |
| `agent_type` | 에이전트 이름 (예: `"Explore"` 또는 `"security-reviewer"`). 세션이 `--agent` 를 사용하거나 hook이 subagent 내부에서 발생할 때 존재합니다. subagent의 경우 subagent의 유형이 세션의 `--agent` 값보다 우선합니다. |

예를 들어 Bash 명령에 대한 `PreToolUse` hook은 stdin에서 다음을 받습니다:

```json
{
  "session_id": "abc123",
  "transcript_path": "/home/user/.claude/projects/.../transcript.jsonl",
  "cwd": "/home/user/my-project",
  "permission_mode": "default",
  "hook_event_name": "PreToolUse",
  "tool_name": "Bash",
  "tool_input": {
    "command": "npm test"
  }
}
```

`tool_name` 및 `tool_input` 필드는 이벤트 특정입니다. 각 [hook 이벤트](#hook-events) 섹션에서는 해당 이벤트의 추가 필드를 문서화합니다.

### 종료 코드 출력

hook 명령의 종료 코드는 Claude Code에 작업을 진행할지, 차단할지 또는 무시할지를 알려줍니다.

**종료 0** 은 성공을 의미합니다. Claude Code는 [JSON 출력 필드](#json-output) 에 대해 stdout을 구문 분석합니다. JSON 출력은 종료 0에서만 처리됩니다. 대부분의 이벤트에서 stdout은 디버그 로그에 기록되지만 트랜스크립트에는 표시되지 않습니다. 예외는 `UserPromptSubmit` 및 `SessionStart` 이며, 여기서 stdout은 Claude가 보고 작용할 수 있는 컨텍스트로 추가됩니다.

**종료 2** 는 차단 오류를 의미합니다. Claude Code는 stdout과 그 안의 JSON을 무시합니다. 대신 stderr 텍스트가 Claude에 오류 메시지로 피드백됩니다. 효과는 이벤트에 따라 다릅니다: `PreToolUse` 는 도구 호출을 차단하고 `UserPromptSubmit` 은 프롬프트를 거부합니다. 전체 목록은 [이벤트별 종료 코드 2 동작](#exit-code-2-behavior-per-event) 을 참조하세요.

**다른 종료 코드** 는 대부분의 hook 이벤트에 대한 차단하지 않는 오류입니다. 트랜스크립트는 `<hook name> hook error` 알림을 표시하고 stderr의 첫 번째 줄을 표시하므로 `--debug` 없이도 원인을 식별할 수 있습니다. 실행이 계속되고 전체 stderr은 디버그 로그에 기록됩니다.

예를 들어 위험한 Bash 명령을 차단하는 hook 명령 스크립트:

```shellscript
#!/bin/bash
# stdin에서 JSON 입력을 읽고 명령을 확인합니다
command=$(jq -r '.tool_input.command' < /dev/stdin)

if [[ "$command" == rm* ]]; then
  echo "Blocked: rm commands are not allowed" >&2
  exit 2  # 차단 오류: 도구 호출이 방지됨
fi

exit 0  # 성공: 도구 호출이 진행됨
```

대부분의 hook 이벤트에서 종료 코드 2만 작업을 차단합니다. Claude Code는 종료 코드 1을 차단하지 않는 오류로 취급하고 작업을 진행합니다. 1이 기존 Unix 실패 코드이지만 말입니다. hook이 정책을 적용하려면 `exit 2` 를 사용합니다. 예외는 `WorktreeCreate` 이며, 0이 아닌 종료 코드는 worktree 생성을 중단합니다.

#### 이벤트별 종료 코드 2 동작

종료 코드 2는 hook이 “멈춰, 이것을 하지 마”라고 신호하는 방식입니다. 효과는 이벤트에 따라 다릅니다. 일부 이벤트는 차단할 수 있는 작업을 나타내고 (아직 발생하지 않은 도구 호출처럼) 다른 이벤트는 이미 발생했거나 방지할 수 없는 것을 나타내기 때문입니다.

| Hook 이벤트 | 차단 가능? | 종료 코드 2에서 발생하는 것 |
| --- | --- | --- |
| `PreToolUse` | 예 | 도구 호출을 차단합니다 |
| `PermissionRequest` | 예 | 권한을 거부합니다 |
| `UserPromptSubmit` | 예 | 프롬프트 처리를 차단하고 프롬프트를 지웁니다 |
| `Stop` | 예 | Claude가 중지되는 것을 방지하고 대화를 계속합니다 |
| `SubagentStop` | 예 | subagent가 중지되는 것을 방지합니다 |
| `TeammateIdle` | 예 | 팀원이 유휴 상태가 되는 것을 방지합니다 (팀원이 계속 작업함) |
| `TaskCreated` | 예 | 작업 생성을 롤백합니다 |
| `TaskCompleted` | 예 | 작업이 완료로 표시되는 것을 방지합니다 |
| `ConfigChange` | 예 | 구성 변경이 적용되는 것을 차단합니다 (`policy_settings` 제외) |
| `StopFailure` | 아니오 | 출력과 종료 코드는 무시됩니다 |
| `PostToolUse` | 아니오 | Claude에 stderr을 표시합니다 (도구가 이미 실행됨) |
| `PostToolUseFailure` | 아니오 | Claude에 stderr을 표시합니다 (도구가 이미 실패함) |
| `PermissionDenied` | 아니오 | 종료 코드와 stderr은 무시됩니다 (거부가 이미 발생함). JSON `hookSpecificOutput.retry: true` 를 사용하여 모델이 재시도할 수 있음을 알립니다 |
| `Notification` | 아니오 | 사용자에게만 stderr을 표시합니다 |
| `SubagentStart` | 아니오 | 사용자에게만 stderr을 표시합니다 |
| `SessionStart` | 아니오 | 사용자에게만 stderr을 표시합니다 |
| `SessionEnd` | 아니오 | 사용자에게만 stderr을 표시합니다 |
| `CwdChanged` | 아니오 | 사용자에게만 stderr을 표시합니다 |
| `FileChanged` | 아니오 | 사용자에게만 stderr을 표시합니다 |
| `PreCompact` | 예 | 압축을 차단합니다 |
| `PostCompact` | 아니오 | 사용자에게만 stderr을 표시합니다 |
| `Elicitation` | 예 | elicitation을 거부합니다 |
| `ElicitationResult` | 예 | 응답을 차단합니다 (작업이 거부됨) |
| `WorktreeCreate` | 예 | 0이 아닌 종료 코드로 인해 worktree 생성이 실패합니다 |
| `WorktreeRemove` | 아니오 | 실패는 디버그 모드에서만 기록됩니다 |
| `InstructionsLoaded` | 아니오 | 종료 코드는 무시됩니다 |

### HTTP 응답 처리

HTTP hook은 종료 코드와 stdout 대신 HTTP 상태 코드와 응답 본문을 사용합니다:

- **2xx 빈 본문**: 성공, 종료 코드 0과 출력 없음과 동등
- **2xx 일반 텍스트 본문**: 성공, 텍스트가 컨텍스트로 추가됨
- **2xx JSON 본문**: 성공, 명령 hook과 동일한 [JSON 출력](#json-output) 스키마를 사용하여 구문 분석됨
- **2xx가 아닌 상태**: 차단하지 않는 오류, 실행이 계속됨
- **연결 실패 또는 시간 초과**: 차단하지 않는 오류, 실행이 계속됨

명령 hook과 달리 HTTP hook은 상태 코드만으로 차단 오류를 신호할 수 없습니다. 도구 호출을 차단하거나 권한을 거부하려면 적절한 결정 필드를 포함하는 JSON 본문이 있는 2xx 응답을 반환합니다.

### JSON 출력

종료 코드를 사용하면 허용 또는 차단할 수 있지만 JSON 출력은 더 세밀한 제어를 제공합니다. 종료 코드 2로 차단하는 대신 종료 0으로 JSON 객체를 stdout에 인쇄합니다. Claude Code는 해당 JSON에서 특정 필드를 읽어 차단, 허용 또는 사용자에게 에스컬레이션을 포함한 동작을 제어합니다.

hook당 하나의 접근 방식을 선택해야 합니다. 둘 다 선택하지 마세요: 종료 코드만 사용하여 신호하거나 종료 0으로 JSON을 인쇄하여 구조화된 제어를 합니다. Claude Code는 종료 0에서만 JSON을 처리합니다. 종료 2로 나가면 JSON은 무시됩니다.

hook의 stdout은 JSON 객체만 포함해야 합니다. 셸 프로필이 시작 시 텍스트를 인쇄하면 JSON 구문 분석을 방해할 수 있습니다. 문제 해결 가이드의 [JSON 검증 실패](https://code.claude.com/docs/ko/hooks-guide#json-validation-failed) 를 참조하세요.

컨텍스트에 주입된 hook 출력 (`additionalContext`, `systemMessage` 또는 일반 stdout)은 10,000자로 제한됩니다. 이 제한을 초과하는 출력은 파일에 저장되고 미리보기 및 파일 경로로 바뀌며, 큰 도구 결과가 처리되는 방식과 동일합니다.

JSON 객체는 세 가지 종류의 필드를 지원합니다:

- **`continue` 와 같은 범용 필드** 는 모든 이벤트에서 작동합니다. 이들은 아래 표에 나열되어 있습니다.
- \*\*최상위 `decision` 및 `reason` \*\*은 일부 이벤트에서 차단하거나 피드백을 제공하는 데 사용됩니다.
- \*\* `hookSpecificOutput` \*\*은 더 풍부한 제어가 필요한 이벤트를 위한 중첩 객체입니다. 이벤트 이름으로 설정된 `hookEventName` 필드가 필요합니다.

| 필드 | 기본값 | 설명 |
| --- | --- | --- |
| `continue` | `true` | `false` 인 경우 hook이 실행된 후 Claude가 완전히 중지됩니다. 모든 이벤트 특정 결정 필드보다 우선합니다 |
| `stopReason` | 없음 | `continue` 가 `false` 일 때 사용자에게 표시되는 메시지. Claude에는 표시되지 않음 |
| `suppressOutput` | `false` | `true` 인 경우 디버그 로그에서 stdout을 숨깁니다 |
| `systemMessage` | 없음 | 사용자에게 표시되는 경고 메시지 |

Claude를 이벤트 유형과 관계없이 완전히 중지하려면:

```json
{ "continue": false, "stopReason": "Build failed, fix errors before continuing" }
```

#### 결정 제어

모든 이벤트가 JSON을 통해 동작을 차단하거나 제어하는 것을 지원하는 것은 아닙니다. 그렇게 하는 이벤트는 각각 다른 필드 집합을 사용하여 해당 결정을 표현합니다. hook을 작성하기 전에 이 표를 빠른 참조로 사용하세요:

| 이벤트 | 결정 패턴 | 주요 필드 |
| --- | --- | --- |
| UserPromptSubmit, PostToolUse, PostToolUseFailure, Stop, SubagentStop, ConfigChange, PreCompact | 최상위 `decision` | `decision: "block"`, `reason` |
| TeammateIdle, TaskCreated, TaskCompleted | 종료 코드 또는 `continue: false` | 종료 코드 2는 stderr 피드백으로 작업을 차단합니다. JSON `{"continue": false, "stopReason": "..."}` 또한 팀원을 완전히 중지하여 `Stop` hook 동작과 일치합니다 |
| PreToolUse | `hookSpecificOutput` | `permissionDecision` (allow/deny/ask/defer), `permissionDecisionReason` |
| PermissionRequest | `hookSpecificOutput` | `decision.behavior` (allow/deny) |
| PermissionDenied | `hookSpecificOutput` | `retry: true` 는 모델이 거부된 도구 호출을 재시도할 수 있음을 알립니다 |
| WorktreeCreate | 경로 반환 | 명령 hook은 stdout에 경로를 인쇄합니다; HTTP hook은 `hookSpecificOutput.worktreePath` 를 반환합니다. hook 실패 또는 누락된 경로는 생성을 실패합니다 |
| Elicitation | `hookSpecificOutput` | `action` (accept/decline/cancel), `content` (form field values for accept) |
| ElicitationResult | `hookSpecificOutput` | `action` (accept/decline/cancel), `content` (form field values override) |
| WorktreeRemove, Notification, SessionEnd, PostCompact, InstructionsLoaded, StopFailure, CwdChanged, FileChanged | 없음 | 결정 제어 없음. 로깅 또는 정리와 같은 부작용에 사용됨 |

다음은 각 패턴의 실제 예입니다:

- 최상위 결정
- PreToolUse
- PermissionRequest

`UserPromptSubmit`, `PostToolUse`, `PostToolUseFailure`, `Stop`, `SubagentStop`, `ConfigChange`, `PreCompact` 에서 사용됩니다. 유일한 값은 `"block"` 입니다. 작업을 진행하도록 허용하려면 JSON에서 `decision` 을 생략하거나 JSON 없이 종료 0으로 나갑니다:

```json
{
  "decision": "block",
  "reason": "Test suite must pass before proceeding"
}
```

Bash 명령 검증, 프롬프트 필터링, 자동 승인 스크립트를 포함한 확장 예제는 가이드의 [자동화할 수 있는 것](https://code.claude.com/docs/ko/hooks-guide#what-you-can-automate) 과 [Bash 명령 검증기 참조 구현](https://github.com/anthropics/claude-code/blob/main/examples/hooks/bash_command_validator_example.py) 을 참조하세요.

## Hook 이벤트

각 이벤트는 hook이 실행될 수 있는 Claude Code의 수명 주기의 지점에 해당합니다. 아래 섹션은 수명 주기와 일치하도록 정렬됩니다: 세션 설정에서 에이전트 루프를 거쳐 세션 종료까지. 각 섹션에서는 이벤트가 언제 발생하는지, 지원하는 matcher, 받는 JSON 입력, 출력을 통해 동작을 제어하는 방법을 설명합니다.

### SessionStart

Claude Code가 새 세션을 시작하거나 기존 세션을 재개할 때 실행됩니다. 기존 문제나 코드베이스의 최근 변경 사항과 같은 개발 컨텍스트를 로드하거나 환경 변수를 설정하는 데 유용합니다. 스크립트가 필요하지 않은 정적 컨텍스트의 경우 [CLAUDE.md](https://code.claude.com/docs/ko/memory) 를 사용하세요.

SessionStart는 모든 세션에서 실행되므로 이러한 hook을 빠르게 유지하세요. `type: "command"` hook만 지원됩니다.

matcher 값은 세션이 시작된 방식에 해당합니다:

| Matcher | 언제 발생하는지 |
| --- | --- |
| `startup` | 새 세션 |
| `resume` | `--resume`, `--continue` 또는 `/resume` |
| `clear` | `/clear` |
| `compact` | 자동 또는 수동 압축 |

#### SessionStart 입력

[공통 입력 필드](#common-input-fields) 외에도 SessionStart hook은 `source`, `model`, 선택적으로 `agent_type` 을 받습니다. `source` 필드는 세션이 시작된 방식을 나타냅니다: 새 세션의 경우 `"startup"`, 재개된 세션의 경우 `"resume"`, `/clear` 후 `"clear"`, 압축 후 `"compact"`. `model` 필드는 모델 식별자를 포함합니다. `claude --agent <name>` 으로 Claude Code를 시작하면 `agent_type` 필드에 에이전트 이름이 포함됩니다.

```json
{
  "session_id": "abc123",
  "transcript_path": "/Users/.../.claude/projects/.../00893aaf-19fa-41d2-8238-13269b9b3ca0.jsonl",
  "cwd": "/Users/...",
  "hook_event_name": "SessionStart",
  "source": "startup",
  "model": "claude-sonnet-4-6"
}
```

#### SessionStart 결정 제어

hook 스크립트가 stdout에 인쇄하는 모든 텍스트는 Claude의 컨텍스트로 추가됩니다. 모든 hook에 사용 가능한 [JSON 출력 필드](#json-output) 외에도 이러한 이벤트 특정 필드를 반환할 수 있습니다:

| 필드 | 설명 |
| --- | --- |
| `additionalContext` | Claude의 컨텍스트에 추가되는 문자열. 여러 hook의 값이 연결됨 |

```json
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "My additional context here"
  }
}
```

#### 환경 변수 유지

SessionStart hook은 `CLAUDE_ENV_FILE` 환경 변수에 액세스할 수 있으며, 이는 후속 Bash 명령에 대한 환경 변수를 유지할 수 있는 파일 경로를 제공합니다.

개별 환경 변수를 설정하려면 `CLAUDE_ENV_FILE` 에 `export` 문을 작성합니다. 다른 hook에서 설정한 변수를 유지하려면 추가 (`>>`)를 사용합니다:

```shellscript
#!/bin/bash

if [ -n "$CLAUDE_ENV_FILE" ]; then
  echo 'export NODE_ENV=production' >> "$CLAUDE_ENV_FILE"
  echo 'export DEBUG_LOG=true' >> "$CLAUDE_ENV_FILE"
  echo 'export PATH="$PATH:./node_modules/.bin"' >> "$CLAUDE_ENV_FILE"
fi

exit 0
```

설정 명령의 환경 변경을 모두 캡처하려면 내보낸 변수를 이전과 이후에 비교합니다:

```shellscript
#!/bin/bash

ENV_BEFORE=$(export -p | sort)

# 환경을 수정하는 설정 명령을 실행합니다
source ~/.nvm/nvm.sh
nvm use 20

if [ -n "$CLAUDE_ENV_FILE" ]; then
  ENV_AFTER=$(export -p | sort)
  comm -13 <(echo "$ENV_BEFORE") <(echo "$ENV_AFTER") >> "$CLAUDE_ENV_FILE"
fi

exit 0
```

이 파일에 작성된 모든 변수는 세션 중에 Claude Code가 실행하는 모든 후속 Bash 명령에서 사용 가능합니다.

`CLAUDE_ENV_FILE` 은 SessionStart, [CwdChanged](#cwdchanged), [FileChanged](#filechanged) hook에 사용 가능합니다. 다른 hook 유형은 이 변수에 액세스할 수 없습니다.

### InstructionsLoaded

`CLAUDE.md` 또는 `.claude/rules/*.md` 파일이 컨텍스트에 로드될 때 발생합니다. 이 이벤트는 세션 시작 시 즉시 로드된 파일에 대해 발생하고 나중에 파일이 지연 로드될 때 다시 발생합니다. 예를 들어 Claude가 중첩된 `CLAUDE.md` 를 포함하는 하위 디렉토리에 액세스할 때 또는 `paths:` frontmatter가 있는 조건부 규칙이 일치할 때입니다. hook은 차단 또는 결정 제어를 지원하지 않습니다. 관찰성 목적으로 비동기적으로 실행됩니다.

matcher는 `load_reason` 에 대해 실행됩니다. 예를 들어 `"matcher": "session_start"` 를 사용하여 세션 시작 시에만 로드된 파일에 대해 발생하거나 `"matcher": "path_glob_match|nested_traversal"` 을 사용하여 지연 로드에만 발생합니다.

#### InstructionsLoaded 입력

[공통 입력 필드](#common-input-fields) 외에도 InstructionsLoaded hook은 이러한 필드를 받습니다:

| 필드 | 설명 |
| --- | --- |
| `file_path` | 로드된 명령 파일의 절대 경로 |
| `memory_type` | 파일의 범위: `"User"`, `"Project"`, `"Local"` 또는 `"Managed"` |
| `load_reason` | 파일이 로드된 이유: `"session_start"`, `"nested_traversal"`, `"path_glob_match"`, `"include"` 또는 `"compact"`. `"compact"` 값은 압축 이벤트 후 명령 파일이 다시 로드될 때 발생합니다 |
| `globs` | 파일의 `paths:` frontmatter의 경로 glob 패턴 (있는 경우). `path_glob_match` 로드에만 존재 |
| `trigger_file_path` | 지연 로드를 트리거한 파일의 경로 |
| `parent_file_path` | 이 파일을 포함한 부모 명령 파일의 경로, `include` 로드의 경우 |

```json
{
  "session_id": "abc123",
  "transcript_path": "/Users/.../.claude/projects/.../transcript.jsonl",
  "cwd": "/Users/my-project",
  "hook_event_name": "InstructionsLoaded",
  "file_path": "/Users/my-project/CLAUDE.md",
  "memory_type": "Project",
  "load_reason": "session_start"
}
```

#### InstructionsLoaded 결정 제어

InstructionsLoaded hook은 결정 제어가 없습니다. 명령 로드를 차단하거나 수정할 수 없습니다. 감사 로깅, 규정 준수 추적 또는 관찰성을 위해 이 이벤트를 사용합니다.

### UserPromptSubmit

사용자가 프롬프트를 제출할 때, Claude가 처리하기 전에 실행됩니다. 이를 통해 프롬프트/대화를 기반으로 추가 컨텍스트를 추가하거나, 프롬프트를 검증하거나, 특정 유형의 프롬프트를 차단할 수 있습니다.

#### UserPromptSubmit 입력

[공통 입력 필드](#common-input-fields) 외에도 UserPromptSubmit hook은 사용자가 제출한 텍스트를 포함하는 `prompt` 필드를 받습니다.

```json
{
  "session_id": "abc123",
  "transcript_path": "/Users/.../.claude/projects/.../00893aaf-19fa-41d2-8238-13269b9b3ca0.jsonl",
  "cwd": "/Users/...",
  "permission_mode": "default",
  "hook_event_name": "UserPromptSubmit",
  "prompt": "Write a function to calculate the factorial of a number"
}
```

#### UserPromptSubmit 결정 제어

`UserPromptSubmit` hook은 사용자 프롬프트 처리 여부를 제어하고 컨텍스트를 추가할 수 있습니다. 모든 [JSON 출력 필드](#json-output) 를 사용할 수 있습니다.

종료 코드 0에서 대화에 컨텍스트를 추가하는 두 가지 방법이 있습니다:

- **일반 텍스트 stdout**: stdout에 작성된 JSON이 아닌 텍스트는 컨텍스트로 추가됩니다
- **`additionalContext` 가 있는 JSON**: 더 많은 제어를 위해 아래 JSON 형식을 사용합니다. `additionalContext` 필드는 컨텍스트로 추가됩니다

일반 stdout은 트랜스크립트에 hook 출력으로 표시됩니다. `additionalContext` 필드는 더 신중하게 추가됩니다.

프롬프트를 차단하려면 `decision` 을 `"block"` 으로 설정한 JSON 객체를 반환합니다:

| 필드 | 설명 |
| --- | --- |
| `decision` | `"block"` 은 프롬프트가 처리되는 것을 방지하고 컨텍스트에서 지웁니다. 생략하여 프롬프트를 진행하도록 허용 |
| `reason` | `decision` 이 `"block"` 일 때 사용자에게 표시됩니다. 컨텍스트에 추가되지 않음 |
| `additionalContext` | Claude의 컨텍스트에 추가되는 문자열 |
| `sessionTitle` | 세션 제목을 설정합니다. `/rename` 과 동일한 효과입니다. 프롬프트 내용을 기반으로 세션을 자동으로 이름 지정하는 데 사용합니다 |

```json
{
  "decision": "block",
  "reason": "Explanation for decision",
  "hookSpecificOutput": {
    "hookEventName": "UserPromptSubmit",
    "additionalContext": "My additional context here",
    "sessionTitle": "My session title"
  }
}
```

JSON 형식은 간단한 사용 사례에는 필요하지 않습니다. 컨텍스트를 추가하려면 종료 코드 0으로 stdout에 일반 텍스트를 인쇄할 수 있습니다. 프롬프트를 차단하거나 더 구조화된 제어가 필요할 때 JSON을 사용합니다.

### PreToolUse

Claude가 도구 매개변수를 생성한 후 도구 호출을 처리하기 전에 실행됩니다. 도구 이름에서 일치합니다: `Bash`, `Edit`, `Write`, `Read`, `Glob`, `Grep`, `Agent`, `WebFetch`, `WebSearch`, `AskUserQuestion`, `ExitPlanMode`, 모든 [MCP 도구 이름](#match-mcp-tools).

[PreToolUse 결정 제어](#pretooluse-decision-control) 를 사용하여 도구 사용을 허용, 거부, 요청 또는 연기합니다.

#### PreToolUse 입력

[공통 입력 필드](#common-input-fields) 외에도 PreToolUse hook은 `tool_name`, `tool_input`, `tool_use_id` 를 받습니다. `tool_input` 필드는 도구에 따라 다릅니다:

##### Bash

셸 명령을 실행합니다.

| 필드 | 유형 | 예제 | 설명 |
| --- | --- | --- | --- |
| `command` | 문자열 | `"npm test"` | 실행할 셸 명령 |
| `description` | 문자열 | `"Run test suite"` | 명령이 수행하는 작업의 선택적 설명 |
| `timeout` | 숫자 | `120000` | 선택적 시간 초과 (밀리초) |
| `run_in_background` | 부울 | `false` | 명령을 백그라운드에서 실행할지 여부 |

##### Write

파일을 생성하거나 덮어씁니다.

| 필드 | 유형 | 예제 | 설명 |
| --- | --- | --- | --- |
| `file_path` | 문자열 | `"/path/to/file.txt"` | 쓸 파일의 절대 경로 |
| `content` | 문자열 | `"file content"` | 파일에 쓸 내용 |

##### Edit

기존 파일의 문자열을 바꿉니다.

| 필드 | 유형 | 예제 | 설명 |
| --- | --- | --- | --- |
| `file_path` | 문자열 | `"/path/to/file.txt"` | 편집할 파일의 절대 경로 |
| `old_string` | 문자열 | `"original text"` | 찾아 바꿀 텍스트 |
| `new_string` | 문자열 | `"replacement text"` | 대체 텍스트 |
| `replace_all` | 부울 | `false` | 모든 발생을 바꿀지 여부 |

##### Read

파일 내용을 읽습니다.

| 필드 | 유형 | 예제 | 설명 |
| --- | --- | --- | --- |
| `file_path` | 문자열 | `"/path/to/file.txt"` | 읽을 파일의 절대 경로 |
| `offset` | 숫자 | `10` | 읽기를 시작할 선택적 줄 번호 |
| `limit` | 숫자 | `50` | 읽을 선택적 줄 수 |

##### Glob

glob 패턴과 일치하는 파일을 찾습니다.

| 필드 | 유형 | 예제 | 설명 |
| --- | --- | --- | --- |
| `pattern` | 문자열 | `"**/*.ts"` | 파일과 일치시킬 glob 패턴 |
| `path` | 문자열 | `"/path/to/dir"` | 검색할 선택적 디렉토리. 기본값은 현재 작업 디렉토리 |

##### Grep

정규식으로 파일 내용을 검색합니다.

| 필드 | 유형 | 예제 | 설명 |
| --- | --- | --- | --- |
| `pattern` | 문자열 | `"TODO.*fix"` | 검색할 정규식 패턴 |
| `path` | 문자열 | `"/path/to/dir"` | 검색할 선택적 파일 또는 디렉토리 |
| `glob` | 문자열 | `"*.ts"` | 파일을 필터링할 선택적 glob 패턴 |
| `output_mode` | 문자열 | `"content"` | `"content"`, `"files_with_matches"` 또는 `"count"`. 기본값은 `"files_with_matches"` |
| `-i` | 부울 | `true` | 대소문자를 구분하지 않는 검색 |
| `multiline` | 부울 | `false` | 다중 줄 일치 활성화 |

##### WebFetch

웹 콘텐츠를 가져오고 처리합니다.

| 필드 | 유형 | 예제 | 설명 |
| --- | --- | --- | --- |
| `url` | 문자열 | `"https://example.com/api"` | 콘텐츠를 가져올 URL |
| `prompt` | 문자열 | `"Extract the API endpoints"` | 가져온 콘텐츠에서 실행할 프롬프트 |

##### WebSearch

웹을 검색합니다.

| 필드 | 유형 | 예제 | 설명 |
| --- | --- | --- | --- |
| `query` | 문자열 | `"react hooks best practices"` | 검색 쿼리 |
| `allowed_domains` | 배열 | `["docs.example.com"]` | 선택적: 이러한 도메인의 결과만 포함 |
| `blocked_domains` | 배열 | `["spam.example.com"]` | 선택적: 이러한 도메인의 결과 제외 |

##### Agent

[subagent](https://code.claude.com/docs/ko/sub-agents) 를 생성합니다.

| 필드 | 유형 | 예제 | 설명 |
| --- | --- | --- | --- |
| `prompt` | 문자열 | `"Find all API endpoints"` | 에이전트가 수행할 작업 |
| `description` | 문자열 | `"Find API endpoints"` | 작업의 짧은 설명 |
| `subagent_type` | 문자열 | `"Explore"` | 사용할 특화된 에이전트의 유형 |
| `model` | 문자열 | `"sonnet"` | 기본값을 재정의할 선택적 모델 별칭 |

##### AskUserQuestion

사용자에게 1~4개의 객관식 질문을 합니다.

| 필드 | 유형 | 예제 | 설명 |
| --- | --- | --- | --- |
| `questions` | 배열 | `[{"question": "Which framework?", "header": "Framework", "options": [{"label": "React"}], "multiSelect": false}]` | 제시할 질문, 각각 `question` 문자열, 짧은 `header`, `options` 배열, 선택적 `multiSelect` 플래그 |
| `answers` | 객체 | `{"Which framework?": "React"}` | 선택적. 질문 텍스트를 선택한 옵션 레이블로 매핑합니다. 다중 선택 답변은 쉼표로 레이블을 결합합니다. Claude는 이 필드를 설정하지 않습니다. `updatedInput` 을 통해 프로그래밍 방식으로 답변을 제공하세요 |

#### PreToolUse 결정 제어

`PreToolUse` hook은 도구 호출 진행 여부를 제어할 수 있습니다. 최상위 `decision` 필드를 사용하는 다른 hook과 달리 PreToolUse는 `hookSpecificOutput` 객체 내에 결정을 반환합니다. 이는 더 풍부한 제어를 제공합니다: 네 가지 결과 (허용, 거부, 요청 또는 연기) 및 실행 전에 도구 입력을 수정하는 기능.

| 필드 | 설명 |
| --- | --- |
| `permissionDecision` | `"allow"` 는 권한 시스템을 우회하고, `"deny"` 는 도구 호출을 방지하고, `"ask"` 는 사용자에게 확인을 요청하고, `"defer"` 는 나중에 재개하도록 연기합니다. [권한 거부 및 요청 규칙](https://code.claude.com/docs/ko/permissions#manage-permissions) 은 hook이 `"allow"` 를 반환할 때도 여전히 적용됩니다 |
| `permissionDecisionReason` | `"allow"` 및 `"ask"` 의 경우 사용자에게 표시되지만 Claude에는 표시되지 않습니다. `"deny"` 의 경우 Claude에 표시됩니다. `"defer"` 의 경우 무시됩니다 |
| `updatedInput` | 실행 전에 도구의 입력 매개변수를 수정합니다. 전체 입력 객체를 바꾸므로 변경되지 않은 필드를 수정된 필드와 함께 포함합니다. `"allow"` 와 결합하여 자동 승인하거나 `"ask"` 와 결합하여 수정된 입력을 사용자에게 표시합니다. `"defer"` 의 경우 무시됩니다 |
| `additionalContext` | 도구가 실행되기 전에 Claude의 컨텍스트에 추가되는 문자열. `"defer"` 의 경우 무시됩니다 |

hook이 `"ask"` 를 반환하면 사용자에게 표시되는 권한 프롬프트에는 hook이 어디에서 왔는지를 나타내는 레이블이 포함됩니다: 예를 들어 `[User]`, `[Project]`, `[Plugin]` 또는 `[Local]`. 이는 사용자가 어느 구성 소스가 확인을 요청하는지 이해하는 데 도움이 됩니다.

```json
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "allow",
    "permissionDecisionReason": "My reason here",
    "updatedInput": {
      "field_to_modify": "new value"
    },
    "additionalContext": "Current environment: production. Proceed with caution."
  }
}
```

`AskUserQuestion` 및 `ExitPlanMode` 는 사용자 상호 작용이 필요하며 일반적으로 [비대화형 모드](https://code.claude.com/docs/ko/headless) 에서 `-p` 플래그로 차단합니다. `permissionDecision: "allow"` 를 `updatedInput` 과 함께 반환하면 해당 요구 사항을 충족합니다: hook은 stdin에서 도구의 입력을 읽고 자신의 UI를 통해 답변을 수집하고 `updatedInput` 에서 반환하여 도구가 프롬프트 없이 실행되도록 합니다. `"allow"` 만 반환하는 것은 이러한 도구에 충분하지 않습니다. `AskUserQuestion` 의 경우 원본 `questions` 배열을 에코백하고 각 질문의 텍스트를 선택한 답변으로 매핑하는 [`answers`](#askuserquestion) 객체를 추가합니다.

PreToolUse는 이전에 최상위 `decision` 및 `reason` 필드를 사용했지만 이 이벤트에는 더 이상 사용되지 않습니다. 대신 `hookSpecificOutput.permissionDecision` 및 `hookSpecificOutput.permissionDecisionReason` 을 사용합니다. 더 이상 사용되지 않는 값 `"approve"` 및 `"block"` 은 각각 `"allow"` 및 `"deny"` 로 매핑됩니다. PostToolUse 및 Stop과 같은 다른 이벤트는 계속 최상위 `decision` 및 `reason` 을 현재 형식으로 사용합니다.

#### 도구 호출을 나중에 재개하도록 연기

`"defer"` 는 Claude Code를 subprocess로 실행하고 JSON 출력을 읽는 Agent SDK 앱 또는 Claude Code 위에 구축된 사용자 정의 UI와 같은 통합을 위한 것입니다. 이를 통해 호출 프로세스가 Claude를 도구 호출에서 일시 중지하고 자신의 인터페이스를 통해 입력을 수집하고 중단된 위치에서 재개할 수 있습니다. Claude Code는 [비대화형 모드](https://code.claude.com/docs/ko/headless) 에서 `-p` 플래그를 사용할 때만 이 값을 준수합니다. 대화형 세션에서는 경고를 기록하고 hook 결과를 무시합니다.

`defer` 값은 Claude Code v2.1.89 이상이 필요합니다. 이전 버전은 이를 인식하지 못하고 도구는 일반 권한 흐름을 통해 진행됩니다.

일반적인 경우는 `AskUserQuestion` 도구입니다: Claude가 사용자에게 뭔가를 묻고 싶지만 답변할 터미널이 없습니다. 왕복은 다음과 같이 작동합니다:

1. Claude가 `AskUserQuestion` 을 호출합니다. `PreToolUse` hook이 발생합니다.
2. hook이 `permissionDecision: "defer"` 를 반환합니다. 도구가 실행되지 않습니다. 프로세스는 `stop_reason: "tool_deferred"` 로 종료되고 보류 중인 도구 호출이 트랜스크립트에 유지됩니다.
3. 호출 프로세스는 SDK 결과에서 `deferred_tool_use` 를 읽고 자신의 UI에서 질문을 표시하고 답변을 기다립니다.
4. 호출 프로세스는 `claude -p --resume <session-id>` 를 실행합니다. 동일한 도구 호출이 `PreToolUse` 를 다시 발생시킵니다.
5. hook이 `permissionDecision: "allow"` 를 `updatedInput` 의 답변과 함께 반환합니다. 도구가 실행되고 Claude가 계속됩니다.

`deferred_tool_use` 필드는 도구의 `id`, `name`, `input` 을 전달합니다. `input` 은 실행 전에 캡처된 도구 호출을 위해 Claude가 생성한 매개변수입니다:

```json
{
  "type": "result",
  "subtype": "success",
  "stop_reason": "tool_deferred",
  "session_id": "abc123",
  "deferred_tool_use": {
    "id": "toolu_01abc",
    "name": "AskUserQuestion",
    "input": { "questions": [{ "question": "Which framework?", "header": "Framework", "options": [{"label": "React"}, {"label": "Vue"}], "multiSelect": false }] }
  }
}
```

시간 초과 또는 재시도 제한이 없습니다. 세션은 재개할 때까지 디스크에 유지됩니다. 재개할 때 답변이 준비되지 않으면 hook이 `"defer"` 를 다시 반환할 수 있고 프로세스는 동일한 방식으로 종료됩니다. 호출 프로세스는 결국 `"allow"` 또는 `"deny"` 를 반환하여 루프를 끝낼 시기를 제어합니다.

연기된 도구가 재개할 때 더 이상 사용 가능하지 않으면 프로세스는 `stop_reason: "tool_deferred_unavailable"` 과 `is_error: true` 로 종료되고 hook이 발생하기 전에 종료됩니다. 이는 도구를 제공한 MCP 서버가 재개된 세션에 연결되지 않을 때 발생합니다. `deferred_tool_use` 페이로드는 여전히 포함되므로 어느 도구가 누락되었는지 식별할 수 있습니다.

`--resume` 은 이전 세션의 권한 모드를 복원하지 않습니다. 도구가 연기되었을 때 활성화된 것과 동일한 `--permission-mode` 플래그를 재개할 때 전달합니다. Claude Code는 모드가 다르면 경고를 기록합니다.

### PermissionRequest

사용자에게 권한 대화 상자가 표시될 때 실행됩니다. [PermissionRequest 결정 제어](#permissionrequest-decision-control) 를 사용하여 사용자를 대신하여 허용하거나 거부합니다.

도구 이름에서 일치합니다. PreToolUse와 동일한 값입니다.

#### PermissionRequest 입력

PermissionRequest hook은 PreToolUse hook과 같은 `tool_name` 및 `tool_input` 필드를 받지만 `tool_use_id` 는 없습니다. 선택적 `permission_suggestions` 배열에는 사용자가 권한 대화 상자에서 일반적으로 볼 수 있는 “항상 허용” 옵션이 포함됩니다. 차이점은 hook이 발생할 때입니다: PermissionRequest hook은 권한 대화 상자가 사용자에게 표시되려고 할 때 실행되고, PreToolUse hook은 권한 상태와 관계없이 도구 실행 전에 실행됩니다.

```json
{
  "session_id": "abc123",
  "transcript_path": "/Users/.../.claude/projects/.../00893aaf-19fa-41d2-8238-13269b9b3ca0.jsonl",
  "cwd": "/Users/...",
  "permission_mode": "default",
  "hook_event_name": "PermissionRequest",
  "tool_name": "Bash",
  "tool_input": {
    "command": "rm -rf node_modules",
    "description": "Remove node_modules directory"
  },
  "permission_suggestions": [
    {
      "type": "addRules",
      "rules": [{ "toolName": "Bash", "ruleContent": "rm -rf node_modules" }],
      "behavior": "allow",
      "destination": "localSettings"
    }
  ]
}
```

#### PermissionRequest 결정 제어

`PermissionRequest` hook은 권한 요청을 허용하거나 거부할 수 있습니다. 모든 hook에 사용 가능한 [JSON 출력 필드](#json-output) 외에도 hook 스크립트는 이러한 이벤트 특정 필드가 있는 `decision` 객체를 반환할 수 있습니다:

| 필드 | 설명 |
| --- | --- |
| `behavior` | `"allow"` 는 권한을 부여하고, `"deny"` 는 거부합니다. [권한 거부 및 요청 규칙](https://code.claude.com/docs/ko/permissions#manage-permissions) 은 여전히 평가되므로 hook이 `"allow"` 를 반환해도 일치하는 거부 규칙을 재정의하지 않습니다 |
| `updatedInput` | `"allow"` 만 해당: 실행 전에 도구의 입력 매개변수를 수정합니다. 전체 입력 객체를 바꾸므로 변경되지 않은 필드를 수정된 필드와 함께 포함합니다. 수정된 입력은 거부 및 요청 규칙에 대해 다시 평가됩니다 |
| `updatedPermissions` | `"allow"` 만 해당: 적용할 [권한 업데이트 항목](#permission-update-entries) 배열, 예를 들어 허용 규칙 추가 또는 세션 권한 모드 변경 |
| `message` | `"deny"` 만 해당: Claude에 권한이 거부된 이유를 알립니다 |
| `interrupt` | `"deny"` 만 해당: `true` 인 경우 Claude를 중지합니다 |

```json
{
  "hookSpecificOutput": {
    "hookEventName": "PermissionRequest",
    "decision": {
      "behavior": "allow",
      "updatedInput": {
        "command": "npm run lint"
      }
    }
  }
}
```

#### 권한 업데이트 항목

`updatedPermissions` 출력 필드와 [`permission_suggestions` 입력 필드](#permissionrequest-input) 모두 동일한 항목 객체 배열을 사용합니다. 각 항목에는 다른 필드를 결정하는 `type` 과 변경이 작성되는 위치를 제어하는 `destination` 이 있습니다.

| `type` | 필드 | 효과 |
| --- | --- | --- |
| `addRules` | `rules`, `behavior`, `destination` | 권한 규칙을 추가합니다. `rules` 는 `{toolName, ruleContent?}` 객체의 배열입니다. 전체 도구와 일치하려면 `ruleContent` 를 생략합니다. `behavior` 는 `"allow"`, `"deny"` 또는 `"ask"` 입니다 |
| `replaceRules` | `rules`, `behavior`, `destination` | 주어진 `behavior` 의 모든 규칙을 `destination` 에서 제공된 `rules` 로 바꿉니다 |
| `removeRules` | `rules`, `behavior`, `destination` | 주어진 `behavior` 의 일치하는 규칙을 제거합니다 |
| `setMode` | `mode`, `destination` | 권한 모드를 변경합니다. 유효한 모드는 `default`, `acceptEdits`, `dontAsk`, `bypassPermissions`, `plan` 입니다 |
| `addDirectories` | `directories`, `destination` | 작업 디렉토리를 추가합니다. `directories` 는 경로 문자열의 배열입니다 |
| `removeDirectories` | `directories`, `destination` | 작업 디렉토리를 제거합니다 |

`setMode` 와 `bypassPermissions` 는 세션이 이미 bypass 모드를 사용 가능하게 시작된 경우에만 적용됩니다: `--dangerously-skip-permissions`, `--permission-mode bypassPermissions`, `--allow-dangerously-skip-permissions`, 또는 설정의 `permissions.defaultMode: "bypassPermissions"`, 그리고 모드가 [`permissions.disableBypassPermissionsMode`](https://code.claude.com/docs/ko/permissions#managed-settings) 에 의해 비활성화되지 않은 경우입니다. 그렇지 않으면 업데이트는 작동하지 않습니다. `bypassPermissions` 는 `destination` 과 관계없이 `defaultMode` 로 절대 유지되지 않습니다.

모든 항목의 `destination` 필드는 변경이 메모리에만 유지되는지 또는 설정 파일에 유지되는지를 결정합니다.

| `destination` | 쓰기 대상 |
| --- | --- |
| `session` | 메모리 전용, 세션이 끝나면 삭제됨 |
| `localSettings` | `.claude/settings.local.json` |
| `projectSettings` | `.claude/settings.json` |
| `userSettings` | `~/.claude/settings.json` |

hook은 받은 `permission_suggestions` 중 하나를 자신의 `updatedPermissions` 출력으로 에코할 수 있으며, 이는 사용자가 대화 상자에서 해당 “항상 허용” 옵션을 선택하는 것과 동등합니다.

### PostToolUse

도구가 성공적으로 완료된 직후 실행됩니다.

도구 이름에서 일치합니다. PreToolUse와 동일한 값입니다.

#### PostToolUse 입력

`PostToolUse` hook은 도구가 이미 성공적으로 실행된 후에 발생합니다. 입력에는 도구에 전송된 인수인 `tool_input` 과 반환한 결과인 `tool_response` 가 모두 포함됩니다. 둘 다의 정확한 스키마는 도구에 따라 다릅니다.

```json
{
  "session_id": "abc123",
  "transcript_path": "/Users/.../.claude/projects/.../00893aaf-19fa-41d2-8238-13269b9b3ca0.jsonl",
  "cwd": "/Users/...",
  "permission_mode": "default",
  "hook_event_name": "PostToolUse",
  "tool_name": "Write",
  "tool_input": {
    "file_path": "/path/to/file.txt",
    "content": "file content"
  },
  "tool_response": {
    "filePath": "/path/to/file.txt",
    "success": true
  },
  "tool_use_id": "toolu_01ABC123..."
}
```

#### PostToolUse 결정 제어

`PostToolUse` hook은 도구 실행 후 Claude에 피드백을 제공할 수 있습니다. 모든 hook에 사용 가능한 [JSON 출력 필드](#json-output) 외에도 hook 스크립트는 이러한 이벤트 특정 필드를 반환할 수 있습니다:

| 필드 | 설명 |
| --- | --- |
| `decision` | `"block"` 은 Claude에 `reason` 을 표시합니다. 생략하여 작업을 진행하도록 허용 |
| `reason` | `decision` 이 `"block"` 일 때 Claude에 표시되는 설명 |
| `additionalContext` | Claude가 고려할 추가 컨텍스트 |
| `updatedMCPToolOutput` | [MCP 도구](#match-mcp-tools) 만 해당: 도구의 출력을 제공된 값으로 바꿉니다 |

```json
{
  "decision": "block",
  "reason": "Explanation for decision",
  "hookSpecificOutput": {
    "hookEventName": "PostToolUse",
    "additionalContext": "Additional information for Claude"
  }
}
```

### PostToolUseFailure

도구 실행이 실패할 때 실행됩니다. 이 이벤트는 오류를 throw하거나 실패 결과를 반환하는 도구 호출에 대해 발생합니다. 이를 사용하여 실패를 기록하고, 경고를 보내거나, Claude에 수정 피드백을 제공합니다.

도구 이름에서 일치합니다. PreToolUse와 동일한 값입니다.

#### PostToolUseFailure 입력

PostToolUseFailure hook은 PostToolUse와 동일한 `tool_name` 및 `tool_input` 필드를 받으며, 오류 정보는 최상위 필드로 받습니다:

```json
{
  "session_id": "abc123",
  "transcript_path": "/Users/.../.claude/projects/.../00893aaf-19fa-41d2-8238-13269b9b3ca0.jsonl",
  "cwd": "/Users/...",
  "permission_mode": "default",
  "hook_event_name": "PostToolUseFailure",
  "tool_name": "Bash",
  "tool_input": {
    "command": "npm test",
    "description": "Run test suite"
  },
  "tool_use_id": "toolu_01ABC123...",
  "error": "Command exited with non-zero status code 1",
  "is_interrupt": false
}
```

| 필드 | 설명 |
| --- | --- |
| `error` | 무엇이 잘못되었는지 설명하는 문자열 |
| `is_interrupt` | 선택적 부울로 실패가 사용자 중단으로 인한 것인지 여부를 나타냅니다 |

#### PostToolUseFailure 결정 제어

`PostToolUseFailure` hook은 도구 실패 후 Claude에 컨텍스트를 제공할 수 있습니다. 모든 hook에 사용 가능한 [JSON 출력 필드](#json-output) 외에도 hook 스크립트는 이러한 이벤트 특정 필드를 반환할 수 있습니다:

| 필드 | 설명 |
| --- | --- |
| `additionalContext` | Claude가 오류와 함께 고려할 추가 컨텍스트 |

```json
{
  "hookSpecificOutput": {
    "hookEventName": "PostToolUseFailure",
    "additionalContext": "Additional information about the failure for Claude"
  }
}
```

### PermissionDenied

[자동 모드](https://code.claude.com/docs/ko/permission-modes#eliminate-prompts-with-auto-mode) 분류기가 도구 호출을 거부할 때 실행됩니다. 이 hook은 자동 모드에서만 발생합니다: 권한 대화 상자를 수동으로 거부할 때, `PreToolUse` hook이 호출을 차단할 때, 또는 `deny` 규칙이 일치할 때 실행되지 않습니다. 이를 사용하여 분류기 거부를 기록하고, 구성을 조정하거나, 모델이 도구 호출을 재시도할 수 있음을 알립니다.

도구 이름에서 일치합니다. PreToolUse와 동일한 값입니다.

#### PermissionDenied 입력

[공통 입력 필드](#common-input-fields) 외에도 PermissionDenied hook은 `tool_name`, `tool_input`, `tool_use_id`, `reason` 을 받습니다.

```json
{
  "session_id": "abc123",
  "transcript_path": "/Users/.../.claude/projects/.../00893aaf-19fa-41d2-8238-13269b9b3ca0.jsonl",
  "cwd": "/Users/...",
  "permission_mode": "auto",
  "hook_event_name": "PermissionDenied",
  "tool_name": "Bash",
  "tool_input": {
    "command": "rm -rf /tmp/build",
    "description": "Clean build directory"
  },
  "tool_use_id": "toolu_01ABC123...",
  "reason": "Auto mode denied: command targets a path outside the project"
}
```

| 필드 | 설명 |
| --- | --- |
| `reason` | 분류기가 도구 호출을 거부한 이유에 대한 설명 |

#### PermissionDenied 결정 제어

PermissionDenied hook은 모델이 거부된 도구 호출을 재시도할 수 있음을 알릴 수 있습니다. `hookSpecificOutput.retry` 를 `true` 로 설정한 JSON 객체를 반환합니다:

```json
{
  "hookSpecificOutput": {
    "hookEventName": "PermissionDenied",
    "retry": true
  }
}
```

`retry` 가 `true` 일 때 Claude Code는 모델이 도구 호출을 재시도할 수 있음을 알리는 메시지를 대화에 추가합니다. 거부 자체는 역전되지 않습니다. hook이 JSON을 반환하지 않거나 `retry: false` 를 반환하면 거부가 유지되고 모델은 원래 거부 메시지를 받습니다.

### Notification

Claude Code가 알림을 보낼 때 실행됩니다. 알림 유형에서 일치합니다: `permission_prompt`, `idle_prompt`, `auth_success`, `elicitation_dialog`. matcher를 생략하여 모든 알림 유형에 대해 hook을 실행합니다.

별도의 matcher를 사용하여 알림 유형에 따라 다른 핸들러를 실행합니다. 이 구성은 Claude가 권한 승인이 필요할 때 권한 특정 경고 스크립트를 트리거하고 Claude가 유휴 상태일 때 다른 알림을 트리거합니다:

```json
{
  "hooks": {
    "Notification": [
      {
        "matcher": "permission_prompt",
        "hooks": [
          {
            "type": "command",
            "command": "/path/to/permission-alert.sh"
          }
        ]
      },
      {
        "matcher": "idle_prompt",
        "hooks": [
          {
            "type": "command",
            "command": "/path/to/idle-notification.sh"
          }
        ]
      }
    ]
  }
}
```

#### Notification 입력

[공통 입력 필드](#common-input-fields) 외에도 Notification hook은 알림 텍스트가 있는 `message`, 선택적 `title`, 발생한 유형을 나타내는 `notification_type` 을 받습니다.

```json
{
  "session_id": "abc123",
  "transcript_path": "/Users/.../.claude/projects/.../00893aaf-19fa-41d2-8238-13269b9b3ca0.jsonl",
  "cwd": "/Users/...",
  "hook_event_name": "Notification",
  "message": "Claude needs your permission to use Bash",
  "title": "Permission needed",
  "notification_type": "permission_prompt"
}
```

Notification hook은 알림을 차단하거나 수정할 수 없습니다. 모든 hook에 사용 가능한 [JSON 출력 필드](#json-output) 외에도 `additionalContext` 를 반환하여 대화에 컨텍스트를 추가할 수 있습니다:

| 필드 | 설명 |
| --- | --- |
| `additionalContext` | Claude의 컨텍스트에 추가되는 문자열 |

### SubagentStart

Agent 도구를 통해 Claude Code subagent가 생성될 때 실행됩니다. 에이전트 유형 이름으로 필터링할 matcher를 지원합니다 (Bash, Explore, Plan과 같은 기본 제공 에이전트 또는 `.claude/agents/` 의 사용자 정의 에이전트 이름).

#### SubagentStart 입력

[공통 입력 필드](#common-input-fields) 외에도 SubagentStart hook은 subagent의 고유 식별자가 있는 `agent_id` 와 에이전트 이름이 있는 `agent_type` (Bash, Explore, Plan과 같은 기본 제공 에이전트 또는 사용자 정의 에이전트 이름)을 받습니다.

```json
{
  "session_id": "abc123",
  "transcript_path": "/Users/.../.claude/projects/.../00893aaf-19fa-41d2-8238-13269b9b3ca0.jsonl",
  "cwd": "/Users/...",
  "hook_event_name": "SubagentStart",
  "agent_id": "agent-abc123",
  "agent_type": "Explore"
}
```

SubagentStart hook은 subagent 생성을 차단할 수 없지만 subagent에 컨텍스트를 주입할 수 있습니다. 모든 hook에 사용 가능한 [JSON 출력 필드](#json-output) 외에도 다음을 반환할 수 있습니다:

| 필드 | 설명 |
| --- | --- |
| `additionalContext` | subagent의 컨텍스트에 추가되는 문자열 |

```json
{
  "hookSpecificOutput": {
    "hookEventName": "SubagentStart",
    "additionalContext": "Follow security guidelines for this task"
  }
}
```

### SubagentStop

Claude Code subagent가 응답을 마쳤을 때 실행됩니다. 에이전트 유형에서 일치합니다. SubagentStart와 동일한 값입니다.

#### SubagentStop 입력

[공통 입력 필드](#common-input-fields) 외에도 SubagentStop hook은 `stop_hook_active`, `agent_id`, `agent_type`, `agent_transcript_path`, `last_assistant_message` 를 받습니다. `agent_type` 필드는 matcher 필터링에 사용되는 값입니다. `transcript_path` 는 메인 세션의 트랜스크립트이고 `agent_transcript_path` 는 중첩된 `subagents/` 폴더에 저장된 subagent의 자체 트랜스크립트입니다. `last_assistant_message` 필드는 subagent의 최종 응답의 텍스트 내용을 포함하므로 hook은 트랜스크립트 파일을 구문 분석하지 않고도 액세스할 수 있습니다.

```json
{
  "session_id": "abc123",
  "transcript_path": "~/.claude/projects/.../abc123.jsonl",
  "cwd": "/Users/...",
  "permission_mode": "default",
  "hook_event_name": "SubagentStop",
  "stop_hook_active": false,
  "agent_id": "def456",
  "agent_type": "Explore",
  "agent_transcript_path": "~/.claude/projects/.../abc123/subagents/agent-def456.jsonl",
  "last_assistant_message": "Analysis complete. Found 3 potential issues..."
}
```

SubagentStop hook은 [Stop hook](#stop-decision-control) 과 동일한 결정 제어 형식을 사용합니다.

### TaskCreated

작업이 `TaskCreate` 도구를 통해 생성될 때 실행됩니다. 이를 사용하여 명명 규칙을 적용하거나, 작업 설명을 요구하거나, 특정 작업이 생성되는 것을 방지합니다.

`TaskCreated` hook이 코드 2로 종료되면 작업이 생성되지 않고 stderr 메시지가 모델에 피드백으로 피드백됩니다. 팀원을 다시 실행하는 대신 완전히 중지하려면 `{"continue": false, "stopReason": "..."}` 이 있는 JSON을 반환합니다. TaskCreated hook은 matcher를 지원하지 않으며 모든 발생에서 발생합니다.

#### TaskCreated 입력

[공통 입력 필드](#common-input-fields) 외에도 TaskCreated hook은 `task_id`, `task_subject`, 선택적으로 `task_description`, `teammate_name`, `team_name` 을 받습니다.

```json
{
  "session_id": "abc123",
  "transcript_path": "/Users/.../.claude/projects/.../00893aaf-19fa-41d2-8238-13269b9b3ca0.jsonl",
  "cwd": "/Users/...",
  "permission_mode": "default",
  "hook_event_name": "TaskCreated",
  "task_id": "task-001",
  "task_subject": "Implement user authentication",
  "task_description": "Add login and signup endpoints",
  "teammate_name": "implementer",
  "team_name": "my-project"
}
```

| 필드 | 설명 |
| --- | --- |
| `task_id` | 생성되는 작업의 식별자 |
| `task_subject` | 작업의 제목 |
| `task_description` | 작업의 자세한 설명. 없을 수 있음 |
| `teammate_name` | 작업을 생성하는 팀원의 이름. 없을 수 있음 |
| `team_name` | 팀의 이름. 없을 수 있음 |

#### TaskCreated 결정 제어

TaskCreated hook은 작업 생성을 제어하는 두 가지 방법을 지원합니다:

- **종료 코드 2**: 작업이 생성되지 않고 stderr 메시지가 모델에 피드백으로 피드백됩니다.
- **JSON `{"continue": false, "stopReason": "..."}`**: 팀원을 완전히 중지하여 `Stop` hook 동작과 일치합니다. `stopReason` 은 사용자에게 표시됩니다.

이 예제는 제목이 필수 형식을 따르지 않는 작업을 차단합니다:

```shellscript
#!/bin/bash
INPUT=$(cat)
TASK_SUBJECT=$(echo "$INPUT" | jq -r '.task_subject')

if [[ ! "$TASK_SUBJECT" =~ ^\[TICKET-[0-9]+\] ]]; then
  echo "Task subject must start with a ticket number, e.g. '[TICKET-123] Add feature'" >&2
  exit 2
fi

exit 0
```

### TaskCompleted

작업이 완료로 표시될 때 실행됩니다. 이는 두 가지 상황에서 발생합니다: 모든 에이전트가 TaskUpdate 도구를 통해 명시적으로 작업을 완료로 표시할 때 또는 [에이전트 팀](https://code.claude.com/docs/ko/agent-teams) 팀원이 진행 중인 작업으로 자신의 턴을 마칠 때입니다. 이를 사용하여 테스트 통과 또는 lint 검사와 같은 완료 기준을 적용하기 전에 작업을 닫을 수 있습니다.

`TaskCompleted` hook이 코드 2로 종료되면 작업이 완료로 표시되지 않고 stderr 메시지가 모델에 피드백으로 피드백됩니다. 팀원을 다시 실행하는 대신 완전히 중지하려면 `{"continue": false, "stopReason": "..."}` 이 있는 JSON을 반환합니다. TaskCompleted hook은 matcher를 지원하지 않으며 모든 발생에서 발생합니다.

#### TaskCompleted 입력

[공통 입력 필드](#common-input-fields) 외에도 TaskCompleted hook은 `task_id`, `task_subject`, 선택적으로 `task_description`, `teammate_name`, `team_name` 을 받습니다.

```json
{
  "session_id": "abc123",
  "transcript_path": "/Users/.../.claude/projects/.../00893aaf-19fa-41d2-8238-13269b9b3ca0.jsonl",
  "cwd": "/Users/...",
  "permission_mode": "default",
  "hook_event_name": "TaskCompleted",
  "task_id": "task-001",
  "task_subject": "Implement user authentication",
  "task_description": "Add login and signup endpoints",
  "teammate_name": "implementer",
  "team_name": "my-project"
}
```

| 필드 | 설명 |
| --- | --- |
| `task_id` | 완료되는 작업의 식별자 |
| `task_subject` | 작업의 제목 |
| `task_description` | 작업의 자세한 설명. 없을 수 있음 |
| `teammate_name` | 작업을 완료하는 팀원의 이름. 없을 수 있음 |
| `team_name` | 팀의 이름. 없을 수 있음 |

#### TaskCompleted 결정 제어

TaskCompleted hook은 작업 완료를 제어하는 두 가지 방법을 지원합니다:

- **종료 코드 2**: 작업이 완료로 표시되지 않고 stderr 메시지가 모델에 피드백으로 피드백됩니다.
- **JSON `{"continue": false, "stopReason": "..."}`**: 팀원을 완전히 중지하여 `Stop` hook 동작과 일치합니다. `stopReason` 은 사용자에게 표시됩니다.

이 예제는 테스트를 실행하고 실패하면 작업 완료를 차단합니다:

```shellscript
#!/bin/bash
INPUT=$(cat)
TASK_SUBJECT=$(echo "$INPUT" | jq -r '.task_subject')

# 테스트 스위트를 실행합니다
if ! npm test 2>&1; then
  echo "Tests not passing. Fix failing tests before completing: $TASK_SUBJECT" >&2
  exit 2
fi

exit 0
```

### Stop

메인 Claude Code 에이전트가 응답을 마쳤을 때 실행됩니다. 중지가 사용자 중단으로 인해 발생한 경우 실행되지 않습니다. API 오류는 [StopFailure](#stopfailure) 대신 발생합니다.

#### Stop 입력

[공통 입력 필드](#common-input-fields) 외에도 Stop hook은 `stop_hook_active` 및 `last_assistant_message` 를 받습니다. `stop_hook_active` 필드는 Claude Code가 이미 stop hook의 결과로 계속되고 있을 때 `true` 입니다. 이 값을 확인하거나 트랜스크립트를 처리하여 Claude Code가 무한정 실행되는 것을 방지합니다. `last_assistant_message` 필드는 Claude의 최종 응답의 텍스트 내용을 포함하므로 hook은 트랜스크립트 파일을 구문 분석하지 않고도 액세스할 수 있습니다.

```json
{
  "session_id": "abc123",
  "transcript_path": "~/.claude/projects/.../00893aaf-19fa-41d2-8238-13269b9b3ca0.jsonl",
  "cwd": "/Users/...",
  "permission_mode": "default",
  "hook_event_name": "Stop",
  "stop_hook_active": true,
  "last_assistant_message": "I've completed the refactoring. Here's a summary..."
}
```

#### Stop 결정 제어

`Stop` 및 `SubagentStop` hook은 Claude가 계속할지 여부를 제어할 수 있습니다. 모든 hook에 사용 가능한 [JSON 출력 필드](#json-output) 외에도 hook 스크립트는 이러한 이벤트 특정 필드를 반환할 수 있습니다:

| 필드 | 설명 |
| --- | --- |
| `decision` | `"block"` 은 Claude가 중지되는 것을 방지합니다. 생략하여 Claude가 중지하도록 허용 |
| `reason` | Claude가 중지되는 것이 차단될 때 필수입니다. Claude에 계속해야 하는 이유를 알립니다 |

```json
{
  "decision": "block",
  "reason": "Must be provided when Claude is blocked from stopping"
}
```

### StopFailure

[Stop](#stop) 대신 턴이 API 오류로 인해 종료될 때 실행됩니다. 출력과 종료 코드는 무시됩니다. 이를 사용하여 실패를 기록하고, 경고를 보내거나, Claude가 API 오류로 인해 응답을 완료할 수 없을 때 복구 조치를 취합니다.

#### StopFailure 입력

[공통 입력 필드](#common-input-fields) 외에도 StopFailure hook은 `error`, 선택적 `error_details`, 선택적 `last_assistant_message` 를 받습니다. `error` 필드는 오류 유형을 식별하며 matcher 필터링에 사용됩니다.

| 필드 | 설명 |
| --- | --- |
| `error` | 오류 유형: `rate_limit`, `authentication_failed`, `billing_error`, `invalid_request`, `server_error`, `max_output_tokens` 또는 `unknown` |
| `error_details` | 사용 가능한 경우 오류에 대한 추가 세부 정보 |
| `last_assistant_message` | 대화에 표시되는 렌더링된 오류 텍스트. `Stop` 및 `SubagentStop` 과 달리 이 필드는 Claude의 대화형 출력을 보유하고 `StopFailure` 의 경우 `"API Error: Rate limit reached"` 와 같은 API 오류 문자열 자체를 포함합니다 |

```json
{
  "session_id": "abc123",
  "transcript_path": "/Users/.../.claude/projects/.../00893aaf-19fa-41d2-8238-13269b9b3ca0.jsonl",
  "cwd": "/Users/...",
  "hook_event_name": "StopFailure",
  "error": "rate_limit",
  "error_details": "429 Too Many Requests",
  "last_assistant_message": "API Error: Rate limit reached"
}
```

StopFailure hook은 결정 제어가 없습니다. 이들은 알림 및 로깅 목적으로만 실행됩니다.

### TeammateIdle

[에이전트 팀](https://code.claude.com/docs/ko/agent-teams) 팀원이 자신의 턴을 마친 후 유휴 상태가 되려고 할 때 실행됩니다. 이를 사용하여 lint 검사 통과 또는 출력 파일 존재 확인과 같은 팀원이 작업을 중지하기 전에 품질 게이트를 적용합니다.

`TeammateIdle` hook이 코드 2로 종료되면 팀원은 stderr 메시지를 피드백으로 받고 유휴 상태가 되는 대신 계속 작업합니다. 팀원을 다시 실행하는 대신 완전히 중지하려면 `{"continue": false, "stopReason": "..."}` 이 있는 JSON을 반환합니다. TeammateIdle hook은 matcher를 지원하지 않으며 모든 발생에서 발생합니다.

#### TeammateIdle 입력

[공통 입력 필드](#common-input-fields) 외에도 TeammateIdle hook은 `teammate_name` 및 `team_name` 을 받습니다.

```json
{
  "session_id": "abc123",
  "transcript_path": "/Users/.../.claude/projects/.../00893aaf-19fa-41d2-8238-13269b9b3ca0.jsonl",
  "cwd": "/Users/...",
  "permission_mode": "default",
  "hook_event_name": "TeammateIdle",
  "teammate_name": "researcher",
  "team_name": "my-project"
}
```

| 필드 | 설명 |
| --- | --- |
| `teammate_name` | 유휴 상태가 되려고 하는 팀원의 이름 |
| `team_name` | 팀의 이름 |

#### TeammateIdle 결정 제어

TeammateIdle hook은 팀원 동작을 제어하는 두 가지 방법을 지원합니다:

- **종료 코드 2**: 팀원은 stderr 메시지를 피드백으로 받고 유휴 상태가 되는 대신 계속 작업합니다.
- **JSON `{"continue": false, "stopReason": "..."}`**: 팀원을 완전히 중지하여 `Stop` hook 동작과 일치합니다. `stopReason` 은 사용자에게 표시됩니다.

이 예제는 팀원이 유휴 상태가 되도록 허용하기 전에 빌드 아티팩트가 존재하는지 확인합니다:

```shellscript
#!/bin/bash

if [ ! -f "./dist/output.js" ]; then
  echo "Build artifact missing. Run the build before stopping." >&2
  exit 2
fi

exit 0
```

### ConfigChange

세션 중에 구성 파일이 변경될 때 실행됩니다. 이를 사용하여 설정 변경을 감사하고, 보안 정책을 적용하거나, 구성 파일에 대한 무단 수정을 차단합니다.

ConfigChange hook은 설정 파일, 관리형 정책 설정, skill 파일의 변경에 대해 발생합니다. 입력의 `source` 필드는 어떤 유형의 구성이 변경되었는지 알려주고, 선택적 `file_path` 필드는 변경된 파일의 경로를 제공합니다.

matcher는 구성 소스에서 필터링합니다:

| Matcher | 언제 발생하는지 |
| --- | --- |
| `user_settings` | `~/.claude/settings.json` 변경 |
| `project_settings` | `.claude/settings.json` 변경 |
| `local_settings` | `.claude/settings.local.json` 변경 |
| `policy_settings` | 관리형 정책 설정 변경 |
| `skills` | `.claude/skills/` 의 skill 파일 변경 |

이 예제는 보안 감사를 위해 모든 구성 변경을 기록합니다:

```json
{
  "hooks": {
    "ConfigChange": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/audit-config-change.sh"
          }
        ]
      }
    ]
  }
}
```

#### ConfigChange 입력

[공통 입력 필드](#common-input-fields) 외에도 ConfigChange hook은 `source` 및 선택적으로 `file_path` 를 받습니다. `source` 필드는 어떤 구성 유형이 변경되었는지 나타내고 `file_path` 는 수정된 특정 파일의 경로를 제공합니다.

```json
{
  "session_id": "abc123",
  "transcript_path": "/Users/.../.claude/projects/.../00893aaf-19fa-41d2-8238-13269b9b3ca0.jsonl",
  "cwd": "/Users/...",
  "hook_event_name": "ConfigChange",
  "source": "project_settings",
  "file_path": "/Users/.../my-project/.claude/settings.json"
}
```

#### ConfigChange 결정 제어

ConfigChange hook은 구성 변경이 적용되는 것을 차단할 수 있습니다. 종료 코드 2 또는 JSON `decision` 을 사용하여 변경을 방지합니다. 차단되면 새 설정이 실행 중인 세션에 적용되지 않습니다.

| 필드 | 설명 |
| --- | --- |
| `decision` | `"block"` 은 구성 변경이 적용되는 것을 방지합니다. 생략하여 변경을 허용 |
| `reason` | `decision` 이 `"block"` 일 때 사용자에게 표시되는 설명 |

```json
{
  "decision": "block",
  "reason": "Configuration changes to project settings require admin approval"
}
```

`policy_settings` 변경은 차단할 수 없습니다. Hook은 여전히 `policy_settings` 소스에 대해 발생하므로 감사 로깅에 사용할 수 있지만 모든 차단 결정은 무시됩니다. 이는 엔터프라이즈 관리 설정이 항상 적용되도록 보장합니다.

### CwdChanged

세션 중에 작업 디렉토리가 변경될 때 실행됩니다. 예를 들어 Claude가 `cd` 명령을 실행할 때입니다. 이를 사용하여 디렉토리 변경에 반응합니다: 환경 변수를 다시 로드하고, 프로젝트 특정 도구 체인을 활성화하거나, 설정 스크립트를 자동으로 실행합니다. [FileChanged](#filechanged) 와 쌍을 이루어 [direnv](https://direnv.net/) 와 같은 디렉토리별 환경을 관리하는 도구를 사용합니다.

CwdChanged hook은 `CLAUDE_ENV_FILE` 에 액세스할 수 있습니다. 해당 파일에 작성된 변수는 [SessionStart hook](#persist-environment-variables) 과 마찬가지로 세션의 후속 Bash 명령에 유지됩니다. `type: "command"` hook만 지원됩니다.

CwdChanged는 matcher를 지원하지 않으며 모든 디렉토리 변경에서 발생합니다.

#### CwdChanged 입력

[공통 입력 필드](#common-input-fields) 외에도 CwdChanged hook은 `old_cwd` 및 `new_cwd` 를 받습니다.

```json
{
  "session_id": "abc123",
  "transcript_path": "/Users/.../.claude/projects/.../transcript.jsonl",
  "cwd": "/Users/my-project/src",
  "hook_event_name": "CwdChanged",
  "old_cwd": "/Users/my-project",
  "new_cwd": "/Users/my-project/src"
}
```

#### CwdChanged 출력

모든 hook에 사용 가능한 [JSON 출력 필드](#json-output) 외에도 CwdChanged hook은 `watchPaths` 를 반환하여 [FileChanged](#filechanged) 가 감시하는 파일 경로를 동적으로 설정할 수 있습니다:

| 필드 | 설명 |
| --- | --- |
| `watchPaths` | 절대 경로의 배열. 현재 동적 감시 목록을 바꿉니다 (matcher 구성의 경로는 항상 감시됨). 새 디렉토리에 들어갈 때 빈 배열을 반환하는 것이 일반적입니다 |

CwdChanged hook은 결정 제어가 없습니다. 디렉토리 변경을 차단할 수 없습니다.

### FileChanged

감시된 파일이 디스크에서 변경될 때 실행됩니다. 유용합니다. 프로젝트 구성 파일이 수정될 때 환경 변수를 다시 로드하는 데 유용합니다.

`matcher` 는 이 이벤트에 대해 두 가지 역할을 합니다:

- **감시 목록 구축**: 값은 `|` 로 분할되고 각 세그먼트는 작업 디렉토리의 리터럴 파일명으로 등록되므로 `".envrc|.env"` 는 정확히 이 두 파일을 감시합니다. 정규식 패턴은 여기서 유용하지 않습니다: `^\.env` 와 같은 값은 `^\.env` 라는 리터럴 이름의 파일을 감시합니다.
- **hook 실행 필터링**: 감시된 파일이 변경되면 동일한 값이 표준 [matcher 규칙](#matcher-patterns) 을 사용하여 변경된 파일의 basename에 대해 실행할 hook 그룹을 필터링합니다.

FileChanged hook은 `CLAUDE_ENV_FILE` 에 액세스할 수 있습니다. 해당 파일에 작성된 변수는 [SessionStart hook](#persist-environment-variables) 과 마찬가지로 세션의 후속 Bash 명령에 유지됩니다. `type: "command"` hook만 지원됩니다.

#### FileChanged 입력

[공통 입력 필드](#common-input-fields) 외에도 FileChanged hook은 `file_path` 및 `event` 를 받습니다.

| 필드 | 설명 |
| --- | --- |
| `file_path` | 변경된 파일의 절대 경로 |
| `event` | 발생한 일: `"change"` (파일 수정), `"add"` (파일 생성) 또는 `"unlink"` (파일 삭제) |

```json
{
  "session_id": "abc123",
  "transcript_path": "/Users/.../.claude/projects/.../transcript.jsonl",
  "cwd": "/Users/my-project",
  "hook_event_name": "FileChanged",
  "file_path": "/Users/my-project/.envrc",
  "event": "change"
}
```

#### FileChanged 출력

모든 hook에 사용 가능한 [JSON 출력 필드](#json-output) 외에도 FileChanged hook은 `watchPaths` 를 반환하여 감시되는 파일 경로를 동적으로 업데이트할 수 있습니다:

| 필드 | 설명 |
| --- | --- |
| `watchPaths` | 절대 경로의 배열. 현재 동적 감시 목록을 바꿉니다 (matcher 구성의 경로는 항상 감시됨). hook 스크립트가 변경된 파일을 기반으로 감시할 추가 파일을 발견할 때 사용합니다 |

FileChanged hook은 결정 제어가 없습니다. 파일 변경을 차단할 수 없습니다.

### WorktreeCreate

`claude --worktree` 를 실행하거나 [subagent가 `isolation: "worktree"` 를 사용](https://code.claude.com/docs/ko/sub-agents#choose-the-subagent-scope) 할 때 Claude Code는 `git worktree` 를 사용하여 격리된 작업 복사본을 생성합니다. WorktreeCreate hook을 구성하면 기본 git 동작을 대체하여 SVN, Perforce 또는 Mercurial과 같은 다른 버전 제어 시스템을 사용할 수 있습니다.

hook은 생성된 worktree 디렉토리의 절대 경로를 반환해야 합니다. Claude Code는 이 경로를 격리된 세션의 작업 디렉토리로 사용합니다. 명령 hook은 stdout에 경로를 인쇄합니다; HTTP hook은 `hookSpecificOutput.worktreePath` 를 반환합니다. hook 실패 또는 누락된 경로는 생성을 실패합니다.

이 예제는 SVN 작업 복사본을 생성하고 Claude Code가 사용할 경로를 인쇄합니다. 리포지토리 URL을 자신의 것으로 바꾸세요:

```json
{
  "hooks": {
    "WorktreeCreate": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash -c 'NAME=$(jq -r .name); DIR=\"$HOME/.claude/worktrees/$NAME\"; svn checkout https://svn.example.com/repo/trunk \"$DIR\" >&2 && echo \"$DIR\"'"
          }
        ]
      }
    ]
  }
}
```

hook은 stdin의 JSON 입력에서 worktree `name` 을 읽고, 새 디렉토리로 신선한 복사본을 체크아웃하고, 디렉토리 경로를 인쇄합니다. 마지막 줄의 `echo` 는 Claude Code가 worktree 경로로 읽는 것입니다. 다른 모든 출력을 stderr로 리디렉션하여 경로를 방해하지 않도록 합니다.

#### WorktreeCreate 입력

[공통 입력 필드](#common-input-fields) 외에도 WorktreeCreate hook은 `name` 필드를 받습니다. 이는 새 worktree의 slug 식별자이며, 사용자가 지정하거나 자동 생성됩니다 (예: `bold-oak-a3f2`).

```json
{
  "session_id": "abc123",
  "transcript_path": "/Users/.../.claude/projects/.../00893aaf-19fa-41d2-8238-13269b9b3ca0.jsonl",
  "cwd": "/Users/...",
  "hook_event_name": "WorktreeCreate",
  "name": "feature-auth"
}
```

#### WorktreeCreate 출력

WorktreeCreate hook은 표준 허용/차단 결정 모델을 사용하지 않습니다. 대신 hook의 성공 또는 실패가 결과를 결정합니다. hook은 생성된 worktree 디렉토리의 절대 경로를 반환해야 합니다:

- **명령 hook** (`type: "command"`): stdout에 경로를 인쇄합니다.
- **HTTP hook** (`type: "http"`): 응답 본문에서 `{ "hookSpecificOutput": { "hookEventName": "WorktreeCreate", "worktreePath": "/absolute/path" } }` 를 반환합니다.

hook이 실패하거나 경로를 생성하지 않으면 worktree 생성이 오류로 실패합니다.

### WorktreeRemove

[WorktreeCreate](#worktreecreate) 의 정리 대응. 이 hook은 worktree가 제거될 때 발생합니다. `--worktree` 세션을 종료하고 제거하도록 선택하거나 `isolation: "worktree"` 를 가진 subagent가 완료될 때입니다. git 기반 worktree의 경우 Claude는 `git worktree remove` 로 정리를 자동으로 처리합니다. git이 아닌 버전 제어 시스템에 대해 WorktreeCreate hook을 구성한 경우 정리를 처리하려면 WorktreeRemove hook과 쌍을 이루세요. 없으면 worktree 디렉토리가 디스크에 남아 있습니다.

Claude Code는 WorktreeCreate가 stdout에 인쇄한 경로를 hook 입력의 `worktree_path` 로 전달합니다. 이 예제는 해당 경로를 읽고 디렉토리를 제거합니다:

```json
{
  "hooks": {
    "WorktreeRemove": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash -c 'jq -r .worktree_path | xargs rm -rf'"
          }
        ]
      }
    ]
  }
}
```

#### WorktreeRemove 입력

[공통 입력 필드](#common-input-fields) 외에도 WorktreeRemove hook은 제거되는 worktree의 절대 경로인 `worktree_path` 필드를 받습니다.

```json
{
  "session_id": "abc123",
  "transcript_path": "/Users/.../.claude/projects/.../00893aaf-19fa-41d2-8238-13269b9b3ca0.jsonl",
  "cwd": "/Users/...",
  "hook_event_name": "WorktreeRemove",
  "worktree_path": "/Users/.../my-project/.claude/worktrees/feature-auth"
}
```

WorktreeRemove hook은 결정 제어가 없습니다. worktree 제거를 차단할 수 없지만 버전 제어 상태 제거 또는 변경 아카이빙과 같은 정리 작업을 수행할 수 있습니다. hook 실패는 디버그 모드에서만 기록됩니다.

### PreCompact

Claude Code가 압축 작업을 실행하려고 하기 전에 실행됩니다.

matcher 값은 압축이 수동으로 또는 자동으로 트리거되었는지 나타냅니다:

| Matcher | 언제 발생하는지 |
| --- | --- |
| `manual` | `/compact` |
| `auto` | 컨텍스트 윈도우가 가득 찼을 때 자동 압축 |

종료 코드 2로 압축을 차단합니다. 수동 `/compact` 의 경우 stderr 메시지가 사용자에게 표시됩니다. JSON `"decision": "block"` 을 사용하여 차단할 수도 있습니다.

자동 압축 차단은 발생 시기에 따라 다른 효과를 가집니다. 컨텍스트 제한 전에 압축이 사전에 트리거된 경우 Claude Code는 이를 건너뛰고 대화가 압축되지 않은 상태로 계속됩니다. 컨텍스트 제한 오류를 복구하기 위해 압축이 트리거된 경우 기본 오류가 표시되고 현재 요청이 실패합니다.

#### PreCompact 입력

[공통 입력 필드](#common-input-fields) 외에도 PreCompact hook은 `trigger` 및 `custom_instructions` 를 받습니다. `manual` 의 경우 `custom_instructions` 는 사용자가 `/compact` 에 전달하는 것을 포함합니다. `auto` 의 경우 `custom_instructions` 는 비어 있습니다.

```json
{
  "session_id": "abc123",
  "transcript_path": "/Users/.../.claude/projects/.../00893aaf-19fa-41d2-8238-13269b9b3ca0.jsonl",
  "cwd": "/Users/...",
  "hook_event_name": "PreCompact",
  "trigger": "manual",
  "custom_instructions": ""
}
```

### PostCompact

Claude Code가 압축 작업을 완료한 후 실행됩니다. 이 이벤트를 사용하여 새로운 압축된 상태에 반응합니다. 예를 들어 생성된 요약을 기록하거나 외부 상태를 업데이트합니다.

`PreCompact` 와 동일한 matcher 값이 적용됩니다:

| Matcher | 언제 발생하는지 |
| --- | --- |
| `manual` | `/compact` 후 |
| `auto` | 컨텍스트 윈도우가 가득 찼을 때 자동 압축 후 |

#### PostCompact 입력

[공통 입력 필드](#common-input-fields) 외에도 PostCompact hook은 `trigger` 및 `compact_summary` 를 받습니다. `compact_summary` 필드는 압축 작업에서 생성된 대화 요약을 포함합니다.

```json
{
  "session_id": "abc123",
  "transcript_path": "/Users/.../.claude/projects/.../00893aaf-19fa-41d2-8238-13269b9b3ca0.jsonl",
  "cwd": "/Users/...",
  "hook_event_name": "PostCompact",
  "trigger": "manual",
  "compact_summary": "Summary of the compacted conversation..."
}
```

PostCompact hook은 결정 제어가 없습니다. 압축 결과에 영향을 미칠 수 없지만 후속 작업을 수행할 수 있습니다.

### SessionEnd

Claude Code 세션이 종료될 때 실행됩니다. 정리 작업, 세션 통계 로깅 또는 세션 상태 저장에 유용합니다. 종료 이유별로 필터링할 matcher를 지원합니다.

hook 입력의 `reason` 필드는 세션이 종료된 이유를 나타냅니다:

| 이유 | 설명 |
| --- | --- |
| `clear` | `/clear` 명령으로 세션 지워짐 |
| `resume` | 대화형 `/resume` 을 통해 세션 전환됨 |
| `logout` | 사용자 로그아웃 |
| `prompt_input_exit` | 프롬프트 입력이 표시되는 동안 사용자 종료 |
| `bypass_permissions_disabled` | 권한 우회 모드 비활성화됨 |
| `other` | 기타 종료 이유 |

#### SessionEnd 입력

[공통 입력 필드](#common-input-fields) 외에도 SessionEnd hook은 세션이 종료된 이유를 나타내는 `reason` 필드를 받습니다. 모든 값은 위의 [이유 표](#sessionend) 를 참조하세요.

```json
{
  "session_id": "abc123",
  "transcript_path": "/Users/.../.claude/projects/.../00893aaf-19fa-41d2-8238-13269b9b3ca0.jsonl",
  "cwd": "/Users/...",
  "hook_event_name": "SessionEnd",
  "reason": "other"
}
```

SessionEnd hook은 결정 제어가 없습니다. 세션 종료를 차단할 수 없지만 정리 작업을 수행할 수 있습니다.

SessionEnd hook의 기본 시간 초과는 1.5초입니다. 이는 세션 종료, `/clear`, 대화형 `/resume` 을 통한 세션 전환 모두에 적용됩니다. hook에 더 많은 시간이 필요하면 hook 구성에서 `timeout` 을 설정합니다. 전체 예산은 설정 파일의 가장 높은 hook별 `timeout` 으로 자동으로 올라가며, 최대 60초입니다. plugin 제공 hook에 설정된 시간 초과는 예산을 올리지 않습니다. 예산을 명시적으로 재정의하려면 `CLAUDE_CODE_SESSIONEND_HOOKS_TIMEOUT_MS` 환경 변수를 밀리초 단위로 설정합니다.

```shellscript
CLAUDE_CODE_SESSIONEND_HOOKS_TIMEOUT_MS=5000 claude
```

### Elicitation

MCP 서버가 작업 중 사용자 입력을 요청할 때 실행됩니다. 기본적으로 Claude Code는 사용자가 응답할 수 있는 대화형 대화 상자를 표시합니다. Hook은 이 요청을 가로채고 프로그래밍 방식으로 응답하여 대화 상자를 완전히 건너뛸 수 있습니다.

matcher 필드는 MCP 서버 이름과 일치합니다.

#### Elicitation 입력

[공통 입력 필드](#common-input-fields) 외에도 Elicitation hook은 `mcp_server_name`, `message`, 선택적으로 `mode`, `url`, `elicitation_id`, `requested_schema` 필드를 받습니다.

form 모드 elicitation (가장 일반적인 경우):

```json
{
  "session_id": "abc123",
  "transcript_path": "/Users/.../.claude/projects/.../00893aaf-19fa-41d2-8238-13269b9b3ca0.jsonl",
  "cwd": "/Users/...",
  "permission_mode": "default",
  "hook_event_name": "Elicitation",
  "mcp_server_name": "my-mcp-server",
  "message": "Please provide your credentials",
  "mode": "form",
  "requested_schema": {
    "type": "object",
    "properties": {
      "username": { "type": "string", "title": "Username" }
    }
  }
}
```

URL 모드 elicitation (브라우저 기반 인증):

```json
{
  "session_id": "abc123",
  "transcript_path": "/Users/.../.claude/projects/.../00893aaf-19fa-41d2-8238-13269b9b3ca0.jsonl",
  "cwd": "/Users/...",
  "permission_mode": "default",
  "hook_event_name": "Elicitation",
  "mcp_server_name": "my-mcp-server",
  "message": "Please authenticate",
  "mode": "url",
  "url": "https://auth.example.com/login"
}
```

#### Elicitation 출력

대화 상자를 표시하지 않고 프로그래밍 방식으로 응답하려면 `hookSpecificOutput` 이 있는 JSON 객체를 반환합니다:

```json
{
  "hookSpecificOutput": {
    "hookEventName": "Elicitation",
    "action": "accept",
    "content": {
      "username": "alice"
    }
  }
}
```

| 필드 | 값 | 설명 |
| --- | --- | --- |
| `action` | `accept`, `decline`, `cancel` | 요청을 수락, 거부 또는 취소할지 여부 |
| `content` | 객체 | 제출할 form 필드 값. `action` 이 `accept` 일 때만 사용됨 |

종료 코드 2는 elicitation을 거부하고 stderr을 사용자에게 표시합니다.

### ElicitationResult

사용자가 MCP elicitation에 응답한 후 실행됩니다. Hook은 응답을 관찰하고, 수정하거나, MCP 서버로 다시 전송되기 전에 차단할 수 있습니다.

matcher 필드는 MCP 서버 이름과 일치합니다.

#### ElicitationResult 입력

[공통 입력 필드](#common-input-fields) 외에도 ElicitationResult hook은 `mcp_server_name`, `action`, 선택적으로 `mode`, `elicitation_id`, `content` 필드를 받습니다.

```json
{
  "session_id": "abc123",
  "transcript_path": "/Users/.../.claude/projects/.../00893aaf-19fa-41d2-8238-13269b9b3ca0.jsonl",
  "cwd": "/Users/...",
  "permission_mode": "default",
  "hook_event_name": "ElicitationResult",
  "mcp_server_name": "my-mcp-server",
  "action": "accept",
  "content": { "username": "alice" },
  "mode": "form",
  "elicitation_id": "elicit-123"
}
```

#### ElicitationResult 출력

사용자의 응답을 재정의하려면 `hookSpecificOutput` 이 있는 JSON 객체를 반환합니다:

```json
{
  "hookSpecificOutput": {
    "hookEventName": "ElicitationResult",
    "action": "decline",
    "content": {}
  }
}
```

| 필드 | 값 | 설명 |
| --- | --- | --- |
| `action` | `accept`, `decline`, `cancel` | 사용자의 작업을 재정의합니다 |
| `content` | 객체 | form 필드 값을 재정의합니다. `action` 이 `accept` 일 때만 의미 있음 |

종료 코드 2는 응답을 차단하여 효과적인 작업을 `decline` 으로 변경합니다.

## 프롬프트 기반 hook

명령 및 HTTP hook 외에도 Claude Code는 LLM을 사용하여 작업을 허용할지 차단할지 평가하는 프롬프트 기반 hook (`type: "prompt"`)과 도구 액세스가 있는 에이전트 검증자를 생성하는 에이전트 hook (`type: "agent"`)을 지원합니다. 모든 이벤트가 모든 hook 유형을 지원하는 것은 아닙니다.

네 가지 hook 유형 모두 (`command`, `http`, `prompt`, `agent`)를 지원하는 이벤트:

- `PermissionRequest`
- `PostToolUse`
- `PostToolUseFailure`
- `PreToolUse`
- `Stop`
- `SubagentStop`
- `TaskCompleted`
- `TaskCreated`
- `UserPromptSubmit`

`command` 및 `http` hook만 지원하지만 `prompt` 또는 `agent` 는 지원하지 않는 이벤트:

- `ConfigChange`
- `CwdChanged`
- `Elicitation`
- `ElicitationResult`
- `FileChanged`
- `InstructionsLoaded`
- `Notification`
- `PermissionDenied`
- `PostCompact`
- `PreCompact`
- `SessionEnd`
- `StopFailure`
- `SubagentStart`
- `TeammateIdle`
- `WorktreeCreate`
- `WorktreeRemove`

`SessionStart` 는 `command` hook만 지원합니다.

### 프롬프트 기반 hook이 어떻게 작동하는지

프롬프트 기반 hook은 Bash 명령을 실행하는 대신:

1. hook 입력과 프롬프트를 Claude 모델 (기본값 Haiku)로 전송합니다
2. LLM은 결정을 포함하는 구조화된 JSON으로 응답합니다
3. Claude Code는 결정을 자동으로 처리합니다

### 프롬프트 hook 구성

`type` 을 `"prompt"` 로 설정하고 `command` 대신 `prompt` 문자열을 제공합니다. `$ARGUMENTS` 자리 표시자를 사용하여 hook의 JSON 입력 데이터를 프롬프트 텍스트에 주입합니다. Claude Code는 결합된 프롬프트와 입력을 빠른 Claude 모델로 전송하며, 이는 JSON 결정을 반환합니다.

이 `Stop` hook은 Claude가 완료되기 전에 모든 작업이 완료되었는지 평가하도록 LLM에 요청합니다:

```json
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "prompt",
            "prompt": "Evaluate if Claude should stop: $ARGUMENTS. Check if all tasks are complete."
          }
        ]
      }
    ]
  }
}
```

| 필드 | 필수 | 설명 |
| --- | --- | --- |
| `type` | 예 | `"prompt"` 여야 합니다 |
| `prompt` | 예 | LLM으로 전송할 프롬프트 텍스트. hook 입력 JSON에 대한 자리 표시자로 `$ARGUMENTS` 사용. `$ARGUMENTS` 가 없으면 입력 JSON이 프롬프트에 추가됩니다 |
| `model` | 아니오 | 평가에 사용할 모델. 기본값은 빠른 모델 |
| `timeout` | 아니오 | 초 단위 시간 초과. 기본값: 30 |

### 응답 스키마

LLM은 다음을 포함하는 JSON으로 응답해야 합니다:

```json
{
  "ok": true | false,
  "reason": "Explanation for the decision"
}
```

| 필드 | 설명 |
| --- | --- |
| `ok` | `true` 는 작업을 허용하고 `false` 는 방지합니다 |
| `reason` | `ok` 가 `false` 일 때 필수입니다. Claude에 표시되는 설명 |

### 예제: 다중 기준 Stop hook

이 `Stop` hook은 Claude가 중지하기 전에 세 가지 조건을 확인하는 자세한 프롬프트를 사용합니다. `"ok"` 가 `false` 이면 Claude는 제공된 이유를 다음 명령으로 받으며 계속 작업합니다. `SubagentStop` hook은 [subagent](https://code.claude.com/docs/ko/sub-agents) 가 중지해야 하는지 평가하는 동일한 형식을 사용합니다:

```json
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "prompt",
            "prompt": "You are evaluating whether Claude should stop working. Context: $ARGUMENTS\n\nAnalyze the conversation and determine if:\n1. All user-requested tasks are complete\n2. Any errors need to be addressed\n3. Follow-up work is needed\n\nRespond with JSON: {\"ok\": true} to allow stopping, or {\"ok\": false, \"reason\": \"your explanation\"} to continue working.",
            "timeout": 30
          }
        ]
      }
    ]
  }
}
```

## 에이전트 기반 hook

에이전트 hook은 실험적입니다. 동작 및 구성은 향후 릴리스에서 변경될 수 있습니다. 프로덕션 워크플로우의 경우 [명령 hook](#command-hook-fields) 을 선호합니다.

에이전트 기반 hook (`type: "agent"`)은 프롬프트 기반 hook과 유사하지만 다중 턴 도구 액세스가 있습니다. 단일 LLM 호출 대신 에이전트 hook은 파일을 읽고, 코드를 검색하고, 코드베이스를 검사하여 조건을 확인할 수 있는 subagent를 생성합니다. 에이전트 hook은 프롬프트 기반 hook과 동일한 이벤트를 지원합니다.

### 에이전트 hook이 어떻게 작동하는지

에이전트 hook이 발생할 때:

1. Claude Code는 프롬프트와 hook의 JSON 입력을 가진 subagent를 생성합니다
2. subagent는 Read, Grep, Glob과 같은 도구를 사용하여 조사할 수 있습니다
3. 최대 50턴 후 subagent는 구조화된 `{ "ok": true/false }` 결정을 반환합니다
4. Claude Code는 프롬프트 hook과 동일한 방식으로 결정을 처리합니다

에이전트 hook은 검증이 hook 입력 데이터만으로 평가하는 것이 아니라 실제 파일이나 테스트 출력을 검사해야 할 때 유용합니다.

### 에이전트 hook 구성

`type` 을 `"agent"` 로 설정하고 `prompt` 문자열을 제공합니다. 구성 필드는 [프롬프트 hook](#prompt-hook-configuration) 과 동일하지만 더 긴 기본 시간 초과가 있습니다:

| 필드 | 필수 | 설명 |
| --- | --- | --- |
| `type` | 예 | `"agent"` 여야 합니다 |
| `prompt` | 예 | 확인할 내용을 설명하는 프롬프트. hook 입력 JSON에 대한 자리 표시자로 `$ARGUMENTS` 사용 |
| `model` | 아니오 | 사용할 모델. 기본값은 빠른 모델 |
| `timeout` | 아니오 | 초 단위 시간 초과. 기본값: 60 |

응답 스키마는 프롬프트 hook과 동일합니다: 허용하려면 `{ "ok": true }` 또는 차단하려면 `{ "ok": false, "reason": "..." }`.

이 `Stop` hook은 Claude가 완료되기 전에 모든 단위 테스트가 통과하는지 확인합니다:

```json
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "agent",
            "prompt": "Verify that all unit tests pass. Run the test suite and check the results. $ARGUMENTS",
            "timeout": 120
          }
        ]
      }
    ]
  }
}
```

## 백그라운드에서 hook 실행

기본적으로 hook은 완료될 때까지 Claude의 실행을 차단합니다. 배포, 테스트 스위트 또는 외부 API 호출과 같은 장기 실행 작업의 경우 `"async": true` 를 설정하여 Claude가 계속 작업하는 동안 백그라운드에서 hook을 실행합니다. 비동기 hook은 차단하거나 Claude의 동작을 제어할 수 없습니다: `decision`, `permissionDecision`, `continue` 와 같은 응답 필드는 효과가 없습니다. 제어했을 작업이 이미 완료되었기 때문입니다.

### 비동기 hook 구성

hook 구성에 `"async": true` 를 추가하여 Claude를 차단하지 않고 백그라운드에서 실행합니다. 이 필드는 `type: "command"` hook에서만 사용 가능합니다.

이 hook은 모든 `Write` 도구 호출 후 테스트 스크립트를 실행합니다. Claude는 `run-tests.sh` 가 최대 120초 동안 실행되는 동안 즉시 계속 작업합니다. 스크립트가 완료되면 출력이 다음 대화 턴에 전달됩니다:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write",
        "hooks": [
          {
            "type": "command",
            "command": "/path/to/run-tests.sh",
            "async": true,
            "timeout": 120
          }
        ]
      }
    ]
  }
}
```

`timeout` 필드는 백그라운드 프로세스의 최대 시간을 초 단위로 설정합니다. 지정하지 않으면 비동기 hook은 동기 hook과 동일한 10분 기본값을 사용합니다.

### 비동기 hook이 어떻게 실행되는지

비동기 hook이 발생하면 Claude Code는 hook 프로세스를 시작하고 완료를 기다리지 않고 즉시 계속합니다. hook은 동기 hook과 동일한 JSON 입력을 stdin을 통해 받습니다.

백그라운드 프로세스가 종료된 후 hook이 `systemMessage` 또는 `additionalContext` 필드가 있는 JSON 응답을 생성한 경우 해당 콘텐츠는 다음 대화 턴에서 Claude에 컨텍스트로 전달됩니다.

비동기 hook 완료 알림은 기본적으로 억제됩니다. 보려면 `Ctrl+O` 로 자세한 모드를 활성화하거나 `--verbose` 로 Claude Code를 시작합니다.

### 예제: 파일 변경 후 테스트 실행

이 hook은 Claude가 파일을 쓸 때마다 백그라운드에서 테스트 스위트를 시작한 후 테스트가 완료되면 결과를 Claude에 보고합니다. 이 스크립트를 프로젝트의 `.claude/hooks/run-tests-async.sh` 에 저장하고 `chmod +x` 로 실행 가능하게 만듭니다:

```shellscript
#!/bin/bash
# run-tests-async.sh

# stdin에서 hook 입력을 읽습니다
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# 소스 파일에 대해서만 테스트를 실행합니다
if [[ "$FILE_PATH" != *.ts && "$FILE_PATH" != *.js ]]; then
  exit 0
fi

# 테스트를 실행하고 systemMessage를 통해 결과를 보고합니다
RESULT=$(npm test 2>&1)
EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ]; then
  echo "{\"systemMessage\": \"Tests passed after editing $FILE_PATH\"}"
else
  echo "{\"systemMessage\": \"Tests failed after editing $FILE_PATH: $RESULT\"}"
fi
```

그런 다음 프로젝트 루트의 `.claude/settings.json` 에 이 구성을 추가합니다. `async: true` 플래그를 사용하면 Claude가 테스트 실행 중에 계속 작업할 수 있습니다:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/run-tests-async.sh",
            "async": true,
            "timeout": 300
          }
        ]
      }
    ]
  }
}
```

### 제한 사항

비동기 hook은 동기 hook과 비교하여 여러 제약이 있습니다:

- `type: "command"` hook만 `async` 를 지원합니다. 프롬프트 기반 hook은 비동기적으로 실행될 수 없습니다.
- 비동기 hook은 도구 호출을 차단하거나 결정을 반환할 수 없습니다. hook이 완료될 때까지 트리거 작업이 이미 진행되었습니다.
- Hook 출력은 다음 대화 턴에 전달됩니다. 세션이 유휴 상태이면 응답은 다음 사용자 상호 작용까지 기다립니다. 예외: `asyncRewake` hook이 종료 코드 2로 종료되면 세션이 유휴 상태일 때도 Claude를 즉시 깨웁니다.
- 각 실행은 별도의 백그라운드 프로세스를 생성합니다. 동일한 비동기 hook의 여러 발생에 걸쳐 중복 제거가 없습니다.

## 보안 고려 사항

### 면책 조항

명령 hook은 시스템 사용자의 전체 권한으로 실행됩니다.

명령 hook은 전체 사용자 권한으로 셸 명령을 실행합니다. 사용자 계정이 액세스할 수 있는 모든 파일을 수정, 삭제 또는 액세스할 수 있습니다. 구성에 추가하기 전에 모든 hook 명령을 검토하고 테스트하세요.

### 보안 모범 사례

hook을 작성할 때 이러한 사례를 염두에 두세요:

- **입력 검증 및 살균**: 입력 데이터를 맹목적으로 신뢰하지 마세요
- **항상 셸 변수를 따옴표로 감싸세요**: `$VAR` 대신 `"$VAR"` 사용
- **경로 순회 차단**: 파일 경로에서 `..` 확인
- **절대 경로 사용**: `"$CLAUDE_PROJECT_DIR"` 을 사용하여 프로젝트 루트에 대한 전체 경로를 지정합니다
- **민감한 파일 건너뛰기**: `.env`, `.git/`, 키 등을 피합니다

## Windows PowerShell 도구

Windows에서 개별 hook을 PowerShell에서 실행할 수 있습니다. 명령 hook에서 `"shell": "powershell"` 을 설정합니다. Hook은 PowerShell을 직접 생성하므로 `CLAUDE_CODE_USE_POWERSHELL_TOOL` 이 설정되어 있는지 여부와 관계없이 작동합니다. Claude Code는 `pwsh.exe` (PowerShell 7+)를 자동 감지하고 `powershell.exe` (5.1)로 폴백합니다.

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write",
        "hooks": [
          {
            "type": "command",
            "shell": "powershell",
            "command": "Write-Host 'File written'"
          }
        ]
      }
    ]
  }
}
```

## Hook 디버그

Hook 실행 세부 정보, 일치한 hook, 종료 코드, 전체 stdout 및 stderr은 디버그 로그 파일에 기록됩니다. `claude --debug-file <path>` 로 Claude Code를 시작하여 로그를 알려진 위치에 작성하거나 `claude --debug` 를 실행하고 `~/.claude/debug/<session-id>.txt` 에서 로그를 읽습니다. `--debug` 플래그는 터미널에 인쇄하지 않습니다.

```text
[DEBUG] Executing hooks for PostToolUse:Write
[DEBUG] Found 1 hook commands to execute
[DEBUG] Executing hook command: <Your command> with timeout 600000ms
[DEBUG] Hook command completed with status 0: <Your stdout>
```

더 세밀한 hook 일치 세부 정보를 보려면 `CLAUDE_CODE_DEBUG_LOG_LEVEL=verbose` 를 설정하여 hook matcher 수 및 쿼리 일치와 같은 추가 로그 줄을 확인합니다.

hook이 발생하지 않음, 무한 Stop hook 루프 또는 구성 오류와 같은 일반적인 문제 해결은 가이드의 [제한 사항 및 문제 해결](https://code.claude.com/docs/ko/hooks-guide#limitations-and-troubleshooting) 을 참조하세요.