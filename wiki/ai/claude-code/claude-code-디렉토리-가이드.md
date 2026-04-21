# Claude Code .claude 디렉토리 완전 가이드

**출처**: `raw/claude-code-directory-guide.md` | https://code.claude.com/docs/en/claude-directory
**날짜**: 2026-04-21
**keywords**: .claude, settings.json, CLAUDE.md, rules, skills, agents, subagent, auto-memory, MCP, hooks, worktree, output-styles

## 요약

Claude Code는 프로젝트 `.claude/`와 홈 `~/.claude` 두 레벨에서 설정·지시사항·스킬·에이전트·메모리를 읽는다. 프로젝트 파일은 git에 커밋해 팀과 공유하고, `~/.claude` 파일은 모든 프로젝트에 적용되는 개인 설정이다. 대부분의 사용자는 `CLAUDE.md`와 `settings.json`만 편집하면 된다.

`CLAUDE_CONFIG_DIR` 환경변수를 설정하면 모든 `~/.claude` 경로가 해당 디렉토리로 이동한다.

---

## 프로젝트 스코프 파일 (`.claude/`)

git에 커밋해 팀과 공유하는 파일들.

### CLAUDE.md

**로드 시점**: 세션 시작 시 항상 컨텍스트에 로드. `.claude/CLAUDE.md`에 두어도 동일하게 동작.

이 저장소에서 Claude가 어떻게 동작할지를 정의하는 프로젝트 전용 지시사항 파일. 팀이 공유하는 규칙, 자주 실행하는 명령어, 아키텍처 컨텍스트를 작성하면 Claude가 팀과 동일한 전제를 갖고 작업한다.

**팁:**
- 200줄 이내를 목표로. 더 길어도 전체가 로드되지만 지시사항 준수율이 낮아질 수 있다
- 특정 작업에만 필요한 내용은 skill이나 경로 제한 rule로 분리해 필요할 때만 로드되도록 한다
- 세션 내에서 `/memory` 명령으로 CLAUDE.md를 열고 편집할 수 있다
- 프로젝트 루트를 깔끔하게 유지하고 싶다면 `.claude/CLAUDE.md`에 두어도 된다

**예제** (TypeScript + React 프로젝트):
```markdown
# Project conventions

## Commands
- Build: `npm run build`
- Test: `npm test`
- Lint: `npm run lint`

## Stack
- TypeScript with strict mode
- React 19, functional components only

## Rules
- Named exports, never default exports
- Tests live next to source: `foo.ts` -> `foo.test.ts`
- All API routes return `{ data, error }` shape
```

---

### .mcp.json

**로드 시점**: 세션 시작 시 서버 연결. 툴 스키마는 기본적으로 지연 로드(deferred)되며 툴 검색 시 필요에 따라 로드됨.

팀이 공유하는 MCP 서버 설정 파일. 개인용 서버는 `~/.claude.json`에 따로 설정한다.

