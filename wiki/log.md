# Wiki Log
<!-- append-only: 수정 금지, 추가만 -->

## [2026-04-13] init | 위키 초기화

## [2026-04-16] lint | 총 8개 이슈 (모순:0, 오래됨:1, 개념공백:1, 교차참조:5, 고립:0, 데이터공백:1, 분산:0)
## [2026-04-16] lint-fix | 8개 이슈 전체 수정: 교차참조 6건 추가, git-worktrees 개념 페이지 신규 생성, 에이전트팀 제한사항 내용 보강, 권한모드 오래된 주장 주의문 추가

## [2026-04-21] cleanup | wiki 대규모 정리: 3개 페이지(claude-code-작동방식-에이전트하네스, claude-code-확장기능-개요, claude-code-메모리-CLAUDE-md)만 유지, 나머지 삭제. index.md 갱신, 각 페이지 관련 항목 내 깨진 링크 7개 제거
## [2026-04-21] skill-fix | obsidian-ingest 스킬 수정: 관련 항목 작성 시 Glob으로 파일 존재 확인 후 링크 추가하도록 2-5, 2-7 단계 보강

## [2026-04-21] ingest | claude-code-context-window.md
## [2026-04-21] ingest | claude code의 일반적인 워크플로우.md
## [2026-04-21] ingest | claude code 모범 사례.md

## [2026-04-21] ingest | claude code 권한 모드 선택.md
## [2026-04-21] ingest | claude code 명령어.md
## [2026-04-21] ingest | claude-code-automate-with-hooks.md

## [2026-04-21] ingest | claude-code-directory-guide.md
## [2026-04-21] ingest | claude code 환경 변수.md
## [2026-04-21] ingest | claude code의 작동 방식.md

## [2026-04-21] ingest | claude가 프로젝트를 기억하는 방법.md
기존 claude-code-메모리-CLAUDE-md 업데이트: CLAUDE_CODE_NEW_INIT=1, CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD, InstructionsLoaded hook 디버깅, HTML 블록 주석 자동 제거, MEMORY.md 200줄 제한 vs CLAUDE.md 전체 로드 명확화
## [2026-04-21] ingest | claude-code-custom-subagent.md
신규 페이지 생성: wiki/ai/claude-code/claude-code-서브에이전트-구성.md — frontmatter 전체 필드, 모델 해결 우선순위, 도구 제어, 권한 모드, hooks, persistent memory, MCP 범위 지정, 호출 패턴

## [2026-04-21] ingest | claude code CLI 참조.md
기존 claude-code-명령어-레퍼런스.md 업데이트: CLI 서브커맨드 전체 목록, CLI 플래그 전체 목록(세션·권한·모델·출력·시스템프롬프트·환경 카테고리) 추가
## [2026-04-21] ingest | claude code Hooks 참조.md
기존 claude-code-hooks-자동화가이드.md 업데이트: 전체 hook 이벤트 레퍼런스(25개), 이벤트별 종료코드 2 동작, JSON 결정 제어 패턴, defer 패턴, HTTP hook 응답 처리, CLAUDE_ENV_FILE, skill frontmatter hook 정의 추가
## [2026-04-21] ingest | MCP를 통해 Claude Code를 도구에 연결하기.md
신규 페이지 생성: wiki/ai/claude-code/claude-code-MCP-연동.md — HTTP/SSE/stdio 설치, local/project/user 범위, .mcp.json 환경변수 확장, OAuth 인증, 동적 헤더 인증, Tool Search, 채널, 출력 제한, Claude Code를 MCP 서버로 사용
