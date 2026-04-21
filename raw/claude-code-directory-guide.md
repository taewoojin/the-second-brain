# Claude Code .claude 디렉토리 완전 가이드

> 출처: https://code.claude.com/docs/en/claude-directory

Claude Code는 프로젝트 디렉토리와 홈 디렉토리(`~/.claude`)에서 설정 파일, 지시사항, 스킬, 서브에이전트, 메모리를 읽는다. 프로젝트 파일은 git에 커밋해 팀이 공유하고, `~/.claude` 파일은 모든 프로젝트에 적용되는 개인 설정이다.

`CLAUDE_CONFIG_DIR` 환경 변수를 설정하면 이 페이지의 모든 `~/.claude` 경로가 해당 디렉토리 아래로 이동한다.

대부분의 사용자는 `CLAUDE.md`와 `settings.json`만 편집한다. 나머지는 필요할 때 추가하면 된다.

---

## 프로젝트 스코프 파일

프로젝트 루트와 `.claude/` 하위에 위치하며, git에 커밋해 팀과 공유할 수 있다.

### CLAUDE.md

**한 줄 설명:** 매 세션마다 Claude가 읽는 프로젝트 지시사항

**로드 시점:** 세션 시작 시 항상 컨텍스트에 로드됨. `.claude/CLAUDE.md`에 두어도 동일하게 동작함

**설명:** 이 저장소에서 Claude가 어떻게 동작할지를 정의하는 프로젝트 전용 지시사항 파일. 팀 전체가 공유하는 규칙, 자주 실행하는 명령어, 아키텍처 컨텍스트를 여기에 작성하면 Claude가 팀과 동일한 전제를 갖고 작업한다.

**팁:**
- 200줄 이내를 목표로 한다. 더 길어도 전체가 로드되지만 지시사항 준수율이 낮아질 수 있다
- CLAUDE.md는 모든 세션에 로드된다. 특정 작업에만 필요한 내용은 스킬(skill)이나 경로 제한 룰(rule)로 분리해 필요할 때만 로드되도록 한다
- 빌드, 테스트, 포맷 등 자주 실행하는 명령어를 나열해두면 Claude가 매번 물어볼 필요가 없다
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

**한 줄 설명:** 팀이 공유하는 프로젝트 스코프 MCP 서버 설정

**로드 시점:** 세션 시작 시 서버가 연결됨. 툴 스키마는 기본적으로 지연 로드(deferred)되며 툴 검색 시 필요에 따라 로드됨

**설명:** Claude에게 외부 도구(데이터베이스, API, 브라우저 등)에 대한 접근 권한을 부여하는 MCP(Model Context Protocol) 서버를 설정하는 파일. 팀 전체가 사용하는 서버를 이 파일에 설정한다. 개인용 서버는 `~/.claude.json`에 따로 설정한다.

**팁:**
- 시크릿(비밀 키)은 환경 변수 참조 방식으로 작성한다: `${GITHUB_TOKEN}`
- 프로젝트 루트에 위치하며, `.claude/` 안이 아님
- 개인용 서버는 `claude mcp add --scope user` 명령으로 추가한다. 이 경우 `.mcp.json`이 아닌 `~/.claude.json`에 기록됨

**예제** (GitHub MCP 서버):
```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_TOKEN": "${GITHUB_TOKEN}"
      }
    }
  }
}
```
> `${GITHUB_TOKEN}`은 Claude Code가 서버를 시작할 때 셸 환경에서 읽어오므로, 실제 토큰 값이 파일에 저장되지 않는다.

---

### .worktreeinclude

**한 줄 설명:** 새 worktree 생성 시 복사할 gitignore 파일 목록

**로드 시점:** `--worktree` 플래그, `EnterWorktree` 툴, 또는 서브에이전트의 `isolation: worktree` 설정으로 git worktree를 생성할 때 읽힘

**설명:** 메인 저장소에서 새 worktree로 복사할 gitignore 파일을 나열한다. Worktree는 새로운 체크아웃이기 때문에 `.env` 같은 트래킹되지 않는 파일이 기본적으로 없다. 패턴 문법은 `.gitignore`와 동일하다. 패턴에 매칭되면서 gitignore된 파일만 복사되므로, 트래킹되는 파일은 절대 중복 복사되지 않는다.

**팁:**
- 프로젝트 루트에 위치하며, `.claude/` 안이 아님
- Git 전용: 다른 VCS용 `WorktreeCreate` 훅을 설정했다면 이 파일은 읽히지 않는다. 해당 훅 스크립트 안에서 직접 파일을 복사해야 한다
- 데스크탑 앱의 병렬 세션에도 동일하게 적용됨

**예제**:
```
# Local environment
.env
.env.local

# API credentials
config/secrets.json
```

---

### .claude/settings.json

**한 줄 설명:** 권한(permissions), 훅(hooks), 설정

