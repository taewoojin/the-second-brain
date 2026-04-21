# Claude Code 일반 워크플로우 — 코드탐색, 버그수정, Plan Mode, 세션관리

**출처**: `raw/claude code의 일반적인 워크플로우.md`
**날짜**: 2026-04-21
**keywords**: Plan Mode, git worktrees, subagent, 세션 재개, thinking mode, headless mode, 파이프라인 통합

## 요약

코드베이스 탐색·버그 수정·리팩토링·테스트·PR 생성 등 일상적인 개발 작업에서 Claude Code를 활용하는 단계별 워크플로우를 다룬다. Plan Mode로 안전한 분석, git worktree로 병렬 세션, thinking mode로 복잡한 추론을 지원하며, CI/CD 파이프라인·unix 파이프 통합 패턴도 포함한다.

## 새로운 코드베이스 이해하기

- 광범위한 질문으로 시작한 다음 특정 영역으로 좁혀나가기
- 프로젝트에서 사용되는 코딩 규칙과 패턴에 대해 질문하기
- 프로젝트별 용어의 용어집 요청하기
- 특정 기능 코드를 찾을 때 도메인 언어와 코드 인텔리전스 플러그인 활용

## 효율적으로 버그 수정하기

- Claude에게 문제를 재현하는 명령과 스택 추적을 알려주기
- 오류가 간헐적인지 일관적인지 명시하기

## 코드 리팩토링

- Claude에게 최신 접근 방식의 이점을 설명하도록 요청하기
- 하위 호환성 유지 여부 명시하기
- 작고 테스트 가능한 증분으로 리팩토링 수행하기

## 특화된 subagent 사용하기

- 팀 공유를 위해 `.claude/agents/`에 프로젝트별 subagent 만들기
- 자동 위임을 활성화하기 위해 설명적인 `description` 필드 사용하기
- 각 subagent가 실제로 필요한 것으로 도구 액세스 제한하기

## Plan Mode를 사용하여 안전한 코드 분석

Plan Mode는 읽기 전용 작업으로 코드베이스를 분석하여 계획을 세우도록 한다. `AskUserQuestion`으로 계획 제안 전에 요구사항을 수집한다.

### Plan Mode를 사용할 때

- **다단계 구현**: 기능이 많은 파일을 편집해야 할 때
- **코드 탐색**: 변경 전에 코드베이스를 철저히 조사하고 싶을 때
- **대화형 개발**: Claude와 방향을 반복하고 싶을 때

### Plan Mode 활성화 방법

```shell
# 세션 중: Shift+Tab으로 순환 (Normal → Auto-Accept → Plan)

# Plan Mode로 새 세션 시작
claude --permission-mode plan

# Plan Mode에서 헤드리스 쿼리 실행
claude --permission-mode plan -p "Analyze the authentication system and suggest improvements"
```

- `Ctrl+G`로 기본 텍스트 편집기에서 계획을 열어 직접 편집 가능
- 계획 수락 시 Claude가 계획 내용에서 자동으로 세션 이름 지정

```json
// .claude/settings.json — Plan Mode를 기본값으로 구성
{
  "permissions": {
    "defaultMode": "plan"
  }
}
```

## 이전 대화 재개하기

```shell
claude --continue      # 현재 디렉토리에서 가장 최근 대화 계속
claude --resume        # 대화 선택기 열기
claude --from-pr 123   # 특정 PR에 연결된 세션 재개
```

세션 선택기 키보드 단축키:

| 단축키 | 작업 |
| --- | --- |
| `↑` / `↓` | 세션 간 이동 |
| `Enter` | 세션 선택 및 재개 |
| `P` | 세션 콘텐츠 미리보기 |
| `R` | 세션 이름 바꾸기 |
| `/` | 검색으로 세션 필터링 |
| `B` | 현재 git 브랜치의 세션으로 필터링 |

## Git worktree를 사용한 병렬 세션

Git worktree는 각각 자체 파일과 브랜치를 가지면서 동일한 저장소 기록을 공유하는 별도 작업 디렉토리를 만든다.

