# Sub-agent 개요

> 출처: https://code.claude.com/docs/en/sub-agents

## 한 눈에 보기

Sub-agent는 특정 작업만 담당하는 독립 AI 어시스턴트다. 자체 컨텍스트 창, 시스템 프롬프트, 도구 접근 권한을 갖고, Claude가 작업을 위임하면 독립적으로 실행하고 결과를 반환한다. Claude Code에는 Explore, Plan, General-purpose 등 내장 Sub-agent가 있으며, 직접 커스텀 Sub-agent를 만들 수도 있다.

## Sub-agent란?

Sub-agent는 특정 유형의 작업을 처리하는 전문화된 AI 어시스턴트다. 각 Sub-agent는 다음을 독립적으로 갖는다.

- 자체 컨텍스트 창: 메인 대화와 별도로 운영
- 커스텀 시스템 프롬프트: 특정 도메인에 집중한 지침
- 제한된 도구 접근: 필요한 도구만 허용
- 독립적인 권한: 메인 대화와 다른 권한 모드 적용 가능

Claude는 각 Sub-agent의 `description` 필드를 보고 어떤 작업을 위임할지 판단한다.

## Sub-agent를 쓰는 이유

| 목적 | 설명 |
|------|------|
| **컨텍스트 보존** | 탐색·구현 작업을 메인 대화 밖에서 처리 |
| **제약 강제** | Sub-agent가 사용할 수 있는 도구를 제한 |
| **설정 재사용** | User-level Sub-agent로 모든 프로젝트에서 공유 |
| **동작 특화** | 특정 도메인에 집중한 시스템 프롬프트 적용 |
| **비용 절감** | Haiku 같은 빠르고 저렴한 모델로 라우팅 |

## Sub-agent vs Agent Teams

Sub-agent는 **단일 세션 내** 에서 동작한다. 병렬로 여러 에이전트가 서로 통신하며 협업해야 하는 경우에는 [Agent Teams](https://code.claude.com/docs/en/agent-teams)를 사용한다.

```
Sub-agent  → 단일 세션, 순차/백그라운드 위임
Agent Teams → 별도 세션, 병렬 협업
```

## 내장 Sub-agent

Claude Code에 기본 탑재된 Sub-agent들이다. Claude가 필요에 따라 자동으로 사용하며, 상위 대화의 권한을 상속받되 도구는 추가 제한이 적용된다.

### Explore

코드베이스 탐색에 특화된 빠른 읽기 전용 에이전트.

- **모델**: Haiku (빠른 응답)
- **도구**: 읽기 전용 (Write, Edit 불가)
- **용도**: 파일 탐색, 코드 검색, 코드베이스 분석

코드를 수정하지 않고 이해해야 할 때 Claude가 위임한다. 탐색 결과가 메인 대화 컨텍스트를 채우지 않는다.

호출 시 Claude가 탐색 깊이를 지정한다: `quick`(빠른 조회), `medium`(균형 탐색), `very thorough`(포괄 분석).

### Plan

[Plan Mode](https://code.claude.com/docs/en/common-workflows#use-plan-mode-for-safe-code-analysis)에서 컨텍스트를 수집하는 리서치 에이전트.

- **모델**: 메인 대화 상속
- **도구**: 읽기 전용 (Write, Edit 불가)
- **용도**: 계획 수립을 위한 코드베이스 조사

Plan Mode에서 코드베이스를 이해해야 할 때 Claude가 위임한다. Sub-agent는 다른 Sub-agent를 생성할 수 없기 때문에, Plan Mode에서의 무한 중첩을 방지하면서도 필요한 컨텍스트를 수집할 수 있다.

### General-purpose

탐색과 수정이 모두 필요한 복잡한 작업을 처리하는 범용 에이전트.

- **모델**: 메인 대화 상속
- **도구**: 전체 도구
- **용도**: 복잡한 리서치, 다단계 작업, 코드 수정

탐색과 수정이 동시에 필요하거나, 복잡한 추론이 필요하거나, 여러 단계가 순서대로 이어지는 작업에서 사용된다.

### 그 외 (Other)

자동으로 호출되는 특수 목적 에이전트들.

| 에이전트 | 모델 | 사용 시점 |
|----------|------|-----------|
| statusline-setup | Sonnet | `/statusline` 실행 시 |
| Claude Code Guide | Haiku | Claude Code 기능 관련 질문 시 |
