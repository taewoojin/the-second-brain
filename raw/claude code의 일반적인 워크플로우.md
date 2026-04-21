---
title: "일반적인 워크플로우"
source: "https://code.claude.com/docs/ko/common-workflows"
author:
published:
created: 2026-04-17
description: "Claude Code를 사용하여 코드베이스 탐색, 버그 수정, 리팩토링, 테스트 및 기타 일상적인 작업을 위한 단계별 가이드입니다."
tags:
  - "clippings"
---
이 페이지는 일상적인 개발을 위한 실용적인 워크플로우를 다룹니다: 낯선 코드 탐색, 디버깅, 리팩토링, 테스트 작성, PR 생성 및 세션 관리. 각 섹션에는 자신의 프로젝트에 맞게 조정할 수 있는 예제 프롬프트가 포함되어 있습니다. 더 높은 수준의 패턴과 팁은 [모범 사례](https://code.claude.com/docs/ko/best-practices) 를 참조하십시오.

## 새로운 코드베이스 이해하기

### 코드베이스의 빠른 개요 얻기

새로운 프로젝트에 방금 참여했고 그 구조를 빠르게 이해해야 한다고 가정해봅시다.

팁:

- 광범위한 질문으로 시작한 다음 특정 영역으로 좁혀나가기
- 프로젝트에서 사용되는 코딩 규칙과 패턴에 대해 질문하기
- 프로젝트별 용어의 용어집 요청하기

### 관련 코드 찾기

특정 기능이나 기능과 관련된 코드를 찾아야 한다고 가정해봅시다.

팁:

- 찾고 있는 것에 대해 구체적으로 설명하기
- 프로젝트의 도메인 언어 사용하기
- 언어에 대한 [코드 인텔리전스 플러그인](https://code.claude.com/docs/ko/discover-plugins#code-intelligence) 을 설치하여 Claude에게 정확한 “정의로 이동” 및 “참조 찾기” 네비게이션 제공하기

---

## 효율적으로 버그 수정하기

오류 메시지가 나타났고 그 원인을 찾아 수정해야 한다고 가정해봅시다.

팁:

- Claude에게 문제를 재현하는 명령과 스택 추적을 알려주기
- 오류를 재현하는 단계 언급하기
- 오류가 간헐적인지 일관적인지 Claude에게 알려주기

---

## 코드 리팩토링

오래된 코드를 최신 패턴과 관행을 사용하도록 업데이트해야 한다고 가정해봅시다.

팁:

- Claude에게 최신 접근 방식의 이점을 설명하도록 요청하기
- 필요할 때 변경사항이 하위 호환성을 유지하도록 요청하기
- 작고 테스트 가능한 증분으로 리팩토링 수행하기

---

## 특화된 subagent 사용하기

특정 작업을 더 효과적으로 처리하기 위해 특화된 AI subagent를 사용하고 싶다고 가정해봅시다.

팁:

- 팀 공유를 위해 `.claude/agents/` 에 프로젝트별 subagent 만들기
- 자동 위임을 활성화하기 위해 설명적인 `description` 필드 사용하기
- 각 subagent가 실제로 필요한 것으로 도구 액세스 제한하기
- 자세한 예제는 [subagent 문서](https://code.claude.com/docs/ko/sub-agents) 를 확인하기

---

## Plan Mode를 사용하여 안전한 코드 분석

Plan Mode는 Claude에게 읽기 전용 작업으로 코드베이스를 분석하여 계획을 세우도록 지시하며, 코드베이스 탐색, 복잡한 변경 계획 또는 코드 안전한 검토에 완벽합니다. Plan Mode에서 Claude는 [`AskUserQuestion`](https://code.claude.com/docs/ko/tools-reference) 을 사용하여 계획을 제안하기 전에 요구사항을 수집하고 목표를 명확히 합니다.

### Plan Mode를 사용할 때

- **다단계 구현**: 기능이 많은 파일을 편집해야 할 때
- **코드 탐색**: 무엇이든 변경하기 전에 코드베이스를 철저히 조사하고 싶을 때
- **대화형 개발**: Claude와 방향을 반복하고 싶을 때

### Plan Mode 사용 방법

**세션 중에 Plan Mode 켜기**

**Shift+Tab** 을 사용하여 세션 중에 Plan Mode로 전환할 수 있습니다.

Normal Mode에 있으면 **Shift+Tab** 은 먼저 Auto-Accept Mode로 전환되며, 터미널 하단에 `⏵⏵ accept edits on` 으로 표시됩니다. 그 다음 **Shift+Tab** 은 Plan Mode로 전환되며, `⏸ plan mode on` 으로 표시됩니다.

**Plan Mode에서 새 세션 시작하기**

Plan Mode에서 새 세션을 시작하려면 `--permission-mode plan` 플래그를 사용합니다:

```shellscript
claude --permission-mode plan
```

**Plan Mode에서 “헤드리스” 쿼리 실행하기**

`-p` 를 사용하여 Plan Mode에서 직접 쿼리를 실행할 수도 있습니다 (즉, [“헤드리스 모드”](https://code.claude.com/docs/ko/headless) 에서):

```shellscript
claude --permission-mode plan -p "Analyze the authentication system and suggest improvements"
```

### 예제: 복잡한 리팩토링 계획하기

```shellscript
claude --permission-mode plan
```

```text
I need to refactor our authentication system to use OAuth2. Create a detailed migration plan.
```

Claude는 현재 구현을 분석하고 포괄적인 계획을 만듭니다. 후속 질문으로 정제합니다:

```text
What about backward compatibility?
```

```text
How should we handle database migration?
```

`Ctrl+G` 를 눌러 기본 텍스트 편집기에서 계획을 열고, Claude가 진행하기 전에 직접 편집할 수 있습니다.

계획을 수락하면 Claude는 계획 콘텐츠에서 자동으로 세션 이름을 지정합니다. 이름은 프롬프트 바와 세션 선택기에 나타납니다. 이미 `--name` 또는 `/rename` 으로 이름을 설정한 경우 계획을 수락해도 덮어쓰지 않습니다.

### Plan Mode를 기본값으로 구성하기

```json
// .claude/settings.json
{
  "permissions": {
    "defaultMode": "plan"
  }
}
```

더 많은 구성 옵션은 [설정 문서](https://code.claude.com/docs/ko/settings#available-settings) 를 참조하십시오.

---

## 테스트 작업하기

적용되지 않은 코드에 대한 테스트를 추가해야 한다고 가정해봅시다.

Claude는 프로젝트의 기존 패턴과 규칙을 따르는 테스트를 생성할 수 있습니다. 테스트를 요청할 때 검증하려는 동작에 대해 구체적으로 설명하십시오. Claude는 기존 테스트 파일을 검토하여 이미 사용 중인 스타일, 프레임워크 및 어설션 패턴을 일치시킵니다.

포괄적인 적용 범위를 위해 Claude에게 놓쳤을 수 있는 엣지 케이스를 식별하도록 요청하십시오. Claude는 코드 경로를 분석하고 오류 조건, 경계값 및 쉽게 간과할 수 있는 예상치 못한 입력에 대한 테스트를 제안할 수 있습니다.

---

## 풀 요청 만들기

Claude에게 직접 풀 요청을 만들도록 요청하거나 (“create a pr for my changes”), 단계별로 Claude를 안내할 수 있습니다:

`gh pr create` 를 사용하여 PR을 만들면 세션이 자동으로 해당 PR에 연결됩니다. 나중에 `claude --from-pr <number>` 로 재개할 수 있습니다.

Claude가 생성한 PR을 제출하기 전에 검토하고 Claude에게 잠재적 위험이나 고려사항을 강조하도록 요청하십시오.

## 문서 처리하기

코드에 대한 문서를 추가하거나 업데이트해야 한다고 가정해봅시다.

팁:

- 원하는 문서 스타일 지정하기 (JSDoc, docstring 등)
- 문서에 예제 요청하기
- 공개 API, 인터페이스 및 복잡한 로직에 대한 문서 요청하기

---

## 이미지 작업하기

코드베이스에서 이미지를 작업해야 하고 Claude의 이미지 콘텐츠 분석 도움을 원한다고 가정해봅시다.

팁:

- 텍스트 설명이 불명확하거나 번거로울 때 이미지 사용하기
- 더 나은 컨텍스트를 위해 오류, UI 디자인 또는 다이어그램의 스크린샷 포함하기
- 대화에서 여러 이미지를 작업할 수 있습니다
- 이미지 분석은 다이어그램, 스크린샷, 목업 등과 함께 작동합니다
- Claude가 이미지를 참조할 때 (예: `[Image #1]`), `Cmd+Click` (Mac) 또는 `Ctrl+Click` (Windows/Linux)을 클릭하여 기본 뷰어에서 이미지를 엽니다

---

## 파일 및 디렉토리 참조하기

@를 사용하여 Claude가 읽을 때까지 기다리지 않고 파일이나 디렉토리를 빠르게 포함합니다.

팁:

- 파일 경로는 상대 또는 절대 경로일 수 있습니다
- @ 파일 참조는 파일의 디렉토리 및 상위 디렉토리에 `CLAUDE.md` 를 추가합니다
- 디렉토리 참조는 내용이 아닌 파일 목록을 표시합니다
- 단일 메시지에서 여러 파일을 참조할 수 있습니다 (예: “@file1.js and @file2.js”)

---

## 확장된 사고 사용하기 (thinking mode)

[확장된 사고](https://platform.claude.com/docs/en/build-with-claude/extended-thinking) 는 기본적으로 활성화되어 있으며, Claude가 복잡한 문제를 단계별로 추론할 수 있는 공간을 제공합니다. 이 추론은 `Ctrl+O` 로 전환할 수 있는 자세한 모드에서 볼 수 있습니다.

또한 Opus 4.6 및 Sonnet 4.6은 적응형 추론을 지원합니다: 고정된 사고 토큰 예산 대신 모델은 [노력 수준](https://code.claude.com/docs/ko/model-config#adjust-effort-level) 설정에 따라 동적으로 사고를 할당합니다. 확장된 사고와 적응형 추론은 함께 작동하여 Claude가 응답하기 전에 얼마나 깊이 있게 추론할지 제어할 수 있습니다.

확장된 사고는 복잡한 아키텍처 결정, 어려운 버그, 다단계 구현 계획 및 다양한 접근 방식 간의 트레이드오프 평가에 특히 유용합니다.

“think”, “think hard”, “think more”와 같은 구문은 일반 프롬프트 지시로 해석되며 사고 토큰을 할당하지 않습니다.

### thinking mode 구성하기

사고는 기본적으로 활성화되어 있지만 조정하거나 비활성화할 수 있습니다.

| 범위 | 구성 방법 | 세부 정보 |
| --- | --- | --- |
| **노력 수준** | `/effort` 실행, `/model` 에서 조정, 또는 [`CLAUDE_CODE_EFFORT_LEVEL`](https://code.claude.com/docs/ko/env-vars) 설정 | Opus 4.6 및 Sonnet 4.6에 대한 사고 깊이 제어. [노력 수준 조정](https://code.claude.com/docs/ko/model-config#adjust-effort-level) 참조 |
| **`ultrathink` 키워드** | 프롬프트의 어디든 “ultrathink” 포함 | Opus 4.6 및 Sonnet 4.6에서 해당 턴에 대해 노력을 높음으로 설정합니다. 설정을 영구적으로 변경하지 않고 깊은 추론이 필요한 일회성 작업에 유용합니다 |
| **토글 단축키** | `Option+T` (macOS) 또는 `Alt+T` (Windows/Linux) 누르기 | 현재 세션에 대해 사고 켜기/끄기 (모든 모델). [터미널 구성](https://code.claude.com/docs/ko/terminal-config) 이 필요할 수 있습니다 |
| **전역 기본값** | `/config` 를 사용하여 thinking mode 토글 | 모든 프로젝트에서 기본값 설정 (모든 모델).   `~/.claude/settings.json` 에 `alwaysThinkingEnabled` 로 저장됩니다 |
| **토큰 예산 제한** | [`MAX_THINKING_TOKENS`](https://code.claude.com/docs/ko/env-vars) 환경 변수 설정 | 사고 예산을 특정 토큰 수로 제한합니다. Opus 4.6 및 Sonnet 4.6에서 적응형 추론이 비활성화되지 않으면 0으로 설정하지 않으면 무시됩니다. 예: `export MAX_THINKING_TOKENS=10000` |

Claude의 사고 과정을 보려면 `Ctrl+O` 를 눌러 자세한 모드를 전환하고 회색 이탤릭 텍스트로 표시된 내부 추론을 확인하십시오.

### 확장된 사고 작동 방식

확장된 사고는 Claude가 응답하기 전에 수행하는 내부 추론의 양을 제어합니다. 더 많은 사고는 솔루션을 탐색하고, 엣지 케이스를 분석하고, 실수를 자체 수정할 수 있는 더 많은 공간을 제공합니다.

**Opus 4.6 및 Sonnet 4.6의 경우**, 사고는 적응형 추론을 사용합니다: 모델은 선택한 [노력 수준](https://code.claude.com/docs/ko/model-config#adjust-effort-level) 에 따라 동적으로 사고 토큰을 할당합니다. 이것은 속도와 추론 깊이 간의 트레이드오프를 조정하는 권장 방법입니다.

**다른 모델의 경우**, 사고는 출력 할당에서 최대 31,999개 토큰의 고정 예산을 사용합니다. [`MAX_THINKING_TOKENS`](https://code.claude.com/docs/ko/env-vars) 환경 변수로 이를 제한하거나 `/config` 또는 `Option+T` / `Alt+T` 토글을 통해 사고를 완전히 비활성화할 수 있습니다.

Opus 4.6 및 Sonnet 4.6에서 [적응형 추론](https://code.claude.com/docs/ko/model-config#adjust-effort-level) 이 사고 깊이를 제어하므로 `MAX_THINKING_TOKENS` 는 0으로 설정하여 사고를 비활성화하거나 `CLAUDE_CODE_DISABLE_ADAPTIVE_THINKING=1` 이 이러한 모델을 고정 예산으로 되돌릴 때만 적용됩니다. [환경 변수](https://code.claude.com/docs/ko/env-vars) 를 참조하십시오.

사고 요약이 편집되더라도 사용된 모든 사고 토큰에 대해 요금이 청구됩니다. 대화형 모드에서 사고는 기본적으로 축소된 스텁으로 나타납니다. `settings.json` 에서 `showThinkingSummaries: true` 를 설정하여 전체 요약을 표시합니다.

---

## 이전 대화 재개하기

Claude Code를 시작할 때 이전 세션을 재개할 수 있습니다:

- `claude --continue` 는 현재 디렉토리에서 가장 최근 대화를 계속합니다
- `claude --resume` 은 대화 선택기를 열거나 이름으로 재개합니다
- `claude --from-pr 123` 은 특정 풀 요청에 연결된 세션을 재개합니다

활성 세션 내에서 `/resume` 을 사용하여 다른 대화로 전환합니다.

세션은 프로젝트 디렉토리별로 저장됩니다. `/resume` 선택기는 worktree를 포함한 동일한 git 저장소의 대화형 세션을 표시합니다. `claude -p` 또는 SDK 호출로 생성된 세션은 선택기에 나타나지 않지만 세션 ID를 `claude --resume <session-id>` 에 직접 전달하여 재개할 수 있습니다.

### 세션 이름 지정하기

나중에 찾기 위해 세션에 설명적인 이름을 지정합니다. 이것은 여러 작업이나 기능을 작업할 때 모범 사례입니다.

### 세션 선택기 사용하기

`/resume` 명령 (또는 인수 없이 `claude --resume`)은 다음 기능이 있는 대화형 세션 선택기를 엽니다:

**선택기의 키보드 단축키:**

| 단축키 | 작업 |
| --- | --- |
| `↑` / `↓` | 세션 간 이동 |
| `→` / `←` | 그룹화된 세션 확장 또는 축소 |
| `Enter` | 강조 표시된 세션 선택 및 재개 |
| `P` | 세션 콘텐츠 미리보기 |
| `R` | 강조 표시된 세션 이름 바꾸기 |
| `/` | 검색하여 세션 필터링 |
| `A` | 현재 디렉토리와 모든 프로젝트 간 전환 |
| `B` | 현재 git 분기의 세션으로 필터링 |
| `Esc` | 선택기 또는 검색 모드 종료 |

**세션 구성:**

선택기는 유용한 메타데이터가 있는 세션을 표시합니다:

- 세션 이름 또는 초기 프롬프트
- 마지막 활동 이후 경과 시간
- 메시지 수
- Git 분기 (해당하는 경우)

포크된 세션 (`/branch`, `/rewind` 또는 `--fork-session` 으로 생성됨)은 루트 세션 아래에 그룹화되어 관련 대화를 더 쉽게 찾을 수 있습니다.

팁:

- **세션 조기 이름 지정**: 고유한 작업을 시작할 때 `/rename` 을 사용합니다—나중에 “explain this function”보다 “payment-integration”을 찾기가 훨씬 쉽습니다
- 현재 디렉토리에서 가장 최근 대화에 빠르게 액세스하려면 `--continue` 사용
- 필요한 세션을 알 때 `--resume session-name` 사용
- 검색하고 선택해야 할 때 `--resume` (이름 없이) 사용
- 스크립트의 경우 `claude --continue --print "prompt"` 를 사용하여 비대화형 모드에서 재개
- 선택기에서 `P` 를 눌러 재개하기 전에 세션을 미리봅니다
- 재개된 대화는 원본과 동일한 모델 및 구성으로 시작됩니다

작동 방식:

1. **대화 저장소**: 모든 대화는 전체 메시지 기록과 함께 로컬에 자동으로 저장됩니다
2. **메시지 역직렬화**: 재개할 때 전체 메시지 기록이 복원되어 컨텍스트를 유지합니다
3. **도구 상태**: 이전 대화의 도구 사용 및 결과가 보존됩니다
4. **컨텍스트 복원**: 대화는 모든 이전 컨텍스트와 함께 재개됩니다

---

## Git worktree를 사용하여 병렬 Claude Code 세션 실행하기

여러 작업을 동시에 수행할 때 각 Claude 세션이 변경사항이 충돌하지 않도록 코드베이스의 자체 복사본을 가져야 합니다. Git worktree는 각각 자체 파일과 분기를 가지면서 동일한 저장소 기록 및 원격 연결을 공유하는 별도의 작업 디렉토리를 만들어 이를 해결합니다. 이는 한 worktree에서 기능을 작업하는 동안 Claude가 다른 worktree에서 버그를 수정할 수 있으며, 어느 세션도 다른 세션을 방해하지 않음을 의미합니다.

`--worktree` (`-w`) 플래그를 사용하여 격리된 worktree를 만들고 Claude를 시작합니다. 전달하는 값은 worktree 디렉토리 이름과 분기 이름이 됩니다:

```shellscript
# "feature-auth"라는 worktree에서 Claude 시작
# 새 분기를 사용하여 .claude/worktrees/feature-auth/ 생성
claude --worktree feature-auth

# 별도의 worktree에서 다른 세션 시작
claude --worktree bugfix-123
```

이름을 생략하면 Claude가 자동으로 임의의 이름을 생성합니다:

```shellscript
# "bright-running-fox"와 같은 이름 자동 생성
claude --worktree
```

Worktree는 `<repo>/.claude/worktrees/<name>` 에 생성되고 기본 원격 분기에서 분기됩니다. worktree 분기는 `worktree-<name>` 으로 이름이 지정됩니다.

기본 분기는 Claude Code 플래그 또는 설정을 통해 구성할 수 없습니다. `origin/HEAD` 는 복제할 때 Git이 설정한 로컬 `.git` 디렉토리에 저장된 참조입니다. 저장소의 기본 분기가 나중에 GitHub 또는 GitLab에서 변경되면 로컬 `origin/HEAD` 는 이전 분기를 계속 가리키며, worktree는 거기에서 분기됩니다. 로컬 참조를 원격이 현재 기본값으로 간주하는 것과 다시 동기화하려면:

```shellscript
git remote set-head origin -a
```

이것은 로컬 `.git` 디렉토리만 업데이트하는 표준 Git 명령입니다. 원격 서버에서는 아무것도 변경되지 않습니다. worktree가 원격의 기본값이 아닌 특정 분기에서 기반하도록 하려면 `git remote set-head origin your-branch-name` 으로 명시적으로 설정합니다.

worktree 생성 방식을 완전히 제어하려면 호출당 다른 기반을 선택하는 것을 포함하여 [WorktreeCreate hook](https://code.claude.com/docs/ko/hooks#worktreecreate) 을 구성합니다. hook은 Claude Code의 기본 `git worktree` 로직을 완전히 대체하므로 필요한 모든 ref에서 가져오고 분기할 수 있습니다.

세션 중에 Claude에게 “work in a worktree” 또는 “start a worktree”를 요청할 수도 있으며, 자동으로 하나를 만듭니다.

### Subagent worktree

Subagent도 worktree 격리를 사용하여 충돌 없이 병렬로 작업할 수 있습니다. Claude에게 “use worktrees for your agents”를 요청하거나 [사용자 정의 subagent](https://code.claude.com/docs/ko/sub-agents#supported-frontmatter-fields) 에서 에이전트의 frontmatter에 `isolation: worktree` 를 추가하여 구성합니다. 각 subagent는 변경사항 없이 완료될 때 자동으로 정리되는 자체 worktree를 가져옵니다.

### Worktree 정리

worktree 세션을 종료할 때 Claude는 변경사항이 있는지 여부에 따라 정리를 처리합니다:

- **변경사항 없음**: worktree 및 해당 분기가 자동으로 제거됩니다
- **변경사항 또는 커밋 존재**: Claude는 worktree를 유지할지 제거할지 묻습니다. 유지하면 디렉토리와 분기가 보존되어 나중에 돌아올 수 있습니다. 제거하면 worktree 디렉토리와 해당 분기가 삭제되어 모든 커밋되지 않은 변경사항과 커밋이 버려집니다

Claude 세션 외부에서 worktree를 정리하려면 [수동 worktree 관리](#manage-worktrees-manually) 를 사용합니다.

`.claude/worktrees/` 를 `.gitignore` 에 추가하여 worktree 콘텐츠가 주 저장소에 추적되지 않은 파일로 나타나지 않도록 합니다.

### Worktree에 gitignored 파일 복사하기

Git worktree는 새로운 체크아웃이므로 주 저장소의 `.env` 또는 `.env.local` 과 같은 추적되지 않은 파일을 포함하지 않습니다. Claude가 worktree를 만들 때 이러한 파일을 자동으로 복사하려면 프로젝트 루트에 `.worktreeinclude` 파일을 추가합니다.

파일은 `.gitignore` 구문을 사용하여 복사할 파일을 나열합니다. 패턴과 일치하고 gitignored인 파일만 복사되므로 추적된 파일은 절대 복제되지 않습니다.

```text
.env
.env.local
config/secrets.json
```

이것은 `--worktree`, subagent worktree 및 [데스크톱 앱](https://code.claude.com/docs/ko/desktop#work-in-parallel-with-sessions) 의 병렬 세션으로 생성된 worktree에 적용됩니다.

### 수동으로 worktree 관리하기

worktree 위치 및 분기 구성을 더 제어하려면 Git을 사용하여 직접 worktree를 만듭니다. 특정 기존 분기를 체크아웃하거나 worktree를 저장소 외부에 배치해야 할 때 유용합니다.

```shellscript
# 새 분기를 사용하여 worktree 만들기
git worktree add ../project-feature-a -b feature-a

# 기존 분기를 사용하여 worktree 만들기
git worktree add ../project-bugfix bugfix-123

# worktree에서 Claude 시작
cd ../project-feature-a && claude

# 완료되면 정리
git worktree list
git worktree remove ../project-feature-a
```

[공식 Git worktree 문서](https://git-scm.com/docs/git-worktree) 에서 자세히 알아봅니다.

프로젝트의 설정에 따라 각 새 worktree에서 개발 환경을 초기화해야 합니다. 스택에 따라 여기에는 종속성 설치 (`npm install`, `yarn`), 가상 환경 설정 또는 프로젝트의 표준 설정 프로세스 따르기가 포함될 수 있습니다.

### 비 git 버전 제어

Worktree 격리는 기본적으로 git과 함께 작동합니다. SVN, Perforce 또는 Mercurial과 같은 다른 버전 제어 시스템의 경우 [WorktreeCreate 및 WorktreeRemove hook](https://code.claude.com/docs/ko/hooks#worktreecreate) 을 구성하여 사용자 정의 worktree 생성 및 정리 로직을 제공합니다. 구성되면 이러한 hook은 `--worktree` 를 사용할 때 기본 git 동작을 대체하므로 [`.worktreeinclude`](#copy-gitignored-files-to-worktrees) 는 처리되지 않습니다. hook 스크립트 내에서 대신 로컬 구성 파일을 복사합니다.

공유 작업 및 메시징을 사용한 병렬 세션의 자동 조정을 위해 [에이전트 팀](https://code.claude.com/docs/ko/agent-teams) 을 참조하십시오.

---

## Claude가 주의가 필요할 때 알림 받기

장기 실행 작업을 시작하고 다른 창으로 전환할 때 Claude가 완료되거나 입력이 필요할 때 알 수 있도록 데스크톱 알림을 설정할 수 있습니다. 이것은 Claude가 권한을 기다리거나, 유휴 상태이고 새 프롬프트를 기다리거나, 인증을 완료할 때마다 발생하는 `Notification` [hook 이벤트](https://code.claude.com/docs/ko/hooks-guide#get-notified-when-claude-needs-input) 를 사용합니다.

전체 이벤트 스키마 및 알림 유형은 [알림 참조](https://code.claude.com/docs/ko/hooks#notification) 를 참조하십시오.

---

## Claude를 unix 스타일 유틸리티로 사용하기

### 검증 프로세스에 Claude 추가하기

Claude Code를 linter 또는 코드 검토자로 사용하고 싶다고 가정해봅시다.

**빌드 스크립트에 Claude 추가하기:**

```json
// package.json
{
    ...
    "scripts": {
        ...
        "lint:claude": "claude -p 'you are a linter. please look at the changes vs. main and report any issues related to typos. report the filename and line number on one line, and a description of the issue on the second line. do not return any other text.'"
    }
}
```

팁:

- CI/CD 파이프라인에서 자동 코드 검토를 위해 Claude 사용
- 프로젝트와 관련된 특정 문제를 확인하도록 프롬프트 사용자 정의
- 다양한 유형의 검증을 위해 여러 스크립트 만들기 고려

### 파이프 인, 파이프 아웃

Claude로 데이터를 파이프하고 구조화된 형식으로 데이터를 다시 받고 싶다고 가정해봅시다.

**Claude를 통해 데이터 파이프하기:**

```shellscript
cat build-error.txt | claude -p 'concisely explain the root cause of this build error' > output.txt
```

팁:

- 기존 셸 스크립트에 Claude를 통합하기 위해 파이프 사용
- 강력한 워크플로우를 위해 다른 Unix 도구와 결합
- 스크립트나 다른 도구에 Claude Code를 통합할 때 `--output-format` 사용 고려

### 출력 형식 제어하기

특히 Claude Code를 스크립트나 다른 도구에 통합할 때 특정 형식의 Claude 출력이 필요하다고 가정해봅시다.

팁:

- Claude의 응답만 필요한 간단한 통합을 위해 `--output-format text` 사용
- 전체 대화 로그가 필요할 때 `--output-format json` 사용
- 각 대화 턴의 실시간 출력을 위해 `--output-format stream-json` 사용

---

## Claude를 일정에 따라 실행하기

Claude가 정기적으로 작업을 자동으로 처리하도록 하고 싶다고 가정해봅시다. 예를 들어 매일 아침 열린 PR을 검토하거나, 매주 종속성을 감사하거나, 밤새 CI 실패를 확인합니다.

작업을 실행할 위치에 따라 일정 옵션을 선택합니다:

| 옵션 | 실행 위치 | 최적 사용 |
| --- | --- | --- |
| [클라우드 예약 작업](https://code.claude.com/docs/ko/web-scheduled-tasks) | Anthropic 관리 인프라 | 컴퓨터가 꺼져 있어도 실행되어야 하는 작업. [claude.ai/code](https://claude.ai/code) 에서 구성합니다. |
| [데스크톱 예약 작업](https://code.claude.com/docs/ko/desktop#schedule-recurring-tasks) | 데스크톱 앱을 통한 컴퓨터 | 로컬 파일, 도구 또는 커밋되지 않은 변경사항에 직접 액세스해야 하는 작업. |
| [GitHub Actions](https://code.claude.com/docs/ko/github-actions) | CI 파이프라인 | 열린 PR 또는 cron 일정과 같은 저장소 이벤트와 연결된 작업. 워크플로우 구성과 함께 있어야 합니다. |
| [`/loop`](https://code.claude.com/docs/ko/scheduled-tasks) | 현재 CLI 세션 | 세션이 열려 있는 동안 빠른 폴링. 종료하면 작업이 취소됩니다. |

예약된 작업을 위한 프롬프트를 작성할 때 성공이 무엇인지, 결과를 어떻게 처리할지 명시적으로 설명하십시오. 작업이 자동으로 실행되므로 명확한 질문을 할 수 없습니다. 예를 들어: “Review open PRs labeled `needs-review`, leave inline comments on any issues, and post a summary in the `#eng-reviews` Slack channel.”

---

## Claude의 기능에 대해 Claude에게 물어보기

Claude는 자신의 문서에 대한 기본 제공 액세스 권한을 가지고 있으며 자신의 기능과 제한사항에 대한 질문에 답할 수 있습니다.

### 예제 질문

```text
can Claude Code create pull requests?
```

```text
how does Claude Code handle permissions?
```

```text
what skills are available?
```

```text
how do I use MCP with Claude Code?
```

```text
how do I configure Claude Code for Amazon Bedrock?
```

```text
what are the limitations of Claude Code?
```

Claude는 이러한 질문에 대해 문서 기반 답변을 제공합니다. 실행 가능한 예제 및 실습 시연을 위해 위의 특정 워크플로우 섹션을 참조하십시오.

팁:

- Claude는 사용 중인 버전에 관계없이 항상 최신 Claude Code 문서에 액세스할 수 있습니다
- 자세한 답변을 얻으려면 구체적인 질문을 하십시오
- Claude는 MCP 통합, 엔터프라이즈 구성 및 고급 워크플로우와 같은 복잡한 기능을 설명할 수 있습니다

---

## 다음 단계

## [모범 사례](https://code.claude.com/docs/ko/best-practices)

Claude Code에서 최대한 활용하기 위한 패턴

## [Claude Code 작동 방식](https://code.claude.com/docs/ko/how-claude-code-works)

에이전트 루프 및 컨텍스트 관리 이해하기

## [Claude Code 확장하기](https://code.claude.com/docs/ko/features-overview)

skill, hook, MCP, subagent 및 플러그인 추가하기

## [참조 구현](https://github.com/anthropics/claude-code/tree/main/.devcontainer)

개발 컨테이너 참조 구현 복제하기