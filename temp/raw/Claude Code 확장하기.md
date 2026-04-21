---
title: "Claude Code 확장하기"
source: "https://code.claude.com/docs/ko/features-overview"
author:
published:
created: 2026-04-20
description: "CLAUDE.md, Skills, subagents, hooks, MCP, 플러그인을 언제 사용할지 이해합니다."
tags:
  - "clippings"
---
Claude Code는 코드를 추론하는 모델과 파일 작업, 검색, 실행 및 웹 접근을 위한 [내장 도구](https://code.claude.com/docs/ko/how-claude-code-works#tools) 를 결합합니다. 내장 도구는 대부분의 코딩 작업을 다룹니다. 이 가이드는 확장 계층을 다룹니다. Claude가 알아야 할 내용을 사용자 정의하고, 외부 서비스에 연결하고, 워크플로우를 자동화하기 위해 추가하는 기능입니다.

핵심 에이전트 루프가 어떻게 작동하는지 알아보려면 [Claude Code 작동 방식](https://code.claude.com/docs/ko/how-claude-code-works) 을 참조하세요.

**Claude Code를 처음 사용하시나요?** 프로젝트 규칙을 위해 [CLAUDE.md](https://code.claude.com/docs/ko/memory) 로 시작하세요. 필요에 따라 다른 확장을 추가하세요.

## 개요

확장은 에이전트 루프의 다양한 부분에 연결됩니다.

- \*\* [CLAUDE.md](https://code.claude.com/docs/ko/memory) \*\*는 Claude가 모든 세션에서 보는 지속적인 컨텍스트를 추가합니다.
- \*\* [Skills](https://code.claude.com/docs/ko/skills) \*\*는 재사용 가능한 지식과 호출 가능한 워크플로우를 추가합니다.
- \*\* [MCP](https://code.claude.com/docs/ko/mcp) \*\*는 Claude를 외부 서비스 및 도구에 연결합니다.
- \*\* [Subagents](https://code.claude.com/docs/ko/sub-agents) \*\*는 격리된 컨텍스트에서 자신의 루프를 실행하고 요약을 반환합니다.
- \*\* [Agent teams](https://code.claude.com/docs/ko/agent-teams) \*\*는 공유 작업 및 피어 투 피어 메시징으로 여러 독립적인 세션을 조정합니다.
- \*\* [Hooks](https://code.claude.com/docs/ko/hooks) \*\*는 결정론적 스크립트로 루프 외부에서 완전히 실행됩니다.
- **[Plugins](https://code.claude.com/docs/ko/plugins)** 및 \*\* [marketplaces](https://code.claude.com/docs/ko/plugin-marketplaces) \*\*는 이러한 기능을 패키징하고 배포합니다.

[Skills](https://code.claude.com/docs/ko/skills) 는 가장 유연한 확장입니다. Skill은 지식, 워크플로우 또는 지침을 포함하는 마크다운 파일입니다. `/deploy` 와 같은 명령으로 skill을 호출하거나, Claude가 관련이 있을 때 자동으로 로드할 수 있습니다. Skill은 현재 대화에서 실행되거나 subagents를 통해 격리된 컨텍스트에서 실행될 수 있습니다.

## 기능을 목표에 맞추기

기능은 Claude가 모든 세션에서 보는 항상 켜진 컨텍스트부터 사용자나 Claude가 호출할 수 있는 온디맨드 기능, 특정 이벤트에서 실행되는 백그라운드 자동화까지 다양합니다. 아래 표는 사용 가능한 기능과 각 기능이 언제 적절한지 보여줍니다.

| 기능 | 수행 작업 | 사용 시기 | 예시 |
| --- | --- | --- | --- |
| **CLAUDE.md** | 모든 대화에서 로드되는 지속적인 컨텍스트 | 프로젝트 규칙, “항상 X를 수행” 규칙 | ”npm이 아닌 pnpm을 사용하세요. 커밋하기 전에 테스트를 실행하세요.” |
| **Skill** | Claude가 사용할 수 있는 지침, 지식 및 워크플로우 | 재사용 가능한 콘텐츠, 참조 문서, 반복 가능한 작업 | `/deploy` 는 배포 체크리스트를 실행합니다. 엔드포인트 패턴이 있는 API 문서 skill |
| **Subagent** | 요약된 결과를 반환하는 격리된 실행 컨텍스트 | 컨텍스트 격리, 병렬 작업, 특화된 워커 | 많은 파일을 읽지만 주요 결과만 반환하는 연구 작업 |
| **[Agent teams](https://code.claude.com/docs/ko/agent-teams)** | 여러 독립적인 Claude Code 세션 조정 | 병렬 연구, 새로운 기능 개발, 경쟁하는 가설로 디버깅 | 보안, 성능 및 테스트를 동시에 확인하는 검토자 생성 |
| **MCP** | 외부 서비스에 연결 | 외부 데이터 또는 작업 | 데이터베이스 쿼리, Slack에 게시, 브라우저 제어 |
| **Hook** | 이벤트에서 실행되는 결정론적 스크립트 | 예측 가능한 자동화, LLM 없음 | 모든 파일 편집 후 ESLint 실행 |

\*\* [Plugins](https://code.claude.com/docs/ko/plugins) \*\*는 패키징 계층입니다. 플러그인은 skill, hook, subagent 및 MCP 서버를 단일 설치 가능한 단위로 번들합니다. 플러그인 skill은 네임스페이스됩니다(예: `/my-plugin:review`). 따라서 여러 플러그인이 공존할 수 있습니다. 여러 저장소에서 동일한 설정을 재사용하거나 \*\* [marketplace](https://code.claude.com/docs/ko/plugin-marketplaces) \*\*를 통해 다른 사용자에게 배포하려는 경우 플러그인을 사용하세요.

### 유사한 기능 비교

일부 기능은 유사해 보일 수 있습니다. 구별하는 방법은 다음과 같습니다.

- Skill vs Subagent
- CLAUDE.md vs Skill
- CLAUDE.md vs Rules vs Skills
- Subagent vs Agent team
- MCP vs Skill

Skill과 subagent는 다양한 문제를 해결합니다.

- **Skills** 는 모든 컨텍스트에 로드할 수 있는 재사용 가능한 콘텐츠입니다.
- **Subagents** 는 주 대화와 별도로 실행되는 격리된 워커입니다.

| 측면 | Skill | Subagent |
| --- | --- | --- |
| **정의** | 재사용 가능한 지침, 지식 또는 워크플로우 | 자신의 컨텍스트를 가진 격리된 워커 |
| **주요 이점** | 컨텍스트 간 콘텐츠 공유 | 컨텍스트 격리. 작업은 별도로 발생하고 요약만 반환됩니다. |
| **최적 용도** | 참조 자료, 호출 가능한 워크플로우 | 많은 파일을 읽는 작업, 병렬 작업, 특화된 워커 |

**Skill은 참조 또는 작업일 수 있습니다.** 참조 skill은 Claude가 세션 전체에서 사용하는 지식을 제공합니다(API 스타일 가이드처럼). 작업 skill은 Claude에게 특정 작업을 수행하도록 지시합니다(배포 워크플로우를 실행하는 `/deploy` 처럼).

**컨텍스트 격리가 필요하거나 컨텍스트 윈도우가 가득 찰 때 subagent를 사용하세요.** Subagent는 수십 개의 파일을 읽거나 광범위한 검색을 실행할 수 있지만, 주 대화는 요약만 받습니다. Subagent 작업이 주 컨텍스트를 소비하지 않으므로, 중간 작업이 표시되어야 할 필요가 없을 때도 유용합니다. 사용자 정의 subagent는 자신의 지침을 가질 수 있고 skill을 미리 로드할 수 있습니다.

**결합할 수 있습니다.** Subagent는 특정 skill을 미리 로드할 수 있습니다(`skills:` 필드). Skill은 `context: fork` 를 사용하여 격리된 컨텍스트에서 실행될 수 있습니다. 자세한 내용은 [Skills](https://code.claude.com/docs/ko/skills) 를 참조하세요.

### 기능이 어떻게 계층화되는지 이해하기

기능은 여러 수준에서 정의될 수 있습니다. 사용자 전체, 프로젝트별, 플러그인을 통해, 또는 관리 정책을 통해. 또한 CLAUDE.md 파일을 하위 디렉토리에 중첩하거나 monorepo의 특정 패키지에 skill을 배치할 수 있습니다. 동일한 기능이 여러 수준에 존재할 때, 계층화 방식은 다음과 같습니다.

- **CLAUDE.md 파일** 은 추가적입니다. 모든 수준이 동시에 Claude의 컨텍스트에 콘텐츠를 제공합니다. 작업 디렉토리 및 위의 파일은 시작 시 로드되고, 하위 디렉토리는 작업할 때 로드됩니다. 지침이 충돌할 때, Claude는 판단을 사용하여 조정하며, 더 구체적인 지침이 일반적으로 우선합니다. [CLAUDE.md 파일이 로드되는 방식](https://code.claude.com/docs/ko/memory#how-claudemd-files-load) 을 참조하세요.
- **Skill과 subagent** 는 이름으로 재정의됩니다. 동일한 이름이 여러 수준에 존재할 때, 우선순위에 따라 하나의 정의가 승리합니다(skill의 경우 관리 > 사용자 > 프로젝트; subagent의 경우 관리 > CLI 플래그 > 프로젝트 > 사용자 > 플러그인). 플러그인 skill은 [네임스페이스됩니다](https://code.claude.com/docs/ko/plugins#add-skills-to-your-plugin). 충돌을 피하기 위해. [Skill 검색](https://code.claude.com/docs/ko/skills#where-skills-live) 및 [subagent 범위](https://code.claude.com/docs/ko/sub-agents#choose-the-subagent-scope) 를 참조하세요.
- **MCP 서버** 는 이름으로 재정의됩니다. 로컬 > 프로젝트 > 사용자. [MCP 범위](https://code.claude.com/docs/ko/mcp#scope-hierarchy-and-precedence) 를 참조하세요.
- **Hooks** 는 병합됩니다. 모든 등록된 hook은 소스에 관계없이 일치하는 이벤트에 대해 실행됩니다. [Hooks](https://code.claude.com/docs/ko/hooks) 를 참조하세요.

### 기능 결합하기

각 확장은 다양한 문제를 해결합니다. CLAUDE.md는 항상 켜진 컨텍스트를 처리하고, skill은 온디맨드 지식과 워크플로우를 처리하고, MCP는 외부 연결을 처리하고, subagent는 격리를 처리하고, hook은 자동화를 처리합니다. 실제 설정은 워크플로우에 따라 이들을 결합합니다.

예를 들어, CLAUDE.md를 프로젝트 규칙에 사용하고, skill을 배포 워크플로우에 사용하고, MCP를 데이터베이스에 연결하고, hook을 모든 편집 후 린팅을 실행하는 데 사용할 수 있습니다. 각 기능은 최적의 작업을 처리합니다.

| 패턴 | 작동 방식 | 예시 |
| --- | --- | --- |
| **Skill + MCP** | MCP는 연결을 제공하고, skill은 Claude에게 잘 사용하는 방법을 가르칩니다. | MCP는 데이터베이스에 연결하고, skill은 스키마 및 쿼리 패턴을 문서화합니다. |
| **Skill + Subagent** | Skill은 병렬 작업을 위해 subagent를 생성합니다. | `/audit` skill은 보안, 성능 및 스타일 subagent를 시작하여 격리된 컨텍스트에서 작동합니다. |
| **CLAUDE.md + Skill** | CLAUDE.md는 항상 켜진 규칙을 보유하고, skill은 온디맨드로 로드되는 참조 자료를 보유합니다. | CLAUDE.md는 “API 규칙을 따르세요”라고 말하고, skill은 전체 API 스타일 가이드를 포함합니다. |
| **Hook + MCP** | Hook은 MCP를 통해 외부 작업을 트리거합니다. | 편집 후 hook은 Claude가 중요한 파일을 수정할 때 Slack 알림을 보냅니다. |

## 컨텍스트 비용 이해하기

추가하는 모든 기능은 Claude의 컨텍스트를 소비합니다. 너무 많으면 컨텍스트 윈도우를 채울 수 있지만, 노이즈를 추가하여 Claude를 덜 효과적으로 만들 수도 있습니다. Skill이 올바르게 트리거되지 않거나 Claude가 규칙을 잃을 수 있습니다. 이러한 트레이드오프를 이해하면 효과적인 설정을 구축하는 데 도움이 됩니다.

### 기능별 컨텍스트 비용

각 기능은 다양한 로딩 전략과 컨텍스트 비용을 가집니다.

| 기능 | 로드 시기 | 로드되는 내용 | 컨텍스트 비용 |
| --- | --- | --- | --- |
| **CLAUDE.md** | 세션 시작 | 전체 콘텐츠 | 모든 요청 |
| **Skill** | 세션 시작 + 사용 시 | 시작 시 설명, 사용 시 전체 콘텐츠 | 낮음(모든 요청마다 설명)\* |
| **MCP 서버** | 세션 시작 | 모든 도구 정의 및 스키마 | 모든 요청 |
| **Subagent** | 생성 시 | 지정된 skill이 있는 신선한 컨텍스트 | 주 세션에서 격리됨 |
| **Hooks** | 트리거 시 | 없음(외부에서 실행) | 0, hook이 추가 컨텍스트를 반환하지 않는 한 |

\*기본적으로 skill 설명은 세션 시작 시 로드되므로 Claude가 사용할 시기를 결정할 수 있습니다. Skill의 frontmatter에서 `disable-model-invocation: true` 를 설정하여 수동으로 호출할 때까지 Claude에서 완전히 숨깁니다. 이는 skill의 컨텍스트 비용을 0으로 줄입니다.

### 기능이 어떻게 로드되는지 이해하기

각 기능은 세션의 다양한 지점에서 로드됩니다. 아래 탭은 각 기능이 언제 로드되고 무엇이 컨텍스트에 들어가는지 설명합니다.

![컨텍스트 로딩: CLAUDE.md와 MCP는 세션 시작 시 로드되고 모든 요청에 유지됩니다. Skill은 시작 시 설명을 로드하고 호출 시 전체 콘텐츠를 로드합니다. Subagent는 격리된 컨텍스트를 받습니다. Hook은 외부에서 실행됩니다.](https://mintcdn.com/claude-code/6yTCYq1p37ZB8-CQ/images/context-loading.svg?w=2500&fit=max&auto=format&n=6yTCYq1p37ZB8-CQ&q=85&s=7807709604d9851e7cba2c604422901c)

컨텍스트 로딩: CLAUDE.md와 MCP는 세션 시작 시 로드되고 모든 요청에 유지됩니다. Skill은 시작 시 설명을 로드하고 호출 시 전체 콘텐츠를 로드합니다. Subagent는 격리된 컨텍스트를 받습니다. Hook은 외부에서 실행됩니다.

- CLAUDE.md
- Skills
- MCP servers
- Subagents
- Hooks

**시기:** 세션 시작

**로드되는 내용:** 모든 CLAUDE.md 파일의 전체 콘텐츠(관리, 사용자 및 프로젝트 수준).

**상속:** Claude는 작업 디렉토리에서 루트까지 CLAUDE.md 파일을 읽고, 해당 파일에 접근할 때 하위 디렉토리에서 중첩된 파일을 검색합니다. 자세한 내용은 [CLAUDE.md 파일이 로드되는 방식](https://code.claude.com/docs/ko/memory#how-claudemd-files-load) 을 참조하세요.

CLAUDE.md를 200줄 이하로 유지하세요. 참조 자료를 skill로 이동하면 온디맨드로 로드됩니다.

## 더 알아보기

각 기능에는 설정 지침, 예시 및 구성 옵션이 있는 자신의 가이드가 있습니다.

## [CLAUDE.md](https://code.claude.com/docs/ko/memory)

프로젝트 컨텍스트, 규칙 및 지침 저장

## [Skills](https://code.claude.com/docs/ko/skills)

Claude에게 도메인 전문성 및 재사용 가능한 워크플로우 제공

## [Subagents](https://code.claude.com/docs/ko/sub-agents)

격리된 컨텍스트로 작업 오프로드

## [Agent teams](https://code.claude.com/docs/ko/agent-teams)

병렬로 작동하는 여러 세션 조정

## [MCP](https://code.claude.com/docs/ko/mcp)

Claude를 외부 서비스에 연결

## [Hooks](https://code.claude.com/docs/ko/hooks-guide)

Hook으로 워크플로우 자동화

## [Plugins](https://code.claude.com/docs/ko/plugins)

기능 세트 번들 및 공유

## [Marketplaces](https://code.claude.com/docs/ko/plugin-marketplaces)

플러그인 컬렉션 호스트 및 배포