**로드 시점:** 글로벌 `~/.claude/settings.json`을 덮어쓴다. 로컬 settings, CLI 플래그, managed settings가 이보다 우선함

**설명:** Claude Code가 직접 적용하는 설정 파일. `permissions`는 Claude가 특정 툴이나 명령어를 사용할 수 있는지 제어하고, `hooks`는 세션의 특정 이벤트 시점에 사용자 스크립트를 실행한다. CLAUDE.md가 Claude가 읽는 "지침"인 것과 달리, 이 파일의 설정은 Claude 의사와 무관하게 강제로 적용된다.

**주요 설정 키:**
- `permissions`: Claude가 특정 툴이나 명령어를 사용할 때 허용/거부/확인 요청 설정
- `hooks`: 툴 호출 전후, 파일 편집 후 등 이벤트에 스크립트 실행
- `statusLine`: Claude 작업 중 하단에 표시되는 줄 커스터마이즈
- `model`: 이 프로젝트의 기본 모델 설정
- `env`: 모든 세션에 설정할 환경 변수
- `outputStyle`: `output-styles/` 폴더에서 커스텀 시스템 프롬프트 스타일 선택

**팁:**
- Bash 권한 패턴은 와일드카드를 지원한다: `Bash(npm test *)` 는 `npm test`로 시작하는 모든 명령에 매칭됨
- `permissions.allow` 같은 배열 설정은 모든 스코프 걸쳐 합산된다. `model` 같은 단일 값 설정은 가장 구체적인(낮은) 스코프 값이 사용됨

**예제** (`npm test`, `npm run` 허용, `rm -rf` 차단, 파일 편집 후 Prettier 실행):
```json
{
  "permissions": {
    "allow": [
      "Bash(npm test *)",
      "Bash(npm run *)"
    ],
    "deny": [
      "Bash(rm -rf *)"
    ]
  },
  "hooks": {
    "PostToolUse": [{
      "matcher": "Edit|Write",
      "hooks": [{
        "type": "command",
        "command": "jq -r '.tool_input.file_path' | xargs npx prettier --write"
      }]
    }]
  }
}
```

---

### .claude/settings.local.json

**한 줄 설명:** 이 프로젝트의 개인 설정 오버라이드

**로드 시점:** 사용자가 편집 가능한 설정 파일 중 가장 높은 우선순위. CLI 플래그와 managed settings는 여전히 이보다 우선함

**설명:** 팀 기본값보다 우선 적용되는 개인 설정. `settings.json`과 동일한 JSON 형식이지만 커밋되지 않는다. 팀 설정과 다른 권한이나 기본값이 필요할 때 사용한다.

**팁:**
- `settings.json`과 동일한 스키마. `permissions.allow` 같은 배열 설정은 스코프 전체에서 합산되고, `model` 같은 단일 값 설정은 로컬 값이 우선 적용됨
- Claude Code가 처음 이 파일을 생성할 때 `~/.config/git/ignore`에 자동으로 추가한다. 커스텀 `core.excludesFile`을 사용 중이라면 직접 패턴을 추가해야 한다. 팀과 ignore 규칙을 공유하려면 프로젝트 `.gitignore`에도 추가한다

**예제** (팀 settings.json에 Docker 권한 추가):
```json
{
  "permissions": {
    "allow": [
      "Bash(docker *)"
    ]
  }
}
```

---

### .claude/rules/

**한 줄 설명:** 파일 경로 조건에 따라 선택적으로 로드되는 주제별 지시사항

**로드 시점:** `paths:` 프론트매터가 없는 룰은 세션 시작 시 로드. `paths:`가 있는 룰은 매칭 파일이 컨텍스트에 들어올 때만 로드

**설명:** 파일 경로에 따라 조건부로 로드할 수 있는 주제별 지시사항 파일들. `paths:` 프론트매터가 없는 룰은 CLAUDE.md처럼 세션 시작 시 로드되고, `paths:`가 있는 룰은 Claude가 매칭 파일을 읽을 때만 로드된다.

CLAUDE.md처럼, 룰은 Claude가 읽는 "지침"이지 Claude Code가 강제하는 "설정"이 아니다. 보장된 동작이 필요하면 훅이나 권한 설정을 사용한다.

**팁:**
- `paths:` 프론트매터에 글로브 패턴을 사용해 디렉토리나 파일 유형으로 범위를 제한한다
- 하위 디렉토리도 동작한다: `.claude/rules/frontend/react.md`도 자동으로 인식됨
- CLAUDE.md가 200줄에 가까워지면 룰로 분리하기 시작한다

**예제 1** — `testing.md` (테스트 파일에만 적용):
```markdown
---
paths:
  - "**/*.test.ts"
  - "**/*.test.tsx"
---

# Testing Rules

- Use descriptive test names: "should [expected] when [condition]"
- Mock external dependencies, not internal modules
- Clean up side effects in afterEach
```

