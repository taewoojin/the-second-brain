
> https://code.claude.com/docs/en/claude-directory

# `.claude` 디렉토리 가이드

Claude Code는 세션을 시작할 때 특정 파일들을 읽어서 어떻게 동작할지 결정한다. 이 파일들이 모이는 곳이 `.claude` 디렉토리다.

## 두 가지 레벨

설정 파일은 두 위치에 존재한다.

```
your-project/          ← 프로젝트 루트
├── CLAUDE.md
├── .mcp.json
├── .worktreeinclude
└── .claude/           ← 프로젝트 레벨 설정
    ├── settings.json
    ├── settings.local.json
    ├── rules/
    ├── skills/
    ├── commands/
    ├── output-styles/
    ├── agents/
    └── agent-memory/

~/                     ← 홈 디렉토리
├── .claude.json
└── .claude/           ← 글로벌 레벨 설정
    ├── CLAUDE.md
    ├── settings.json
    ├── keybindings.json
    ├── projects/
    ├── rules/
    ├── skills/
    ├── commands/
    ├── output-styles/
    ├── agents/
    └── agent-memory/
```

- **프로젝트 레벨**: 현재 프로젝트에만 적용. 대부분 git에 커밋해서 팀과 공유한다.
- **글로벌 레벨**: 모든 프로젝트에 적용. 개인 설정이라 커밋하지 않는다.

같은 설정이 두 레벨에 모두 있으면 프로젝트 레벨이 우선한다.

## 파일별 역할 요약

### 프로젝트 레벨

| 파일/폴더 | 역할 | 로드 시점 |
|-----------|------|-----------|
| `CLAUDE.md` | Claude가 매 세션 읽는 프로젝트 지침 | 세션 시작 시 |
| `.mcp.json` | 프로젝트용 MCP 서버 설정 | 세션 시작 시 서버 연결. 도구 스키마는 도구 검색 시 필요에 따라 로드 |
| `.worktreeinclude` | 워크트리 생성 시 복사할 gitignore 파일 목록 | 워크트리 생성 시 |
| `.claude/settings.json` | 권한, 훅, 모델 등 강제 적용 설정 | 세션 전반 적용 (글로벌 설정 오버라이드) |
| `.claude/settings.local.json` | 개인 설정 오버라이드 (gitignore) | 세션 전반 적용 (사용자 편집 가능 설정 중 최우선) |
| `.claude/rules/` | 주제별 또는 경로 조건부 지침 | `paths:` 없음 → 세션 시작 시. `paths:` 있음 → 해당 파일이 컨텍스트에 들어올 때 |
| `.claude/skills/` | `/이름`으로 호출하는 재사용 프롬프트 | `/이름` 호출 시 또는 Claude가 자동 호출할 때 |
| `.claude/commands/` | 단일 파일 명령어 (skills로 대체 중) | `/이름` 호출 시 |
| `.claude/output-styles/` | 프로젝트 공유 출력 스타일 | `outputStyle` 설정 시 다음 세션 시작부터 |
| `.claude/agents/` | 독립 컨텍스트를 가진 서브에이전트 정의 | 호출될 때 (독립 컨텍스트 창에서 실행) |
| `.claude/agent-memory/` | 서브에이전트의 프로젝트 범위 메모리 | 서브에이전트 시작 시 MEMORY.md 첫 200줄(최대 25KB) |

### 글로벌 레벨

| 파일/폴더 | 역할 | 로드 시점 |
|-----------|------|-----------|
| `~/.claude.json` | 앱 상태, UI 설정, 개인 MCP 서버 | 세션 시작 시 |
| `~/.claude/CLAUDE.md` | 모든 프로젝트에 적용되는 개인 지침 | 세션 시작 시 (모든 프로젝트) |
| `~/.claude/settings.json` | 전역 기본 설정 | 세션 전반 적용 (프로젝트 설정이 없을 때 기본값) |
| `~/.claude/keybindings.json` | 키보드 단축키 커스터마이징 | 세션 시작 시 + 파일 편집 시 핫 리로드 |
| `~/.claude/projects/` | Claude가 자동으로 쌓는 프로젝트별 메모리 | MEMORY.md: 세션 시작 시 첫 200줄(최대 25KB). 주제별 파일: 관련 작업 발생 시 |
| `~/.claude/rules/` | 모든 프로젝트에 적용되는 개인 규칙 | 프로젝트 `rules/`와 동일 |
| `~/.claude/skills/` | 모든 프로젝트에서 쓸 수 있는 개인 스킬 | `/이름` 호출 시 (모든 프로젝트) |
| `~/.claude/commands/` | 모든 프로젝트에서 쓸 수 있는 개인 명령어 | `/이름` 호출 시 (모든 프로젝트) |
| `~/.claude/output-styles/` | 출력 방식을 바꾸는 스타일 파일 | `outputStyle` 설정 시 다음 세션 시작부터 |
| `~/.claude/agents/` | 모든 프로젝트에서 쓸 수 있는 개인 서브에이전트 | 호출될 때 (모든 프로젝트) |
| `~/.claude/agent-memory/` | `memory: user` 서브에이전트의 영구 메모리 | 서브에이전트 시작 시 |

## 더 읽기

- [프로젝트 레벨 파일 상세](project-level.md)
- [글로벌 레벨 파일 상세](global-level.md)
