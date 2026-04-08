# 글로벌 레벨 파일

> **한눈에 보기**
> 홈 디렉토리(`~/`)와 `~/.claude/` 폴더에 위치한 파일들. 모든 프로젝트에 걸쳐 적용되는 개인 설정이며, git에 커밋하지 않는다. 프로젝트 레벨 설정과 충돌하면 프로젝트 레벨이 우선한다.

---

## ~/.claude.json

앱 상태와 UI 설정을 저장하는 파일로, 세션 시작 시 읽힌다. `/config`에서 설정을 바꾸거나 신뢰 승인 프롬프트에 응답하면 Claude Code가 자동으로 이 파일에 기록한다. 테마, OAuth 세션, 프로젝트별 신뢰 결정, 개인용 MCP 서버 설정, UI 토글 등이 여기에 저장된다.

**저장되는 주요 항목:**
- `editorMode`: 편집기 모드 (예: `"vim"`)
- `showTurnDuration`: 응답 시간 표시 여부
- `mcpServers`: 개인용 MCP 서버 (팀 공유는 `.mcp.json` 사용)
- `projects`: 프로젝트별 신뢰 설정 및 마지막 세션 정보

```json
{
  "editorMode": "vim",
  "showTurnDuration": false,
  "mcpServers": {
    "my-tools": {
      "command": "npx",
      "args": ["-y", "@example/mcp-server"]
    }
  }
}
```

> 팀 전체가 공유해야 하는 MCP 서버는 프로젝트 루트의 `.mcp.json`에 설정한다.

---

## ~/.claude/CLAUDE.md

세션 시작 시 프로젝트의 `CLAUDE.md`와 함께 컨텍스트에 로드된다. 지침이 충돌하면 프로젝트 레벨이 우선한다. 응답 스타일, 커밋 형식, 개인 코딩 습관 등 모든 작업에 공통으로 적용할 내용을 여기에 둔다.

**작성 팁:**
- 모든 프로젝트에 로드되므로 짧게 유지한다.
- 프로젝트별로 달라지는 내용은 프로젝트 `CLAUDE.md`에 넣는다.

```markdown
# 전역 선호 설정

- 설명은 간결하게
- 커밋은 conventional commit 형식 사용
- 변경 사항 확인을 위한 터미널 명령어 함께 제시
- 상속보다 조합을 선호
```

---

## ~/.claude/settings.json

전역 기본 설정 파일로, 형식은 프로젝트의 `.claude/settings.json`과 동일하다. 항상 허용하고 싶은 명령어, 선호하는 모델, 어느 프로젝트에서나 실행하고 싶은 훅 등을 설정한다.

배열 설정(예: `permissions.allow`)은 모든 레벨의 값이 합산되고, 단일 값 설정(예: `model`)은 프로젝트 레벨이 있으면 그 값이 사용된다.

```json
{
  "permissions": {
    "allow": [
      "Bash(git log *)",
      "Bash(git diff *)"
    ]
  }
}
```

---

## ~/.claude/keybindings.json

CLI 단축키를 커스터마이징하는 파일이다. `/keybindings` 명령어로 열거나 새로 만들 수 있다. 세션 시작 시 읽히며, 이후 파일을 편집하면 세션을 재시작하지 않아도 핫 리로드된다. `Ctrl+C`, `Ctrl+D`, `Ctrl+M`은 예약 키라 변경할 수 없다.

```json
{
  "$schema": "https://www.schemastore.org/claude-code-keybindings.json",
  "bindings": [
    {
      "context": "Chat",
      "bindings": {
        "ctrl+e": "chat:externalEditor",
        "ctrl+u": null
      }
    }
  ]
}
```

위 예시는 `Ctrl+E`를 외부 편집기 열기로 바인딩하고, `Ctrl+U`를 비활성화(`null`)한다. `context` 필드는 바인딩이 적용되는 UI 영역을 지정한다.

---

## ~/.claude/projects/

Claude는 작업하면서 빌드 명령어, 디버깅 인사이트, 아키텍처 설명 등을 여기에 스스로 기록한다. 다음 세션에 이 내용을 다시 읽어 프로젝트 문맥을 이어간다. 각 프로젝트는 저장소 경로를 기준으로 별도 디렉토리를 가진다.

