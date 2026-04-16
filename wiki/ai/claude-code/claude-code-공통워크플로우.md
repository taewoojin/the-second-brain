# Claude Code 공통 워크플로우

**출처**: https://code.claude.com/docs/en/common-workflows | **날짜**: 2026-04-13

## 요약
Claude Code로 일상적인 개발 작업을 수행하는 실용적인 워크플로우를 정리한다. 코드베이스 탐색, 버그 수정, 리팩토링, 테스트 작성, PR 생성, Plan Mode 활용이 주요 패턴이다.

## 코드베이스 이해

**빠른 구조 파악** (신규 프로젝트):
- 넓은 질문에서 시작, 특정 영역으로 좁혀가기
- 코딩 규칙과 패턴 질문
- 프로젝트 특화 용어 정리 요청

**관련 코드 찾기**:
- 찾는 것을 구체적으로 명시
- 프로젝트 도메인 언어 사용
- 코드 인텔리전스 플러그인 설치로 "정의로 이동", "참조 찾기" 내비게이션 활성화

## 버그 수정

효과적인 버그 수정 접근:
- 재현 명령과 스택 트레이스 제공
- 재현 단계 명시
- 간헐적/일관적 여부 알리기

예시 프롬프트:
```
세션 만료 후 로그인 실패. src/auth/ 인증 플로우 확인.
토큰 갱신 쪽 특히. 실패 재현 테스트 작성 후 수정해줘.
```

## 코드 리팩토링

- 현대 패턴으로 변환 시 이점 설명 요청
- 하위 호환성 유지가 필요하면 명시
- 작고 테스트 가능한 단위로 나눠서 진행

## Subagent 활용

```
Use specialized subagents to handle specific tasks more effectively.
```

팁:
- 프로젝트별 Subagent는 `.claude/agents/`에 생성 (팀 공유)
- `description` 필드를 명확하게 작성해야 자동 위임이 정확함
- 각 Subagent의 도구 접근을 실제 필요한 것만으로 제한

## Plan Mode 활용

Plan Mode: Claude가 읽기 전용 작업으로만 분석하고 계획 수립. 구현 전 검토 가능.

**Plan Mode 권장 상황**:
- 여러 파일에 걸친 구현
- 변경 전 코드베이스 탐색
- 방향을 반복적으로 조정하며 개발

**Plan Mode 진입 방법**:
```bash
# 새 세션으로 시작
claude --permission-mode plan

# 비대화형 모드
claude --permission-mode plan -p "인증 시스템 분석하고 개선 방향 제안해줘"
```

또는 세션 중 `Shift+Tab`으로 모드 순환: Normal → Auto-Accept (`⏵⏵ accept edits on`) → Plan (`⏸ plan mode on`)

**Plan Mode 기본값 설정**:
```json
// .claude/settings.json
{
  "permissions": {
    "defaultMode": "plan"
  }
}
```

계획 수립 후 `Ctrl+G`로 기본 텍스트 에디터에서 직접 편집 가능.

## 테스트 작성

효과적인 테스트 요청:
- 검증할 동작을 구체적으로 명시
- Claude가 기존 테스트 파일 패턴 자동 분석 (스타일, 프레임워크, 어서션 패턴 일치)
- 엣지 케이스 식별 요청 (오류 조건, 경계값, 예상치 못한 입력)

## PR 생성

```
현재 변경사항으로 PR 만들어줘. 변경 내용 요약과 테스트 방법 포함해서.
```

Claude는 `gh` CLI를 사용해 직접 PR 생성 가능.

## 병렬 세션 (git worktrees)

```bash
# 새 worktree 생성
git worktree add ../project-feature feature-branch

# 각 worktree 디렉토리에서 별도 claude 세션 실행
```

각 worktree가 별도 디렉토리 → 각 Claude 세션은 독립적 컨텍스트.

## 관련 항목
- [[wiki/ai/claude-code/claude-code-모범사례]]
- [[wiki/ai/claude-code/claude-code-권한모드]]
- [[wiki/ai/claude-code/claude-code-서브에이전트-커스텀]]