**팁:**
- 시크릿은 환경변수 참조 방식으로 작성: `${GITHUB_TOKEN}` → Claude Code가 서버 시작 시 셸 환경에서 읽어옴
- 프로젝트 루트에 위치하며, `.claude/` 안이 아님
- 개인용 서버는 `claude mcp add --scope user` 명령으로 추가 → `~/.claude.json`에 기록됨

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": { "GITHUB_TOKEN": "${GITHUB_TOKEN}" }
    }
  }
}
```

---

### .worktreeinclude

**로드 시점**: `--worktree` 플래그, `EnterWorktree` 툴, 또는 subagent의 `isolation: worktree` 설정으로 git worktree를 생성할 때 읽힘.

새 worktree 생성 시 메인 저장소에서 복사할 gitignore 파일(`.env` 등 트래킹되지 않는 파일) 목록. `.gitignore`와 동일한 패턴 문법. 프로젝트 루트에 위치.

---

### .claude/settings.json

**로드 시점**: 글로벌 `~/.claude/settings.json`을 덮어씀.

Claude Code가 직접 적용하는 설정 파일. CLAUDE.md가 Claude가 읽는 "지침"인 것과 달리, 이 파일의 설정은 Claude 의사와 무관하게 강제로 적용된다.

**주요 설정 키:**
- `permissions`: Claude가 특정 툴이나 명령어를 사용할 때 허용/거부/확인 요청 설정
- `hooks`: 툴 호출 전후, 파일 편집 후 등 이벤트에 스크립트 실행
- `statusLine`: Claude 작업 중 하단에 표시되는 줄 커스터마이즈
- `model`: 이 프로젝트의 기본 모델 설정
- `env`: 모든 세션에 설정할 환경변수
- `outputStyle`: `output-styles/` 폴더에서 커스텀 시스템 프롬프트 스타일 선택

**팁:**
- Bash 권한 패턴은 와일드카드 지원: `Bash(npm test *)` → `npm test`로 시작하는 모든 명령 매칭
- `permissions.allow` 같은 배열 설정은 모든 스코프에 걸쳐 합산. `model` 같은 단일 값 설정은 가장 구체적인 스코프 값이 사용됨

```json
{
  "permissions": {
    "allow": ["Bash(npm test *)", "Bash(npm run *)"],
    "deny": ["Bash(rm -rf *)"]
  },
  "hooks": {
    "PostToolUse": [{
      "matcher": "Edit|Write",
      "hooks": [{"type": "command", "command": "jq -r '.tool_input.file_path' | xargs npx prettier --write"}]
    }]
  }
}
```

---

### .claude/settings.local.json

**로드 시점**: 사용자가 편집 가능한 설정 파일 중 가장 높은 우선순위.

팀 기본값보다 우선 적용되는 개인 설정. `settings.json`과 동일한 JSON 형식이지만 커밋되지 않는다. Claude Code가 처음 이 파일을 생성할 때 `~/.config/git/ignore`에 자동으로 추가한다.

---

### .claude/rules/

**로드 시점**: `paths:` 프론트매터가 없는 룰은 세션 시작 시 로드. `paths:`가 있는 룰은 매칭 파일이 컨텍스트에 들어올 때만 로드.

파일 경로에 따라 조건부로 로드할 수 있는 주제별 지시사항 파일들. CLAUDE.md가 200줄에 가까워지면 rule로 분리하기 시작한다. 하위 디렉토리도 자동 인식: `.claude/rules/frontend/react.md`.

**예제** — `testing.md` (테스트 파일에만 적용):
```markdown
---
paths:
  - "**/*.test.ts"
  - "**/*.test.tsx"
---

# Testing Rules

- Use descriptive test names: "should [expected] when [condition]"
- Mock external dependencies, not internal modules
```

---

### .claude/skills/

**로드 시점**: `/skill-name`으로 직접 호출하거나 Claude가 작업에 맞는 스킬을 자동으로 매칭할 때 실행.

각 스킬은 `SKILL.md` 파일과 지원 파일들로 이루어진 폴더. 기본적으로 사용자와 Claude 모두 스킬을 호출할 수 있다.

**프론트매터 제어:**
- `disable-model-invocation: true` → `/deploy` 같은 사용자 전용 워크플로우
- `user-invocable: false` → `/` 메뉴에는 숨기되 Claude는 호출 가능

**팁:**
- 스킬은 인수를 받는다: `/deploy staging` → "staging"이 `$ARGUMENTS`로 전달됨. 위치 인수는 `$0`, `$1` 등으로 접근
- `description` 프론트매터가 Claude가 자동으로 스킬을 호출하는 시점을 결정함
- 스킬 디렉토리 내 지원 파일 참조 시 `${CLAUDE_SKILL_DIR}` 플레이스홀더 사용

```markdown
---
description: Reviews code changes for security vulnerabilities
disable-model-invocation: true
argument-hint: <branch-or-path>
---

!`git diff $ARGUMENTS`

