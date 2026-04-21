# Claude가 프로젝트를 기억하는 방법: CLAUDE.md와 Auto Memory

**출처**: `raw/claude가 프로젝트를 기억하는 방법.md`
**날짜**: 2026-04-20
**keywords**: CLAUDE.md, auto memory, 세션 지속성, .claude/rules/, memory isolation, 경로별 규칙

## 요약

각 세션은 독립적인 컨텍스트 윈도우로 시작하며, CLAUDE.md(사람이 작성하는 지속 지침)와 Auto Memory(Claude가 자동으로 작성하는 노트) 두 메커니즘으로 세션 간 지식이 전달된다. `.claude/rules/`로 파일 유형별 규칙 범위를 지정하고, 200줄 이하로 간결하게 유지하는 것이 핵심이다.

## CLAUDE.md vs Auto Memory 비교

|  | CLAUDE.md 파일 | Auto Memory |
| --- | --- | --- |
| **작성자** | 사용자 | Claude |
| **포함 내용** | 지침 및 규칙 | 학습 및 패턴 |
| **범위** | 프로젝트, 사용자 또는 조직 | 작업 트리당 |
| **로드 대상** | 모든 세션 | 모든 세션 (처음 200줄 또는 25KB) |
| **사용 목적** | 코딩 표준, 워크플로우, 프로젝트 아키텍처 | 빌드 명령, 디버깅 인사이트, Claude가 발견한 선호도 |

## CLAUDE.md 파일

### 배치 위치와 범위

| 범위 | 위치 | 공유 대상 |
| --- | --- | --- |
| **관리 정책** | macOS: `/Library/Application Support/ClaudeCode/CLAUDE.md` | 조직의 모든 사용자 |
| **프로젝트 지침** | `./CLAUDE.md` 또는 `./.claude/CLAUDE.md` | 팀 멤버 (소스 제어) |
| **사용자 지침** | `~/.claude/CLAUDE.md` | 본인만 (모든 프로젝트) |

로드 순서: 작업 디렉토리에서 루트까지 상위 CLAUDE.md 전체 로드 → 하위 디렉토리 CLAUDE.md는 해당 파일 접근 시 지연 로드.

### 효과적인 지침 작성

**크기**: 파일당 200줄 이하. 더 긴 파일은 컨텍스트를 소비하고 준수율이 낮아진다.

**구체성**: 검증 가능할 정도로 구체적으로 작성한다.

| 나쁜 예 | 좋은 예 |
| --- | --- |
| "코드를 제대로 포맷합니다" | "2칸 들여쓰기 사용" |
| "변경 사항을 테스트합니다" | "커밋하기 전에 `npm test` 실행" |
| "파일을 정리된 상태로 유지합니다" | "API 핸들러는 `src/api/handlers/`에 있습니다" |

**초기 설정**: `/init` 실행 시 코드베이스를 분석하여 빌드 명령, 테스트 지침, 프로젝트 규칙을 포함한 CLAUDE.md를 자동 생성한다. `CLAUDE_CODE_NEW_INIT=1` 설정 시 대화형 다단계 흐름으로 전환—CLAUDE.md·skills·hooks 아티팩트를 순차적으로 설정하고 제안을 검토한 후 파일을 작성한다.

### 추가 파일 가져오기

`@path/to/import` 구문으로 파일 가져오기 (최대 5홉 재귀):

```markdown
프로젝트 개요는 @README를 참조하고 npm 명령은 @package.json을 참조합니다.

# 추가 지침
- git 워크플로우 @docs/git-instructions.md
- 개인 선호도 @~/.claude/my-project-instructions.md
```

가져온 파일은 참조하는 CLAUDE.md와 함께 세션 시작 시 컨텍스트에 로드된다.

### AGENTS.md

Claude Code는 `CLAUDE.md`를 읽으며 `AGENTS.md`는 읽지 않는다. 두 도구가 공존해야 하는 경우:

```markdown
@AGENTS.md

## Claude Code
`src/billing/` 아래 변경 사항에 대해 plan mode를 사용합니다.
```

## .claude/rules/ 규칙 구성

대규모 프로젝트에서 지침을 여러 파일로 모듈화할 수 있다.

```text
your-project/
├── .claude/
│   ├── CLAUDE.md           # 주 프로젝트 지침
│   └── rules/
│       ├── code-style.md   # 코드 스타일 가이드라인
│       ├── testing.md      # 테스트 규칙
│       └── security.md     # 보안 요구사항
```

### 경로별 규칙 (Path-specific Rules)

YAML frontmatter의 `paths` 필드로 특정 파일 유형에만 적용:

```markdown
---
paths:
  - "src/api/**/*.ts"
  - "src/**/*.{ts,tsx}"
---

# API 개발 규칙

- 모든 API 엔드포인트는 입력 검증을 포함해야 합니다
- 표준 오류 응답 형식을 사용합니다
```

| 패턴 | 일치 |
| --- | --- |
| `**/*.ts` | 모든 TypeScript 파일 |
| `src/**/*` | src/ 아래 모든 파일 |
| `*.md` | 프로젝트 루트의 마크다운 파일 |

`paths` 필드가 없는 규칙은 무조건 모든 파일에 적용된다. 경로 범위 규칙은 도구 사용 시가 아닌 Claude가 해당 파일을 읽을 때 트리거된다.

