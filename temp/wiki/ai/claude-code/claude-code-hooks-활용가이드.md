# Claude Code Hooks 활용 가이드

**출처**: https://code.claude.com/docs/ko/hooks-guide | https://code.claude.com/docs/en/hooks | **날짜**: 2026-04-14

## 요약
Hooks는 Claude Code 라이프사이클의 특정 지점에서 자동으로 실행되는 사용자 정의 셸 명령/HTTP 엔드포인트/LLM 프롬프트이다. LLM이 "선택"하는 것이 아니라 **결정론적으로 항상 실행**되므로, 특정 동작을 보장하거나 자동화할 때 사용한다. 가이드(`hooks-guide`)와 레퍼런스(`hooks`)를 통합 정리한 페이지.

## Hook 이벤트 목록

| Event | 발생 시점 |
| --- | --- |
| `SessionStart` | 세션 시작 또는 재개 시 |
| `UserPromptSubmit` | 프롬프트 제출 후, Claude 처리 전 |
| `PreToolUse` | 도구 호출 실행 전 (차단 가능) |
| `PermissionRequest` | 권한 다이얼로그 표시 시 |
| `PermissionDenied` | auto mode에서 도구 호출 거부 시 |
| `PostToolUse` | 도구 호출 성공 후 |
| `PostToolUseFailure` | 도구 호출 실패 후 |
| `Notification` | Claude Code 알림 전송 시 |
| `SubagentStart` / `SubagentStop` | Subagent 생성/종료 시 |
| `TaskCreated` / `TaskCompleted` | TaskCreate 도구로 태스크 생성/완료 시 |
| `Stop` | Claude 응답 완료 시 |
| `StopFailure` | API 오류로 턴 종료 시 |
| `TeammateIdle` | Agent team 멤버가 유휴 상태 직전 |
| `InstructionsLoaded` | CLAUDE.md 또는 rules 파일 로드 시 |
| `ConfigChange` | 세션 중 설정 파일 변경 시 |
| `CwdChanged` | 작업 디렉토리 변경 시 |
| `FileChanged` | 감시 파일 변경 시 (`matcher`로 파일명 지정) |
| `WorktreeCreate` / `WorktreeRemove` | worktree 생성/제거 시 |
| `PreCompact` / `PostCompact` | 컨텍스트 compaction 전/후 |
| `Elicitation` / `ElicitationResult` | MCP 서버가 사용자 입력 요청 시 |
| `SessionEnd` | 세션 종료 시 |

## 실용 예제

### 입력 대기 알림 (macOS)
```json
{
  "hooks": {
    "Notification": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "osascript -e 'display notification \"Claude Code needs your attention\" with title \"Claude Code\"'"
          }
        ]
      }
    ]
  }
}
```

### 편집 후 코드 자동 포맷 (Prettier)
```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "jq -r '.tool_input.file_path' | xargs npx prettier --write"
          }
        ]
      }
    ]
  }
}
```

### Compaction 후 컨텍스트 재주입
```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "compact",
        "hooks": [
          {
            "type": "command",
            "command": "echo 'Reminder: use Bun, not npm. Run bun test before committing.'"
          }
        ]
      }
    ]
  }
}
```

### 특정 권한 프롬프트 자동 승인
```json
{
  "hooks": {
    "PermissionRequest": [
      {
        "matcher": "ExitPlanMode",
        "hooks": [
          {
            "type": "command",
            "command": "echo '{\"hookSpecificOutput\": {\"hookEventName\": \"PermissionRequest\", \"decision\": {\"behavior\": \"allow\"}}}'"
          }
        ]
      }
    ]
  }
}
```

### `rm -rf` 명령 차단 (exit 2 방식)
```bash
#!/bin/bash
COMMAND=$(jq -r '.tool_input.command')
if echo "$COMMAND" | grep -q 'rm -rf'; then
  jq -n '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: "Destructive command blocked by hook"
    }
  }'
else
  exit 0
fi
```

## Hook 동작 원리

### 통신 방식
Hook은 stdin/stdout/stderr/종료 코드로 Claude Code와 통신한다:
- **Exit 0**: 작업 진행. `UserPromptSubmit`, `SessionStart`의 경우 stdout 텍스트가 Claude 컨텍스트에 추가됨
- **Exit 2**: 작업 차단. stderr에 이유를 쓰면 Claude가 피드백으로 받아 조정 가능
- **다른 종료 코드**: 작업 진행, stderr는 기록되지만 Claude에 표시 안 됨

### 구조화된 JSON 출력
Exit 2(차단) 또는 Exit 0 + JSON stdout(세밀한 제어) 중 선택. 혼합 금지.

```json
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "Use rg instead of grep"
  }
}
```

`PreToolUse` 결정 옵션: `"allow"` (프롬프트 없이 진행), `"deny"` (취소 + 피드백), `"ask"` (권한 프롬프트 강제)

### Matcher 패턴

| Matcher 값 | 평가 방식 |
| --- | --- |
| `"*"`, `""`, 또는 생략 | 모든 발생에 매칭 |
| 문자/숫자/`_`/`\|`만 포함 | 정확한 문자열 또는 `\|` 구분 목록 |
| 다른 문자 포함 | JavaScript 정규식 |

| 이벤트 | Matcher 필터 대상 | 예시 |
| --- | --- | --- |
| `PreToolUse`, `PostToolUse` 등 | 도구 이름 | `Bash`, `Edit\|Write`, `mcp__.*` |
| `SessionStart` | 세션 시작 방식 | `startup`, `resume`, `clear`, `compact` |
| `ConfigChange` | 설정 소스 | `user_settings`, `project_settings`, `skills` |
| `FileChanged` | 파일 이름 (basename) | `.envrc`, `.env` |

### if 필드 (v2.1.85+)
`matcher`보다 더 세밀한 필터링. 도구 이름과 인수 모두로 조건 지정 가능.

### Hook 범위 (위치별)
| 위치 | 범위 | 공유 가능 |
| --- | --- | --- |
| `~/.claude/settings.json` | 모든 프로젝트 | 아니오 (로컬 머신) |
| `.claude/settings.json` | 단일 프로젝트 | 예 (저장소 커밋 가능) |
| `.claude/settings.local.json` | 단일 프로젝트 | 아니오 (gitignore) |

## Hook 유형

- `"type": "command"` — 셸 명령 (기본)
- `"type": "http"` — 이벤트 데이터를 URL에 POST
- `"type": "prompt"` — 단일 턴 LLM 평가 (프롬프트 기반 hooks)
- `"type": "agent"` — 도구 액세스를 통한 다중 턴 검증 (에이전트 기반 hooks)

## 관련 항목
- [[wiki/ai/claude-code/claude-code-확장기능-개요]]
- [[wiki/ai/claude-code/claude-code-디렉토리-구조]]
- [[wiki/ai/claude-code/claude-code-권한모드]]
- [[wiki/ai/claude-code/claude-code-컨텍스트윈도우-시각화]]