**예제 2** — `api-design.md` (백엔드 코드에만 적용):
```markdown
---
paths:
  - "src/api/**/*.ts"
---

# API Design Rules

- All endpoints must validate input with Zod schemas
- Return shape: { data: T } | { error: string }
- Rate limit all public endpoints
```

---

### .claude/skills/

**한 줄 설명:** 이름으로 호출하는 재사용 가능한 프롬프트

**로드 시점:** `/skill-name`으로 직접 호출하거나 Claude가 작업에 맞는 스킬을 자동으로 매칭할 때 실행

**설명:** 각 스킬은 `SKILL.md` 파일과 필요한 지원 파일들로 이루어진 폴더다. 기본적으로 사용자와 Claude 모두 스킬을 호출할 수 있다. 프론트매터로 제어할 수 있다: `/deploy` 같은 사용자 전용 워크플로우에는 `disable-model-invocation: true`를 쓰고, `/` 메뉴에는 숨기되 Claude는 호출할 수 있게 하려면 `user-invocable: false`를 쓴다.

**팁:**
- 스킬은 인수를 받는다: `/deploy staging`을 입력하면 "staging"이 `$ARGUMENTS`로 전달됨. 위치 인수는 `$0`, `$1` 등으로 접근
- `description` 프론트매터가 Claude가 자동으로 스킬을 호출하는 시점을 결정함
- SKILL.md 옆에 참조 문서를 함께 두면 Claude가 스킬 디렉토리 경로를 알고 있어 파일명으로 읽을 수 있음

**예제** — `security-review/SKILL.md` (사용자만 호출 가능한 보안 리뷰 스킬):
```markdown
---
description: Reviews code changes for security vulnerabilities, authentication gaps, and injection risks
disable-model-invocation: true
argument-hint: <branch-or-path>
---

## Diff to review

!`git diff $ARGUMENTS`

Audit the changes above for:

1. Injection vulnerabilities (SQL, XSS, command)
2. Authentication and authorization gaps
3. Hardcoded secrets or credentials

Use checklist.md in this skill directory for the full review checklist.

Report findings with severity ratings and remediation steps.
```

> `disable-model-invocation: true`로 Claude가 자체적으로 이 스킬을 실행할 수 없게 제한한다.  
> `` !`...` `` 문법은 셸 명령을 실행하고 그 출력을 프롬프트에 주입한다.  
> `$ARGUMENTS`는 스킬 이름 뒤에 입력한 내용으로 대체된다.

**예제** — `security-review/checklist.md` (스킬과 함께 묶이는 지원 파일):
```markdown
# Security Review Checklist

## Input Validation
- [ ] All user input sanitized before DB queries
- [ ] File upload MIME types validated
- [ ] Path traversal prevented on file operations

## Authentication
- [ ] JWT tokens expire after 24 hours
- [ ] API keys stored in environment variables
- [ ] Passwords hashed with bcrypt or argon2
```

> 스킬은 참조 문서, 템플릿, 스크립트 등 모든 지원 파일을 함께 묶을 수 있다. bash 주입 명령에서 스크립트를 참조할 때는 `${CLAUDE_SKILL_DIR}` 플레이스홀더를 사용한다.

---

### .claude/commands/

**한 줄 설명:** `/name`으로 호출하는 단일 파일 프롬프트

> **주의:** 커맨드와 스킬은 이제 동일한 메커니즘이다. 새 워크플로우는 `skills/`를 사용하는 것을 권장한다. 같은 `/name` 호출 방식에 더해 지원 파일을 함께 묶을 수 있다.

**로드 시점:** 사용자가 `/command-name`을 입력할 때 실행

**설명:** `commands/deploy.md` 파일을 만들면 `skills/deploy/SKILL.md`와 동일하게 `/deploy` 명령이 생성된다. 둘 다 Claude가 자동 호출할 수 있다. 스킬은 디렉토리 구조로 참조 문서, 템플릿, 스크립트를 함께 번들링할 수 있다는 장점이 있다.

**팁:**
- 파일 안에 `$ARGUMENTS`를 사용하면 파라미터를 받을 수 있다: `/fix-issue 123`
- 스킬과 커맨드의 이름이 같으면 스킬이 우선함
- 새 커맨드는 보통 스킬로 만드는 것이 낫다. 커맨드는 하위 호환을 위해 계속 지원됨

**예제** — `fix-issue.md`:
```markdown
---
argument-hint: <issue-number>
---

!`gh issue view $ARGUMENTS`

Investigate and fix the issue above.

1. Trace the bug to its root cause
2. Implement the fix
3. Write or update tests
4. Summarize what you changed and why
```

> `` !`gh issue view 123` ``은 셸에서 `gh issue view 123`을 실행하고 출력을 프롬프트에 주입한다.

---

### .claude/output-styles/

