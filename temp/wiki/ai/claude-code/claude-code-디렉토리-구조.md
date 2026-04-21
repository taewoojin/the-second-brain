# Claude Code .claude 디렉토리 구조

**출처**: https://code.claude.com/docs/en/claude-directory | **날짜**: 2026-04-13

## 요약
Claude Code는 프로젝트의 `.claude/` 디렉토리와 전역 `~/.claude/`에서 지시, 설정, Skills, Subagents, 메모리를 읽는다. 프로젝트 파일은 git에 커밋하여 팀과 공유하고, `~/.claude/`는 모든 프로젝트에 적용되는 개인 설정이다.

## 프로젝트 범위 파일

| 파일/경로 | 역할 | 커밋 |
| --- | --- | --- |
| `CLAUDE.md` | 매 세션 로드되는 프로젝트 지시 | ✓ |
| `.mcp.json` | 팀 공유 MCP 서버 목록 | ✓ |
| `.worktreeinclude` | 새 worktree 생성 시 복사할 gitignore 파일 목록 | ✓ |
| `.claude/settings.json` | 권한, hooks, 환경변수, 모델 설정 | ✓ |
| `.claude/settings.local.json` | 개인 설정 오버라이드 (자동 gitignore) | - |
| `.claude/rules/*.md` | 파일 경로 조건부 로드되는 주제별 지시 | ✓ |
| `.claude/skills/<name>/SKILL.md` | `/name`으로 호출하는 재사용 프롬프트 | ✓ |
| `.claude/commands/*.md` | Skills와 동일 메커니즘의 단일 파일 명령 | ✓ |
| `.claude/agents/*.md` | 자체 프롬프트와 도구를 가진 Subagent 정의 | ✓ |
| `.claude/agent-memory/<name>/` | Subagent 전용 영속 메모리 | ✓ |
| `.claude/output-styles/*.md` | 커스텀 시스템 프롬프트 섹션 | ✓ |

## 전역 범위 파일 (`~/.claude/`)

| 파일/경로 | 역할 |
| --- | --- |
| `~/.claude.json` | 앱 상태, OAuth, UI 토글, 개인 MCP 서버 |
| `~/.claude/CLAUDE.md` | 모든 프로젝트에 적용되는 개인 선호 |
| `~/.claude/settings.json` | 모든 프로젝트 기본 설정 |
| `~/.claude/keybindings.json` | 커스텀 키보드 단축키 |
| `~/.claude/projects/` | Auto memory: 프로젝트별 자동 학습 메모 |
| `~/.claude/skills/` | 모든 프로젝트에서 사용 가능한 개인 Skills |
| `~/.claude/agents/` | 모든 프로젝트에서 사용 가능한 개인 Subagents |
| `~/.claude/rules/` | 모든 프로젝트에 적용되는 사용자 수준 규칙 |

## 설정 우선순위

관리형 설정(managed) > CLI 플래그 > `.claude/settings.local.json` > `.claude/settings.json` > `~/.claude/settings.json`

`CLAUDE.md`는 우선순위 규칙이 아니라 **additive** 방식: 모든 레벨의 파일이 동시에 컨텍스트에 로드된다.

## Skills vs Commands 차이

`commands/*.md`와 `skills/<name>/SKILL.md`는 동일 메커니즘을 사용하며, 같은 이름이 있으면 Skill이 우선한다. 새 워크플로우는 Skills를 사용하는 것이 권장된다 (지원 파일 번들 가능).

## 세션 확인 명령어

| 명령 | 확인 내용 |
| --- | --- |
| `/context` | 토큰 사용량 카테고리별 (시스템 프롬프트, 메모리, Skills, MCP 도구, 메시지) |
| `/memory` | 로드된 CLAUDE.md와 rules 파일, auto-memory 항목 |
| `/agents` | 설정된 Subagent와 설정 |
| `/hooks` | 활성 Hook 설정 |
| `/mcp` | 연결된 MCP 서버와 상태 |
| `/skills` | 프로젝트/사용자/플러그인 소스의 사용 가능한 Skills |
| `/permissions` | 현재 allow/deny 규칙 |

## 애플리케이션 데이터 (자동 삭제)

`~/.claude/` 아래에 Claude Code가 세션 중 기록하는 파일들:
- `projects/<project>/<session>.jsonl` — 전체 대화 트랜스크립트 (기본 30일 후 삭제)
- `file-history/<session>/` — 편집 전 파일 스냅샷 (체크포인트 복원용)
- `history.jsonl` — 입력한 모든 프롬프트 (수동 삭제 필요)

> **주의**: 트랜스크립트는 암호화되지 않음. `.env` 파일 읽기나 자격증명 출력 명령이 실행되면 해당 값이 `projects/<project>/<session>.jsonl`에 기록됨.

## 관련 항목
- [[wiki/ai/claude-code/claude-code-작동원리-에이전틱루프]]
- [[wiki/ai/claude-code/claude-code-확장기능-개요]]
- [[wiki/ai/claude-code/claude-code-메모리-CLAUDE-md]]
- [[wiki/ai/claude-code/claude-code-hooks-활용가이드]]
- [[wiki/ai/claude-code/claude-code-서브에이전트-커스텀]]
