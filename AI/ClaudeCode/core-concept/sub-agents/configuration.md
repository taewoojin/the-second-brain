# Sub-agent 설정

> 출처: https://code.claude.com/docs/en/sub-agents

## 한 눈에 보기

Sub-agent는 저장 위치(Scope)에 따라 우선순위가 결정된다. `/agents` 명령어로 관리하거나 Markdown 파일을 직접 작성해 설정한다. frontmatter로 모델, 도구, 권한 모드, MCP 서버, 메모리, Hook 등을 세밀하게 제어할 수 있다.

## Scope와 우선순위

같은 이름의 Sub-agent가 여러 위치에 있으면 우선순위가 높은 쪽이 사용된다.

| 위치 | 범위 | 우선순위 |
|------|------|----------|
| Managed settings | 조직 전체 | 1 (최고) |
| `--agents` CLI 플래그 | 현재 세션 | 2 |
| `.claude/agents/` | 현재 프로젝트 | 3 |
| `~/.claude/agents/` | 모든 프로젝트 | 4 |
| 플러그인 `agents/` 디렉토리 | 플러그인 활성화 범위 | 5 (최저) |

- 프로젝트 Sub-agent (`.claude/agents/`): 코드베이스 전용 Sub-agent. 버전 관리에 포함해 팀과 공유한다.
- User Sub-agent (`~/.claude/agents/`): 모든 프로젝트에서 사용 가능한 개인 Sub-agent.
- Plugin Sub-agent: 보안상 `hooks`, `mcpServers`, `permissionMode` frontmatter 필드를 지원하지 않는다. 이 기능이 필요하면 `.claude/agents/` 또는 `~/.claude/agents/`에 파일을 복사해야 한다.

## /agents 명령어

`/agents`는 Sub-agent를 관리하는 대화형 인터페이스다.

- 모든 Sub-agent 조회 (내장, User, 프로젝트, 플러그인)
- Sub-agent 편집 및 삭제
- 동일 이름의 Sub-agent 중 어느 것이 활성화되어 있는지 확인

대화형 세션 없이 목록만 보려면:
```bash
claude agents
```

## CLI 플래그로 정의

`--agents` 플래그로 세션 한정 Sub-agent를 JSON으로 전달한다. 디스크에 저장되지 않아 빠른 테스트나 자동화 스크립트에 유용하다.

```bash
claude --agents '{
  "code-reviewer": {
    "description": "Expert code reviewer. Use proactively after code changes.",
    "prompt": "You are a senior code reviewer. Focus on code quality, security, and best practices.",
    "tools": ["Read", "Grep", "Glob", "Bash"],
    "model": "sonnet"
  }
}'
```

`prompt` 필드가 파일 기반 Sub-agent의 마크다운 본문(시스템 프롬프트)에 해당한다.

## frontmatter 필드

Sub-agent 파일은 YAML frontmatter + 마크다운 본문 구조다. 본문이 시스템 프롬프트가 된다.

```markdown
---
name: code-reviewer
description: Reviews code for quality and best practices
tools: Read, Glob, Grep
model: sonnet
---

You are a code reviewer. Analyze code and provide actionable feedback.
```

Sub-agent는 이 시스템 프롬프트만 받는다. 기본 Claude Code 시스템 프롬프트와 메인 대화 컨텍스트는 전달되지 않는다.

| 필드 | 필수 | 설명 |
|------|------|------|
| `name` | ✓ | 소문자 + 하이픈 조합의 고유 식별자 |
| `description` | ✓ | Claude가 이 Sub-agent에 위임할 시점 판단 기준 |
| `tools` | - | 허용 도구 목록. 생략 시 전체 상속 |
| `disallowedTools` | - | 차단할 도구 목록 |
| `model` | - | `sonnet`, `opus`, `haiku`, 전체 모델 ID, `inherit`. 기본값: `inherit` |
| `permissionMode` | - | 권한 모드 (`default`, `acceptEdits`, `auto`, `dontAsk`, `bypassPermissions`, `plan`) |
| `maxTurns` | - | Sub-agent의 최대 턴 수 |
| `skills` | - | 시작 시 컨텍스트에 주입할 Skills 목록 |
| `mcpServers` | - | 이 Sub-agent 전용 MCP 서버 목록 |
| `hooks` | - | Sub-agent 생명주기 Hook |
| `memory` | - | 영구 메모리 범위 (`user`, `project`, `local`) |
| `background` | - | `true`로 설정 시 항상 백그라운드로 실행. 기본값: `false` |
| `effort` | - | 노력 수준 (`low`, `medium`, `high`, `max`). 기본값: 세션 상속 |
| `isolation` | - | `worktree` 설정 시 임시 git worktree에서 실행 |
| `color` | - | 작업 목록에서 표시할 색상 |
| `initialPrompt` | - | `--agent` 플래그로 메인 세션 에이전트로 실행될 때 자동 제출되는 첫 번째 사용자 턴 |