**한 줄 설명:** 팀이 공유하는 프로젝트 스코프 출력 스타일

**로드 시점:** `outputStyle` 설정으로 선택되면 세션 시작 시 적용됨

**설명:** 출력 스타일은 보통 개인적인 것이므로 대부분 `~/.claude/output-styles/`에 위치한다. 팀 전체가 공유하는 스타일(예: 모두가 사용하는 리뷰 모드)이 있다면 여기에 두면 된다. 상세 설명과 예제는 글로벌 스코프의 `output-styles/` 항목 참고.

---

### .claude/agents/

**한 줄 설명:** 별도 컨텍스트 윈도우를 가진 전문화된 서브에이전트

**로드 시점:** 사용자 또는 Claude가 호출하면 별도의 컨텍스트 윈도우에서 실행됨

**설명:** 각 마크다운 파일이 자체 시스템 프롬프트, 툴 접근 권한, 선택적으로 전용 모델을 갖는 서브에이전트를 정의한다. 서브에이전트는 새로운 컨텍스트 윈도우에서 실행되므로 메인 대화가 깔끔하게 유지된다. 병렬 작업이나 독립적인 작업에 유용하다.

**팁:**
- 각 에이전트는 메인 세션과 분리된 새로운 컨텍스트 윈도우를 가짐
- `tools:` 프론트매터로 에이전트별 툴 접근을 제한할 수 있음
- `@`를 입력하고 자동완성에서 에이전트를 선택해 직접 작업을 위임할 수 있음

**예제** — `agents/code-reviewer.md` (읽기 전용 도구만 허용하는 코드 리뷰 에이전트):
```markdown
---
name: code-reviewer
description: Reviews code for correctness, security, and maintainability
tools: Read, Grep, Glob
---

You are a senior code reviewer. Review for:

1. Correctness: logic errors, edge cases, null handling
2. Security: injection, auth bypass, data exposure
3. Maintainability: naming, complexity, duplication

Every finding must include a concrete fix.
```

> `description` 프론트매터가 Claude가 자동으로 이 에이전트에 위임하는 시점을 결정한다.  
> `tools: Read, Grep, Glob`으로 코드를 읽을 수만 있고 편집은 불가능하게 제한했다.

---

### .claude/agent-memory/

**한 줄 설명:** 서브에이전트의 프로젝트 스코프 영구 메모리 (메인 세션 메모리와 별개)

**로드 시점:** 서브에이전트 실행 시 `MEMORY.md`의 첫 200줄 (최대 25KB)이 서브에이전트 시스템 프롬프트에 로드됨

**설명:** 프론트매터에 `memory: project`를 설정한 서브에이전트는 여기에 전용 메모리 디렉토리를 가진다. 이는 `~/.claude/projects/`의 메인 세션 자동 메모리와 별개다. 각 서브에이전트는 자신만의 MEMORY.md를 읽고 쓴다.

**팁:**
- `memory:` 프론트매터를 설정한 서브에이전트에만 생성됨
- 이 디렉토리는 프로젝트 스코프 서브에이전트 메모리로 팀과 공유하도록 설계됨
- 버전 관리에서 제외하려면 `memory: local` 사용 → `.claude/agent-memory-local/`에 저장됨
- 프로젝트 전반에 걸친 메모리는 `memory: user` 사용 → `~/.claude/agent-memory/`에 저장됨
- 메인 세션 자동 메모리는 별도 기능이며 `~/.claude/projects/`에 위치함

**예제** — `agent-memory/<agent-name>/MEMORY.md`:
```markdown
# code-reviewer memory

## Patterns seen
- Project uses custom Result<T, E> type, not exceptions
- Auth middleware expects Bearer token in Authorization header
- Tests use factory functions in test/factories/

## Recurring issues
- Missing null checks on API responses (src/api/*)
- Unhandled promise rejections in background jobs
```

> 서브에이전트가 직접 이 파일을 생성하고 업데이트한다. 사용자가 직접 작성하지 않는다.

---

## 글로벌 스코프 파일 (`~/`)

홈 디렉토리에 위치하며 모든 프로젝트에 적용된다. git 저장소에 커밋되지 않는 개인 설정이다.

### ~/.claude.json

**한 줄 설명:** 앱 상태 및 UI 설정

**로드 시점:** 세션 시작 시 설정과 MCP 서버를 읽음. `/config`에서 설정을 변경하거나 신뢰 프롬프트를 승인할 때 Claude Code가 다시 씀

**설명:** `settings.json`에 속하지 않는 상태를 보관한다: 테마, OAuth 세션, 프로젝트별 신뢰 결정, 개인 MCP 서버, UI 토글. 직접 편집하기보다는 주로 `/config`를 통해 관리한다.