심볼릭 링크 지원: `ln -s ~/shared-claude-rules .claude/rules/shared`

### HTML 블록 주석 자동 제거

CLAUDE.md 파일의 블록 수준 HTML 주석(`<!-- maintainer notes -->`)은 Claude의 컨텍스트에 주입되기 전 자동으로 제거된다. 컨텍스트 토큰을 소비하지 않고 사람 유지보수자용 메모를 남길 때 활용한다. 코드 블록 내부 주석은 보존되며, Read 도구로 직접 파일을 열면 주석이 그대로 표시된다.

### 추가 디렉토리에서 CLAUDE.md 로드

`--add-dir` 플래그로 추가된 디렉토리는 기본적으로 CLAUDE.md를 로드하지 않는다. 추가 디렉토리의 CLAUDE.md도 로드하려면 `CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD=1` 환경변수를 설정한다:

```bash
CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD=1 claude --add-dir ../shared-config
```

이 설정은 `CLAUDE.md`, `.claude/CLAUDE.md`, `.claude/rules/*.md`를 모두 포함하여 로드한다.

### 사용자 수준 규칙

`~/.claude/rules/`의 규칙은 모든 프로젝트에 적용된다. 프로젝트별이 아닌 개인 선호도에 사용.

## Auto Memory

### 작동 방식

Claude가 작업하면서 자동으로 저장하는 노트:
- 빌드 명령, 디버깅 인사이트, 아키텍처 노트, 코드 스타일 선호도, 워크플로우 습관
- 정보가 향후 세션에서 유용할지 판단하여 선택적으로 저장

**저장 위치**: `~/.claude/projects/<project>/memory/`

```text
~/.claude/projects/<project>/memory/
├── MEMORY.md          # 간결한 인덱스, 모든 세션에 로드됨
├── debugging.md       # 디버깅 패턴에 대한 자세한 노트
├── api-conventions.md # API 설계 결정
└── ...                # Claude가 만드는 다른 주제 파일
```

**로드 규칙**: `MEMORY.md`의 처음 200줄 또는 25KB(먼저 도달하는 것) → 임계값 초과분은 세션 시작 시 로드되지 않음. 주제 파일(debugging.md 등)은 시작 시 로드되지 않고 필요할 때 Claude가 직접 읽음. 이 200줄 제한은 `MEMORY.md`에만 적용되며, CLAUDE.md 파일은 길이에 관계없이 전체 로드된다(단, 짧을수록 준수율이 높아짐).

**범위**: 컴퓨터 로컬. 동일 git 저장소 내 모든 worktree와 하위 디렉토리는 하나의 auto memory 공유.

### 설정

```json
// autoMemoryEnabled 토글
{
  "autoMemoryEnabled": false
}

// 저장 위치 변경 (project 설정에서는 불가, 보안상)
{
  "autoMemoryDirectory": "~/my-custom-memory-dir"
}
```

환경 변수로 비활성화: `CLAUDE_CODE_DISABLE_AUTO_MEMORY=1`

`/memory` 명령으로 현재 로드된 CLAUDE.md 목록 확인, 파일 편집기 열기, auto memory 토글 가능.

## 대규모 팀 설정

### 조직 전체 CLAUDE.md 배포

관리 CLAUDE.md vs 관리 설정 역할 구분:

| 관심사 | 구성 대상 |
| --- | --- |
| 특정 도구·명령·경로 차단 | 관리 설정: `permissions.deny` |
| 샌드박스 격리 강제 | 관리 설정: `sandbox.enabled` |
| 환경 변수 및 API 라우팅 | 관리 설정: `env` |
| 코드 스타일 및 품질 가이드라인 | 관리 CLAUDE.md |
| 데이터 처리 및 규정 준수 | 관리 CLAUDE.md |

관리 정책 CLAUDE.md는 개인 설정으로 제외 불가.

### 특정 CLAUDE.md 파일 제외 (모노레포)

```json
// .claude/settings.local.json
{
  "claudeMdExcludes": [
    "**/monorepo/CLAUDE.md",
    "/home/user/monorepo/other-team/.claude/rules/**"
  ]
}
```

## 문제 해결

| 증상 | 해결 방법 |
| --- | --- |
| Claude가 CLAUDE.md를 따르지 않음 | `/memory` 실행 → 파일 로드 여부 확인. 지침 더 구체적으로 작성. 충돌 규칙 제거. `InstructionsLoaded` hook으로 로드된 파일·시기·이유를 정확히 기록 (경로별 규칙·지연 로드 파일 디버깅에 유용). |
| Auto memory 내용 불명확 | `/memory` → auto memory 폴더 선택하여 탐색 |
| CLAUDE.md가 너무 큼 | `@path` 가져오기로 분리, `.claude/rules/`로 분할 |
| `/compact` 후 지침 손실 | 대화에만 있던 지침이 손실됨. CLAUDE.md에 명시적으로 추가 필요 |

시스템 프롬프트 수준 지침이 필요한 경우: `--append-system-prompt` 사용 (스크립트·자동화에 적합).

## 관련 항목

- [[wiki/ai/claude-code/claude-code-작동방식-에이전트하네스]]
- [[wiki/ai/claude-code/claude-code-확장기능-개요]]