Audit the changes above for injection vulnerabilities, auth gaps, and hardcoded secrets.
```

> `` !`...` `` 문법은 셸 명령을 실행하고 그 출력을 프롬프트에 주입한다.

---

### .claude/commands/ (레거시)

`/name`으로 호출하는 단일 파일 프롬프트. **새 워크플로우는 `skills/` 사용 권장.** 스킬과 커맨드의 이름이 같으면 스킬이 우선한다.

---

### .claude/output-styles/

**로드 시점**: `outputStyle` 설정으로 선택되면 세션 시작 시 적용됨.

시스템 프롬프트에 추가되는 섹션으로 코딩 이외의 용도로 Claude Code를 활용하거나 강의/리뷰 모드를 추가할 때 사용한다. `/config` 또는 settings의 `outputStyle` 키로 선택한다.

**팁:**
- 기존 작업 지시사항을 유지하면서 추가하려면 프론트매터에 `keep-coding-instructions: true` 설정
- 시스템 프롬프트는 시작 시 캐싱되므로 변경사항은 다음 세션부터 적용됨

---

### .claude/agents/

**로드 시점**: 사용자 또는 Claude가 호출하면 별도의 컨텍스트 윈도우에서 실행됨.

각 마크다운 파일이 자체 시스템 프롬프트, 툴 접근 권한, 선택적으로 전용 모델을 갖는 subagent를 정의한다. `@`를 입력하고 자동완성에서 에이전트를 선택해 직접 작업 위임 가능.

**팁:**
- `tools:` 프론트매터로 에이전트별 툴 접근 제한 가능
- `description` 프론트매터가 Claude가 자동으로 이 에이전트에 위임하는 시점을 결정

```markdown
---
name: code-reviewer
description: Reviews code for correctness, security, and maintainability
tools: Read, Grep, Glob
---

