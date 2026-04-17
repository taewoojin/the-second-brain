---
title: "Claude Code 모범 사례"
source: "https://code.claude.com/docs/ko/best-practices"
author:
published:
created: 2026-04-17
description: "환경 구성부터 병렬 세션 확장까지 Claude Code를 최대한 활용하기 위한 팁과 패턴입니다."
tags:
  - "clippings"
---
Claude Code는 에이전트 코딩 환경입니다. 질문에 답하고 기다리는 챗봇과 달리 Claude Code는 파일을 읽고, 명령을 실행하고, 변경을 수행하며, 당신이 지켜보거나 방향을 바꾸거나 완전히 떠나 있는 동안에도 자율적으로 문제를 해결할 수 있습니다.

이는 작업 방식을 바꿉니다. 직접 코드를 작성하고 Claude에게 검토를 요청하는 대신, 원하는 것을 설명하면 Claude가 어떻게 구축할지 파악합니다. Claude는 탐색하고, 계획하고, 구현합니다.

하지만 이러한 자율성에도 학습 곡선이 있습니다. Claude는 이해해야 할 특정 제약 조건 내에서 작동합니다.

이 가이드는 Anthropic의 내부 팀과 다양한 코드베이스, 언어, 환경에서 Claude Code를 사용하는 엔지니어들 사이에서 효과적으로 입증된 패턴을 다룹니다. 에이전트 루프가 내부적으로 어떻게 작동하는지에 대해서는 [Claude Code 작동 방식](https://code.claude.com/docs/ko/how-claude-code-works) 을 참조하십시오.

---

대부분의 모범 사례는 하나의 제약 조건을 기반으로 합니다: Claude의 context window가 빠르게 채워지고, 채워질수록 성능이 저하됩니다.

Claude의 context window는 모든 메시지, Claude가 읽은 모든 파일, 모든 명령 출력을 포함한 전체 대화를 보유합니다. 그러나 이는 빠르게 채워질 수 있습니다. 단일 디버깅 세션이나 코드베이스 탐색만으로도 수만 개의 토큰을 생성하고 소비할 수 있습니다.

LLM 성능이 context가 채워질수록 저하되기 때문에 이는 중요합니다. context window가 거의 가득 차면 Claude는 이전 지시사항을 “잊기” 시작하거나 더 많은 실수를 할 수 있습니다. context window는 관리해야 할 가장 중요한 리소스입니다. [사용자 정의 상태 줄](https://code.claude.com/docs/ko/statusline) 로 context 사용량을 지속적으로 추적하고, [토큰 사용량 감소](https://code.claude.com/docs/ko/costs#reduce-token-usage) 에서 토큰 사용량을 줄이기 위한 전략을 참조하십시오.

---

## Claude에게 작업을 검증할 방법 제공하기

Claude가 자신의 작업을 확인할 수 있도록 테스트, 스크린샷 또는 예상 출력을 포함하십시오. 이것이 할 수 있는 가장 높은 영향력의 단일 작업입니다.

Claude는 테스트를 실행하고, 스크린샷을 비교하고, 출력을 검증하는 등 자신의 작업을 검증할 수 있을 때 훨씬 더 잘 수행합니다.

명확한 성공 기준이 없으면 올바르게 보이지만 실제로는 작동하지 않는 것을 생성할 수 있습니다. 당신이 유일한 피드백 루프가 되고, 모든 실수가 당신의 주의를 필요로 합니다.

| 전략 | 이전 | 이후 |
| --- | --- | --- |
| **검증 기준 제공** | *”이메일 주소를 검증하는 함수를 구현하세요"* | *"validateEmail 함수를 작성하세요. 예제 테스트 케이스: [user@example.com](mailto:user@example.com) 은 true, invalid는 false, [user@.com](mailto:user@.com) 은 false입니다. 구현 후 테스트를 실행하세요”* |
| **UI 변경 사항을 시각적으로 검증** | *”대시보드를 더 좋게 보이게 하세요"* | *"\[스크린샷 붙여넣기\] 이 디자인을 구현하세요. 결과의 스크린샷을 찍고 원본과 비교하세요. 차이점을 나열하고 수정하세요”* |
| **증상이 아닌 근본 원인 해결** | *”빌드가 실패하고 있습니다"* | *"빌드가 이 오류로 실패합니다: \[오류 붙여넣기\]. 수정하고 빌드가 성공하는지 확인하세요. 근본 원인을 해결하고 오류를 억제하지 마세요”* |

UI 변경 사항은 [Chrome 확장 프로그램의 Claude](https://code.claude.com/docs/ko/chrome) 를 사용하여 검증할 수 있습니다. 브라우저에서 새 탭을 열고, UI를 테스트하고, 코드가 작동할 때까지 반복합니다.

검증은 테스트 스위트, linter 또는 출력을 확인하는 Bash 명령일 수도 있습니다. 검증을 견고하게 만드는 데 투자하십시오.

---

## 먼저 탐색하고, 그 다음 계획하고, 그 다음 코드 작성하기

연구 및 계획을 구현과 분리하여 잘못된 문제를 해결하는 것을 피하십시오.

Claude가 바로 코딩으로 뛰어들도록 하면 잘못된 문제를 해결하는 코드가 생성될 수 있습니다. [Plan Mode](https://code.claude.com/docs/ko/common-workflows#use-plan-mode-for-safe-code-analysis) 를 사용하여 탐색을 실행과 분리하십시오.

권장 워크플로우에는 4가지 단계가 있습니다:

Plan Mode는 유용하지만 오버헤드도 추가합니다.

범위가 명확하고 수정이 작은 작업(예: 오타 수정, 로그 줄 추가 또는 변수 이름 바꾸기)의 경우 Claude에게 직접 수행하도록 요청하십시오.

계획은 접근 방식이 불확실할 때, 변경이 여러 파일을 수정할 때, 또는 수정 중인 코드에 익숙하지 않을 때 가장 유용합니다. diff를 한 문장으로 설명할 수 있다면 계획을 건너뛰십시오.

---

## 프롬프트에서 구체적인 컨텍스트 제공하기

지시사항이 정확할수록 필요한 수정이 적습니다.

Claude는 의도를 추론할 수 있지만 마음을 읽을 수는 없습니다. 특정 파일을 참조하고, 제약 조건을 언급하고, 예제 패턴을 지적하십시오.

| 전략 | 이전 | 이후 |
| --- | --- | --- |
| **작업 범위 지정.** 어떤 파일, 어떤 시나리오, 테스트 선호도를 지정하십시오. | *”foo.py에 대한 테스트 추가"* | *"사용자가 로그아웃된 경우의 엣지 케이스를 다루는 foo.py에 대한 테스트를 작성하세요. 모의 객체를 피하세요.”* |
| **소스 지적.** Claude를 질문에 답할 수 있는 소스로 안내하십시오. | *”ExecutionFactory가 왜 그렇게 이상한 API를 가지고 있습니까?"* | *"ExecutionFactory의 git 히스토리를 살펴보고 API가 어떻게 되었는지 요약하세요”* |
| **기존 패턴 참조.** Claude를 코드베이스의 패턴으로 지적하십시오. | *”캘린더 위젯 추가"* | *"홈 페이지에서 기존 위젯이 어떻게 구현되는지 살펴보고 패턴을 이해하세요. HotDogWidget.php는 좋은 예입니다. 패턴을 따라 사용자가 월을 선택하고 앞뒤로 이동하여 연도를 선택할 수 있는 새로운 캘린더 위젯을 구현하세요. 코드베이스에서 이미 사용 중인 라이브러리 외에는 라이브러리를 사용하지 않고 처음부터 빌드하세요.”* |
| **증상 설명.** 증상, 가능한 위치, “수정됨”의 모습을 제공하십시오. | *”로그인 버그 수정"* | *"사용자가 세션 시간 초과 후 로그인이 실패한다고 보고합니다. src/auth/의 인증 흐름, 특히 토큰 새로 고침을 확인하세요. 문제를 재현하는 실패한 테스트를 작성한 다음 수정하세요”* |

모호한 프롬프트는 탐색 중이고 과정을 수정할 여유가 있을 때 유용할 수 있습니다. `"이 파일에서 무엇을 개선하시겠습니까?"` 와 같은 프롬프트는 당신이 생각하지 못했을 것들을 드러낼 수 있습니다.

### 풍부한 콘텐츠 제공하기

`@` 를 사용하여 파일을 참조하거나, 스크린샷/이미지를 붙여넣거나, 데이터를 직접 파이프하십시오.

여러 가지 방법으로 Claude에게 풍부한 데이터를 제공할 수 있습니다:

- **`@` 로 파일 참조** 코드가 어디에 있는지 설명하는 대신. Claude는 응답하기 전에 파일을 읽습니다.
- **이미지를 직접 붙여넣기**. 프롬프트에 이미지를 복사/붙여넣기 또는 드래그 앤 드롭하십시오.
- **문서 및 API 참조에 URL 제공**. `/permissions` 를 사용하여 자주 사용되는 도메인을 허용 목록에 추가하십시오.
- **데이터 파이프** `cat error.log | claude` 를 실행하여 파일 내용을 직접 전송하십시오.
- **Claude가 필요한 것을 가져오도록 하기**. Bash 명령, MCP 도구 또는 파일 읽기를 사용하여 Claude가 자체적으로 컨텍스트를 가져오도록 하십시오.

---

## 환경 구성하기

몇 가지 설정 단계를 통해 Claude Code를 모든 세션에서 훨씬 더 효과적으로 만들 수 있습니다. 확장 기능의 전체 개요 및 각 기능을 사용할 시기에 대해서는 [Claude Code 확장](https://code.claude.com/docs/ko/features-overview) 을 참조하십시오.

### 효과적인 CLAUDE.md 작성하기

`/init` 을 실행하여 현재 프로젝트 구조를 기반으로 시작 CLAUDE.md 파일을 생성한 다음 시간이 지남에 따라 개선하십시오.

CLAUDE.md는 Claude가 모든 대화의 시작 부분에서 읽는 특수 파일입니다. Bash 명령, 코드 스타일 및 워크플로우 규칙을 포함하십시오. 이는 Claude에게 코드만으로는 추론할 수 없는 지속적인 컨텍스트를 제공합니다.

`/init` 명령은 코드베이스를 분석하여 빌드 시스템, 테스트 프레임워크 및 코드 패턴을 감지하여 개선할 수 있는 견고한 기초를 제공합니다.

CLAUDE.md 파일에 필수 형식은 없지만 짧고 인간이 읽을 수 있도록 유지하십시오. 예를 들어:

```markdown
# 코드 스타일
- ES 모듈(import/export) 구문을 사용하고, CommonJS(require)는 사용하지 마세요
- 가능하면 import를 구조 분해하세요 (예: import { foo } from 'bar')

# 워크플로우
- 일련의 코드 변경을 완료했을 때 타입 체크를 확인하세요
- 성능상 이유로 전체 테스트 스위트가 아닌 단일 테스트를 실행하는 것을 선호하세요
```

CLAUDE.md는 모든 세션에서 로드되므로 광범위하게 적용되는 것만 포함하십시오. 도메인 지식이나 때때만 관련된 워크플로우의 경우 대신 [skills](https://code.claude.com/docs/ko/skills) 를 사용하십시오. Claude는 필요에 따라 로드하므로 모든 대화를 복잡하게 하지 않습니다.

간결하게 유지하십시오. 각 줄에 대해 다음을 물어보십시오: *“이것을 제거하면 Claude가 실수를 할까?”* 그렇지 않으면 삭제하십시오. 부풀려진 CLAUDE.md 파일은 Claude가 실제 지시사항을 무시하게 합니다!

| ✅ 포함 | ❌ 제외 |
| --- | --- |
| Claude가 추측할 수 없는 Bash 명령 | Claude가 코드를 읽어서 파악할 수 있는 것 |
| 기본값과 다른 코드 스타일 규칙 | Claude가 이미 알고 있는 표준 언어 규칙 |
| 테스트 지시사항 및 선호하는 테스트 러너 | 상세한 API 문서(대신 문서 링크) |
| 저장소 에티켓(분기 이름 지정, PR 규칙) | 자주 변경되는 정보 |
| 프로젝트에 특정한 아키텍처 결정 | 긴 설명 또는 튜토리얼 |
| 개발자 환경 특이성(필수 환경 변수) | 자명한 관행(예: “깨끗한 코드 작성”) |
| 일반적인 함정 또는 명백하지 않은 동작 | 파일별 코드베이스 설명 |

Claude가 규칙에도 불구하고 계속 원하지 않는 작업을 수행하면 파일이 너무 길어서 규칙이 손실되고 있을 가능성이 있습니다. Claude가 CLAUDE.md에서 답변된 질문을 하면 표현이 모호할 수 있습니다. CLAUDE.md를 코드처럼 취급하십시오: 문제가 발생하면 검토하고, 정기적으로 정리하고, 변경 사항을 관찰하여 Claude의 동작이 실제로 변경되는지 테스트하십시오.

강조(예: “IMPORTANT” 또는 “YOU MUST”)를 추가하여 지시사항을 조정하면 준수를 개선할 수 있습니다. CLAUDE.md를 git에 체크인하여 팀이 기여할 수 있도록 하십시오. 파일은 시간이 지남에 따라 가치가 증가합니다.

CLAUDE.md 파일은 `@path/to/import` 구문을 사용하여 추가 파일을 가져올 수 있습니다:

```markdown
프로젝트 개요는 @README.md를 참조하고 사용 가능한 npm 명령은 @package.json을 참조하세요.

# 추가 지시사항
- Git 워크플로우: @docs/git-instructions.md
- 개인 재정의: @~/.claude/my-project-instructions.md
```

CLAUDE.md 파일을 여러 위치에 배치할 수 있습니다:

- **홈 폴더(`~/.claude/CLAUDE.md`)**: 모든 Claude 세션에 적용됨
- **프로젝트 루트(`./CLAUDE.md`)**: git에 체크인하여 팀과 공유
- **상위 디렉토리**: 모노레포에 유용하며, `root/CLAUDE.md` 와 `root/foo/CLAUDE.md` 모두 자동으로 가져와집니다
- **하위 디렉토리**: Claude는 해당 디렉토리의 파일로 작업할 때 필요에 따라 하위 CLAUDE.md 파일을 가져옵니다

### 권한 구성하기

[auto mode](https://code.claude.com/docs/ko/permission-modes#eliminate-prompts-with-auto-mode) 를 사용하여 분류기가 승인을 처리하도록 하거나, `/permissions` 를 사용하여 특정 명령을 허용 목록에 추가하거나, `/sandbox` 를 사용하여 OS 수준 격리를 수행하십시오. 각각은 제어를 유지하면서 중단을 줄입니다.

기본적으로 Claude Code는 시스템을 수정할 수 있는 작업에 대한 권한을 요청합니다: 파일 쓰기, Bash 명령, MCP 도구 등. 이는 안전하지만 번거롭습니다. 10번째 승인 후에는 실제로 검토하지 않고 클릭만 하고 있습니다. 이러한 중단을 줄이는 세 가지 방법이 있습니다:

- **Auto mode**: 별도의 분류기 모델이 명령을 검토하고 위험해 보이는 것만 차단합니다: 범위 확대, 알 수 없는 인프라, 또는 적대적 콘텐츠 기반 작업. 작업의 일반적인 방향을 신뢰하지만 모든 단계를 클릭하고 싶지 않을 때 최고입니다
- **권한 허용 목록**: 안전하다고 알고 있는 특정 도구 허용(예: `npm run lint` 또는 `git commit`)
- **샌드박싱**: Claude가 정의된 경계 내에서 더 자유롭게 작동할 수 있도록 하는 OS 수준 격리를 활성화하여 파일 시스템 및 네트워크 액세스를 제한합니다

[권한 모드](https://code.claude.com/docs/ko/permission-modes), [권한 규칙](https://code.claude.com/docs/ko/permissions), [샌드박싱](https://code.claude.com/docs/ko/sandboxing) 에 대해 자세히 읽어보십시오.

### CLI 도구 사용하기

Claude Code에 `gh`, `aws`, `gcloud`, `sentry-cli` 와 같은 CLI 도구를 사용하여 외부 서비스와 상호 작용하도록 하십시오.

CLI 도구는 외부 서비스와 상호 작용하는 가장 context 효율적인 방법입니다. GitHub를 사용하면 `gh` CLI를 설치하십시오. Claude는 이슈 생성, pull 요청 열기, 댓글 읽기에 사용하는 방법을 알고 있습니다. `gh` 없으면 Claude는 여전히 GitHub API를 사용할 수 있지만 인증되지 않은 요청은 종종 속도 제한에 도달합니다.

Claude는 또한 아직 알지 못하는 CLI 도구를 배우는 데 효과적입니다. `Use 'foo-cli-tool --help' to learn about foo tool, then use it to solve A, B, C.`와 같은 프롬프트를 시도해보십시오.

### MCP 서버 연결하기

`claude mcp add` 를 실행하여 Notion, Figma 또는 데이터베이스와 같은 외부 도구를 연결하십시오.

[MCP 서버](https://code.claude.com/docs/ko/mcp) 를 사용하면 이슈 추적기에서 기능을 구현하고, 데이터베이스를 쿼리하고, 모니터링 데이터를 분석하고, Figma에서 디자인을 통합하고, 워크플로우를 자동화하도록 Claude에게 요청할 수 있습니다.

### hooks 설정하기

예외 없이 매번 발생해야 하는 작업에 hooks를 사용하십시오.

[Hooks](https://code.claude.com/docs/ko/hooks-guide) 는 Claude의 워크플로우의 특정 지점에서 자동으로 스크립트를 실행합니다. 권고적인 CLAUDE.md 지시사항과 달리 hooks는 결정론적이며 작업이 발생함을 보장합니다.

Claude가 hooks를 작성할 수 있습니다. *“모든 파일 편집 후 eslint를 실행하는 hook 작성”* 또는 \*“마이그레이션 폴더에 대한 쓰기를 차단하는 hook 작성”\*과 같은 프롬프트를 시도해보십시오. `.claude/settings.json` 을 직접 편집하여 hooks를 구성하고, `/hooks` 를 실행하여 구성된 것을 탐색하십시오.

### skills 생성하기

`.claude/skills/` 에 `SKILL.md` 파일을 생성하여 Claude에게 도메인 지식과 재사용 가능한 워크플로우를 제공하십시오.

[Skills](https://code.claude.com/docs/ko/skills) 는 프로젝트, 팀 또는 도메인에 특정한 정보로 Claude의 지식을 확장합니다. Claude는 관련이 있을 때 자동으로 적용하거나 `/skill-name` 으로 직접 호출할 수 있습니다.

`.claude/skills/` 에 `SKILL.md` 가 있는 디렉토리를 추가하여 skill을 생성하십시오:

```markdown
---
name: api-conventions
description: 우리 서비스의 REST API 설계 규칙
---
# API 규칙
- URL 경로에 kebab-case 사용
- JSON 속성에 camelCase 사용
- 항상 목록 엔드포인트에 페이지 매김 포함
- URL 경로에서 API 버전 지정 (/v1/, /v2/)
```

Skills는 또한 직접 호출하는 반복 가능한 워크플로우를 정의할 수 있습니다:

```markdown
---
name: fix-issue
description: GitHub 이슈 수정
disable-model-invocation: true
---
GitHub 이슈를 분석하고 수정하세요: $ARGUMENTS.

1. \`gh issue view\`를 사용하여 이슈 세부 정보 가져오기
2. 이슈에 설명된 문제 이해
3. 관련 파일에 대한 코드베이스 검색
4. 이슈를 수정하기 위해 필요한 변경 사항 구현
5. 수정을 확인하기 위해 테스트 작성 및 실행
6. 코드가 linting 및 타입 체크를 통과하는지 확인
7. 설명적인 커밋 메시지 생성
8. 푸시 및 PR 생성
```

`/fix-issue 1234` 를 실행하여 호출하십시오. 부작용이 있는 워크플로우의 경우 `disable-model-invocation: true` 를 사용하여 수동으로 트리거하려고 합니다.

### 사용자 정의 subagents 생성하기

`.claude/agents/` 에서 전문화된 어시스턴트를 정의하여 Claude가 격리된 작업에 위임할 수 있도록 하십시오.

[Subagents](https://code.claude.com/docs/ko/sub-agents) 는 자신의 context와 자신의 허용된 도구 집합으로 실행됩니다. 많은 파일을 읽거나 주요 대화를 복잡하게 하지 않고 전문화된 초점이 필요한 작업에 유용합니다.

```markdown
---
name: security-reviewer
description: 보안 취약점에 대한 코드 검토
tools: Read, Grep, Glob, Bash
model: opus
---
당신은 선임 보안 엔지니어입니다. 다음에 대해 코드를 검토하세요:
- 주입 취약점(SQL, XSS, 명령 주입)
- 인증 및 권한 부여 결함
- 코드의 비밀 또는 자격 증명
- 안전하지 않은 데이터 처리

특정 줄 참조 및 제안된 수정 사항을 제공하세요.
```

Claude에게 명시적으로 subagents를 사용하도록 하십시오: *“subagent를 사용하여 이 코드를 보안 문제에 대해 검토하세요.”*

### plugins 설치하기

`/plugin` 을 실행하여 마켓플레이스를 탐색하십시오. Plugins는 구성 없이 skills, tools, integrations를 추가합니다.

[Plugins](https://code.claude.com/docs/ko/plugins) 는 커뮤니티 및 Anthropic의 마켓플레이스에서 설치 가능한 단일 단위로 skills, hooks, subagents, MCP 서버를 번들로 제공합니다. 타입이 지정된 언어로 작업하면 [코드 인텔리전스 plugin](https://code.claude.com/docs/ko/discover-plugins#code-intelligence) 을 설치하여 Claude에게 정확한 기호 탐색 및 편집 후 자동 오류 감지를 제공하십시오.

skills, subagents, hooks, MCP 중에서 선택하는 방법에 대한 지침은 [Claude Code 확장](https://code.claude.com/docs/ko/features-overview#match-features-to-your-goal) 을 참조하십시오.

---

## 효과적으로 소통하기

Claude Code와의 소통 방식은 결과의 품질에 크게 영향을 미칩니다.

### 코드베이스 질문 하기

선임 엔지니어에게 물어볼 질문을 Claude에게 하십시오.

새로운 코드베이스에 온보딩할 때 Claude Code를 학습 및 탐색에 사용하십시오. Claude에게 다른 엔지니어에게 물어볼 것과 같은 종류의 질문을 할 수 있습니다:

- 로깅은 어떻게 작동합니까?
- 새로운 API 엔드포인트를 어떻게 만듭니까?
- `foo.rs` 의 134번 줄에서 `async move { ... }` 는 무엇을 합니까?
- `CustomerOnboardingFlowImpl` 은 어떤 엣지 케이스를 처리합니까?
- 이 코드가 333번 줄에서 `bar()` 대신 `foo()` 를 호출하는 이유는 무엇입니까?

이런 방식으로 Claude Code를 사용하는 것은 효과적인 온보딩 워크플로우이며, 램프업 시간을 개선하고 다른 엔지니어의 부담을 줄입니다. 특별한 프롬프팅이 필요하지 않습니다: 직접 질문하십시오.

### Claude가 당신을 인터뷰하도록 하기

더 큰 기능의 경우 Claude가 먼저 당신을 인터뷰하도록 하십시오. 최소한의 프롬프트로 시작하고 Claude에게 `AskUserQuestion` 도구를 사용하여 당신을 인터뷰하도록 요청하십시오.

Claude는 기술 구현, UI/UX, 엣지 케이스, 트레이드오프를 포함하여 아직 고려하지 않은 것들에 대해 질문합니다.

```text
[간단한 설명]을 빌드하고 싶습니다. AskUserQuestion 도구를 사용하여 자세히 인터뷰해주세요.

기술 구현, UI/UX, 엣지 케이스, 우려 사항, 트레이드오프에 대해 질문하세요. 명백한 질문을 하지 마세요, 당신이 고려하지 않았을 수 있는 어려운 부분을 파고드세요.

모든 것을 다룰 때까지 인터뷰를 계속한 다음 SPEC.md에 완전한 사양을 작성하세요.
```

사양이 완료되면 새 세션을 시작하여 실행하십시오. 새 세션은 구현에만 집중하는 깨끗한 context를 가지고 있으며, 참조할 수 있는 작성된 사양이 있습니다.

---

## 세션 관리하기

대화는 지속적이고 되돌릴 수 있습니다. 이를 활용하십시오!

### 조기에 자주 방향 수정하기

Claude가 궤도를 벗어나는 것을 알아차리면 즉시 수정하십시오.

최고의 결과는 긴밀한 피드백 루프에서 나옵니다. Claude가 때때로 첫 시도에서 문제를 완벽하게 해결하지만, 빠르게 수정하면 일반적으로 더 빠르게 더 나은 솔루션을 생성합니다.

- **`Esc`**: `Esc` 키로 Claude의 작업을 중간에 중지하십시오. Context는 보존되므로 방향을 바꿀 수 있습니다.
- **`Esc + Esc` 또는 `/rewind`**: `Esc` 를 두 번 누르거나 `/rewind` 를 실행하여 rewind 메뉴를 열고 이전 대화 및 코드 상태를 복원하거나 선택한 메시지에서 요약하십시오.
- **`"Undo that"`**: Claude에게 변경 사항을 되돌리도록 하십시오.
- **`/clear`**: 관련 없는 작업 간에 context를 재설정하십시오. 관련 없는 context가 있는 긴 세션은 성능을 줄일 수 있습니다.

한 세션에서 같은 문제에 대해 Claude를 두 번 이상 수정했다면 context는 실패한 접근 방식으로 복잡해져 있습니다. `/clear` 를 실행하고 배운 내용을 통합하는 더 구체적인 프롬프트로 새로 시작하십시오. 누적된 수정이 있는 긴 세션보다 더 나은 프롬프트가 있는 깨끗한 세션이 거의 항상 더 나은 성능을 발휘합니다.

### context 적극적으로 관리하기

관련 없는 작업 간에 `/clear` 를 자주 실행하여 context window를 재설정하십시오.

Claude Code는 context 제한에 접근할 때 대화 기록을 자동으로 압축하여 중요한 코드와 결정을 보존하면서 공간을 확보합니다.

긴 세션 동안 Claude의 context window는 관련 없는 대화, 파일 내용, 명령으로 채워질 수 있습니다. 이는 성능을 줄이고 때때로 Claude를 산만하게 할 수 있습니다.

- 작업 간에 자주 `/clear` 를 사용하여 context window를 완전히 재설정하십시오
- 자동 압축이 트리거되면 Claude는 코드 패턴, 파일 상태, 주요 결정을 포함하여 가장 중요한 것을 요약합니다
- 더 많은 제어를 위해 `/compact <instructions>` 를 실행하십시오(예: `/compact Focus on the API changes`)
- 대화의 일부만 압축하려면 `Esc + Esc` 또는 `/rewind` 를 사용하고, 메시지 체크포인트를 선택하고, **Summarize from here** 를 선택하십시오. 이는 해당 지점부터의 메시지를 압축하면서 이전 context를 유지합니다.
- CLAUDE.md에서 `"When compacting, always preserve the full list of modified files and any test commands"` 와 같은 지시사항으로 압축 동작을 사용자 정의하여 중요한 context가 요약을 통해 유지되도록 하십시오
- 빠른 질문의 경우 context에 들어가지 않아야 하므로 [`/btw`](https://code.claude.com/docs/ko/interactive-mode#side-questions-with-btw) 를 사용하십시오. 답변은 해제 가능한 오버레이에 나타나고 대화 기록에 들어가지 않으므로 context를 증가시키지 않고 세부 정보를 확인할 수 있습니다.

### subagents를 사용하여 조사하기

`"use subagents to investigate X"` 로 연구를 위임하십시오. 그들은 별도의 context에서 탐색하여 구현을 위해 주요 대화를 깨끗하게 유지합니다.

context가 기본 제약 조건이므로 subagents는 사용 가능한 가장 강력한 도구 중 하나입니다. Claude가 코드베이스를 연구할 때 많은 파일을 읽으며, 모두 context를 소비합니다. Subagents는 별도의 context window에서 실행되고 요약을 보고합니다:

```text
subagents를 사용하여 인증 시스템이 토큰 새로 고침을 어떻게 처리하는지,
그리고 재사용해야 할 기존 OAuth 유틸리티가 있는지 조사하세요.
```

subagent는 코드베이스를 탐색하고, 관련 파일을 읽고, 주요 대화를 복잡하게 하지 않고 발견 사항을 보고합니다.

Claude가 구현한 후 검증을 위해 subagents를 사용할 수도 있습니다:

```text
subagent를 사용하여 이 코드를 엣지 케이스에 대해 검토하세요
```

### 체크포인트로 rewind하기

Claude가 수행하는 모든 작업은 체크포인트를 생성합니다. 이전 체크포인트로 대화, 코드 또는 둘 다를 복원할 수 있습니다.

Claude는 변경 전에 자동으로 체크포인트합니다. `Escape` 를 두 번 누르거나 `/rewind` 를 실행하여 rewind 메뉴를 열기. 대화만 복원하거나, 코드만 복원하거나, 둘 다 복원하거나, 선택한 메시지에서 요약할 수 있습니다. 자세한 내용은 [Checkpointing](https://code.claude.com/docs/ko/checkpointing) 을 참조하십시오.

모든 움직임을 신중하게 계획하는 대신 Claude에게 위험한 것을 시도하도록 할 수 있습니다. 작동하지 않으면 rewind하고 다른 접근 방식을 시도하십시오. 체크포인트는 세션 간에 유지되므로 터미널을 닫아도 나중에 rewind할 수 있습니다.

체크포인트는 Claude가 수행한 변경만 추적하며, 외부 프로세스는 추적하지 않습니다. 이는 git의 대체품이 아닙니다.

### 대화 재개하기

`claude --continue` 를 실행하여 중단한 곳에서 계속하거나, `--resume` 을 사용하여 최근 세션에서 선택하십시오.

Claude Code는 대화를 로컬로 저장합니다. 작업이 여러 세션에 걸쳐 있을 때 context를 다시 설명할 필요가 없습니다:

```shellscript
claude --continue    # 가장 최근 대화 재개
claude --resume      # 최근 대화에서 선택
```

`/rename` 을 사용하여 세션에 `"oauth-migration"` 또는 `"debugging-memory-leak"` 과 같은 설명적인 이름을 지정하여 나중에 찾을 수 있도록 하십시오. 세션을 분기처럼 취급하십시오: 다양한 작업 스트림은 별도의 지속적인 context를 가질 수 있습니다.

---

## 자동화 및 확장하기

한 Claude로 효과적이 되면 병렬 세션, 비대화형 모드, fan-out 패턴으로 출력을 곱하십시오.

지금까지 모든 것은 한 명의 인간, 한 명의 Claude, 한 개의 대화를 가정합니다. 하지만 Claude Code는 수평으로 확장됩니다. 이 섹션의 기술은 더 많은 작업을 수행하는 방법을 보여줍니다.

### 비대화형 모드 실행하기

CI, pre-commit hooks 또는 스크립트에서 `claude -p "prompt"` 를 사용하십시오. 스트리밍 JSON 출력의 경우 `--output-format stream-json` 을 추가하십시오.

`claude -p "your prompt"` 를 사용하면 세션 없이 비대화형으로 Claude를 실행할 수 있습니다. 비대화형 모드는 Claude를 CI 파이프라인, pre-commit hooks 또는 자동화된 워크플로우에 통합하는 방법입니다. 출력 형식을 사용하면 결과를 프로그래밍 방식으로 구문 분석할 수 있습니다: 일반 텍스트, JSON 또는 스트리밍 JSON.

```shellscript
# 일회성 쿼리
claude -p "이 프로젝트가 무엇을 하는지 설명하세요"

# 스크립트를 위한 구조화된 출력
claude -p "모든 API 엔드포인트 나열" --output-format json

# 실시간 처리를 위한 스트리밍
claude -p "이 로그 파일 분석" --output-format stream-json
```

### 여러 Claude 세션 실행하기

개발 속도를 높이거나, 격리된 실험을 실행하거나, 복잡한 워크플로우를 시작하기 위해 여러 Claude 세션을 병렬로 실행하십시오.

병렬 세션을 실행하는 세 가지 주요 방법이 있습니다:

- [Claude Code 데스크톱 앱](https://code.claude.com/docs/ko/desktop#work-in-parallel-with-sessions): 여러 로컬 세션을 시각적으로 관리하십시오. 각 세션은 자신의 격리된 worktree를 가집니다.
- [웹의 Claude Code](https://code.claude.com/docs/ko/claude-code-on-the-web): Anthropic의 안전한 클라우드 인프라에서 격리된 VM에서 실행하십시오.
- [Agent teams](https://code.claude.com/docs/ko/agent-teams): 공유 작업, 메시징, 팀 리더를 사용한 여러 세션의 자동 조정.

작업을 병렬화하는 것 외에도 여러 세션은 품질 중심 워크플로우를 활성화합니다. 새로운 context는 Claude가 방금 작성한 코드에 편향되지 않으므로 코드 검토를 개선합니다.

예를 들어 Writer/Reviewer 패턴을 사용하십시오:

| 세션 A (작성자) | 세션 B (검토자) |
| --- | --- |
| `API 엔드포인트에 대한 속도 제한기 구현` |  |
|  | `@src/middleware/rateLimiter.ts의 속도 제한기 구현을 검토하세요. 엣지 케이스, 경쟁 조건, 기존 미들웨어 패턴과의 일관성을 찾으세요.` |
| `검토 피드백은 다음과 같습니다: [세션 B 출력]. 이 문제들을 해결하세요.` |  |

테스트로 비슷한 작업을 수행할 수 있습니다: 한 Claude가 테스트를 작성하고 다른 Claude가 테스트를 통과하는 코드를 작성합니다.

### 파일 전체에 fan out하기

각각에 대해 `claude -p` 를 호출하는 루프를 통해 작업을 분배하십시오. 배치 작업의 경우 `--allowedTools` 를 사용하여 권한을 범위 지정하십시오.

대규모 마이그레이션 또는 분석의 경우 많은 병렬 Claude 호출 전체에 작업을 분배할 수 있습니다:

Claude를 기존 데이터/처리 파이프라인에 통합할 수도 있습니다:

```shellscript
claude -p "<your prompt>" --output-format json | your_command
```

개발 중에 디버깅을 위해 `--verbose` 를 사용하고 프로덕션에서는 끄십시오.

### auto mode로 자율적으로 실행하기

중단 없는 실행과 백그라운드 안전 검사를 위해 [auto mode](https://code.claude.com/docs/ko/permission-modes#eliminate-prompts-with-auto-mode) 를 사용하십시오. 분류기 모델이 명령을 실행하기 전에 검토하여 범위 확대, 알 수 없는 인프라, 적대적 콘텐츠 기반 작업을 차단하면서 일상적인 작업이 프롬프트 없이 진행되도록 합니다.

```shellscript
claude --permission-mode auto -p "fix all lint errors"
```

`-p` 플래그가 있는 비대화형 실행의 경우, 분류기가 반복적으로 작업을 차단하면 auto mode가 중단됩니다. 폴백할 사용자가 없기 때문입니다. [auto mode가 폴백할 때](https://code.claude.com/docs/ko/permission-modes#when-auto-mode-falls-back) 의 임계값을 참조하십시오.

---

## 일반적인 실패 패턴 피하기

이는 일반적인 실수입니다. 조기에 인식하면 시간을 절약합니다:

- **주방 싱크 세션.** 한 작업으로 시작한 다음 Claude에게 관련 없는 것을 물어본 다음 첫 번째 작업으로 돌아갑니다. Context는 관련 없는 정보로 가득 찹니다.
	> **수정**: 관련 없는 작업 간에 `/clear`.
- **반복적으로 수정.** Claude가 뭔가 잘못하고, 당신이 수정하고, 여전히 잘못되고, 다시 수정합니다. Context는 실패한 접근 방식으로 오염됩니다.
	> **수정**: 두 번의 실패한 수정 후 `/clear` 를 하고 배운 내용을 통합하는 더 나은 초기 프롬프트를 작성하십시오.
- **과도하게 지정된 CLAUDE.md.** CLAUDE.md가 너무 길면 Claude는 중요한 규칙이 노이즈에 손실되기 때문에 절반을 무시합니다.
	> **수정**: 무자비하게 정리하십시오. Claude가 지시사항 없이 이미 올바르게 수행하면 삭제하거나 hook으로 변환하십시오.
- **신뢰-검증 간격.** Claude는 그럴듯해 보이지만 엣지 케이스를 처리하지 않는 구현을 생성합니다.
	> **수정**: 항상 검증(테스트, 스크립트, 스크린샷)을 제공하십시오. 검증할 수 없으면 배포하지 마십시오.
- **무한 탐색.** 범위를 지정하지 않고 Claude에게 뭔가를 “조사”하도록 요청합니다. Claude는 수백 개의 파일을 읽으며 context를 채웁니다.
	> **수정**: 조사를 좁게 범위 지정하거나 subagents를 사용하여 탐색이 주요 context를 소비하지 않도록 하십시오.

---

## 직관 개발하기

이 가이드의 패턴은 정해진 것이 아닙니다. 일반적으로 잘 작동하지만 모든 상황에 최적일 수는 없는 시작점입니다.

때로는 복잡한 문제에 깊이 있고 기록이 가치 있기 때문에 context가 누적되도록 *해야* 합니다. 때로는 작업이 탐색적이기 때문에 계획을 건너뛰고 Claude가 파악하도록 *해야* 합니다. 때로는 모호한 프롬프트가 정확히 맞기 때문에 Claude가 문제를 해석하는 방식을 보고 싶을 때입니다.

작동하는 것에 주의를 기울이십시오. Claude가 훌륭한 출력을 생성할 때 당신이 한 것을 주목하십시오: 프롬프트 구조, 제공한 context, 당신이 있던 모드. Claude가 어려움을 겪을 때 왜인지 물어보십시오. Context가 너무 시끄러웠습니까? 프롬프트가 너무 모호했습니까? 작업이 한 번에 너무 컸습니까?

시간이 지남에 따라 어떤 가이드도 포착할 수 없는 직관을 개발할 것입니다. 구체적일 때와 개방적일 때, 계획할 때와 탐색할 때, context를 지울 때와 누적하도록 할 때를 알게 될 것입니다.

## 관련 리소스

- [Claude Code 작동 방식](https://code.claude.com/docs/ko/how-claude-code-works): 에이전트 루프, 도구, context 관리
- [Claude Code 확장](https://code.claude.com/docs/ko/features-overview): skills, hooks, MCP, subagents, plugins
- [일반적인 워크플로우](https://code.claude.com/docs/ko/common-workflows): 디버깅, 테스트, PR 등에 대한 단계별 레시피
- [CLAUDE.md](https://code.claude.com/docs/ko/memory): 프로젝트 규칙 및 지속적인 context 저장