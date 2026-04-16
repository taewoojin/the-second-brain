# Git Worktrees

**출처**: https://git-scm.com/docs/git-worktree | **날짜**: 2026-04-16

## 요약
Git worktrees는 하나의 git 저장소에서 여러 작업 디렉토리를 동시에 체크아웃할 수 있는 기능이다. Claude Code에서는 병렬 세션 간 파일 충돌 없이 각각 독립적인 컨텍스트로 작업하기 위한 핵심 메커니즘으로 활용된다.

## 등장 맥락

Claude Code의 병렬 세션 패턴에서 등장. `claude-code-모범사례.md`, `claude-code-공통워크플로우.md`, `claude-code-에이전트팀.md` 세 페이지가 각각 병렬 세션의 전제 조건으로 언급한다. 단일 저장소에서 브랜치를 전환하지 않고 여러 Claude 인스턴스가 동시에 다른 디렉토리를 수정할 수 있게 한다.

## 기본 사용법

```bash
# 새 worktree 생성 (feature-branch 브랜치, ./feature-dir 디렉토리)
git worktree add ../feature-dir feature-branch

# 새 브랜치와 함께 worktree 생성
git worktree add -b new-branch ../new-dir main

# 현재 worktree 목록 확인
git worktree list

# worktree 제거
git worktree remove ../feature-dir
```

## Claude Code에서의 활용 패턴

| 상황 | 방법 |
| --- | --- |
| 동일 태스크의 다른 접근 방식 탐색 | 각 접근마다 별도 worktree → 별도 Claude 세션 |
| 프론트엔드/백엔드 병렬 작업 | 작업 영역별 worktree → 파일 충돌 방지 |
| 리팩토링 중 안전망 유지 | 기존 브랜치 worktree를 그대로 두고 새 worktree에서 실험 |

### `.worktreeinclude` 활용

`.worktreeinclude` 파일에 새 worktree 생성 시 복사할 파일 목록을 지정할 수 있다 (gitignore 형식). 예: `.env`, `.env.local` 같은 환경 파일을 새 worktree에도 자동 복사.

## 주요 특성

- **공유 git 히스토리**: 모든 worktree가 동일한 `.git/` 디렉토리를 참조한다.
- **브랜치 독점**: 하나의 브랜치는 한 번에 하나의 worktree에서만 체크아웃 가능.
- **독립적 작업 디렉토리**: 각 worktree의 파일 변경은 다른 worktree에 영향 없음.
- **공유 스태시/refs**: 스태시, 태그 등은 모든 worktree에서 공유.

## 관련 항목
- [[wiki/ai/claude-code/claude-code-모범사례]]
- [[wiki/ai/claude-code/claude-code-공통워크플로우]]
- [[wiki/ai/claude-code/claude-code-에이전트팀]]
- [[wiki/ai/claude-code/claude-code-디렉토리-구조]]
