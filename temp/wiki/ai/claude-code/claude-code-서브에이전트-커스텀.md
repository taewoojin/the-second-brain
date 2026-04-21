# Claude Code 커스텀 Subagent

**출처**: https://code.claude.com/docs/ko/sub-agents | **날짜**: 2026-04-14

## 요약
Subagent는 자체 컨텍스트 윈도우에서 실행되는 특화된 AI 어시스턴트로, 커스텀 시스템 프롬프트, 제한된 도구 접근, 독립적인 권한을 가진다. 주 대화의 컨텍스트를 소모하지 않고 작업을 격리하여 처리한 뒤 요약만 반환한다.

## 내장 Subagent

| Subagent | 모델 | 도구 | 목적 |
| --- | --- | --- | --- |
| **Explore** | Haiku (빠름) | 읽기 전용 | 파일 검색, 코드 탐색 |
| **Plan** | - | 읽기 전용 | 변경 전 분석/계획 |
| **General-purpose** | - | 전체 상속 | 범용 태스크 |

Claude는 작업에 따라 자동으로 내장 Subagent에 위임함.

## Subagent 파일 형식

YAML frontmatter + 시스템 프롬프트 Markdown:

```markdown
---
name: code-reviewer
description: Reviews code for quality and best practices
tools: Read, Glob, Grep
model: sonnet
---

You are a code reviewer. When invoked, analyze the code and provide
specific, actionable feedback on quality, security, and best practices.
```

`name`과 `description`만 필수. Subagent는 전체 Claude Code 시스템 프롬프트가 아닌 이 시스템 프롬프트만 받음.

## 주요 Frontmatter 필드

| 필드 | 설명 |
| --- | --- |
| `name` | 소문자 하이픈 구분 고유 식별자 |
| `description` | Claude가 언제 이 Subagent를 사용할지 결정하는 설명 |
| `tools` | 허용할 도구 목록 (허용 목록) |
| `disallowedTools` | 거부할 도구 목록 (거부 목록) |
| `model` | `sonnet`, `opus`, `haiku`, 전체 모델 ID, 또는 `inherit` |
| `permissionMode` | `default`, `acceptEdits`, `auto`, `dontAsk`, `bypassPermissions`, `plan` |
| `maxTurns` | 최대 에이전트 턴 수 |
| `skills` | 시작 시 컨텍스트에 로드할 Skills (전체 콘텐츠 주입) |
| `mcpServers` | 이 Subagent에서 사용 가능한 MCP 서버 목록 |
| `hooks` | 이 Subagent 범위 라이프사이클 Hooks |
| `memory` | 영속 메모리 범위: `user`, `project`, `local` |
| `isolation` | `worktree` — 임시 git worktree에서 실행 |
| `background` | `true` — 항상 백그라운드 태스크로 실행 |
| `effort` | 노력 수준: `low`, `medium`, `high`, `max` (Opus 4.6만 해당) |
| `color` | 표시 색상: `red`, `blue`, `green`, `yellow`, `purple` 등 |

## 도구 제한 패턴

```yaml
# 허용 목록: Read/Grep/Glob/Bash만 사용
---
tools: Read, Grep, Glob, Bash
---
```

```yaml
# 거부 목록: Write와 Edit을 제외한 모든 도구 상속
---
disallowedTools: Write, Edit
---
```

둘 다 설정 시 `disallowedTools`가 먼저 적용, `tools`가 남은 풀에서 해결.

## 모델 선택 우선순위

1. `CLAUDE_CODE_SUBAGENT_MODEL` 환경변수
2. 호출별 `model` 파라미터
3. Subagent 정의의 `model` frontmatter
4. 주 대화의 모델

## Subagent 범위 (저장 위치)

| 위치 | 범위 | 우선순위 |
| --- | --- | --- |
| 관리형 설정 | 조직 전체 | 1 (최고) |
| `--agents` CLI 플래그 | 현재 세션 | 2 |
| `.claude/agents/` | 현재 프로젝트 | 3 |
| `~/.claude/agents/` | 모든 프로젝트 | 4 |
| 플러그인 `agents/` | 플러그인 활성화된 곳 | 5 |

## 예제 Subagent

```markdown
---
name: safe-researcher
description: Research codebase without making any modifications
tools: Read, Grep, Glob, Bash
model: haiku
---

You are a read-only research agent. Explore and analyze the codebase,
but never write, edit, or modify any files. Return a structured summary
of your findings.
```

## 관련 항목
- [[wiki/ai/claude-code/claude-code-확장기능-개요]]
- [[wiki/ai/claude-code/claude-code-에이전트팀]]
- [[wiki/ai/claude-code/claude-code-디렉토리-구조]]