**구조:**
```
~/.claude/projects/
└── -Users-taewoo-dev-my-project/
    └── memory/
        ├── MEMORY.md         ← 세션 시작 시 자동으로 로드되는 인덱스
        └── debugging.md      ← 주제별 세부 파일 (필요 시 로드)
```

**동작 방식:**
- `MEMORY.md`의 첫 200줄 또는 25KB가 세션 시작 시 로드된다.
- 주제별 파일(`debugging.md`, `architecture.md` 등)은 관련 작업이 생길 때 Claude가 직접 읽는다.
- 기본 활성화. `/memory` 명령어 또는 `autoMemoryEnabled` 설정으로 끌 수 있다.
- 파일을 직접 편집하거나 삭제해도 된다. Claude가 계속 업데이트한다.

```markdown
# 메모리 인덱스

## 프로젝트
- [build-and-test.md](build-and-test.md): npm run build (~45초), Vitest, 개발 서버 3001번
- [architecture.md](architecture.md): API 클라이언트 싱글톤, 리프레시 토큰 인증

## 참조
- [debugging.md](debugging.md): 인증 토큰 순환 및 DB 연결 문제 해결
```

---

## ~/.claude/rules/

프로젝트의 `.claude/rules/`와 동일한 구조로, 모든 프로젝트에서 일관되게 지키고 싶은 코딩 스타일, 커밋 메시지 형식 등을 여기에 둔다. `paths:` frontmatter를 사용하면 특정 파일 패턴에서만 규칙을 로드할 수 있다.

---

## ~/.claude/skills/

프로젝트의 `.claude/skills/`와 동일한 구조다. 프로젝트에 관계없이 자주 쓰는 워크플로우를 여기에 스킬로 만들어두면 어디서든 `/이름`으로 호출할 수 있다.

---

## ~/.claude/commands/

프로젝트의 `.claude/commands/`와 동일한 구조다. 현재는 스킬이 명령어를 대체하고 있으므로 새 워크플로우는 `~/.claude/skills/`에 만드는 것을 권장한다.

---

## ~/.claude/output-styles/

Claude의 작동 방식을 조정하는 출력 스타일 파일을 두는 폴더로, 각 마크다운 파일이 하나의 스타일을 정의한다. 스타일을 적용하면 해당 파일 내용이 시스템 프롬프트에 추가된다. 기본적으로는 기존 소프트웨어 엔지니어링 지침이 제거되므로, 유지하고 싶다면 frontmatter에 `keep-coding-instructions: true`를 설정한다.

**적용 방법:** `/config`에서 선택하거나 `settings.json`의 `outputStyle` 키에 파일명(`.md` 제외)을 지정한다. 시스템 프롬프트는 세션 시작 시 고정(캐싱 목적)되므로, 스타일을 변경하면 **다음 세션부터** 적용된다.

**기본 제공 스타일:** `Explanatory`, `Learning`

**커스텀 스타일 예시:**
```markdown
---
description: 이유를 설명하고 작은 변경은 직접 구현하도록 유도하는 교육 모드
keep-coding-instructions: true
---

각 작업 완료 후 핵심 설계 결정을 설명하는 "이 방식을 선택한 이유" 노트를 추가하라.

10줄 미만의 변경 사항은 직접 작성하지 말고 TODO(human) 마커를 남겨 사용자가 직접 구현하도록 유도하라.
```

> `.claude/output-styles/`(프로젝트 레벨)에 동일한 이름의 스타일이 있으면 프로젝트 레벨이 우선한다.

---

## ~/.claude/agents/

프로젝트의 `.claude/agents/`와 동일한 형식이다. 프로젝트에 관계없이 자주 활용하는 서브에이전트를 여기에 두면 어디서든 `@에이전트이름`으로 호출하거나 Claude가 자동으로 위임할 수 있다.

---

## ~/.claude/agent-memory/

서브에이전트 정의 파일에 `memory: user`를 설정하면 여기에 에이전트별 메모리 디렉토리가 생성된다. 프로젝트와 관계없이 동일한 메모리를 공유해야 하는 서브에이전트에 적합하다.

**메모리 범위 비교:**
| 설정 | 저장 위치 | 공유 범위 |
|------|-----------|-----------|
| `memory: project` | `.claude/agent-memory/` | 해당 프로젝트 팀 |
| `memory: local` | `.claude/agent-memory-local/` | 본인, 해당 프로젝트만 |
| `memory: user` | `~/.claude/agent-memory/` | 본인, 모든 프로젝트 |
