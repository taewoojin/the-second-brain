# Claude Code 확장하기

> https://code.claude.com/docs/en/features-overview

---

## 개요

Claude Code는 파일 작업, 검색, 실행, 웹 접근 등의 내장 도구를 제공한다.
이 문서는 그 위에 추가할 수 있는 **확장 레이어**를 다룬다.

### 확장 기능 종류

| 기능 | 역할 |
|------|------|
| **CLAUDE.md** | 매 세션마다 Claude가 자동으로 읽는 영구 컨텍스트 |
| **Skill** | 재사용 가능한 지식 및 호출 가능한 워크플로우 |
| **MCP** | 외부 서비스·도구와 Claude를 연결 |
| **Subagent** | 격리된 컨텍스트에서 독립 실행 후 요약 반환 |
| **Agent team** | 여러 독립 세션이 공유 태스크·P2P 메시지로 협업 |
| **Hooks** | 특정 이벤트 발생 시 자동 실행되는 셸 스크립트 (Claude 개입 없음) |
| **Plugins / Marketplaces** | 위 기능들을 묶어 패키징·배포하는 단위 |

> **Skill이 가장 유연한 확장 기능.** 마크다운 파일로 지식·워크플로우·명령을 담고, `/deploy` 같은 명령으로 직접 호출하거나 Claude가 자동으로 로드할 수 있다.

---

## 어떤 기능을 써야 하나?

| 기능 | 하는 일 | 사용 시점 |
|------|---------|----------|
| **CLAUDE.md** | 매 대화마다 로드되는 영구 컨텍스트 | 프로젝트 규칙, "항상 X 해" |
| **Skill** | Claude가 활용할 수 있는 지침·지식·워크플로우 | 재사용 콘텐츠, 참조 문서, 반복 작업 |
| **Subagent** | 요약된 결과를 반환하는 격리 실행 컨텍스트 | 컨텍스트 격리, 병렬 작업, 전문화된 워커 |
| **Agent team** | 독립적인 여러 Claude Code 세션 조율 | 병렬 리서치, 신기능 개발, 여러 원인을 동시에 탐색하는 디버깅 |
| **MCP** | 외부 서비스 연결 | 외부 데이터·액션 필요 시 |
| **Hook** | 이벤트 발생 시 자동 실행되는 셸 스크립트 | Claude 개입 없이 항상 같은 동작을 보장해야 할 때 |

### 빠른 판단 기준

- 항상 알아야 하는 규칙? → **CLAUDE.md** (~500줄 이하, 넘으면 `.claude/rules/` 또는 Skill로 분리)
- 필요할 때만 참조/호출? → **Skill** (Reference: 지식 제공 / Action: `/<name>`으로 워크플로우 실행)
- 외부 서비스 연결? → **MCP** (Skill과 조합하면 시너지)
- 컨텍스트 격리 필요? → **Subagent** (Skill을 `skills:` 필드로 미리 로드 가능, `context: fork`로도 격리 가능)
- 팀원 간 소통 필요? → **Agent team** (실험적 기능, 기본 비활성화)
- Claude 개입 없이 자동화? → **Hook**
- 언어·디렉토리별 규칙? → **`.claude/rules/`** (paths 프론트매터로 파일 경로 기준 범위 지정)

> **전환 시점**: 병렬 Subagent를 운영 중 컨텍스트 한계에 부딪히거나, Subagent끼리 서로 통신이 필요하면 Agent team으로 전환.

### 비슷한 기능 구분

- **Skill vs Subagent** — Skill은 재사용 콘텐츠(지식·워크플로우), Subagent는 격리된 실행 환경. Subagent에 Skill을 미리 로드해서 조합 가능
- **CLAUDE.md vs Skill** — CLAUDE.md는 항상 로드, Skill은 필요 시 로드. CLAUDE.md가 ~500줄 넘으면 Skill로 분리
- **Subagent vs Agent team** — Subagent는 메인에 결과만 반환, Agent team은 세션끼리 직접 소통. 통신이 필요해지면 전환
- **MCP vs Skill** — MCP는 도구 제공(연결), Skill은 지식 제공(사용법). 함께 쓰면 시너지

---

## 기능 간 관계

### 레이어링 규칙

기능은 사용자, 프로젝트, 플러그인, 관리 정책 등 여러 레벨에 정의될 수 있다.

| 기능 | 레이어링 규칙 |
|------|-------------|
| **CLAUDE.md** | **추가(additive)**: 모든 레벨의 내용이 동시에 컨텍스트에 포함. 충돌 시 더 구체적인 지침이 우선 |
| **Skills** | **이름으로 오버라이드**: 동일 이름이면 우선순위에 따라 하나만 적용 (managed > user > project) |
| **Subagents** | **이름으로 오버라이드**: 동일 이름이면 우선순위에 따라 하나만 적용 (managed > CLI > project > user > plugin) |
| **MCP servers** | **이름으로 오버라이드**: local > project > user |
| **Hooks** | **병합(merge)**: 등록된 모든 훅이 매칭 이벤트에서 실행 |

### 조합 패턴

| 패턴 | 동작 방식 |
|------|----------|
| **Skill + MCP** | MCP가 연결을 제공, Skill이 사용 방법을 가르침 |
| **Skill + Subagent** | Skill이 병렬 작업을 위한 Subagent를 생성 |
| **CLAUDE.md + Skills** | CLAUDE.md에 항상 켜진 규칙, Skills에 온디맨드 참조 자료 |
| **Hook + MCP** | Hook이 MCP를 통해 외부 액션을 트리거 |

---

## 컨텍스트와 로딩

> 기능을 많이 추가할수록 컨텍스트 창이 채워지고, 불필요한 정보가 늘어 Claude의 효율이 떨어질 수 있다.

| 기능 | 로드 시점 | 로드 내용 | 컨텍스트 비용 |
|------|----------|----------|-------------|
| **CLAUDE.md** | 세션 시작 | 전체 내용 | 매 요청마다 |
| **Skills** | 세션 시작 + 사용 시 | 설명은 시작 시, 전체 내용은 사용 시 | 낮음 (설명만 매 요청)* |
| **MCP servers** | 세션 시작 | 모든 도구 정의·JSON 스키마 | 매 요청마다 |
| **Subagents** | 생성 시 | 지정된 Skill이 포함된 신규 컨텍스트 | 메인 세션과 격리 |
| **Hooks** | 트리거 시 | 없음 (외부에서 실행) | 0 |

> *`disable-model-invocation: true` 설정 시 직접 호출 전까지 Claude에게 완전히 숨겨져 비용 0.

### 주의사항

- **Skills**:
  - 설명이 모호하거나 겹치면 Claude가 잘못된 Skill을 선택할 수 있음 → `/<name>`으로 직접 호출 권장
  - Subagent에서는 온디맨드 로드 없이 시작 시 전체 미리 로드되며, 메인 세션의 Skill을 상속하지 않음
  - 외부 상태를 변경하는 Skill은 `disable-model-invocation: true` 설정 권장
- **MCP**:
  - Tool search(기본 활성화)는 MCP 도구를 컨텍스트의 최대 10%까지 로드, 나머지는 필요 시 지연 로드
  - 연결이 세션 중간에 조용히 끊길 수 있으므로 문제 시 `/mcp`로 확인
- **Hooks**: 컨텍스트에 영향을 주지 않는 사이드 이펙트(린팅, 로깅 등)에 이상적
