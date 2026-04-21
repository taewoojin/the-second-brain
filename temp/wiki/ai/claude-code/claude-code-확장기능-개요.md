# Claude Code 확장 기능 개요

**출처**: https://code.claude.com/docs/en/features-overview | **날짜**: 2026-04-13

## 요약
Claude Code는 내장 도구 외에 CLAUDE.md, Skills, MCP, Subagents, Agent teams, Hooks, Plugins라는 7가지 확장 계층을 제공한다. 각 확장은 에이전틱 루프의 서로 다른 지점에 연결되며, 목적에 맞는 것을 선택하는 것이 핵심이다.

## 기능별 비교

| 기능 | 역할 | 사용 시기 | 예시 |
| --- | --- | --- | --- |
| **CLAUDE.md** | 매 대화 로드되는 영속 컨텍스트 | 프로젝트 규칙, "항상 X" 규칙 | "pnpm 사용, 커밋 전 테스트 실행" |
| **Skill** | 사용자/Claude가 호출하는 재사용 지식/워크플로우 | 반복 태스크, 참조 문서 | `/deploy` 배포 체크리스트 |
| **Subagent** | 격리된 컨텍스트에서 실행, 요약만 반환 | 컨텍스트 격리, 병렬 작업 | 수십 파일 탐색 후 핵심만 반환 |
| **Agent teams** | 독립 세션 여러 개 조율, peer-to-peer 메시징 | 병렬 연구, 신기능 개발 | 보안/성능/테스트 서브에이전트 동시 실행 |
| **MCP** | 외부 서비스 연결 | 외부 데이터/액션 필요 시 | DB 쿼리, Slack 포스팅, 브라우저 제어 |
| **Hook** | 이벤트 기반 결정론적 스크립트 | LLM 없이 자동화 | 파일 편집 후 ESLint 실행 |
| **Plugin** | Skills/Hooks/Subagents/MCP를 패키지로 번들 | 여러 저장소에서 재사용, 배포 | 팀 공유 보안 리뷰 플러그인 |

## Skill vs Subagent 구분

| 측면 | Skill | Subagent |
| --- | --- | --- |
| **정의** | 재사용 가능한 지시/지식/워크플로우 | 자체 컨텍스트로 실행되는 격리 워커 |
| **핵심 장점** | 여러 컨텍스트에서 콘텐츠 공유 | 컨텍스트 격리: 중간 작업이 주 대화에 안 남음 |
| **최적 사용** | 참조 자료, 호출 가능한 워크플로우 | 많은 파일 읽기, 병렬 작업, 특화 워커 |

## 기능 레이어링 규칙

- **CLAUDE.md**: 모든 레벨의 파일이 동시에 컨텍스트에 추가됨 (additive)
- **Skills/Subagents**: 같은 이름이 여러 레벨에 있으면 더 높은 우선순위가 우선
- **MCP 서버**: local > project > user 순 우선순위
- **Hooks**: 모든 등록된 훅이 이벤트에 맞게 실행됨 (merge)

## 단계적 도입 패턴

| 트리거 | 추가할 것 |
| --- | --- |
| Claude가 같은 실수를 두 번 반복 | CLAUDE.md에 추가 |
| 매번 같은 프롬프트를 타이핑 | 사용자 호출 Skill로 저장 |
| 같은 플레이북을 세 번째 붙여넣기 | Skill로 캡처 |
| Claude가 볼 수 없는 브라우저 탭 데이터 복사 | MCP 서버로 연결 |
| 사이드 태스크가 대화를 출력으로 넘침 | Subagent로 라우팅 |
| 매번 자동으로 일어나길 원하는 것 | Hook 작성 |
| 다른 저장소에도 같은 설정 필요 | Plugin으로 패키징 |

## 컨텍스트 비용

| 기능 | 로드 시점 | 컨텍스트 비용 |
| --- | --- | --- |
| **CLAUDE.md** | 세션 시작 | 매 요청마다 |
| **Skills** | 시작 + 사용 시 | 낮음 (설명만 항상 로드) |
| **MCP 서버** | 세션 시작 | 도구 사용 전까지 낮음 |
| **Subagents** | 생성 시 | 주 세션과 격리 |
| **Hooks** | 트리거 시 | 0 (외부 실행) |

`disable-model-invocation: true` frontmatter를 설정하면 Skill 설명이 컨텍스트에 로드되지 않아 수동 호출만 가능.

## 관련 항목
- [[wiki/ai/claude-code/claude-code-작동원리-에이전틱루프]]
- [[wiki/ai/claude-code/claude-code-hooks-활용가이드]]
- [[wiki/ai/claude-code/claude-code-서브에이전트-커스텀]]
- [[wiki/ai/claude-code/claude-code-에이전트팀]]
- [[wiki/ai/MCP-claude-code-연결]]
