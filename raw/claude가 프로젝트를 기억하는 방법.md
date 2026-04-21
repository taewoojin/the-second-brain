---
title: "Claude가 프로젝트를 기억하는 방법"
source: "https://code.claude.com/docs/ko/memory"
author:
published:
created: 2026-04-20
description: "CLAUDE.md 파일로 Claude에 지속적인 지침을 제공하고, 자동 메모리를 통해 Claude가 자동으로 학습을 축적하도록 합니다."
tags:
  - "clippings"
---
각 Claude Code 세션은 새로운 컨텍스트 윈도우로 시작됩니다. 두 가지 메커니즘이 세션 간에 지식을 전달합니다:

- **CLAUDE.md 파일**: Claude에 지속적인 컨텍스트를 제공하기 위해 작성하는 지침
- **자동 메모리**: 수정 및 선호도에 따라 Claude가 자신을 위해 작성하는 노트

이 페이지에서는 다음을 다룹니다:

- [CLAUDE.md 파일 작성 및 구성](#claude-md-files)
- [`.claude/rules/` 를 사용하여 특정 파일 유형에 규칙 범위 지정](#organize-rules-with-clauderules)
- [자동 메모리 구성](#auto-memory) 하여 Claude가 자동으로 노트를 작성하도록 함
- [지침이 따라지지 않을 때 문제 해결](#troubleshoot-memory-issues)

## CLAUDE.md vs 자동 메모리

Claude Code에는 두 가지 상호 보완적인 메모리 시스템이 있습니다. 둘 다 모든 대화의 시작 시 로드됩니다. Claude는 이들을 강제된 구성이 아닌 컨텍스트로 취급합니다. 지침이 더 구체적이고 간결할수록 Claude가 더 일관되게 따릅니다.

|  | CLAUDE.md 파일 | 자동 메모리 |
| --- | --- | --- |
| **작성자** | 사용자 | Claude |
| **포함 내용** | 지침 및 규칙 | 학습 및 패턴 |
| **범위** | 프로젝트, 사용자 또는 조직 | 작업 트리당 |
| **로드 대상** | 모든 세션 | 모든 세션(처음 200줄 또는 25KB) |
| **사용 목적** | 코딩 표준, 워크플로우, 프로젝트 아키텍처 | 빌드 명령, 디버깅 인사이트, Claude가 발견한 선호도 |

Claude의 동작을 안내하려면 CLAUDE.md 파일을 사용합니다. 자동 메모리를 통해 Claude는 수동 작업 없이 수정 사항에서 학습할 수 있습니다.

Subagent도 자신의 자동 메모리를 유지할 수 있습니다. 자세한 내용은 [subagent 구성](https://code.claude.com/docs/ko/sub-agents#enable-persistent-memory) 을 참조하세요.

## CLAUDE.md 파일

CLAUDE.md 파일은 프로젝트, 개인 워크플로우 또는 전체 조직에 대해 Claude에 지속적인 지침을 제공하는 마크다운 파일입니다. 이러한 파일을 일반 텍스트로 작성하면 Claude가 모든 세션의 시작 시 읽습니다.

### CLAUDE.md 파일을 어디에 배치할지 선택

CLAUDE.md 파일은 여러 위치에 있을 수 있으며, 각각 다른 범위를 가집니다. 더 구체적인 위치가 더 광범위한 위치보다 우선합니다.

| 범위 | 위치 | 목적 | 사용 사례 | 공유 대상 |
| --- | --- | --- | --- | --- |
| **관리 정책** | • macOS: `/Library/Application Support/ClaudeCode/CLAUDE.md`   • Linux 및 WSL: `/etc/claude-code/CLAUDE.md`   • Windows: `C:\Program Files\ClaudeCode\CLAUDE.md` | IT/DevOps에서 관리하는 조직 전체 지침 | 회사 코딩 표준, 보안 정책, 규정 준수 요구사항 | 조직의 모든 사용자 |
| **프로젝트 지침** | `./CLAUDE.md` 또는 `./.claude/CLAUDE.md` | 프로젝트에 대한 팀 공유 지침 | 프로젝트 아키텍처, 코딩 표준, 일반적인 워크플로우 | 소스 제어를 통한 팀 멤버 |
| **사용자 지침** | `~/.claude/CLAUDE.md` | 모든 프로젝트에 대한 개인 선호도 | 코드 스타일 선호도, 개인 도구 단축키 | 본인만(모든 프로젝트) |

작업 디렉토리 위의 디렉토리 계층 구조에 있는 CLAUDE.md 파일은 시작 시 전체 로드됩니다. 하위 디렉토리의 CLAUDE.md 파일은 Claude가 해당 디렉토리의 파일을 읽을 때 필요에 따라 로드됩니다. 전체 해석 순서는 [CLAUDE.md 파일이 로드되는 방식](#how-claudemd-files-load) 을 참조하세요.

대규모 프로젝트의 경우 [프로젝트 규칙](#organize-rules-with-clauderules) 을 사용하여 지침을 주제별 파일로 나눌 수 있습니다. 규칙을 통해 특정 파일 유형 또는 하위 디렉토리에 지침의 범위를 지정할 수 있습니다.

### 프로젝트 CLAUDE.md 설정

프로젝트 CLAUDE.md는 `./CLAUDE.md` 또는 `./.claude/CLAUDE.md` 에 저장할 수 있습니다. 이 파일을 만들고 프로젝트에서 작업하는 모든 사람에게 적용되는 지침을 추가합니다: 빌드 및 테스트 명령, 코딩 표준, 아키텍처 결정, 명명 규칙 및 일반적인 워크플로우. 이러한 지침은 버전 제어를 통해 팀과 공유되므로 개인 선호도보다는 프로젝트 수준의 표준에 중점을 두세요.

`/init` 을 실행하여 시작 CLAUDE.md를 자동으로 생성합니다. Claude는 코드베이스를 분석하고 발견한 빌드 명령, 테스트 지침 및 프로젝트 규칙이 포함된 파일을 만듭니다. CLAUDE.md가 이미 존재하면 `/init` 은 덮어쓰지 않고 개선 사항을 제안합니다. Claude가 자신에게 발견하지 못할 지침으로 그곳에서 개선합니다.

`CLAUDE_CODE_NEW_INIT=1` 을 설정하여 대화형 다단계 흐름을 활성화합니다. `/init` 은 설정할 아티팩트를 묻습니다: CLAUDE.md 파일, skills 및 hooks. 그런 다음 subagent로 코드베이스를 탐색하고 후속 질문을 통해 간격을 채우며 파일을 작성하기 전에 검토 가능한 제안을 제시합니다.

### 효과적인 지침 작성

CLAUDE.md 파일은 모든 세션의 시작 시 컨텍스트 윈도우에 로드되어 대화와 함께 토큰을 소비합니다. [컨텍스트 윈도우 시각화](https://code.claude.com/docs/ko/context-window) 는 CLAUDE.md가 나머지 시작 컨텍스트를 기준으로 어디에 로드되는지 보여줍니다. 강제된 구성이 아닌 컨텍스트이기 때문에 지침을 작성하는 방식이 Claude가 얼마나 안정적으로 따르는지에 영향을 미칩니다. 구체적이고 간결하며 잘 구조화된 지침이 가장 잘 작동합니다.

**크기**: CLAUDE.md 파일당 200줄 이하를 목표로 합니다. 더 긴 파일은 더 많은 컨텍스트를 소비하고 준수를 줄입니다. 지침이 커지면 [가져오기](#import-additional-files) 를 사용하거나 [`.claude/rules/`](#organize-rules-with-clauderules) 파일로 분할합니다.

**구조**: 마크다운 헤더와 글머리 기호를 사용하여 관련 지침을 그룹화합니다. Claude는 독자와 같은 방식으로 구조를 스캔합니다: 구성된 섹션이 조밀한 단락보다 따르기 쉽습니다.

**구체성**: 검증할 수 있을 정도로 구체적인 지침을 작성합니다. 예를 들어:

- “코드를 제대로 포맷합니다”보다는 “2칸 들여쓰기 사용”
- “변경 사항을 테스트합니다”보다는 “커밋하기 전에 `npm test` 실행”
- “파일을 정리된 상태로 유지합니다”보다는 “API 핸들러는 `src/api/handlers/` 에 있습니다”

**일관성**: 두 규칙이 서로 모순되면 Claude가 하나를 임의로 선택할 수 있습니다. CLAUDE.md 파일, 하위 디렉토리의 중첩된 CLAUDE.md 파일 및 [`.claude/rules/`](#organize-rules-with-clauderules) 을 정기적으로 검토하여 오래되었거나 충돌하는 지침을 제거합니다. 모노레포에서는 [`claudeMdExcludes`](#exclude-specific-claudemd-files) 를 사용하여 작업과 관련이 없는 다른 팀의 CLAUDE.md 파일을 건너뜁니다.

### 추가 파일 가져오기

CLAUDE.md 파일은 `@path/to/import` 구문을 사용하여 추가 파일을 가져올 수 있습니다. 가져온 파일은 확장되어 참조하는 CLAUDE.md와 함께 시작 시 컨텍스트에 로드됩니다.

상대 경로와 절대 경로 모두 허용됩니다. 상대 경로는 작업 디렉토리가 아닌 가져오기를 포함하는 파일을 기준으로 해석됩니다. 가져온 파일은 최대 5개 홉의 깊이로 다른 파일을 재귀적으로 가져올 수 있습니다.

README, package.json 및 워크플로우 가이드를 가져오려면 CLAUDE.md의 어디든지 `@` 구문으로 참조합니다:

```text
프로젝트 개요는 @README를 참조하고 이 프로젝트의 사용 가능한 npm 명령은 @package.json을 참조합니다.

# 추가 지침
- git 워크플로우 @docs/git-instructions.md
```

체크인하지 않으려는 개인 선호도의 경우 홈 디렉토리에서 파일을 가져옵니다. 가져오기는 공유 CLAUDE.md에 있지만 가리키는 파일은 컴퓨터에 남아 있습니다:

```text
# 개인 선호도
- @~/.claude/my-project-instructions.md
```

Claude Code가 프로젝트에서 외부 가져오기를 처음 만날 때 파일을 나열하는 승인 대화를 표시합니다. 거부하면 가져오기가 비활성화된 상태로 유지되고 대화가 다시 나타나지 않습니다.

지침을 구성하는 더 구조화된 접근 방식은 [`.claude/rules/`](#organize-rules-with-clauderules) 을 참조하세요.

### AGENTS.md

Claude Code는 `CLAUDE.md` 를 읽으며 `AGENTS.md` 를 읽지 않습니다. 저장소가 이미 다른 코딩 에이전트에 `AGENTS.md` 를 사용하는 경우 `CLAUDE.md` 를 만들어 이를 가져오면 두 도구가 중복 없이 동일한 지침을 읽을 수 있습니다. Claude 특정 지침을 가져오기 아래에 추가할 수도 있습니다. Claude는 가져온 파일을 세션 시작 시 로드한 다음 나머지를 추가합니다:

```markdown
@AGENTS.md

## Claude Code

\`src/billing/\` 아래의 변경 사항에 대해 plan mode를 사용합니다.
```

### CLAUDE.md 파일이 로드되는 방식

Claude Code는 현재 작업 디렉토리에서 디렉토리 트리를 따라 올라가며 CLAUDE.md 파일을 읽고 각 디렉토리를 확인합니다. 즉, `foo/bar/` 에서 Claude Code를 실행하면 `foo/bar/CLAUDE.md` 와 `foo/CLAUDE.md` 모두에서 지침을 로드합니다.

Claude는 또한 현재 작업 디렉토리 아래의 하위 디렉토리에서 CLAUDE.md 파일을 발견합니다. 시작 시 로드하는 대신 Claude가 해당 하위 디렉토리의 파일을 읽을 때 포함됩니다.

대규모 모노레포에서 작업하고 다른 팀의 CLAUDE.md 파일이 선택되는 경우 [`claudeMdExcludes`](#exclude-specific-claudemd-files) 를 사용하여 건너뜁니다.

CLAUDE.md 파일의 블록 수준 HTML 주석(`<!-- maintainer notes -->`)은 콘텐츠가 Claude의 컨텍스트에 주입되기 전에 제거됩니다. 컨텍스트 토큰을 소비하지 않고 인간 유지보수자를 위한 노트를 남기는 데 사용합니다. 코드 블록 내의 주석은 보존됩니다. Read 도구로 CLAUDE.md 파일을 직접 열 때 주석이 표시된 상태로 유지됩니다.

#### 추가 디렉토리에서 로드

`--add-dir` 플래그는 Claude에 주 작업 디렉토리 외부의 추가 디렉토리에 대한 액세스를 제공합니다. 기본적으로 이러한 디렉토리의 CLAUDE.md 파일은 로드되지 않습니다.

추가 디렉토리에서 CLAUDE.md 파일을 로드하려면 `CLAUDE.md`, `.claude/CLAUDE.md` 및 `.claude/rules/*.md` 를 포함하여 `CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD` 환경 변수를 설정합니다:

```shellscript
CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD=1 claude --add-dir ../shared-config
```

### .claude/rules/로 규칙 구성

대규모 프로젝트의 경우 `.claude/rules/` 디렉토리를 사용하여 지침을 여러 파일로 구성할 수 있습니다. 이렇게 하면 지침이 모듈식이 되고 팀이 유지 관리하기 쉬워집니다. 규칙을 [특정 파일 경로로 범위 지정](#path-specific-rules) 할 수도 있으므로 Claude가 일치하는 파일로 작업할 때만 컨텍스트에 로드되어 노이즈를 줄이고 컨텍스트 공간을 절약합니다.

규칙은 모든 세션 또는 일치하는 파일이 열릴 때 컨텍스트에 로드됩니다. 항상 컨텍스트에 있을 필요가 없는 작업별 지침의 경우 대신 [skills](https://code.claude.com/docs/ko/skills) 를 사용하세요. 이는 호출할 때 또는 Claude가 프롬프트와 관련이 있다고 판단할 때만 로드됩니다.

#### 규칙 설정

프로젝트의 `.claude/rules/` 디렉토리에 마크다운 파일을 배치합니다. 각 파일은 `testing.md` 또는 `api-design.md` 와 같은 설명적인 파일명으로 한 가지 주제를 다루어야 합니다. 모든 `.md` 파일은 재귀적으로 발견되므로 `frontend/` 또는 `backend/` 와 같은 하위 디렉토리로 규칙을 구성할 수 있습니다:

```text
your-project/
├── .claude/
│   ├── CLAUDE.md           # 주 프로젝트 지침
│   └── rules/
│       ├── code-style.md   # 코드 스타일 가이드라인
│       ├── testing.md      # 테스트 규칙
│       └── security.md     # 보안 요구사항
```

[`paths` frontmatter](#path-specific-rules) 가 없는 규칙은 `.claude/CLAUDE.md` 와 동일한 우선순위로 시작 시 로드됩니다.

#### 경로별 규칙

규칙은 `paths` 필드가 있는 YAML frontmatter를 사용하여 특정 파일로 범위를 지정할 수 있습니다. 이러한 조건부 규칙은 Claude가 지정된 패턴과 일치하는 파일로 작업할 때만 적용됩니다.

```markdown
---
paths:
  - "src/api/**/*.ts"
---

# API 개발 규칙

- 모든 API 엔드포인트는 입력 검증을 포함해야 합니다
- 표준 오류 응답 형식을 사용합니다
- OpenAPI 문서 주석을 포함합니다
```

`paths` 필드가 없는 규칙은 무조건 로드되며 모든 파일에 적용됩니다. 경로 범위 규칙은 모든 도구 사용 시가 아니라 Claude가 패턴과 일치하는 파일을 읽을 때 트리거됩니다.

`paths` 필드에서 glob 패턴을 사용하여 확장명, 디렉토리 또는 조합으로 파일을 일치시킵니다:

| 패턴 | 일치 |
| --- | --- |
| `**/*.ts` | 모든 디렉토리의 모든 TypeScript 파일 |
| `src/**/*` | `src/` 디렉토리 아래의 모든 파일 |
| `*.md` | 프로젝트 루트의 마크다운 파일 |
| `src/components/*.tsx` | 특정 디렉토리의 React 컴포넌트 |

여러 패턴을 지정하고 중괄호 확장을 사용하여 한 패턴에서 여러 확장명을 일치시킬 수 있습니다:

```markdown
---
paths:
  - "src/**/*.{ts,tsx}"
  - "lib/**/*.ts"
  - "tests/**/*.test.ts"
---
```

#### 심볼릭 링크로 프로젝트 간 규칙 공유

`.claude/rules/` 디렉토리는 심볼릭 링크를 지원하므로 공유 규칙 세트를 유지하고 여러 프로젝트에 링크할 수 있습니다. 심볼릭 링크는 해석되어 정상적으로 로드되며 순환 심볼릭 링크는 감지되고 우아하게 처리됩니다.

이 예제는 공유 디렉토리와 개별 파일을 모두 링크합니다:

```shellscript
ln -s ~/shared-claude-rules .claude/rules/shared
ln -s ~/company-standards/security.md .claude/rules/security.md
```

#### 사용자 수준 규칙

`~/.claude/rules/` 의 개인 규칙은 컴퓨터의 모든 프로젝트에 적용됩니다. 프로젝트별이 아닌 선호도에 사용합니다:

```text
~/.claude/rules/
├── preferences.md    # 개인 코딩 선호도
└── workflows.md      # 선호하는 워크플로우
```

사용자 수준 규칙은 프로젝트 규칙 전에 로드되어 프로젝트 규칙에 더 높은 우선순위를 제공합니다.

### 대규모 팀을 위한 CLAUDE.md 관리

조직에서 Claude Code를 팀 전체에 배포하는 경우 지침을 중앙 집중식으로 관리하고 로드되는 CLAUDE.md 파일을 제어할 수 있습니다.

#### 조직 전체 CLAUDE.md 배포

조직은 컴퓨터의 모든 사용자에게 적용되는 중앙 집중식으로 관리되는 CLAUDE.md를 배포할 수 있습니다. 이 파일은 개별 설정으로 제외될 수 없습니다.

관리 CLAUDE.md와 [관리 설정](https://code.claude.com/docs/ko/settings#settings-files) 은 다른 목적을 제공합니다. 기술적 강제를 위해 설정을 사용하고 CLAUDE.md를 행동 지침으로 사용합니다:

| 관심사 | 구성 대상 |
| --- | --- |
| 특정 도구, 명령 또는 파일 경로 차단 | 관리 설정: `permissions.deny` |
| 샌드박스 격리 강제 | 관리 설정: `sandbox.enabled` |
| 환경 변수 및 API 공급자 라우팅 | 관리 설정: `env` |
| 인증 방법 및 조직 잠금 | 관리 설정: `forceLoginMethod`, `forceLoginOrgUUID` |
| 코드 스타일 및 품질 가이드라인 | 관리 CLAUDE.md |
| 데이터 처리 및 규정 준수 알림 | 관리 CLAUDE.md |
| Claude의 행동 지침 | 관리 CLAUDE.md |

설정 규칙은 Claude가 무엇을 하기로 결정하든 클라이언트에 의해 강제됩니다. CLAUDE.md 지침은 Claude의 행동을 형성하지만 하드 강제 레이어가 아닙니다.

#### 특정 CLAUDE.md 파일 제외

대규모 모노레포에서 상위 CLAUDE.md 파일에는 작업과 관련이 없는 지침이 포함될 수 있습니다. `claudeMdExcludes` 설정을 통해 경로 또는 glob 패턴으로 특정 파일을 건너뛸 수 있습니다.

이 예제는 상위 폴더의 최상위 CLAUDE.md 및 규칙 디렉토리를 제외합니다. 제외가 컴퓨터에 로컬로 유지되도록 `.claude/settings.local.json` 에 추가합니다:

```json
{
  "claudeMdExcludes": [
    "**/monorepo/CLAUDE.md",
    "/home/user/monorepo/other-team/.claude/rules/**"
  ]
}
```

패턴은 glob 구문을 사용하여 절대 파일 경로와 일치합니다. `claudeMdExcludes` 를 [설정 레이어](https://code.claude.com/docs/ko/settings#settings-files): 사용자, 프로젝트, 로컬 또는 관리 정책에서 구성할 수 있습니다. 배열은 레이어 전체에서 병합됩니다.

관리 정책 CLAUDE.md 파일은 제외될 수 없습니다. 이렇게 하면 개별 설정에 관계없이 조직 전체 지침이 항상 적용됩니다.

## 자동 메모리

자동 메모리를 통해 Claude는 아무것도 작성하지 않고도 세션 간에 지식을 축적할 수 있습니다. Claude는 작업할 때 자신을 위해 노트를 저장합니다: 빌드 명령, 디버깅 인사이트, 아키텍처 노트, 코드 스타일 선호도 및 워크플로우 습관. Claude는 모든 세션마다 뭔가를 저장하지 않습니다. 정보가 향후 대화에서 유용할지 여부에 따라 기억할 가치가 있는지 결정합니다.

자동 메모리는 Claude Code v2.1.59 이상이 필요합니다. `claude --version` 으로 버전을 확인합니다.

### 자동 메모리 활성화 또는 비활성화

자동 메모리는 기본적으로 켜져 있습니다. 토글하려면 세션에서 `/memory` 를 열고 자동 메모리 토글을 사용하거나 프로젝트 설정에서 `autoMemoryEnabled` 를 설정합니다:

```json
{
  "autoMemoryEnabled": false
}
```

환경 변수를 통해 자동 메모리를 비활성화하려면 `CLAUDE_CODE_DISABLE_AUTO_MEMORY=1` 을 설정합니다.

### 저장소 위치

각 프로젝트는 `~/.claude/projects/<project>/memory/` 에서 자신의 메모리 디렉토리를 가집니다. `<project>` 경로는 git 저장소에서 파생되므로 동일한 저장소 내의 모든 worktree 및 하위 디렉토리는 하나의 자동 메모리 디렉토리를 공유합니다. git 저장소 외부에서는 프로젝트 루트가 대신 사용됩니다.

자동 메모리를 다른 위치에 저장하려면 사용자 또는 로컬 설정에서 `autoMemoryDirectory` 를 설정합니다:

```json
{
  "autoMemoryDirectory": "~/my-custom-memory-dir"
}
```

이 설정은 정책, 로컬 및 사용자 설정에서 허용됩니다. 공유 프로젝트가 자동 메모리 쓰기를 민감한 위치로 리디렉션하는 것을 방지하기 위해 프로젝트 설정(`.claude/settings.json`)에서는 허용되지 않습니다.

디렉토리에는 `MEMORY.md` 진입점과 선택적 주제 파일이 포함됩니다:

```text
~/.claude/projects/<project>/memory/
├── MEMORY.md          # 간결한 인덱스, 모든 세션에 로드됨
├── debugging.md       # 디버깅 패턴에 대한 자세한 노트
├── api-conventions.md # API 설계 결정
└── ...                # Claude가 만드는 다른 주제 파일
```

`MEMORY.md` 는 메모리 디렉토리의 인덱스 역할을 합니다. Claude는 세션 전체에서 이 디렉토리의 파일을 읽고 쓰며 `MEMORY.md` 를 사용하여 저장된 내용을 추적합니다.

자동 메모리는 컴퓨터 로컬입니다. 동일한 git 저장소 내의 모든 worktree 및 하위 디렉토리는 하나의 자동 메모리 디렉토리를 공유합니다. 파일은 컴퓨터 또는 클라우드 환경 간에 공유되지 않습니다.

### 작동 방식

`MEMORY.md` 의 처음 200줄 또는 처음 25KB(둘 중 먼저 오는 것)는 모든 대화의 시작 시 로드됩니다. 해당 임계값을 초과하는 콘텐츠는 세션 시작 시 로드되지 않습니다. Claude는 자세한 노트를 별도의 주제 파일로 이동하여 `MEMORY.md` 를 간결하게 유지합니다.

이 200줄 제한은 `MEMORY.md` 에만 적용됩니다. CLAUDE.md 파일은 길이에 관계없이 전체 로드되지만 더 짧은 파일이 더 나은 준수를 생성합니다.

`debugging.md` 또는 `patterns.md` 와 같은 주제 파일은 시작 시 로드되지 않습니다. Claude는 필요한 정보가 필요할 때 표준 파일 도구를 사용하여 필요에 따라 읽습니다.

Claude는 세션 중에 메모리 파일을 읽고 씁니다. Claude Code 인터페이스에서 “Writing memory” 또는 “Recalled memory”를 보면 Claude가 `~/.claude/projects/<project>/memory/` 에서 활발히 업데이트하거나 읽고 있습니다.

### 메모리 감사 및 편집

자동 메모리 파일은 언제든지 편집하거나 삭제할 수 있는 일반 마크다운입니다. [`/memory`](#view-and-edit-with-memory) 를 실행하여 세션 내에서 메모리 파일을 찾아보고 엽니다.

## /memory로 보기 및 편집

`/memory` 명령은 현재 세션에 로드된 모든 CLAUDE.md 및 규칙 파일을 나열하고, 자동 메모리를 켜거나 끌 수 있으며, 자동 메모리 폴더를 열 수 있는 링크를 제공합니다. 파일을 선택하여 편집기에서 엽니다.

Claude에게 “항상 npm이 아닌 pnpm을 사용합니다” 또는 “API 테스트에 로컬 Redis 인스턴스가 필요하다는 것을 기억합니다”와 같이 뭔가를 기억하도록 요청하면 Claude는 자동 메모리에 저장합니다. 대신 CLAUDE.md에 지침을 추가하려면 Claude에게 직접 “이것을 CLAUDE.md에 추가합니다”라고 요청하거나 `/memory` 를 통해 파일을 직접 편집합니다.

## 메모리 문제 해결

이들은 CLAUDE.md 및 자동 메모리의 가장 일반적인 문제와 디버깅 단계입니다.

### Claude가 CLAUDE.md를 따르지 않습니다

CLAUDE.md 콘텐츠는 시스템 프롬프트의 일부가 아니라 시스템 프롬프트 후 사용자 메시지로 전달됩니다. Claude는 이를 읽고 따르려고 하지만 특히 모호하거나 충돌하는 지침의 경우 엄격한 준수를 보장하지 않습니다.

디버깅하려면:

- `/memory` 를 실행하여 CLAUDE.md 파일이 로드되는지 확인합니다. 파일이 나열되지 않으면 Claude가 볼 수 없습니다.
- 관련 CLAUDE.md가 세션에 대해 로드되는 위치에 있는지 확인합니다([CLAUDE.md 파일을 어디에 배치할지 선택](#choose-where-to-put-claudemd-files) 참조).
- 지침을 더 구체적으로 만듭니다. “2칸 들여쓰기 사용”이 “코드를 제대로 포맷합니다”보다 더 잘 작동합니다.
- CLAUDE.md 파일 전체에서 충돌하는 지침을 찾습니다. 두 파일이 동일한 동작에 대해 다른 지침을 제공하면 Claude가 하나를 임의로 선택할 수 있습니다.

시스템 프롬프트 수준의 지침의 경우 [`--append-system-prompt`](https://code.claude.com/docs/ko/cli-reference#system-prompt-flags) 를 사용합니다. 이는 모든 호출 시 전달되어야 하므로 대화형 사용보다는 스크립트 및 자동화에 더 적합합니다.

[`InstructionsLoaded` hook](https://code.claude.com/docs/ko/hooks#instructionsloaded) 을 사용하여 로드된 지침 파일, 로드 시기 및 이유를 정확히 기록합니다. 이는 경로별 규칙 또는 하위 디렉토리의 지연 로드 파일을 디버깅하는 데 유용합니다.

### 자동 메모리가 저장한 내용을 모릅니다

`/memory` 를 실행하고 자동 메모리 폴더를 선택하여 Claude가 저장한 내용을 찾아봅니다. 모든 것이 읽고, 편집하거나 삭제할 수 있는 일반 마크다운입니다.

### CLAUDE.md가 너무 큽니다

200줄을 초과하는 파일은 더 많은 컨텍스트를 소비하고 준수를 줄일 수 있습니다. `@path` 가져오기로 참조되는 별도의 파일로 자세한 콘텐츠를 이동합니다([추가 파일 가져오기](#import-additional-files) 참조) 또는 `.claude/rules/` 파일 전체에서 지침을 분할합니다.

### /compact 후 지침이 손실된 것 같습니다

CLAUDE.md는 압축을 완전히 생존합니다. `/compact` 후 Claude는 디스크에서 CLAUDE.md를 다시 읽고 세션에 새로 다시 주입합니다. 압축 후 지침이 사라진 경우 CLAUDE.md에 작성되지 않고 대화에서만 제공되었습니다. 세션 간에 지속되도록 CLAUDE.md에 추가합니다.

효과적인 지침에 대한 지침은 [효과적인 지침 작성](#write-effective-instructions) 을 참조하세요.

## 관련 리소스

- [Skills](https://code.claude.com/docs/ko/skills): 필요에 따라 로드되는 반복 가능한 워크플로우 패키지
- [설정](https://code.claude.com/docs/ko/settings): 설정 파일로 Claude Code 동작 구성
- [세션 관리](https://code.claude.com/docs/ko/sessions): 컨텍스트 관리, 대화 재개 및 병렬 세션 실행
- [Subagent 메모리](https://code.claude.com/docs/ko/sub-agents#enable-persistent-memory): subagent가 자신의 자동 메모리를 유지하도록 허용