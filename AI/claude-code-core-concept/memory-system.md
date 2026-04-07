
> https://code.claude.com/docs/en/memory

# Claude Code 메모리 시스템

# 목표

Claude Code가 세션 간 지식을 유지하는 두 가지 메커니즘(CLAUDE.md, Auto Memory)을 이해하고, 상황에 맞게 설정·활용할 수 있다.

---

# 문제: 매 세션이 백지 상태

Claude Code는 세션을 시작할 때마다 새로운 컨텍스트 윈도우에서 출발한다. 이전 대화에서 알려준 코딩 규칙, 프로젝트 구조, 디버깅 노하우가 다음 세션에는 전달되지 않는다.

이 문제를 해결하기 위해 두 가지 메모리 시스템이 존재한다.

---

# 두 가지 해법

|            | CLAUDE.md          | Auto Memory             |
| ---------- | ------------------ | ----------------------- |
| **누가 쓰는가** | 사용자가 직접 작성         | Claude가 스스로 작성          |
| **내용**     | 지시사항, 규칙           | 학습한 패턴, 발견한 정보          |
| **스코프**    | 프로젝트 / 사용자 / 조직    | 작업 트리(worktree) 단위      |
| **로딩**     | 매 세션 시작 시 전체 로드    | MEMORY.md 첫 200줄만 로드    |
| **용도**     | 코딩 표준, 워크플로우, 아키텍처 | 빌드 명령어, 디버깅 인사이트, 선호 패턴 |

## 판단 기준: 어디에 넣을까?

- **"Claude야, 항상 이렇게 해"** → CLAUDE.md
  - 코딩 컨벤션, 테스트 방식, 커밋 규칙 등 명시적 지시
- **"Claude가 알아서 기억하면 좋겠다"** → Auto Memory
  - 작업 중 발견한 빌드 명령어, 프로젝트 특성, 사용자 교정 패턴

CLAUDE.md는 행동을 가이드하고, Auto Memory는 교정에서 학습한다.

---

# CLAUDE.md 실전 가이드

CLAUDE.md는 마크다운 파일로, Claude가 매 세션 시작 시 자동으로 읽는 영구 지시사항이다.

## 어디에 놓을까 — 스코프별 위치

구체적인 위치일수록 우선순위가 높다.

| 스코프 | 위치 | 용도 | 공유 범위 |
|--------|------|------|-----------|
| **Managed policy** | macOS: `/Library/Application Support/ClaudeCode/CLAUDE.md`<br/>Linux/WSL: `/etc/claude-code/CLAUDE.md` | 조직 전체 지시사항 | 해당 머신의 모든 사용자 |
| **프로젝트** | `./CLAUDE.md` 또는 `./.claude/CLAUDE.md` | 팀 공유 프로젝트 규칙 | 소스 컨트롤을 통해 팀 전체 |
| **사용자** | `~/.claude/CLAUDE.md` | 개인 선호 설정 | 본인만 (모든 프로젝트에 적용) |

- 현재 작업 디렉토리 **상위**에 있는 CLAUDE.md는 시작 시 전부 로드
- **하위** 디렉토리의 CLAUDE.md는 Claude가 해당 디렉토리의 파일을 읽을 때 지연 로드(lazy load)

> `/init` 명령으로 CLAUDE.md를 자동 생성할 수 있다. 코드베이스를 분석해서 빌드 명령어, 테스트 방법, 컨벤션을 추출한다. 이미 CLAUDE.md가 있으면 덮어쓰지 않고 개선을 제안한다.

## 잘 쓰는 법

CLAUDE.md는 컨텍스트 윈도우에 로드되므로 토큰을 소비한다. 잘 쓸수록 Claude가 더 일관되게 따른다.
**크기**: 파일당 200줄 이내를 목표로 한다. 길어지면 임포트나 rules로 분할한다.
**구조**: 마크다운 헤더와 불릿으로 그룹핑한다. 밀도 높은 문단보다 구조화된 섹션이 낫다.
**구체성**: 검증 가능할 만큼 구체적으로 쓴다.