**팁:**
- `showTurnDuration`, `terminalProgressBarEnabled` 같은 UI 토글은 `settings.json`이 아닌 여기에 위치함
- `projects` 키는 신뢰 대화 수락, 마지막 세션 지표 등 프로젝트별 상태를 추적함. 세션 중에 승인한 권한 규칙은 `.claude/settings.local.json`에 저장됨
- 여기의 MCP 서버는 개인용: user 스코프는 모든 프로젝트에 적용되고, local 스코프는 커밋 없이 해당 프로젝트에만 적용됨. 팀 공유 서버는 프로젝트 루트의 `.mcp.json`에 설정할 것

**예제**:
```json
{
  "editorMode": "vim",
  "showTurnDuration": false,
  "mcpServers": {
    "my-tools": {
      "command": "npx",
      "args": ["-y", "@example/mcp-server"]
    }
  }
}
```

---

### ~/.claude/CLAUDE.md

**한 줄 설명:** 모든 프로젝트에 적용되는 개인 설정

**로드 시점:** 모든 프로젝트의 모든 세션 시작 시 로드됨

**설명:** 글로벌 지시사항 파일. 세션 시작 시 프로젝트 CLAUDE.md와 함께 컨텍스트에 로드되어 둘 다 적용된다. 지시사항이 충돌하면 프로젝트 레벨이 우선한다. 어디서나 적용되는 설정을 여기에 넣는다: 응답 스타일, 커밋 형식, 개인 규칙 등.

**팁:**
- 모든 프로젝트의 CLAUDE.md와 함께 컨텍스트에 로드되므로 짧게 유지한다
- 응답 스타일, 커밋 형식, 개인 규칙에 적합함

**예제**:
```markdown
# Global preferences

- Keep explanations concise
- Use conventional commit format
- Show the terminal command to verify changes
- Prefer composition over inheritance
```

---

### ~/.claude/settings.json

**한 줄 설명:** 모든 프로젝트의 기본 설정

**로드 시점:** 기본값으로 적용됨. 프로젝트와 로컬 settings.json이 여기에 설정한 키를 덮어씀

**설명:** 프로젝트 `settings.json`과 동일한 키들(permissions, hooks, model, 환경 변수 등). 모든 프로젝트에 항상 적용할 설정을 여기에 넣는다. 예: 항상 허용하는 권한, 선호 모델, 어느 프로젝트에서나 실행할 알림 훅.

> 설정 우선순위: 프로젝트 `settings.json`이 여기에 설정한 키를 덮어씀. 이는 CLAUDE.md와 다르다. CLAUDE.md는 글로벌과 프로젝트 파일 모두 컨텍스트에 로드되지만, settings는 키별로 가장 구체적인 값이 사용됨.

**예제**:
```json
{
  "permissions": {
    "allow": [
      "Bash(git log *)",
      "Bash(git diff *)"
    ]
  }
}
```

---

### ~/.claude/keybindings.json

**한 줄 설명:** 커스텀 키보드 단축키

**로드 시점:** 세션 시작 시 읽히며, 파일을 편집하면 핫리로드됨

**설명:** 인터랙티브 CLI의 키보드 단축키를 재설정한다. `/keybindings` 명령으로 이 파일을 스키마 참조와 함께 생성하거나 열 수 있다. Ctrl+C, Ctrl+D, Ctrl+M은 예약되어 재설정 불가하다.

**예제** (Ctrl+E를 외부 에디터로, Ctrl+U를 해제):
```json
{
  "$schema": "https://www.schemastore.org/claude-code-keybindings.json",
  "$docs": "https://code.claude.com/docs/en/keybindings",
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

> `context` 필드로 CLI의 특정 부분에만 바인딩을 적용할 수 있다. `null`로 설정하면 해당 키 바인딩을 해제한다.

---

### ~/.claude/projects/ (자동 메모리)

**한 줄 설명:** Claude가 세션 간에 스스로 축적하는 프로젝트별 메모

**로드 시점:** 세션 시작 시 `MEMORY.md` 로드; 토픽 파일은 필요 시 읽힘

**설명:** 자동 메모리(auto memory)는 Claude가 사용자의 작업 없이 세션 간 지식을 축적할 수 있게 한다. 빌드 명령어, 디버깅 인사이트, 아키텍처 메모 등을 작업하면서 저장한다. 각 프로젝트는 저장소 경로를 키로 하는 전용 메모리 디렉토리를 가진다.

**팁:**
- 기본적으로 활성화됨. `/memory` 명령이나 settings의 `autoMemoryEnabled`로 토글 가능
- `MEMORY.md`는 세션마다 로드되는 인덱스. 첫 200줄 또는 25KB 중 먼저 도달하는 것까지 읽힘
- `debugging.md` 같은 토픽 파일은 관련 작업이 생길 때만 읽힘 (시작 시 전부 로드하지 않음)
- 일반 마크다운 파일이므로 언제든 편집하거나 삭제할 수 있음

**예제** — `MEMORY.md` (Claude가 작성하는 인덱스 파일):
```markdown
# Memory Index

