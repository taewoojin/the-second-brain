# Claude Code 메모리와 CLAUDE.md

**출처**: https://code.claude.com/docs/en/memory | **날짜**: 2026-04-13

## 요약
Claude Code는 두 가지 메모리 메커니즘으로 세션 간 지식을 유지한다. CLAUDE.md는 사람이 작성하는 영속 지시 파일이고, Auto memory는 Claude가 세션 중 자동으로 학습을 저장하는 시스템이다.

## CLAUDE.md vs Auto Memory

|  | CLAUDE.md | Auto memory |
| --- | --- | --- |
| **작성 주체** | 사람 | Claude |
| **포함 내용** | 지시와 규칙 | 학습 내용과 패턴 |
| **범위** | 프로젝트, 사용자, 조직 | 작업 트리별 |
| **로드 방식** | 매 세션 전체 로드 | 매 세션 첫 200줄 또는 25KB |
| **사용 목적** | 코딩 표준, 워크플로우, 아키텍처 | 빌드 명령, 디버깅 인사이트, 발견된 선호도 |

## CLAUDE.md 파일 범위

| 범위 | 위치 | 용도 |
| --- | --- | --- |
| 관리형 정책 | `/Library/Application Support/ClaudeCode/CLAUDE.md` (macOS) | 조직 전체 지시 (IT/DevOps 관리) |
| 프로젝트 | `./CLAUDE.md` 또는 `./.claude/CLAUDE.md` | 팀 공유 프로젝트 지시 |
| 사용자 | `~/.claude/CLAUDE.md` | 모든 프로젝트 개인 선호 |
| 로컬 | `./CLAUDE.local.md` (gitignore 처리 필요) | 개인 프로젝트별 선호 |

## CLAUDE.md 로드 방식

Claude Code는 현재 작업 디렉토리에서 위로 트리 탐색:
- `foo/bar/CLAUDE.md`, `foo/CLAUDE.md`, `CLAUDE.md` 순으로 모두 로드
- 모든 발견된 파일은 덮어쓰는 게 아니라 **concatenate** (연결)
- 같은 디렉토리에서 충돌 시 `CLAUDE.local.md`가 `CLAUDE.md` 뒤에 오므로 개인 노트가 우선
- 서브디렉토리의 CLAUDE.md는 해당 디렉토리 파일 읽을 때 로드 (시작 시 아님)

## 효과적인 CLAUDE.md 작성법

**추가해야 할 때**:
- Claude가 같은 실수를 두 번 반복할 때
- 코드 리뷰에서 Claude가 알았어야 할 것을 발견할 때
- 지난 세션과 같은 수정/설명을 채팅에 타이핑할 때
- 신규 팀원도 알아야 할 컨텍스트일 때

**작성 원칙**:
- 200줄 이하 유지 (더 길면 준수율 저하)
- 구체적이고 검증 가능한 지시 작성
  - ✅ "2칸 들여쓰기 사용" vs ❌ "코드 포맷 올바르게"
  - ✅ "커밋 전 `npm test` 실행" vs ❌ "변경사항 테스트해"
- 마크다운 헤더와 불릿으로 구조화
- 모순되는 규칙 없도록 주기적으로 검토
- CLAUDE.md에 넣을 내용이 아닌 것: 특정 태스크용 다중 단계 절차 → Skill로 이동

## 파일 임포트 (`@` 문법)

```markdown
See @README for project overview and @package.json for available npm commands.

# Additional Instructions
- git workflow @docs/git-instructions.md
```

- 임포트된 파일은 세션 시작 시 함께 로드
- 상대 경로는 CLAUDE.md 위치 기준
- 최대 5단계 재귀 임포트 가능

## `.claude/rules/` 로 모듈화

규모 큰 프로젝트에서 주제별로 지시 분리:

```
.claude/
├── CLAUDE.md           # 메인 프로젝트 지시
└── rules/
    ├── code-style.md   # 코드 스타일 가이드
    ├── testing.md      # 테스트 규칙
    └── security.md     # 보안 요구사항
```

**경로 범위 규칙** — 특정 파일 타입에만 로드되도록:
```markdown
---
paths:
  - "src/api/**/*.ts"
---

# API Development Rules
- 모든 API 엔드포인트는 입력 검증 포함 필수
```

`paths` 없는 규칙은 세션 시작 시 로드. `paths` 있는 규칙은 매칭 파일 열 때만 로드.

## Auto Memory

Claude가 세션 중 자동으로 학습 내용을 저장:
- 위치: `~/.claude/projects/<project>/memory/`
- `MEMORY.md`: 세션 시작 시 첫 200줄 또는 25KB 로드
- 주제별 파일 (예: `debugging.md`): 시작 시 로드 안 됨, 필요 시 참조

**Auto memory 관리**:
- `/memory` 명령으로 로드된 파일과 auto-memory 항목 확인
- `autoMemoryEnabled: false` 설정으로 비활성화 가능
- 파일은 일반 마크다운 — 언제든 편집/삭제 가능

## AGENTS.md와의 호환

다른 AI 에이전트를 위해 이미 `AGENTS.md`가 있는 저장소:
```markdown
# CLAUDE.md
@AGENTS.md

## Claude Code
Use plan mode for changes under `src/billing/`.
```

## 관련 항목
- [[wiki/ai/claude-code/claude-code-디렉토리-구조]]
- [[wiki/ai/claude-code/claude-code-컨텍스트윈도우-시각화]]
- [[wiki/ai/claude-code/claude-code-모범사례]]