| 나쁜 예           | 좋은 예                               |
| -------------- | ---------------------------------- |
| "코드를 적절히 포맷하라" | "2칸 들여쓰기를 사용하라"                    |
| "변경사항을 테스트하라"  | "커밋 전에 `npm test`를 실행하라"           |
| "파일을 잘 정리하라"   | "API 핸들러는 `src/api/handlers/`에 둔다" |

**일관성**: 여러 CLAUDE.md 파일에 서로 모순되는 지시가 있으면 Claude가 임의로 하나를 선택할 수 있다. 주기적으로 검토해서 충돌을 제거한다.

## 커질 때 — 임포트(@path)와 .claude/rules/

### 파일 임포트

`@path/to/file` 문법으로 다른 파일을 CLAUDE.md에 포함할 수 있다. 상대 경로는 해당 CLAUDE.md 파일 기준으로 해석된다. 최대 5단계 중첩까지 가능하다.

```text
See @README for project overview and @package.json for available npm commands.

# Additional Instructions
- git workflow @docs/git-instructions.md
```

소스 컨트롤에 넣고 싶지 않은 개인 설정은 홈 디렉토리의 파일을 임포트한다:

```text
# Individual Preferences
- @~/.claude/my-project-instructions.md
```

> 프로젝트에서 외부 임포트를 처음 만나면 승인 다이얼로그가 표시된다. 거부하면 해당 임포트는 비활성화된다.

### .claude/rules/ 디렉토리

프로젝트가 커지면 지시사항을 주제별 마크다운 파일로 분리할 수 있다. `.md` 파일은 재귀적으로 탐색되므로 하위 디렉토리 구조도 가능하다.

```
your-project/
├── .claude/
│   ├── CLAUDE.md
│   └── rules/
│       ├── code-style.md
│       ├── testing.md
│       └── security.md
```

`paths` frontmatter가 없는 규칙은 시작 시 무조건 로드된다.

#### 경로별 스코핑 (path-specific rules)

YAML frontmatter의 `paths` 필드로 특정 파일에만 적용되는 규칙을 만들 수 있다. Claude가 매칭되는 파일을 읽을 때만 로드된다.

```markdown
---
paths:
  - "src/api/**/*.ts"
---

# API Development Rules

- All API endpoints must include input validation
- Use the standard error response format
```

glob 패턴 예시:

| 패턴 | 매칭 대상 |
|------|-----------|
| `**/*.ts` | 모든 디렉토리의 TypeScript 파일 |
| `src/**/*` | src/ 하위 전체 |
| `*.md` | 프로젝트 루트의 마크다운 파일 |
| `src/components/*.tsx` | 특정 디렉토리의 React 컴포넌트 |

여러 패턴과 brace expansion도 지원한다:

```markdown
---
paths:
  - "src/**/*.{ts,tsx}"
  - "lib/**/*.ts"
  - "tests/**/*.test.ts"
---
```

#### 심볼릭 링크로 프로젝트 간 공유

`.claude/rules/`는 심볼릭 링크를 지원한다. 공유 규칙 세트를 여러 프로젝트에 링크할 수 있다.

```bash
ln -s ~/shared-claude-rules .claude/rules/shared
ln -s ~/company-standards/security.md .claude/rules/security.md
```

#### 사용자 레벨 규칙

`~/.claude/rules/`에 개인 규칙을 두면 모든 프로젝트에 적용된다. 프로젝트 규칙보다 낮은 우선순위로 로드된다.

## 로딩 순서

Claude Code는 현재 작업 디렉토리에서 **상위로 올라가며** 각 디렉토리의 CLAUDE.md를 탐색한다. `foo/bar/`에서 실행하면 `foo/bar/CLAUDE.md`와 `foo/CLAUDE.md` 모두 로드된다.

