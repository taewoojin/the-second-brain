# Context Window Management

**출처**: [Claude Code 모범 사례](https://code.claude.com/docs/ko/best-practices) | **날짜**: 2026-04-17

## 요약

Claude의 context window는 전체 대화(메시지, 읽은 파일, 명령 출력)를 보유하며, 채워질수록 성능이 저하된다. Claude Code의 모든 모범 사례는 이 제약을 관리하는 데 귀결된다. context window는 가장 중요한 리소스다.

---

## 왜 성능이 저하되는가

LLM은 context가 가득 찰수록 이전 지시사항을 "잊기" 시작하고 실수가 늘어난다. 단일 디버깅 세션이나 코드베이스 탐색만으로도 수만 토큰을 소비할 수 있다.

---

## 관리 전략

### 재설정
- `/clear`: context 완전 재설정. 관련 없는 작업 전환 시 사용
- `Esc+Esc` / `/rewind`: 이전 체크포인트로 대화·코드 복원

### 압축
- 자동 압축: context 한계 접근 시 Claude가 자동으로 요약 (코드 패턴, 파일 상태, 주요 결정 보존)
- `/compact <지시사항>`: 수동 압축 (예: `/compact Focus on API changes`)
- CLAUDE.md에 압축 동작 커스터마이즈 가능 (`"When compacting, always preserve..."`)

### context를 소비하지 않는 도구
- `/btw`: 답변이 대화 기록에 포함되지 않는 사이드 질문
- Subagents: 별도 context window에서 탐색 후 요약만 반환

### 탐색 전략
- Subagents에 조사 위임 → 주요 대화의 context 보호
- Plan Mode: 많은 파일을 읽는 탐색을 실행과 분리

---

## 언제 `/clear`를 해야 하는가

- 관련 없는 작업으로 전환할 때
- 같은 문제를 두 번 이상 수정했을 때 (context가 실패한 접근 방식으로 오염된 상태)
- Claude가 긴 세션에서 이전 지시사항을 무시하기 시작할 때

> 누적된 수정이 있는 긴 세션보다 더 나은 프롬프트가 있는 깨끗한 세션이 거의 항상 더 낫다.

---

## 관련 항목

- [[wiki/claude-code-best-practices]]