> Sub-agent 파일은 세션 시작 시 로드된다. 파일을 직접 추가한 경우 세션을 재시작하거나 `/agents`를 실행해야 즉시 적용된다.

## 모델 선택

`model` 필드에 지정할 수 있는 값:

- 별칭: `sonnet`, `opus`, `haiku`
- 전체 모델 ID: `claude-opus-4-6`, `claude-sonnet-4-6` 등
- `inherit`: 메인 대화와 동일한 모델 사용 (기본값)

모델 결정 우선순위:

1. `CLAUDE_CODE_SUBAGENT_MODEL` 환경변수
2. 호출 시 전달된 `model` 파라미터
3. Sub-agent frontmatter의 `model` 필드
4. 메인 대화 모델

## 도구(Tool) 제어

### 허용 목록(allowlist) vs 차단 목록(denylist)

```yaml
# allowlist: 지정한 도구만 허용
tools: Read, Grep, Glob, Bash

# denylist: 나머지는 전부 상속, 지정한 것만 차단
disallowedTools: Write, Edit
```

두 필드가 모두 설정된 경우: `disallowedTools`를 먼저 적용한 뒤, 남은 도구 중 `tools`에 있는 것만 허용된다.

### 생성 가능한 Sub-agent 제한

에이전트가 `claude --agent`로 메인 스레드로 실행될 때, 생성할 수 있는 Sub-agent 유형을 제한할 수 있다.

```yaml
tools: Agent(worker, researcher), Read, Bash
```

`Agent` 없이 허용 목록에서 제외하면 어떤 Sub-agent도 생성할 수 없다. 특정 유형만 차단하려면 `permissions.deny`를 사용한다.

> Sub-agent는 다른 Sub-agent를 생성할 수 없으므로, `Agent(type)` 제한은 Sub-agent 정의에서는 효과가 없다.

## 권한 모드(Permission Mode)

Sub-agent는 상위 대화의 권한 컨텍스트를 상속받으며, frontmatter로 모드를 재정의할 수 있다.

| 모드 | 동작 |
|------|------|
| `default` | 표준 권한 확인 및 승인 요청 |
| `acceptEdits` | 보호된 디렉토리 제외 파일 편집 자동 승인 |
| `auto` | 백그라운드 분류기가 명령어와 보호 디렉토리 쓰기를 검토 |
| `dontAsk` | 권한 요청 자동 거부 (명시적으로 허용된 도구는 작동) |
| `bypassPermissions` | 권한 확인 건너뜀 |
| `plan` | Plan Mode (읽기 전용 탐색) |

주의사항:
- 상위가 `bypassPermissions`를 사용하면 이 설정이 강제 적용되며 재정의 불가
- 상위가 `auto` 모드이면 Sub-agent의 `permissionMode`는 무시되고 상위의 분류 규칙이 그대로 적용됨

> `bypassPermissions`는 `.git`, `.claude`, `.vscode` 등 일부 디렉토리는 여전히 확인을 요구한다.

## MCP 서버 범위 제한

`mcpServers` 필드로 이 Sub-agent 전용 MCP 서버를 연결할 수 있다. Sub-agent 시작 시 연결되고 종료 시 해제된다.

```yaml
---
name: browser-tester
description: Tests features in a real browser using Playwright
mcpServers:
  # 인라인 정의: 이 Sub-agent 전용
  - playwright:
      type: stdio
      command: npx
      args: ["-y", "@playwright/mcp@latest"]
  # 이름 참조: 이미 설정된 서버를 공유
  - github
---
```

메인 대화에는 노출시키지 않고 Sub-agent에만 특정 MCP 도구를 제공할 때 유용하다. 메인 대화의 컨텍스트에서 해당 도구 설명이 차지하는 공간도 절약된다.

## Skills 사전 주입

