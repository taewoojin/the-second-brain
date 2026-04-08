
> https://code.claude.com/docs/en/context-window

# Context Window

Claude Code 세션에서 컨텍스트 윈도우에 무엇이, 어떤 순서로 로드되는지 정리한 노트

---

## 세션 시작 시 자동 로드

첫 프롬프트 전에 이미 로드된다.

| 항목                      | 설명                                 |
| ----------------------- | ---------------------------------- |
| System prompt           | 행동/툴 사용/응답 형식 지침. 터미널에서 보이지 않음     |
| Auto memory (MEMORY.md) | 이전 세션에서 저장한 메모리. 최대 200줄 또는 25KB   |
| Environment info        | 작업 디렉토리, 플랫폼, 쉘, OS 버전, git 상태     |
| MCP tools (deferred)    | 툴 이름만 나열. 스키마는 필요 시 ToolSearch로 로드 |
| Skill descriptions      | 스킬 한 줄 설명. `/compact` 후 재주입되지 않음   |
| ~/.claude/CLAUDE.md     | 전역 설정. 모든 프로젝트에 적용                 |
| Project CLAUDE.md       | 프로젝트 규칙. 200줄 이하 권장                |

> `ENABLE_TOOL_SEARCH=auto` 설정 시 MCP 스키마를 컨텍스트 10% 범위 내에서 사전 로드.  
> `ENABLE_TOOL_SEARCH=false` 설정 시 모든 스키마를 처음부터 로드.

---

## 컨텍스트 소비 패턴

### 파일 읽기

파일 읽기가 토큰의 대부분을 차지한다. 터미널엔 한 줄만 보이지만 Claude 컨텍스트엔 전체 내용이 들어간다.

```
Read src/api/auth.ts    →  2,400 토큰 (터미널: "Read auth.ts" 한 줄)
Read src/lib/tokens.ts  →  1,100 토큰
Read middleware.ts      →  1,800 토큰
```

### Path-scoped Rule 자동 로드

`.claude/rules/` 안의 규칙 파일에 `paths:` 패턴을 지정하면, 해당 패턴의 파일을 읽을 때 자동으로 컨텍스트에 로드된다.

```
Read src/api/auth.ts  →  Rule: api-conventions.md 자동 로드 (380 토큰)
Read auth.test.ts     →  Rule: testing.md 자동 로드 (290 토큰)
```

### Hook 출력

`settings.json`의 PostToolUse 훅은 파일 편집 후 자동 실행된다.

- `hookSpecificOutput.additionalContext` 필드로 반환하면 Claude 컨텍스트에 들어간다
- 일반 stdout (exit 0)은 컨텍스트에 들어가지 않음 (`Ctrl+O` verbose 모드에서만 확인 가능)
- exit code 2이면 stderr가 에러로 표시되지만, 파일은 이미 수정된 후라 차단 불가

### Subagent

서브에이전트는 별도의 컨텍스트 윈도우로 작동한다. 대규모 파일 읽기를 메인 컨텍스트에서 분리하는 데 유용하다.

```
서브에이전트가 파일 6,100 토큰 읽음
→ 메인 컨텍스트에 반환되는 건 요약 420 토큰뿐
```

서브에이전트 컨텍스트 구성:

| 항목                | 설명                                   |
| ----------------- | ------------------------------------ |
| System prompt     | 메인보다 짧음. auto memory 없음              |
| Project CLAUDE.md | 동일 파일 로드 (서브의 컨텍스트 사용)               |
| MCP/Skills        | 동일하게 접근 가능. `Agent` 툴은 기본 제외 (재귀 방지) |

### `!` 접두사 명령어

`!git status`처럼 `!` 접두사로 실행한 쉘 명령어는 명령어와 출력이 모두 컨텍스트에 들어간다. Claude가 직접 실행하지 않고도 출력을 볼 수 있다.

---

## /compact 동작

대화 전체를 구조적 요약으로 교체한다. 원본 토큰의 약 12% 크기로 압축.

압축 후에도 남는 것:
- 자동 로드 항목 (System prompt, CLAUDE.md, Memory 등)
- 압축된 대화 요약 1개 블록

압축 후 사라지는 것:
- Skill descriptions (재주입 안 됨, 실제 사용한 스킬만 보존)
- 전체 툴 출력, 중간 추론 과정

요약 블록 내용:
- 사용자 요청과 의도
- 핵심 기술 개념
- 수정된 파일과 주요 코드 스니펫
- 에러와 해결 방법
- 대기 중인 작업

---

## 실용 팁

| 상황                  | 방법                                                  |
| ------------------- | --------------------------------------------------- |
| 파일 읽기 토큰 줄이기        | 프롬프트를 구체적으로 작성 ("fix the bug in auth.ts")           |
| 대규모 조사 작업           | 서브에이전트에 위임                                          |
| CLAUDE.md 관리        | 200줄 이하 유지. 자주 안 쓰는 규칙은 path-scoped rule로 분리        |
| 사이드 이펙트가 있는 스킬      | `disable-model-invocation: true` 설정 → 호출 전까지 컨텍스트 0 |
| Claude에게 명령 출력 보여주기 | `!명령어` 접두사 사용                                       |