하위 디렉토리의 CLAUDE.md는 시작 시가 아닌, Claude가 해당 디렉토리의 파일을 읽을 때 로드된다.

### --add-dir로 추가 디렉토리 로드

`--add-dir` 플래그로 추가 디렉토리에 접근할 수 있지만, 해당 디렉토리의 CLAUDE.md는 기본적으로 로드되지 않는다. 로드하려면 환경변수를 설정한다:

```bash
CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD=1 claude --add-dir ../shared-config
```

## 조직 단위 관리

### Managed CLAUDE.md 배포

조직 관리자가 머신 전체에 적용되는 CLAUDE.md를 배포할 수 있다. MDM, Group Policy, Ansible 등으로 배포하며, 개별 사용자가 제외할 수 없다.

### Managed CLAUDE.md vs Managed Settings

같은 조직 관리 기능이지만 역할이 다르다.

| 목적 | 설정 위치 |
|------|-----------|
| 도구·명령어·파일 경로 차단 | Managed Settings: `permissions.deny` |
| 샌드박스 강제 | Managed Settings: `sandbox.enabled` |
| 환경변수, API 라우팅 | Managed Settings: `env` |
| 인증 방식 강제 | Managed Settings: `forceLoginMethod` |
| 코드 스타일, 품질 가이드라인 | Managed CLAUDE.md |
| 데이터 처리, 컴플라이언스 안내 | Managed CLAUDE.md |
| Claude 행동 지시 | Managed CLAUDE.md |

핵심 구분: **Settings는 클라이언트가 기술적으로 강제**하고, **CLAUDE.md는 Claude의 행동을 유도**한다. CLAUDE.md는 강제 실행 계층이 아니다.

### claudeMdExcludes로 불필요한 파일 제외

대규모 모노레포에서 다른 팀의 CLAUDE.md가 로드되는 것을 방지할 수 있다. `.claude/settings.local.json`에 설정하면 로컬에만 적용된다.

```json
{
  "claudeMdExcludes": [
    "**/monorepo/CLAUDE.md",
    "/home/user/monorepo/other-team/.claude/rules/**"
  ]
}
```

- glob 패턴으로 절대 경로에 매칭
- user, project, local, managed policy 모든 설정 레이어에서 설정 가능하며, 배열은 레이어 간 병합됨
- Managed policy CLAUDE.md는 제외 불가 — 조직 지시사항은 항상 적용됨

---

# Auto Memory 실전 가이드

Auto Memory는 Claude가 세션 중 스스로 메모를 남기는 기능이다. 빌드 명령어, 디버깅 인사이트, 아키텍처 노트, 코드 스타일, 워크플로우 습관 등을 기록한다. 매 세션마다 저장하는 것은 아니고, 미래 대화에서 유용할 정보인지 Claude가 판단한다. Subagent도 자체 auto memory를 유지할 수 있다.

> Auto Memory는 Claude Code v2.1.59 이상에서 사용 가능하다.

## 저장 위치와 구조

프로젝트별로 `~/.claude/projects/<project>/memory/`에 저장된다. `<project>` 경로는 git 저장소 기준이므로, 같은 repo의 모든 worktree와 하위 디렉토리가 하나의 메모리 디렉토리를 공유한다. git repo 밖에서는 프로젝트 루트가 기준이 된다.

```
~/.claude/projects/<project>/memory/
├── MEMORY.md          # 간결한 인덱스, 매 세션 로드
├── debugging.md       # 디버깅 패턴 상세 노트
├── api-conventions.md # API 설계 결정
└── ...                # Claude가 만드는 기타 토픽 파일
```

저장 위치를 변경하려면 user 또는 local 설정에서 `autoMemoryDirectory`를 지정한다:

```json
{
  "autoMemoryDirectory": "~/my-custom-memory-dir"
}
```

> 보안상 project 설정(`.claude/settings.json`)에서는 이 값을 설정할 수 없다. 공유 프로젝트가 메모리 쓰기를 민감한 경로로 리디렉션하는 것을 방지하기 위함이다.