`skills` 필드로 Sub-agent 시작 시 컨텍스트에 Skills 내용을 주입할 수 있다. Sub-agent는 상위 대화의 Skills를 상속하지 않으므로 필요한 것을 명시적으로 나열해야 한다.

```yaml
---
name: api-developer
description: Implement API endpoints following team conventions
skills:
  - api-conventions
  - error-handling-patterns
---
```

`skills`에 나열된 각 Skill의 전체 내용이 Sub-agent 컨텍스트에 직접 주입된다.

## 영구 메모리(Persistent Memory)

`memory` 필드로 대화가 끝나도 유지되는 전용 디렉토리를 부여할 수 있다. Sub-agent가 코드베이스 패턴, 디버깅 인사이트 등을 대화 간에 축적할 때 사용한다.

| Scope | 위치 | 사용 시기 |
|-------|------|-----------|
| `user` | `~/.claude/agent-memory/<name>/` | 모든 프로젝트에서 공유할 지식 |
| `project` | `.claude/agent-memory/<name>/` | 프로젝트 전용, 버전 관리로 공유 가능 |
| `local` | `.claude/agent-memory-local/<name>/` | 프로젝트 전용, 버전 관리에서 제외 |

메모리 활성화 시 동작:
- Sub-agent 시스템 프롬프트에 메모리 디렉토리 읽기/쓰기 지침이 포함됨
- 메모리 디렉토리의 `MEMORY.md`를 최대 200줄 또는 25KB까지 자동으로 시스템 프롬프트에 포함
- Read, Write, Edit 도구가 자동으로 활성화됨

권장 범위: `project`. 팀과 지식을 공유할 수 있다. 프로젝트와 무관한 범용 지식은 `user`, 버전 관리에 포함하면 안 되는 경우는 `local`.

## Hook

### Sub-agent frontmatter의 Hook

Sub-agent frontmatter에 정의된 Hook은 해당 Sub-agent가 활성화된 동안만 실행되고, 종료 시 정리된다.

| 이벤트 | 매처 입력 | 실행 시점 |
|--------|-----------|-----------|
| `PreToolUse` | 도구 이름 | Sub-agent가 도구를 사용하기 전 |
| `PostToolUse` | 도구 이름 | Sub-agent가 도구를 사용한 후 |
| `Stop` | (없음) | Sub-agent 종료 시 (`SubagentStop`으로 자동 변환) |

```yaml
hooks:
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "./scripts/validate-command.sh $TOOL_INPUT"
  PostToolUse:
    - matcher: "Edit|Write"
      hooks:
        - type: command
          command: "./scripts/run-linter.sh"
```

**`$TOOL_INPUT`**: Hook 명령어에서 사용할 수 있는 환경변수로, Claude가 도구를 호출할 때 전달하는 입력 파라미터를 JSON 형식으로 담고 있다. Hook 스크립트는 stdin(표준 입력)으로도 동일한 JSON을 받으며, `jq` 등으로 파싱해 사용할 수 있다.

```bash
# stdin으로 전달된 JSON에서 도구 입력 파싱
INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')
```

### settings.json의 프로젝트 레벨 Hook

메인 세션에서 Sub-agent 생명주기 이벤트에 반응하는 Hook을 설정할 수 있다.

| 이벤트 | 매처 입력 | 실행 시점 |
|--------|-----------|-----------|
| `SubagentStart` | 에이전트 유형 이름 | Sub-agent 실행 시작 시 |
| `SubagentStop` | 에이전트 유형 이름 | Sub-agent 실행 완료 시 |

```json
{
  "hooks": {
    "SubagentStart": [
      {
        "matcher": "db-agent",
        "hooks": [
          { "type": "command", "command": "./scripts/setup-db-connection.sh" }
        ]
      }
    ],
    "SubagentStop": [
      {
        "hooks": [
          { "type": "command", "command": "./scripts/cleanup-db-connection.sh" }
        ]
      }
    ]
  }
}
```

## 특정 Sub-agent 비활성화

`settings.json`의 `deny` 배열에 `Agent(subagent-name)` 형식으로 추가한다.

```json
{
  "permissions": {
    "deny": ["Agent(Explore)", "Agent(my-custom-agent)"]
  }
}
```

CLI 플래그로도 가능하다:

```bash
claude --disallowedTools "Agent(Explore)"
```

내장 및 커스텀 Sub-agent 모두 적용된다.