```shell
# "feature-auth" worktree에서 Claude 시작
claude --worktree feature-auth

# 이름 자동 생성
claude --worktree
```

- Worktree는 `<repo>/.claude/worktrees/<name>`에 생성됨
- 브랜치명: `worktree-<name>`
- **변경사항 없음**: worktree 및 브랜치 자동 제거
- **변경사항 존재**: Claude가 유지/제거 여부 물어봄

```shell
# 기본 브랜치 참조 업데이트
git remote set-head origin -a
```

`.claude/worktrees/`를 `.gitignore`에 추가하여 추적 방지.

`.worktreeinclude` 파일로 gitignored 파일(`.env` 등)을 worktree 생성 시 자동 복사:

```text
.env
.env.local
config/secrets.json
```

### subagent worktree

subagent에서 `isolation: worktree` 설정으로 병렬 작업 시 충돌 방지.

## 확장된 사고 (thinking mode)

기본적으로 활성화되어 있으며 복잡한 문제를 단계별로 추론하는 공간을 제공한다.

| 범위 | 구성 방법 |
| --- | --- |
| **노력 수준** | `/effort` 실행, `/model`에서 조정, 또는 `CLAUDE_CODE_EFFORT_LEVEL` 설정 |
| **`ultrathink` 키워드** | 프롬프트의 어디든 "ultrathink" 포함하면 해당 턴에 대해 노력을 높음으로 설정 |
| **토글 단축키** | `Option+T` (macOS) / `Alt+T` (Windows/Linux) |
| **전역 기본값** | `/config`에서 thinking mode 토글 → `alwaysThinkingEnabled`로 저장 |
| **토큰 예산 제한** | `MAX_THINKING_TOKENS` 환경 변수 |

- `Ctrl+O`로 자세한 모드 전환 → 회색 이탤릭 텍스트로 내부 추론 확인
- "think", "think hard", "think more"는 사고 토큰을 할당하지 않음 (일반 프롬프트로 해석됨)

### 사고 요약 표시 (`showThinkingSummaries`)

대화형 모드에서 사고는 기본적으로 **축소된 스텁**으로 표시된다. `settings.json`에서 `showThinkingSummaries: true`를 설정하면 전체 요약이 보인다.

```json
// .claude/settings.json
{
  "showThinkingSummaries": true
}
```

> 사고 요약이 축소되더라도 사용된 모든 사고 토큰에 대해 요금이 청구된다.

## Claude를 unix 스타일 유틸리티로 사용하기

### 빌드 스크립트에 Claude 추가하기

```json
// package.json
{
  "scripts": {
    "lint:claude": "claude -p 'you are a linter. please look at the changes vs. main and report any issues related to typos. report the filename and line number on one line, and a description of the issue on the second line. do not return any other text.'"
  }
}
```

### 파이프 인, 파이프 아웃

```shell
cat build-error.txt | claude -p 'concisely explain the root cause of this build error' > output.txt
```

### 출력 형식 제어

- `--output-format text`: 간단한 통합
- `--output-format json`: 전체 대화 로그
- `--output-format stream-json`: 각 대화 턴의 실시간 출력

## 예약 작업으로 Claude 실행하기

| 옵션 | 실행 위치 | 최적 사용 |
| --- | --- | --- |
| 클라우드 예약 작업 | Anthropic 관리 인프라 | 컴퓨터가 꺼져 있어도 실행되어야 하는 작업 |
| 데스크톱 예약 작업 | 데스크톱 앱 통해 컴퓨터 | 로컬 파일·도구에 직접 접근이 필요한 작업 |
| GitHub Actions | CI 파이프라인 | 저장소 이벤트와 연결된 작업 |
| `/loop` | 현재 CLI 세션 | 세션이 열려 있는 동안 빠른 폴링 |

## 관련 항목

- [[wiki/ai/claude-code/claude-code-작동방식-에이전트하네스]]
- [[wiki/ai/claude-code/claude-code-모범사례]]
- [[wiki/ai/claude-code/claude-code-컨텍스트윈도우]]
