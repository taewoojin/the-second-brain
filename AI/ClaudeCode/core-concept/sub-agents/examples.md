# Sub-agent 예시

> 출처: https://code.claude.com/docs/en/sub-agents#example-subagents

## 한 눈에 보기

각 예시의 핵심 설계 포인트를 정리했다. 전체 마크다운은 공식 문서에서 확인한다.

## 설계 원칙

- 하나의 Sub-agent는 하나의 특정 작업에 집중한다
- `description`을 구체적으로 작성한다 (Claude가 위임 시점 판단에 사용)
- 필요한 도구만 허용한다 (보안 + 집중도)
- 프로젝트 Sub-agent는 버전 관리에 포함해 팀과 공유한다

---

## Code Reviewer

> [공식 문서 전체 마크다운](https://code.claude.com/docs/en/sub-agents#code-reviewer)

핵심 포인트:
- `tools: Read, Grep, Glob, Bash` — Edit과 Write를 제외해 코드를 수정하지 않는 읽기 전용 리뷰어
- `description`에 "Use immediately after writing or modifying code" 포함 → 코드 변경 직후 자동 위임 유도
- 피드백을 우선순위별로 구조화 (Critical → Warnings → Suggestions)

---

## Debugger

> [공식 문서 전체 마크다운](https://code.claude.com/docs/en/sub-agents#debugger)

핵심 포인트:
- `tools: Read, Edit, Bash, Grep, Glob` — Edit 포함. 단순 분석이 아닌 실제 수정까지 담당
- 워크플로가 명확하게 정의됨: 오류 캡처 → 재현 → 원인 분리 → 수정 → 검증
- 증상이 아닌 근본 원인 해결에 집중하도록 프롬프트를 설계

---

## Data Scientist

> [공식 문서 전체 마크다운](https://code.claude.com/docs/en/sub-agents#data-scientist)

핵심 포인트:
- `model: sonnet` — 도메인 특화 분석 작업에 더 높은 모델 능력 명시 지정
- SQL/BigQuery 같은 특정 기술 스택에 특화된 도메인 전용 Sub-agent 예시
- 일반 코딩 외 워크플로에도 Sub-agent를 적용할 수 있음을 보여줌

---

## Database Query Validator

> [공식 문서 전체 마크다운](https://code.claude.com/docs/en/sub-agents#database-query-validator)

핵심 포인트:
- `tools: Bash` + `PreToolUse` Hook 조합 — `tools` 필드만으로 제어하기 어려운 조건부 제한을 Hook으로 구현
- `$TOOL_INPUT`을 통해 Hook 스크립트가 실제 실행될 명령어를 stdin으로 받아 SQL 쓰기 작업 차단
- Hook 스크립트가 exit code 2를 반환하면 Claude Code가 해당 도구 호출을 차단하고 오류 메시지를 Claude에게 전달

이 패턴은 "Bash는 허용하되 SELECT만 가능"처럼 도구 수준이 아닌 **명령어 수준**의 제어가 필요할 때 사용한다.