You are a senior code reviewer. Review for correctness, security, and maintainability.
```

---

### .claude/agent-memory/

**로드 시점**: subagent 실행 시 `MEMORY.md`의 첫 200줄 (최대 25KB)이 subagent 시스템 프롬프트에 로드됨.

`memory: project`를 설정한 subagent의 전용 메모리 디렉토리. 메인 세션 자동 메모리(`~/.claude/projects/`)와 별개다.

- `memory: local` → `.claude/agent-memory-local/`에 저장 (버전 관리 제외)
- `memory: user` → `~/.claude/agent-memory/`에 저장 (모든 프로젝트)

---

## 글로벌 스코프 파일 (`~/.claude/`)

홈 디렉토리에 위치하며 모든 프로젝트에 적용되는 개인 설정. git에 커밋되지 않는다.

### ~/.claude.json

앱 상태 및 UI 설정. `/config`에서 설정 변경 시 Claude Code가 다시 씀.

- `showTurnDuration`, `terminalProgressBarEnabled` 같은 UI 토글이 여기 위치
- `projects` 키는 신뢰 대화 수락, 마지막 세션 지표 등 프로젝트별 상태 추적
- 개인용 MCP 서버 (user 스코프: 모든 프로젝트 적용, local 스코프: 해당 프로젝트만)

---

### ~/.claude/CLAUDE.md

모든 프로젝트의 모든 세션 시작 시 로드됨. 프로젝트 CLAUDE.md와 함께 컨텍스트에 로드되어 둘 다 적용된다. 지시사항이 충돌하면 프로젝트 레벨이 우선. 짧게 유지할 것.

---

### ~/.claude/settings.json

프로젝트 `settings.json`과 동일한 키들. 모든 프로젝트에 항상 적용할 설정을 여기에 넣는다. 프로젝트 `settings.json`이 여기 키를 덮어씀.

**우선순위 순서 (높음 → 낮음):**
1. Managed settings (조직 배포)
2. CLI 플래그 (`--permission-mode`, `--settings`)
3. `.claude/settings.local.json` (프로젝트 개인)
4. `.claude/settings.json` (프로젝트 팀)
5. `~/.claude/settings.json` (글로벌 기본)

---

### ~/.claude/keybindings.json

**로드 시점**: 세션 시작 시 읽히며, 파일 편집 시 핫리로드됨.

인터랙티브 CLI 키보드 단축키 재설정. `/keybindings` 명령으로 이 파일을 스키마 참조와 함께 생성하거나 열 수 있다. Ctrl+C, Ctrl+D, Ctrl+M은 예약되어 재설정 불가.

```json
{
  "$schema": "https://www.schemastore.org/claude-code-keybindings.json",
  "bindings": [
    {
      "context": "Chat",
      "bindings": {
        "ctrl+e": "chat:externalEditor",
        "ctrl+u": null
      }
    }
  ]
}
```

> `null`로 설정하면 해당 키 바인딩을 해제한다.

---

### ~/.claude/projects/ (자동 메모리)

**로드 시점**: 세션 시작 시 `MEMORY.md` 로드. 토픽 파일은 필요 시 읽힘.

Claude가 세션 간에 스스로 축적하는 프로젝트별 메모. 빌드 명령어, 디버깅 인사이트, 아키텍처 메모 등을 작업하면서 저장한다.

**팁:**
- 기본적으로 활성화됨. `/memory` 명령이나 settings의 `autoMemoryEnabled`로 토글 가능
- `MEMORY.md`: 세션마다 로드되는 인덱스. 첫 200줄 또는 25KB 중 먼저 도달하는 것까지 읽힘
- `debugging.md` 같은 토픽 파일은 관련 작업이 생길 때만 읽힘 (시작 시 전부 로드하지 않음)
- 일반 마크다운 파일이므로 언제든 편집하거나 삭제할 수 있음

---

## 파일 전체 참조 테이블

| 파일 | 스코프 | git 커밋 | 역할 |
|------|--------|----------|------|
| `CLAUDE.md` | 프로젝트 + 글로벌 | ✓ | 매 세션 로드되는 지시사항 |
| `rules/*.md` | 프로젝트 + 글로벌 | ✓ | 주제별 지시사항, 선택적 경로 게이팅 |
| `settings.json` | 프로젝트 + 글로벌 | ✓ | 권한, 훅, 환경변수, 모델 기본값 |
| `settings.local.json` | 프로젝트 전용 | - | 개인 오버라이드, 자동 gitignore |
| `.mcp.json` | 프로젝트 전용 | ✓ | 팀 공유 MCP 서버 |
| `.worktreeinclude` | 프로젝트 전용 | ✓ | 새 worktree에 복사할 gitignore 파일 |
| `skills/<name>/SKILL.md` | 프로젝트 + 글로벌 | ✓ | `/name`으로 호출하거나 자동 호출되는 재사용 프롬프트 |
| `commands/*.md` | 프로젝트 + 글로벌 | ✓ | 단일 파일 프롬프트 (레거시, 스킬 권장) |
| `output-styles/*.md` | 프로젝트 + 글로벌 | ✓ | 커스텀 시스템 프롬프트 섹션 |
| `agents/*.md` | 프로젝트 + 글로벌 | ✓ | 전용 프롬프트와 툴을 가진 subagent 정의 |
| `agent-memory/<name>/` | 프로젝트 + 글로벌 | ✓ | subagent의 영구 메모리 |
| `~/.claude.json` | 글로벌 전용 | - | 앱 상태, OAuth, UI 토글, 개인 MCP 서버 |
| `projects/<project>/memory/` | 글로벌 전용 | - | 자동 메모리: Claude가 세션 간 스스로 기록 |
| `keybindings.json` | 글로벌 전용 | - | 커스텀 키보드 단축키 |

---

## 실제로 로드된 내용 확인하기

| 명령어 | 표시 내용 |
|--------|-----------|
| `/context` | 카테고리별 토큰 사용량: 시스템 프롬프트, 메모리 파일, 스킬, MCP 툴, 메시지 |
| `/memory` | 로드된 CLAUDE.md와 룰 파일들, 자동 메모리 항목 |
| `/agents` | 설정된 subagent와 설정값 |
| `/hooks` | 활성화된 훅 설정 |
| `/mcp` | 연결된 MCP 서버와 상태 |
| `/skills` | 프로젝트, 사용자, 플러그인 소스의 사용 가능한 스킬 |
| `/permissions` | 현재 허용/거부 규칙 |
| `/doctor` | 설치 및 설정 진단 |

---

## 애플리케이션 데이터 보안

트랜스크립트와 히스토리는 저장 시 암호화되지 않는다. OS 파일 권한만이 유일한 보호 수단. 툴이 `.env` 파일을 읽거나 명령어가 자격증명을 출력하면 `projects/<project>/<session>.jsonl`에 기록된다.

노출 줄이기:
- `cleanupPeriodDays`를 낮춰 트랜스크립트 보관 기간 단축
- `CLAUDE_CODE_SKIP_PROMPT_HISTORY` 환경변수로 트랜스크립트와 프롬프트 히스토리 기록 건너뛰기
- 자격증명 파일 읽기를 거부하는 권한 규칙 설정

**삭제하면 안 되는 파일:**
- `~/.claude.json` (인증 정보)
- `~/.claude/settings.json` (설정)
- `~/.claude/plugins/` (설치된 플러그인)

## 관련 항목

- [[wiki/ai/claude-code/claude-code-메모리-CLAUDE-md]]
- [[wiki/ai/claude-code/claude-code-확장기능-개요]]
- [[wiki/ai/claude-code/claude-code-hooks-자동화가이드]]
- [[wiki/ai/claude-code/claude-code-작동방식-에이전트하네스]]
