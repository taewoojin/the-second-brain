# Claude Code 사용자 정의 Subagent 구성

**출처**: `raw/claude-code-custom-subagent.md` | **날짜**: 2026-04-21

## 요약

Subagent는 YAML frontmatter가 있는 Markdown 파일로 정의되는 특화된 AI 어시스턴트다. 각 subagent는 독립적인 컨텍스트 윈도우에서 실행되어 주 대화의 컨텍스트를 보호하며, 도구 제한·권한 모드·hooks·persistent memory를 세밀하게 구성할 수 있다.

## Subagent가 해결하는 문제

| 목적 | 설명 |
| --- | --- |
| **컨텍스트 보존** | 탐색·구현 작업을 주 대화에서 분리하여 컨텍스트 절약 |
| **제약 조건 적용** | subagent가 사용할 수 있는 도구·권한을 제한 |
| **구성 재사용** | 사용자 수준 subagent로 프로젝트 간 재사용 |
| **비용 제어** | Haiku 같은 더 빠르고 저렴한 모델로 작업 라우팅 |

## 저장 위치와 우선순위

| 위치 | 범위 | 우선순위 |
| --- | --- | --- |
| 관리되는 설정 내 `.claude/agents/` | 조직 전체 | 1 (최고) |
| `--agents` CLI 플래그 | 현재 세션 | 2 |
| `.claude/agents/` | 현재 프로젝트 | 3 |
| `~/.claude/agents/` | 모든 프로젝트 | 4 |
| 플러그인의 `agents/` | 플러그인 활성화 범위 | 5 (최저) |

같은 이름의 subagent가 여러 위치에 있으면 더 높은 우선순위가 우선한다. `/agents` 명령으로 중복 포함 전체 subagent 목록을 확인할 수 있다.

## Subagent 파일 구조

Subagent는 YAML frontmatter + Markdown 시스템 프롬프트로 구성된다:

```markdown
---
name: code-reviewer
description: Reviews code for quality and best practices. Use proactively after code changes.
tools: Read, Glob, Grep, Bash
model: sonnet
---

You are a senior code reviewer. When invoked, analyze the code and provide
specific, actionable feedback on quality, security, and best practices.
```

Subagent는 이 시스템 프롬프트만 받는다. 전체 Claude Code 시스템 프롬프트는 받지 않는다.

## frontmatter 전체 필드 목록

| 필드 | 필수 | 설명 |
| --- | --- | --- |
| `name` | 예 | 소문자·하이픈으로 구성된 고유 식별자 |
| `description` | 예 | Claude가 언제 이 subagent에 위임할지 결정하는 기준 |
| `tools` | 아니오 | 허용할 도구 목록 (생략 시 주 대화의 모든 도구 상속) |
| `disallowedTools` | 아니오 | 거부할 도구 목록 (상속된 목록에서 제거) |
| `model` | 아니오 | `sonnet` / `opus` / `haiku` / 전체 ID / `inherit`. 기본값: `inherit` |
| `permissionMode` | 아니오 | `default` / `acceptEdits` / `auto` / `dontAsk` / `bypassPermissions` / `plan` |
| `maxTurns` | 아니오 | 중지 전 최대 에이전트 턴 수 |
| `skills` | 아니오 | 시작 시 컨텍스트에 주입할 skill 목록 (호출 가능이 아닌 콘텐츠 주입) |
| `mcpServers` | 아니오 | 이 subagent에만 범위 지정된 MCP 서버 (인라인 정의 또는 이름 참조) |
| `hooks` | 아니오 | 이 subagent가 활성화된 동안만 실행되는 라이프사이클 hooks |
| `memory` | 아니오 | 지속적 메모리 범위: `user` / `project` / `local` |
| `background` | 아니오 | `true`로 설정 시 항상 background task로 실행. 기본값: `false` |
| `effort` | 아니오 | 노력 수준 재정의: `low` / `medium` / `high` / `max` (Opus 4.6만) |
| `isolation` | 아니오 | `worktree` 설정 시 임시 git worktree에서 실행 |
| `color` | 아니오 | 작업 목록·트랜스크립트 표시 색상 |
| `initialPrompt` | 아니오 | `--agent`로 주 세션 에이전트로 실행될 때 첫 번째 사용자 턴으로 자동 제출 |

## 모델 해결 우선순위

Claude Code가 subagent 모델을 해결하는 순서:
1. `CLAUDE_CODE_SUBAGENT_MODEL` 환경변수
2. 호출별 `model` 매개변수
3. Subagent 정의의 `model` frontmatter
4. 주 대화의 모델 (상속)

## 도구 제어

### 허용 목록 vs. 거부 목록