Auto Memory는 머신 로컬이다. 다른 머신이나 클라우드 환경과 공유되지 않는다.

## 200줄 제한과 동작 방식

- **MEMORY.md의 첫 200줄**만 세션 시작 시 로드된다. 200줄 이후는 로드되지 않는다.
- Claude는 MEMORY.md를 간결하게 유지하기 위해 상세 내용을 별도 토픽 파일로 분리한다.
- 토픽 파일(`debugging.md`, `patterns.md` 등)은 시작 시 로드되지 않는다. Claude가 필요할 때 파일 도구로 읽는다.
- 이 200줄 제한은 MEMORY.md에만 적용된다. CLAUDE.md는 길이와 무관하게 전체 로드된다(다만 짧을수록 지시가 더 잘 반영된다).

세션 중 Claude가 메모리를 읽거나 쓸 때 인터페이스에 "Writing memory" 또는 "Recalled memory"가 표시된다.

## 활성화 / 비활성화

기본적으로 켜져 있다. 끄는 방법:

- 세션 내에서 `/memory` → auto memory 토글
- 프로젝트 설정:

```json
{
  "autoMemoryEnabled": false
}
```

- 환경변수: `CLAUDE_CODE_DISABLE_AUTO_MEMORY=1`

## 확인 · 편집 · 삭제

Auto Memory 파일은 일반 마크다운이므로 언제든 직접 편집하거나 삭제할 수 있다.

- `/memory` 명령으로 현재 세션에 로드된 모든 CLAUDE.md와 rules 파일 목록 확인
- auto memory 폴더를 에디터에서 열기
- 개별 파일 선택하여 편집

Claude에게 "항상 pnpm을 써" 또는 "API 테스트에 로컬 Redis가 필요하다는 걸 기억해"라고 말하면 Auto Memory에 저장된다. CLAUDE.md에 넣고 싶으면 "이걸 CLAUDE.md에 추가해"라고 명시적으로 요청하거나 `/memory`에서 직접 편집한다.

---

# 문제가 생겼을 때

## Claude가 CLAUDE.md를 따르지 않는다

CLAUDE.md는 시스템 프롬프트가 아닌 사용자 메시지로 전달된다. Claude가 읽고 따르려 하지만, 엄격한 준수가 보장되지는 않는다.

디버깅 순서:
1. `/memory`로 해당 CLAUDE.md가 로드되었는지 확인
2. 파일 위치가 로딩 대상인지 확인 (스코프별 위치 참고)
3. 지시를 더 구체적으로 수정
4. 여러 CLAUDE.md 간 충돌 여부 검토

> 시스템 프롬프트 수준의 지시가 필요하면 `--append-system-prompt` 플래그를 사용한다. 매 실행마다 전달해야 하므로 스크립트/자동화에 적합하다.

> `InstructionsLoaded` 훅을 사용하면 어떤 지시 파일이 언제, 왜 로드되었는지 로그로 확인할 수 있다.

## Auto Memory에 뭐가 저장됐는지 모르겠다

`/memory`에서 auto memory 폴더를 열어 확인한다. 전부 일반 마크다운이므로 읽기·편집·삭제 모두 가능하다.

## CLAUDE.md가 너무 길다

200줄 이상이면 컨텍스트를 많이 소비하고 Claude가 지시를 잘 따르지 못할 수 있다. `@path` 임포트로 분할하거나 `.claude/rules/`로 분리한다.

## /compact 후 지시사항이 사라졌다

CLAUDE.md는 compaction 후에도 완전히 유지된다. `/compact` 후 Claude가 디스크에서 CLAUDE.md를 다시 읽고 세션에 주입한다. 사라진 지시가 있다면, 그것은 대화 중에만 전달된 것이지 CLAUDE.md에 기록된 것이 아니다. 영구적으로 유지하려면 CLAUDE.md에 추가해야 한다.
