# 프로젝트 레벨 파일

> **한눈에 보기**
> 프로젝트 루트와 `.claude/` 폴더에 위치한 파일들. 대부분 git에 커밋해서 팀과 공유하고, 세션 시작 시 또는 특정 조건을 만족할 때 자동으로 적용된다. `settings.local.json`만 예외적으로 개인용이라 gitignore된다.

---

## CLAUDE.md

**Claude가 매 세션 시작 시 읽는 프로젝트 지침 파일이다.**

프로젝트의 규칙, 자주 쓰는 명령어, 아키텍처 맥락 등을 적어두면 Claude가 팀과 같은 전제를 가지고 작업한다. `.claude/CLAUDE.md`에 두어도 동일하게 동작한다.

**작성 팁:**
- 200줄 이내를 권장. 더 길어도 전체를 읽지만 지침 준수율이 떨어질 수 있다.
- 모든 세션에 로드되므로, 특정 작업에만 필요한 내용은 [rules/](#rules) 또는 [skills/](#skills)로 분리한다.
- 자주 쓰는 빌드, 테스트, 포맷 명령어를 적어두면 매번 알려주지 않아도 된다.
- 세션 중에 `/memory` 명령어로 이 파일을 열고 편집할 수 있다.

```markdown
# 프로젝트 규칙

## 명령어
- 빌드: `npm run build`
- 테스트: `npm test`
- 린트: `npm run lint`

## 스택
- TypeScript strict 모드
- React 19, 함수형 컴포넌트만 사용

## 규칙
- named export 사용, default export 금지
- 테스트는 소스 파일 옆에: `foo.ts` → `foo.test.ts`
- 모든 API 라우트는 `{ data, error }` 형태로 반환
```

---

## .mcp.json

**프로젝트 팀 전체가 공유하는 MCP(Model Context Protocol) 서버 설정 파일이다.**

MCP 서버는 Claude에게 외부 도구 접근 권한을 부여한다. 데이터베이스, API, 브라우저 자동화 등을 Claude가 직접 사용할 수 있게 된다. 이 파일에 설정한 서버는 팀 전체가 공유하며, 본인만 쓰는 서버는 `claude mcp add --scope user` 명령어로 `~/.claude.json`에 따로 추가한다.

**주의사항:**
- `.claude/` 안이 아니라 프로젝트 루트에 위치한다.
- 시크릿 값은 파일에 직접 쓰지 않고 환경 변수 참조(`${GITHUB_TOKEN}`)를 사용한다.
- 세션 시작 시 서버가 연결된다. 단, MCP 도구 스키마는 기본적으로 지연(deferred) 로드되어 도구 검색 시 필요에 따라 가져온다. 덕분에 도구가 많은 서버를 연결해도 컨텍스트를 낭비하지 않는다.

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

---

## .worktreeinclude

**git 워크트리 생성 시 복사할 gitignore 파일 목록이다.**

git 워크트리는 새로운 체크아웃 공간이라서 `.env` 같은 gitignore 파일이 기본적으로 없다. 이 파일에 패턴을 적어두면 Claude가 워크트리를 만들 때 해당 파일들을 자동으로 복사해준다. 문법은 `.gitignore`와 동일하며, 이미 git에 추적 중인 파일은 복사 대상에서 제외된다.

**주의사항:**
- `.claude/` 안이 아니라 프로젝트 루트에 위치한다.
- Claude가 `--worktree` 옵션, `EnterWorktree` 도구, 또는 서브에이전트의 `isolation: worktree`를 사용할 때만 읽힌다.

```gitignore
# 로컬 환경 변수
.env
.env.local

# API 인증 정보
config/secrets.json
```

---

## .claude/settings.json

**Claude Code가 직접 강제 적용하는 설정 파일이다.**

CLAUDE.md가 "Claude에게 읽혀서 따르도록 요청하는" 지침이라면, settings.json은 Claude의 의지와 관계없이 강제로 적용되는 규칙이다. 권한(어떤 명령어를 허용/차단할지), 훅(파일 편집 후 자동 실행할 스크립트), 기본 모델 등을 설정한다.

**설정할 수 있는 항목:**
- `permissions`: Claude가 사용할 수 있는 도구와 명령어 허용/차단
- `hooks`: 특정 이벤트(파일 편집, 도구 사용 등) 발생 시 실행할 스크립트
- `statusLine`: 작업 중 하단에 표시할 상태 표시줄 커스터마이징
- `model`: 이 프로젝트의 기본 모델 지정
- `env`: 매 세션에 설정할 환경 변수
- `outputStyle`: 출력 스타일 선택

**권한 패턴 작성 예시:**
- `Bash(npm test *)` → `npm test`로 시작하는 명령어 모두 허용
- `Bash(rm -rf *)` → 해당 명령어 차단

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

> 글로벌 `~/.claude/settings.json`보다 이 파일이 우선 적용된다. 배열 설정(예: `permissions.allow`)은 모든 레벨 값이 합산되고, 단일 값 설정(예: `model`)은 가장 구체적인 레벨 값이 사용된다.

---

## .claude/settings.local.json

**개인 설정 오버라이드 파일이다. gitignore되어 혼자만 사용한다.**

팀 설정(`settings.json`)을 기반으로 본인에게만 필요한 설정을 추가하거나 덮어쓸 때 사용한다. 형식은 `settings.json`과 동일하다.

Claude Code가 이 파일을 처음 생성할 때 `~/.config/git/ignore`에 자동으로 무시 패턴을 추가한다. 팀 전체의 `.gitignore`에도 추가하고 싶다면 직접 넣어야 한다.

```json
{
  "permissions": {
    "allow": [
      "Bash(docker *)"
    ]
  }
}
```

> 사용자가 편집 가능한 설정 파일 중 가장 높은 우선순위를 가진다. CLI 플래그와 관리형 설정만 이 파일보다 우선한다.

---

## .claude/rules/

**주제별로 분리된 지침 파일들을 두는 폴더다.**

CLAUDE.md가 길어지면 `rules/` 폴더에 주제별 파일로 분리할 수 있다. `paths:` 옵션을 사용하면 특정 파일이 컨텍스트에 들어왔을 때만 해당 규칙을 로드할 수 있어 불필요한 컨텍스트 낭비를 줄인다.

**로드 시점:**
- `paths:` 없음 → 세션 시작 시 CLAUDE.md처럼 무조건 로드
- `paths:` 있음 → 해당 글로브 패턴과 일치하는 파일이 컨텍스트에 들어올 때만 로드

**파일 예시 — 테스트 파일에만 적용되는 규칙:**
```markdown
---
paths:
  - "**/*.test.ts"
  - "**/*.test.tsx"
---

# 테스트 규칙

- 테스트 이름 형식: "should [예상 결과] when [조건]"
- 외부 의존성만 목(mock) 처리, 내부 모듈은 목 금지
- afterEach에서 부작용 정리
```

**파일 예시 — API 파일에만 적용되는 규칙:**
```markdown
---
paths:
  - "src/api/**/*.ts"
---

# API 설계 규칙

- 모든 엔드포인트는 Zod 스키마로 입력 검증
- 반환 형태: { data: T } | { error: string }
- 공개 엔드포인트는 모두 속도 제한 적용
```

> 하위 디렉토리도 자동으로 탐색된다. `.claude/rules/frontend/react.md`처럼 구성할 수 있다.

---

## .claude/skills/

**`/이름`으로 호출하는 재사용 가능한 프롬프트 모음이다.**

각 스킬은 `SKILL.md`를 포함한 폴더로 구성된다. 명령어 실행, 체크리스트 수행 등 반복적인 작업 흐름을 스킬로 만들어두면 매번 긴 지침을 입력하지 않아도 된다. Claude가 작업 맥락에 맞는 스킬을 자동으로 호출하게 할 수도 있다.

**핵심 기능:**
- 인수 전달: `/deploy staging`처럼 호출하면 `$ARGUMENTS`로 "staging"이 전달된다. `$0`, `$1` 등으로 위치별 접근도 가능하다.
- 쉘 명령어 실행: `` !`git diff $ARGUMENTS` ``처럼 쓰면 실행 결과가 프롬프트에 주입된다.
- 파일 번들링: `SKILL.md` 옆에 체크리스트, 템플릿, 스크립트 등 보조 파일을 함께 두고 참조할 수 있다.
- `disable-model-invocation: true` 설정 시 사용자만 호출 가능, Claude는 자동 호출 불가.
- `user-invocable: false` 설정 시 `/` 메뉴에서 숨겨지고 Claude만 호출 가능.

**폴더 구조 예시:**
```
.claude/skills/
└── security-review/
    ├── SKILL.md
    └── checklist.md
```

**SKILL.md 예시:**
```markdown
---
description: 코드 변경 사항의 보안 취약점, 인증 누락, 인젝션 위험을 검토한다
disable-model-invocation: true
argument-hint: <브랜치-또는-경로>
---

## 검토할 diff

!`git diff $ARGUMENTS`

위 변경 사항을 다음 항목으로 감사하라:

1. 인젝션 취약점 (SQL, XSS, 명령어)
2. 인증 및 권한 누락
3. 하드코딩된 시크릿 또는 인증 정보

전체 검토 체크리스트는 이 스킬 디렉토리의 checklist.md를 참고하라.
```

---

## .claude/commands/

**단일 마크다운 파일로 만드는 명령어 폴더다.**

`commands/deploy.md` 파일 하나가 `/deploy` 명령어가 된다. 스킬과 동일한 방식으로 동작하지만 폴더 구조 없이 파일 하나로만 구성된다는 차이가 있다. 현재는 스킬이 commands를 대체하고 있으며, 새 워크플로우는 스킬로 만드는 것을 권장한다. 기존 commands는 계속 지원된다.

> 같은 이름의 스킬과 명령어가 있으면 스킬이 우선한다.

---

## .claude/output-styles/

**팀이 공유하는 출력 스타일 파일을 두는 폴더다.**

출력 스타일은 Claude의 시스템 프롬프트에 추가되는 섹션으로, Claude가 작업하는 방식을 조정한다. 기본적으로는 개인 설정이라 `~/.claude/output-styles/`에 두지만, 팀 전체가 공유할 스타일은 여기에 둔다. 자세한 설명은 [글로벌 레벨 output-styles](global-level.md#claudeoutput-styles) 항목을 참고한다.

---

## .claude/agents/

**독립적인 컨텍스트 창을 가진 서브에이전트를 정의하는 폴더다.**

각 마크다운 파일이 하나의 서브에이전트를 정의한다. 서브에이전트는 메인 대화와 분리된 새 컨텍스트 창에서 실행되므로, 병렬 작업이나 독립적인 작업에 적합하다. `@에이전트이름`으로 직접 지목하거나 Claude가 자동으로 위임한다.

**frontmatter 옵션:**
- `description`: Claude가 언제 이 에이전트에 위임할지 결정하는 설명
- `tools`: 이 에이전트가 사용할 수 있는 도구 목록 (기본은 전체)

**예시 — 읽기 전용으로 제한된 코드 리뷰 에이전트:**
```markdown
---
name: code-reviewer
description: 정확성, 보안, 유지보수성 관점에서 코드를 검토한다
tools: Read, Grep, Glob
---

당신은 시니어 코드 리뷰어입니다. 다음 관점으로 검토하세요:

1. 정확성: 로직 오류, 엣지 케이스, null 처리
2. 보안: 인젝션, 인증 우회, 데이터 노출
3. 유지보수성: 네이밍, 복잡도, 중복

모든 지적 사항에는 구체적인 수정 방법을 포함해야 합니다.
```

---

## .claude/agent-memory/

**서브에이전트가 프로젝트 범위에서 쌓는 영구 메모리 폴더다. Claude가 자동으로 생성하고 관리한다.**

서브에이전트 정의 파일에 `memory: project`를 설정하면 여기에 에이전트별 메모리 디렉토리가 생성된다. 메인 세션의 자동 메모리(`~/.claude/projects/`)와는 별개다.

**메모리 범위 옵션:**
- `memory: project` → `.claude/agent-memory/` (팀과 공유, git 커밋)
- `memory: local` → `.claude/agent-memory-local/` (버전 관리 제외)
- `memory: user` → `~/.claude/agent-memory/` (모든 프로젝트에서 공유)

세션 시작 시 `MEMORY.md`의 첫 200줄(최대 25KB)이 서브에이전트 시스템 프롬프트에 자동으로 로드된다.