## Project
- [build-and-test.md](build-and-test.md): npm run build (~45s), Vitest, dev server on 3001
- [architecture.md](architecture.md): API client singleton, refresh-token auth

## Reference
- [debugging.md](debugging.md): auth token rotation and DB connection troubleshooting
```

**예제** — `debugging.md` (MEMORY.md가 길어지면 Claude가 분리하는 토픽 파일):
```markdown
---
name: Debugging patterns
description: Auth token rotation and database connection troubleshooting for this project
type: reference
---

## Auth Token Issues
- Refresh token rotation: old token invalidated immediately
- If 401 after refresh: check clock skew between client and server

## Database Connection Drops
- Connection pool: max 10 in dev, 50 in prod
- Always check `docker compose ps` first
```

> Claude가 파일명을 직접 결정한다 (debugging.md, architecture.md, build-commands.md 등). 사용자가 직접 생성하지 않는다.

---

### ~/.claude/rules/

**한 줄 설명:** 모든 프로젝트에 적용되는 사용자 레벨 룰

**로드 시점:** `paths:`가 없는 룰은 세션 시작 시 로드. `paths:`가 있는 룰은 매칭 파일이 컨텍스트에 들어올 때 로드

**설명:** 프로젝트 `.claude/rules/`와 동일하지만 모든 프로젝트에 적용된다. 전체 작업에 걸쳐 원하는 규칙(개인 코드 스타일, 커밋 메시지 형식 등)을 여기에 설정한다.

---

### ~/.claude/skills/

**한 줄 설명:** 모든 프로젝트에서 사용 가능한 개인 스킬

**로드 시점:** 어느 프로젝트에서든 `/skill-name`으로 호출

**설명:** 개인이 만든 스킬로 어디서나 동작한다. 프로젝트 스킬과 동일한 구조(SKILL.md가 있는 폴더)이며, 단일 프로젝트가 아닌 사용자 계정에 스코프된다.

---

### ~/.claude/commands/

**한 줄 설명:** 모든 프로젝트에서 사용 가능한 개인 단일 파일 커맨드

> **주의:** 커맨드와 스킬은 이제 동일한 메커니즘이다. 새 워크플로우는 `skills/`를 사용하는 것을 권장한다.

**로드 시점:** 어느 프로젝트에서든 사용자가 `/command-name`을 입력할 때

**설명:** 프로젝트 `commands/`와 동일하지만 사용자 계정에 스코프된다. 각 마크다운 파일이 어디서나 사용 가능한 커맨드가 된다.

---

### ~/.claude/output-styles/

**한 줄 설명:** Claude의 동작 방식을 조정하는 커스텀 시스템 프롬프트 섹션

**로드 시점:** `outputStyle` 설정으로 선택되면 세션 시작 시 적용됨

**설명:** 각 마크다운 파일이 출력 스타일을 정의한다. 시스템 프롬프트에 추가되는 섹션으로, 기본적으로 기존 소프트웨어 엔지니어링 작업 지시사항을 대체한다. 코딩 이외의 용도로 Claude Code를 활용하거나 강의/리뷰 모드를 추가할 때 사용한다.

`/config` 또는 settings의 `outputStyle` 키로 스타일을 선택한다. 여기의 스타일은 모든 프로젝트에서 사용 가능하며, 같은 이름의 프로젝트 레벨 스타일이 우선됨.

**팁:**
- 내장 스타일 Explanatory와 Learning은 Claude Code에 기본 포함됨. 커스텀 스타일은 여기에 추가
- 기존 작업 지시사항을 유지하면서 추가하려면 프론트매터에 `keep-coding-instructions: true` 설정
- 시스템 프롬프트는 시작 시 고정(캐싱)되므로 변경사항은 다음 세션부터 적용됨

**예제** — `teaching.md` (설명을 추가하고 작은 변경은 직접 구현하도록 유도하는 스타일):
```markdown
---
description: Explains reasoning and asks you to implement small pieces
keep-coding-instructions: true
---

After completing each task, add a brief "Why this approach" note
explaining the key design decision.

