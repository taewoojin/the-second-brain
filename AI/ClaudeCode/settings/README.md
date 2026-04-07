---
한눈에 보기:
- settings.json은 4개 scope(Managed/User/Project/Local)로 계층화되며, 구체적일수록 우선순위가 높다
- 설정 방법: `/config` 명령어(인터랙티브) 또는 settings.json 직접 편집
- `/status` 명령어로 현재 활성 설정과 출처를 확인할 수 있다
- 원문: https://code.claude.com/docs/en/settings
---

# 설정 개요(Settings Overview)

## scope 시스템

Claude Code는 설정이 어디에 적용되고 누구와 공유되는지를 scope로 관리한다.

| Scope | 위치 | 적용 대상 | 팀 공유 |
|:--|:--|:--|:--|
| **Managed** | 서버 또는 시스템 레벨 `managed-settings.json` | 머신의 모든 사용자 | Yes (IT 배포) |
| **User** | `~/.claude/settings.json` | 나, 모든 프로젝트에 적용 | No |
| **Project** | `.claude/settings.json` | 저장소의 모든 협업자 | Yes (git 커밋) |
| **Local** | `.claude/settings.local.json` | 나, 이 저장소에만 적용 | No (gitignore) |

### 언제 어떤 scope를 쓰는가

**User scope** — 모든 프로젝트에서 쓰고 싶은 개인 설정 (언어, 모델, 에디터 설정 등)

**Project scope** — 팀 전체가 공유해야 하는 설정 (권한 규칙, hooks, MCP 서버 등). `.claude/settings.json`으로 git에 커밋한다.

**Local scope** — 팀과 공유하기 전 테스트하거나, 나만의 프로젝트별 오버라이드. `.claude/settings.local.json`은 자동으로 gitignore된다.

**Managed scope** — IT/DevOps가 조직 전체에 강제 배포하는 정책. 다른 scope에서 덮어쓸 수 없다.

## 우선순위

높은 쪽이 낮은 쪽을 덮어쓴다:

```
Managed (최고, 덮어쓸 수 없음)
  ↓
Command line arguments (세션 임시 오버라이드)
  ↓
Local (.claude/settings.local.json)
  ↓
Project (.claude/settings.json)
  ↓
User (~/.claude/settings.json, 최저)
```

> **배열 설정의 병합**: `permissions.allow`, `sandbox.filesystem.allowWrite` 같은 배열 값은 덮어쓰지 않고 **합쳐진다(concatenate + deduplicate)**. 예: managed에서 `["/opt/tools"]`, user에서 `["~/.kube"]`를 설정하면 두 경로 모두 적용된다.

## 파일 위치

| 기능 | User | Project | Local |
|:--|:--|:--|:--|
| **Settings** | `~/.claude/settings.json` | `.claude/settings.json` | `.claude/settings.local.json` |
| **MCP 서버** | `~/.claude.json` | `.mcp.json` | `~/.claude.json` (per-project) |
| **Plugins** | `~/.claude/settings.json` | `.claude/settings.json` | `.claude/settings.local.json` |
| **CLAUDE.md** | `~/.claude/CLAUDE.md` | `CLAUDE.md` 또는 `.claude/CLAUDE.md` | `CLAUDE.local.md` |

> `~/.claude.json`에는 테마, 알림, 에디터 모드 등 UI 설정과 OAuth 세션, MCP 서버 설정, per-project 상태가 저장된다. `settings.json`과는 별도 파일이다.

## 설정 방법

**인터랙티브:** Claude Code 내에서 `/config` 명령어 실행 → 탭 형식의 설정 UI

**직접 편집:** `settings.json`을 열어 수정. VS Code/Cursor 등에서 자동완성을 사용하려면 파일 상단에 추가:

```json
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json"
}
```

**현재 설정 확인:** `/status` 명령어로 활성 설정과 출처(어떤 scope에서 왔는지) 확인. 설정 파일에 오류가 있으면 여기서 보고된다.

> Claude Code는 설정 파일의 타임스탬프 백업을 자동으로 생성하며 최근 5개를 보관한다.

## See also

- [권한 설정 상세](permissions.md) — allow/deny/ask 규칙 문법
- [플러그인 설정](plugins.md) — enabledPlugins, extraKnownMarketplaces
- [전체 설정 목록](available-settings.md) — 모든 settings.json 필드
- [치트 시트](cheatsheet.md) — 자주 쓰는 설정 빠른 참조
- [환경변수 레퍼런스](https://code.claude.com/docs/en/env-vars) — env vars 전체 목록
- [권한 시스템 상세](https://code.claude.com/docs/en/permissions) — rule syntax, tool별 패턴, managed policy