```yaml
# 허용 목록: 지정된 도구만 사용 가능
tools: Read, Grep, Glob, Bash

# 거부 목록: 상속된 모든 도구에서 지정 도구만 제외
disallowedTools: Write, Edit
```

둘 다 설정하면 `disallowedTools`가 먼저 적용되고, `tools`가 남은 풀에서 필터링된다.

### subagent가 생성할 수 있는 에이전트 제한

```yaml
# coordinator만 worker, researcher를 생성 가능
tools: Agent(worker, researcher), Read, Bash

# 모든 subagent 생성 허용
tools: Agent, Read, Bash
```

`Agent`가 `tools`에 없으면 해당 subagent는 다른 subagent를 생성할 수 없다. 이 제한은 `claude --agent`로 주 스레드로 실행되는 에이전트에만 적용된다.

## 권한 모드

| 모드 | 동작 |
| --- | --- |
| `default` | 표준 권한 확인 (프롬프트 표시) |
| `acceptEdits` | 파일 편집 자동 수락 |
| `auto` | AI 분류기가 각 도구 호출을 평가 |
| `dontAsk` | 권한 프롬프트 자동 거부 (명시적 허용 도구는 유지) |
| `bypassPermissions` | 권한 프롬프트 건너뜀 |
| `plan` | 읽기 전용 탐색 |

부모가 `bypassPermissions` 또는 `auto` 모드를 사용하면 subagent의 `permissionMode` 설정은 무시된다.

## Hooks 구성

### Subagent frontmatter에서 정의 (subagent가 활성화된 동안만 실행)

```yaml
hooks:
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "./scripts/validate-command.sh"
  PostToolUse:
    - matcher: "Edit|Write"
      hooks:
        - type: command
          command: "./scripts/run-linter.sh"
```

frontmatter의 `Stop` hook은 자동으로 `SubagentStop` 이벤트로 변환된다.

### settings.json에서 정의 (주 세션에서 subagent 라이프사이클에 반응)

```json
{
  "hooks": {
    "SubagentStart": [{ "matcher": "db-agent", "hooks": [...] }],
    "SubagentStop": [{ "hooks": [...] }]
  }
}
```

## 지속적 메모리 (Persistent Memory)

`memory` 필드로 교차 세션 학습을 활성화한다:

| 범위 | 위치 | 사용 시기 |
| --- | --- | --- |
| `user` | `~/.claude/agent-memory/<name>/` | 모든 프로젝트에 걸친 학습 |
| `project` | `.claude/agent-memory/<name>/` | 프로젝트별·팀 공유 가능 학습 |
| `local` | `.claude/agent-memory-local/<name>/` | 프로젝트별이지만 버전 제어 제외 |

활성화되면 subagent의 시스템 프롬프트에 메모리 디렉토리 읽기/쓰기 지침과 `MEMORY.md` 처음 200줄이 자동 포함된다. `project`가 권장 기본값이다.

## MCP 서버 범위 지정

주 대화에 없는 MCP 서버를 특정 subagent에만 제공할 수 있다. 인라인 정의는 subagent 시작 시 연결되고 완료 시 종료된다:

```yaml
mcpServers:
  - playwright:
      type: stdio
      command: npx
      args: ["-y", "@playwright/mcp@latest"]
  - github  # 이미 구성된 서버 이름 참조
```

## Subagent 호출 패턴

### 자동 위임
Claude가 `description` 필드를 보고 작업을 자동 위임한다. `"use proactively"` 구문을 description에 포함하면 적극적인 위임을 유도할 수 있다.

### 명시적 호출

```text
# 자연어
Use the code-reviewer subagent to review auth changes

# @-mention (해당 subagent 실행 보장)
@"code-reviewer (agent)" look at the auth changes
```

### 세션 전체 에이전트로 실행

```bash
claude --agent code-reviewer
```

세션의 시스템 프롬프트가 subagent의 것으로 완전히 교체된다. 프로젝트 기본값으로 설정하려면 `.claude/settings.json`에 `"agent": "code-reviewer"` 추가.

### Background vs Foreground
- **Foreground**: 완료까지 주 대화 차단. 권한 프롬프트 사용자에게 전달
- **Background**: 동시 실행. 사전 승인된 권한만 사용, 미승인 요청은 자동 거부

`Ctrl+B`로 실행 중인 작업을 background로 전환 가능.

## 특정 Subagent 비활성화

```json
{
  "permissions": {
    "deny": ["Agent(Explore)", "Agent(my-custom-agent)"]
  }
}
```

## 관련 항목

- [[wiki/ai/claude-code/claude-code-확장기능-개요]]
- [[wiki/ai/claude-code/claude-code-hooks-자동화가이드]]
- [[wiki/ai/claude-code/claude-code-메모리-CLAUDE-md]]
- [[wiki/ai/claude-code/claude-code-권한모드]]