When a change is under 10 lines, ask the user to implement it
themselves by leaving a TODO(human) marker instead of writing it.
```

> `outputStyle`을 파일명에서 `.md`를 제거한 값으로 설정하거나, 프론트매터에 `name` 필드를 설정한 경우 그 값으로 선택할 수 있다.

---

### ~/.claude/agents/

**한 줄 설명:** 모든 프로젝트에서 사용 가능한 개인 서브에이전트

**로드 시점:** 어느 프로젝트에서든 Claude가 위임하거나 사용자가 @-멘션할 때

**설명:** 여기에 정의된 서브에이전트는 모든 프로젝트에서 사용 가능하다. 프로젝트 agents/와 동일한 형식이다.

---

### ~/.claude/agent-memory/

**한 줄 설명:** `memory: user`를 설정한 서브에이전트의 영구 메모리

**로드 시점:** 서브에이전트 시작 시 서브에이전트 시스템 프롬프트에 로드됨

**설명:** 프론트매터에 `memory: user`를 설정한 서브에이전트는 모든 프로젝트에 걸쳐 지속되는 지식을 여기에 저장한다. 프로젝트 스코프 서브에이전트 메모리는 `.claude/agent-memory/`를 사용한다.

---

## 탐색기에 표시되지 않는 파일들

탐색기는 사용자가 작성하고 편집하는 파일만 다룬다. 관련 파일 중 다른 곳에 위치한 것들:

| 파일 | 위치 | 용도 |
|------|------|------|
| `managed-settings.json` | OS별 시스템 레벨 | 사용자가 오버라이드할 수 없는 기업 적용 설정. 서버 관리 설정(server-managed settings) 참고 |
| `CLAUDE.local.md` | 프로젝트 루트 | 이 프로젝트의 개인 설정으로, CLAUDE.md와 함께 로드됨. 직접 생성하고 `.gitignore`에 추가해야 함 |
| 설치된 플러그인 | `~/.claude/plugins/` | 클론된 마켓플레이스, 설치된 플러그인 버전, 플러그인별 데이터. `claude plugin` 명령으로 관리됨. 플러그인 업데이트/제거 후 7일이 지난 오래된 버전은 자동 삭제됨 |

`~/.claude`에는 Claude Code가 작업하면서 쓰는 데이터도 있다: 트랜스크립트, 프롬프트 히스토리, 파일 스냅샷, 캐시, 로그.

---

## 파일 전체 참조 테이블

> **설정 오버라이드 우선순위:**
> 1. 조직이 배포한 Managed settings가 최우선
> 2. `--permission-mode`, `--settings` 같은 CLI 플래그가 해당 세션의 `settings.json`을 오버라이드
> 3. 일부 환경 변수는 동등한 설정보다 우선함 (환경 변수 레퍼런스에서 각각 확인)
> 
> 전체 순서는 설정 우선순위(settings precedence) 문서 참고.

| 파일 | 스코프 | 커밋 | 역할 |
|------|--------|------|------|
| `CLAUDE.md` | 프로젝트 + 글로벌 | ✓ | 매 세션 로드되는 지시사항 |
| `rules/*.md` | 프로젝트 + 글로벌 | ✓ | 주제별 지시사항, 선택적 경로 게이팅 |
| `settings.json` | 프로젝트 + 글로벌 | ✓ | 권한, 훅, 환경 변수, 모델 기본값 |
| `settings.local.json` | 프로젝트 전용 | - | 개인 오버라이드, 자동 gitignore |
| `.mcp.json` | 프로젝트 전용 | ✓ | 팀 공유 MCP 서버 |
| `.worktreeinclude` | 프로젝트 전용 | ✓ | 새 worktree에 복사할 gitignore 파일 |
| `skills/<name>/SKILL.md` | 프로젝트 + 글로벌 | ✓ | `/name`으로 호출하거나 자동 호출되는 재사용 프롬프트 |
| `commands/*.md` | 프로젝트 + 글로벌 | ✓ | 단일 파일 프롬프트; 스킬과 동일한 메커니즘 |
| `output-styles/*.md` | 프로젝트 + 글로벌 | ✓ | 커스텀 시스템 프롬프트 섹션 |
| `agents/*.md` | 프로젝트 + 글로벌 | ✓ | 전용 프롬프트와 툴을 가진 서브에이전트 정의 |
| `agent-memory/<name>/` | 프로젝트 + 글로벌 | ✓ | 서브에이전트의 영구 메모리 |
| `~/.claude.json` | 글로벌 전용 | - | 앱 상태, OAuth, UI 토글, 개인 MCP 서버 |
| `projects/<project>/memory/` | 글로벌 전용 | - | 자동 메모리: Claude가 세션 간 스스로 기록하는 메모 |
| `keybindings.json` | 글로벌 전용 | - | 커스텀 키보드 단축키 |

---

## 실제로 로드된 내용 확인하기

탐색기는 어떤 파일이 존재할 수 있는지를 보여준다. 현재 세션에서 실제로 로드된 것을 확인하려면:

| 명령어 | 표시 내용 |
|--------|-----------|
| `/context` | 카테고리별 토큰 사용량: 시스템 프롬프트, 메모리 파일, 스킬, MCP 툴, 메시지 |
| `/memory` | 로드된 CLAUDE.md와 룰 파일들, 자동 메모리 항목 |
| `/agents` | 설정된 서브에이전트와 설정값 |
| `/hooks` | 활성화된 훅 설정 |
| `/mcp` | 연결된 MCP 서버와 상태 |
| `/skills` | 프로젝트, 사용자, 플러그인 소스의 사용 가능한 스킬 |
| `/permissions` | 현재 허용/거부 규칙 |
| `/doctor` | 설치 및 설정 진단 |

전체 개요는 `/context`를 먼저 실행하고, 특정 영역은 해당 명령어로 확인한다.

---

## 애플리케이션 데이터

설정 파일 외에도 `~/.claude`에는 Claude Code가 세션 중에 기록하는 데이터가 있다. 이 파일들은 평문(plaintext)이다. 툴을 통해 전달되는 모든 것은 디스크의 트랜스크립트에 기록된다: 파일 내용, 명령어 출력, 붙여넣은 텍스트.

### 자동 정리되는 파일

아래 경로의 파일들은 `cleanupPeriodDays` 설정(기본값: 30일)보다 오래된 경우 시작 시 삭제된다.

| `~/.claude/` 하위 경로 | 내용 |
|----------------------|------|
| `projects/<project>/<session>.jsonl` | 전체 대화 트랜스크립트: 모든 메시지, 툴 호출, 툴 결과 |
| `projects/<project>/<session>/tool-results/` | 별도 파일로 분리된 대용량 툴 출력 |
| `file-history/<session>/` | Claude가 변경한 파일의 편집 전 스냅샷 (체크포인트 복원에 사용) |
| `plans/` | 플랜 모드 중 작성된 플랜 파일 |
| `debug/` | 세션별 디버그 로그 (`--debug`로 시작하거나 `/debug` 실행 시에만 기록) |
| `paste-cache/`, `image-cache/` | 대용량 붙여넣기 내용과 첨부 이미지 |
| `session-env/` | 세션별 환경 메타데이터 |

### 직접 삭제해야 하는 파일

아래 경로는 자동 정리 대상이 아니며 무기한 유지된다.

| `~/.claude/` 하위 경로 | 내용 |
|----------------------|------|
| `history.jsonl` | 입력한 모든 프롬프트 (타임스탬프, 프로젝트 경로 포함). 위쪽 화살표 히스토리 불러오기에 사용 |
| `stats-cache.json` | `/cost`에 표시되는 집계된 토큰 및 비용 수치 |
| `backups/` | 설정 마이그레이션 전에 타임스탬프가 붙어 저장되는 `~/.claude.json` 백업 |
| `todos/` | 레거시 세션별 태스크 목록. 현재 버전에서는 더 이상 기록하지 않음. 삭제해도 무방 |

`shell-snapshots/`는 세션이 정상 종료될 때 제거되는 런타임 파일을 보관한다. 그 외 소규모 캐시 및 잠금 파일은 사용하는 기능에 따라 생성되며 삭제해도 안전하다.

### 보안 고려사항 (평문 저장)

트랜스크립트와 히스토리는 저장 시 암호화되지 않는다. OS 파일 권한만이 유일한 보호 수단이다. 툴이 `.env` 파일을 읽거나 명령어가 자격증명을 출력하면 해당 값이 `projects/<project>/<session>.jsonl`에 기록된다.

노출을 줄이려면:
- `cleanupPeriodDays`를 낮춰 트랜스크립트 보관 기간을 단축한다
- `CLAUDE_CODE_SKIP_PROMPT_HISTORY` 환경 변수를 설정해 모든 모드에서 트랜스크립트와 프롬프트 히스토리 기록을 건너뛴다. 비인터랙티브 모드에서는 `-p`와 함께 `--no-session-persistence`를 전달하거나, Agent SDK에서 `persistSession: false`를 설정할 수 있다
- 자격증명 파일 읽기를 거부하는 권한 규칙을 설정한다

### 로컬 데이터 삭제 시 영향

아래 경로는 언제든지 삭제할 수 있다. 새 세션에는 영향이 없다. 삭제 시 과거 세션에 대해 잃게 되는 것:

| 삭제 대상 | 잃게 되는 것 |
|----------|------------|
| `~/.claude/projects/` | 과거 세션의 이어하기, 계속하기, 되감기 기능 |
| `~/.claude/history.jsonl` | 위쪽 화살표 프롬프트 히스토리 |
| `~/.claude/file-history/` | 과거 세션의 체크포인트 복원 |
| `~/.claude/stats-cache.json` | `/cost`에 표시되는 히스토리 합계 |
| `~/.claude/backups/` | 과거 설정 마이그레이션의 롤백 복사본 |
| `~/.claude/debug/`, `plans/`, `paste-cache/`, `image-cache/`, `session-env/` | 사용자에게 노출되는 기능 없음 |
| `~/.claude/todos/` | 없음. 현재 버전에서는 기록하지 않는 레거시 디렉토리 |

> **주의:** `~/.claude.json`, `~/.claude/settings.json`, `~/.claude/plugins/`는 삭제하지 않는다. 각각 인증 정보, 설정, 설치된 플러그인을 보관한다.
