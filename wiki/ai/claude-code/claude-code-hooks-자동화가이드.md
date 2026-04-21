# Claude Code Hooks 자동화 가이드

**출처**: `raw/claude-code-automate-with-hooks.md`, `raw/claude code Hooks 참조.md`
**날짜**: 2026-04-21
**keywords**: hooks, PostToolUse, PreToolUse, SessionStart, Notification, PermissionRequest, matcher, 결정론적 자동화, 프롬프트 기반 hook, 에이전트 기반 hook, HTTP hook, hook events, JSON input/output, exit codes, WorktreeCreate, Elicitation, TeammateIdle

## 요약

Hooks는 Claude Code 라이프사이클의 특정 이벤트(파일 편집, 세션 시작, 권한 요청 등)에서 실행되는 셸 명령으로, LLM 없는 결정론적 자동화를 가능하게 한다. command·prompt·agent·http 4가지 타입이 있으며, stdin으로 이벤트 JSON을 받고 stdout/stderr/종료코드로 Claude Code와 통신한다. 판단이 필요한 경우 프롬프트 기반 또는 에이전트 기반 hook을 사용할 수 있다.

## 주요 Hook 이벤트

| Event | 발생 시점 |
| --- | --- |
| `SessionStart` | 세션 시작 또는 재개 시 |
| `UserPromptSubmit` | 프롬프트 제출, Claude 처리 전 |
| `PreToolUse` | 도구 호출 전. 차단 가능 |
| `PermissionRequest` | 권한 대화 표시 시 |
| `PermissionDenied` | auto mode 분류기가 도구 호출 거부 시 |
| `PostToolUse` | 도구 호출 성공 후 |
| `Stop` | Claude가 응답 완료 시 |
| `Notification` | Claude Code가 알림 전송 시 |
| `SubagentStart` / `SubagentStop` | 서브에이전트 생성/완료 시 |
| `InstructionsLoaded` | CLAUDE.md 또는 `.claude/rules/*.md` 파일 로드 시 |
| `ConfigChange` | 세션 중 설정 파일 변경 시 |
| `CwdChanged` | 작업 디렉토리 변경 시 |
| `FileChanged` | 감시 중인 파일이 디스크에서 변경 시 |
| `PreCompact` / `PostCompact` | 컨텍스트 압축 전/후 |
| `SessionEnd` | 세션 종료 시 |

여러 hook이 일치하면 **병렬 실행**. 결정 충돌 시 가장 제한적인 답변 우선 (`deny` > `ask` > `allow`).

## 실용 패턴

### 알림 받기 (Notification hook)

Claude가 입력 대기 시 macOS 데스크톱 알림:

```json
// ~/.claude/settings.json
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

**macOS 주의**: `osascript`는 Script Editor 앱을 통해 알림을 전달함. Script Editor에 알림 권한이 없으면 자동 실패. 시스템 설정 > 알림에서 **Script Editor** 허용 필요.

### 파일 편집 후 코드 포매팅 (PostToolUse hook)

```json
// .claude/settings.json (프로젝트)
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

`jq` 필요: `brew install jq` (macOS), `apt-get install jq` (Debian/Ubuntu).

### 압축 후 컨텍스트 재주입 (SessionStart hook)

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

stdout에 쓰는 모든 텍스트가 Claude의 컨텍스트에 추가됨. `echo` 대신 `git log --oneline -5` 같은 동적 명령도 사용 가능.

### 구성 변경 감사 (ConfigChange hook)

```json
{
  "hooks": {
    "ConfigChange": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "jq -c '{timestamp: now | todate, source: .source, file: .file_path}' >> ~/claude-config-audit.log"
          }
        ]
      }
    ]
  }
}
```

matcher 필터: `user_settings`, `project_settings`, `local_settings`, `policy_settings`, `skills`

### direnv 환경 재로드 (CwdChanged hook)

```json
{
  "hooks": {
    "CwdChanged": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "direnv export bash >> \"$CLAUDE_ENV_FILE\""
          }
        ]
      }
    ]
  }
}
```

`$CLAUDE_ENV_FILE`에 작성하면 Claude Code가 각 Bash 명령 전에 적용.

### 특정 권한 프롬프트 자동 승인 (PermissionRequest hook)

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

matcher를 가능한 한 좁게 유지. `.*` 또는 빈 matcher는 모든 권한 프롬프트를 자동 승인.

## Hook 입출력 메커니즘

### 입력 (stdin)

이벤트 발생 시 Claude Code가 JSON을 stdin으로 전달:

```json
{
  "session_id": "abc123",
  "cwd": "/Users/sarah/myproject",
  "hook_event_name": "PreToolUse",
  "tool_name": "Bash",
  "tool_input": {
    "command": "npm test"
  }
}
```

### 출력 (종료 코드)

| 종료 코드 | 동작 |
| --- | --- |
| **Exit 0** | 작업 진행. `UserPromptSubmit`·`SessionStart`의 stdout은 Claude 컨텍스트에 추가 |
| **Exit 2** | 작업 차단. stderr → Claude가 피드백으로 받음 |
| **다른 코드** | 작업 진행. stderr는 기록되지만 Claude에 미표시 |

`Ctrl+O`로 자세한 모드 전환 시 트랜스크립트에서 hook 출력 확인 가능.

### 구조화된 JSON 출력

더 세밀한 제어가 필요할 때 exit 0 + JSON stdout 사용:

```json
// PreToolUse: 도구 거부 + 이유 전달
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "Use rg instead of grep for better performance"
  }
}
```

`permissionDecision` 옵션: `"allow"` (프롬프트 없이 진행) | `"deny"` (취소 + 이유 전달) | `"ask"` (사용자에게 프롬프트)

**주의**: exit 2일 때 JSON은 무시됨. 혼합 금지.

## Matcher 필터링

matcher가 없으면 해당 이벤트의 모든 발생에서 실행. 정규식 패턴 지원:

| 이벤트 | Matcher가 필터링하는 것 | 예제 |
| --- | --- | --- |
| `PreToolUse`, `PostToolUse`, `PermissionRequest` | 도구 이름 | `Bash`, `Edit\|Write`, `mcp__.*` |
| `SessionStart` | 세션 시작 방식 | `startup`, `resume`, `clear`, `compact` |
| `Notification` | 알림 유형 | `permission_prompt`, `idle_prompt` |
| `ConfigChange` | 구성 소스 | `user_settings`, `project_settings` |
| `FileChanged` | 파일 이름 (기본 이름) | `.envrc`, `.env` |

### `if` 필드로 인수 기반 필터링 (v2.1.85+)

도구 이름과 인수를 함께 필터링:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "if": "Bash(git *)",
            "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/check-git-policy.sh"
          }
        ]
      }
    ]
  }
}
```

`if`는 `PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `PermissionRequest`, `PermissionDenied`에서만 작동.

## Hook 타입

### command (기본)

셸 명령 실행. 위 모든 예제가 해당.

### prompt (LLM 단일 호출)

판단이 필요한 결정에 사용. Claude Code가 프롬프트 + 입력 데이터를 Haiku(기본값)에 전송:

```json
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "prompt",
            "prompt": "Check if all tasks are complete. If not, respond with {\"ok\": false, \"reason\": \"what remains to be done\"}."
          }
        ]
      }
    ]
  }
}
```

응답 형식: `{"ok": true}` 또는 `{"ok": false, "reason": "..."}`.

### agent (다중 턴, 도구 사용 가능)

파일 검사나 명령 실행이 필요한 검증에 사용. 기본 타임아웃 60초, 최대 50회 도구 사용:

```json
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "agent",
            "prompt": "Verify that all unit tests pass. Run the test suite and check the results.",
            "timeout": 120
          }
        ]
      }
    ]
  }
}
```

### http (HTTP 엔드포인트 POST)

이벤트 데이터를 외부 서비스로 전송:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "hooks": [
          {
            "type": "http",
            "url": "http://localhost:8080/hooks/tool-use",
            "headers": {
              "Authorization": "Bearer $MY_TOKEN"
            },
            "allowedEnvVars": ["MY_TOKEN"]
          }
        ]
      }
    ]
  }
}
```

환경 변수 보간(`$VAR_NAME`)은 `allowedEnvVars`에 나열된 변수만 해결됨.

## Hook 위치

| 위치 | 범위 | 공유 가능 |
| --- | --- | --- |
| `~/.claude/settings.json` | 모든 프로젝트 | 아니오 (컴퓨터 로컬) |
| `.claude/settings.json` | 단일 프로젝트 | 예 (리포지토리 커밋 가능) |
| `.claude/settings.local.json` | 단일 프로젝트 | 아니오 (gitignored) |
| 관리형 정책 설정 | 조직 전체 | 예 (관리자 제어) |
| Plugin `hooks/hooks.json` | 플러그인 활성화 시 | 예 |

`/hooks` 실행으로 모든 구성된 hook 탐색. `"disableAllHooks": true`로 전체 비활성화.

## 제한 사항

- `PostToolUse` hook은 도구가 이미 실행된 후이므로 작업 취소 불가
- `PermissionRequest` hook은 비대화형 모드(`-p`)에서 발생하지 않음 → 비대화형 자동화에는 `PreToolUse` 사용
- `Stop` hook은 사용자 중단 시에는 발생하지 않음
- Hook 타임아웃 기본 10분, `timeout` 필드로 hook당 설정 가능 (초 단위)
- `Stop` hook 무한 루프 방지: `stop_hook_active` 필드 확인 후 `true`이면 조기 종료

## 문제 해결

- **hook이 발생하지 않음**: `/hooks`로 구성 확인, matcher 대소문자 구분 확인
- **JSON 검증 실패**: `~/.zshrc`의 `echo` 문이 비대화형 셸에도 실행될 경우 발생. `if [[ $- == *i* ]]; then echo ...; fi`로 래핑
- **디버그**: `Ctrl+O`로 자세한 모드 전환, 또는 `claude --debug` 실행

## 전체 Hook 이벤트 목록 (레퍼런스)

아래 표는 `raw/claude code Hooks 참조.md`의 공식 레퍼런스 기준 전체 이벤트 목록.

| Event | 발생 시점 | matcher 지원 |
| --- | --- | --- |
| `SessionStart` | 세션 시작 또는 재개 | `startup`, `resume`, `clear`, `compact` |
| `UserPromptSubmit` | 프롬프트 제출, Claude 처리 전 | 없음 (모든 발생) |
| `PreToolUse` | 도구 실행 전 (차단 가능) | 도구 이름 |
| `PermissionRequest` | 권한 대화 표시 전 | 도구 이름 |
| `PermissionDenied` | auto mode 분류기가 도구 호출 거부 시. `{retry: true}` 반환으로 재시도 가능 | 도구 이름 |
| `PostToolUse` | 도구 호출 성공 후 | 도구 이름 |
| `PostToolUseFailure` | 도구 호출 실패 후 | 도구 이름 |
| `Notification` | Claude Code 알림 발생 시 | `permission_prompt`, `idle_prompt`, `auth_success`, `elicitation_dialog` |
| `SubagentStart` | subagent 생성 시 | 에이전트 유형 (`Bash`, `Explore`, `Plan`, 사용자 정의) |
| `SubagentStop` | subagent 완료 시 | SubagentStart와 동일 |
| `TaskCreated` | `TaskCreate`로 작업 생성 시 | 없음 |
| `TaskCompleted` | 작업 완료 표시 시 | 없음 |
| `Stop` | Claude 응답 완료 시 | 없음 |
| `StopFailure` | API 오류로 턴 종료 시. 출력·종료코드 무시됨 | `rate_limit`, `authentication_failed`, `billing_error`, `invalid_request`, `server_error`, `max_output_tokens`, `unknown` |
| `TeammateIdle` | 에이전트 팀 팀원이 유휴 상태 진입 직전 | 없음 |
| `InstructionsLoaded` | CLAUDE.md 또는 `.claude/rules/*.md` 로드 시. 비동기 실행, 결정 제어 없음 | `session_start`, `nested_traversal`, `path_glob_match`, `include`, `compact` |
| `ConfigChange` | 세션 중 설정 파일 변경 시 | `user_settings`, `project_settings`, `local_settings`, `policy_settings`, `skills` |
| `CwdChanged` | 작업 디렉토리 변경 시 | 없음 |
| `FileChanged` | 감시 중인 파일이 디스크에서 변경 시 | 리터럴 파일명 (`.envrc\|.env`) |
| `WorktreeCreate` | `--worktree` 또는 `isolation: "worktree"`로 worktree 생성 시. 기본 git 동작 교체 | 없음 |
| `WorktreeRemove` | worktree 제거 시 | 없음 |
| `PreCompact` | 컨텍스트 압축 전 | `manual`, `auto` |
| `PostCompact` | 컨텍스트 압축 후 | `manual`, `auto` |
| `Elicitation` | MCP 서버가 도구 호출 중 사용자 입력 요청 시 | MCP 서버 이름 |
| `ElicitationResult` | 사용자가 MCP elicitation에 응답 후, 서버로 전송 전 | MCP 서버 이름 |
| `SessionEnd` | 세션 종료 시 | `clear`, `resume`, `logout`, `prompt_input_exit`, `bypass_permissions_disabled`, `other` |

### 종료 코드 2 이벤트별 동작

| Hook 이벤트 | 차단 가능? | 종료 코드 2에서 발생하는 것 |
| --- | --- | --- |
| `PreToolUse` | 예 | 도구 호출 차단 |
| `PermissionRequest` | 예 | 권한 거부 |
| `UserPromptSubmit` | 예 | 프롬프트 처리 차단 및 지움 |
| `Stop` | 예 | Claude 중지 방지, 대화 계속 |
| `SubagentStop` | 예 | subagent 중지 방지 |
| `TeammateIdle` | 예 | 팀원 유휴 방지 (계속 작업) |
| `TaskCreated` | 예 | 작업 생성 롤백 |
| `TaskCompleted` | 예 | 작업 완료 표시 방지 |
| `ConfigChange` | 예 | 구성 변경 적용 차단 (`policy_settings` 제외) |
| `PreCompact` | 예 | 압축 차단 |
| `Elicitation` | 예 | elicitation 거부 |
| `ElicitationResult` | 예 | 응답 차단 (작업 거부됨) |
| `WorktreeCreate` | 예 | 0이 아닌 종료 코드 = worktree 생성 실패 |
| `PostToolUse`, `PostToolUseFailure` | 아니오 | Claude에게 stderr 표시 (도구 이미 실행됨) |
| `StopFailure` | 아니오 | 출력·종료코드 무시됨 |
| `PermissionDenied` | 아니오 | 종료코드·stderr 무시됨. JSON `{retry: true}`로 재시도 신호 |
| `Notification` | 아니오 | 사용자에게만 stderr 표시 |
| `SessionStart`, `SessionEnd` | 아니오 | 사용자에게만 stderr 표시 |
| `CwdChanged`, `FileChanged` | 아니오 | 사용자에게만 stderr 표시 |
| `PostCompact`, `InstructionsLoaded`, `WorktreeRemove` | 아니오 | 무시 또는 로깅만 |

### JSON 결정 제어 패턴

종료 코드 대신 JSON으로 더 세밀하게 제어. 종료 0 + JSON stdout 방식. 둘 혼용 불가.

| 이벤트 | 결정 패턴 | 주요 필드 |
| --- | --- | --- |
| `UserPromptSubmit`, `PostToolUse`, `Stop`, `SubagentStop`, `ConfigChange`, `PreCompact` | 최상위 `decision` | `decision: "block"`, `reason` |
| `PreToolUse` | `hookSpecificOutput` | `permissionDecision` (allow/deny/ask/defer), `permissionDecisionReason`, `updatedInput`, `additionalContext` |
| `PermissionRequest` | `hookSpecificOutput` | `decision.behavior` (allow/deny), `updatedInput`, `updatedPermissions`, `message`, `interrupt` |
| `PermissionDenied` | `hookSpecificOutput` | `retry: true` |
| `WorktreeCreate` | 경로 반환 | 명령 hook: stdout에 경로 출력; HTTP hook: `hookSpecificOutput.worktreePath` |
| `Elicitation`, `ElicitationResult` | `hookSpecificOutput` | `action` (accept/decline/cancel), `content` |
| `SessionStart`, `UserPromptSubmit` | stdout 또는 `additionalContext` | stdout 텍스트가 Claude 컨텍스트에 추가됨 |

#### 범용 JSON 출력 필드 (모든 이벤트 공통)

| 필드 | 기본값 | 설명 |
| --- | --- | --- |
| `continue` | `true` | `false`이면 모든 이벤트 특정 결정보다 우선하여 Claude 완전 중지 |
| `stopReason` | 없음 | `continue: false`일 때 사용자에게 표시되는 메시지. Claude에게는 표시 안 됨 |
| `suppressOutput` | `false` | `true`이면 디버그 로그에서 stdout 숨김 |
| `systemMessage` | 없음 | 사용자에게 표시되는 경고 메시지 |

### PreToolUse defer 패턴 (Agent SDK 연동)

비대화형 모드(`-p`)에서 Claude를 도구 호출에서 일시 중지하고 외부 UI에서 입력을 수집한 후 재개하는 패턴. Claude Code v2.1.89 이상 필요.

1. Claude가 `AskUserQuestion` 호출 → `PreToolUse` hook 발생
2. hook이 `permissionDecision: "defer"` 반환 → 프로세스가 `stop_reason: "tool_deferred"`로 종료
3. 호출 프로세스가 `deferred_tool_use` 페이로드 읽고 자체 UI에서 응답 수집
4. `claude -p --resume <session-id>` 실행 → 동일 도구 호출이 `PreToolUse` 재발생
5. hook이 `permissionDecision: "allow"` + `updatedInput`(답변 포함) 반환 → 계속 실행

### HTTP hook 응답 처리

명령 hook과 달리 상태 코드만으로 차단 불가. 차단하려면 `decision: "block"` 포함된 2xx 응답 반환 필요.

| 응답 | 동작 |
| --- | --- |
| 2xx 빈 본문 | 성공 (exit 0과 동일) |
| 2xx 텍스트 본문 | 성공, 텍스트가 컨텍스트에 추가 |
| 2xx JSON 본문 | 성공, 명령 hook과 동일한 JSON 출력 스키마로 파싱 |
| 2xx가 아닌 상태 | 비차단 오류, 실행 계속 |
| 연결 실패 또는 시간 초과 | 비차단 오류, 실행 계속 |

### 환경 변수 유지 (`CLAUDE_ENV_FILE`)

`SessionStart`, `CwdChanged`, `FileChanged` hook에서만 사용 가능. `$CLAUDE_ENV_FILE` 경로에 `export` 문 작성하면 이후 모든 Bash 명령에서 사용 가능.

```shellscript
#!/bin/bash
if [ -n "$CLAUDE_ENV_FILE" ]; then
  echo 'export NODE_ENV=production' >> "$CLAUDE_ENV_FILE"
  # direnv 같은 설정 명령의 환경 변경도 캡처 가능:
  # direnv export bash >> "$CLAUDE_ENV_FILE"
fi
exit 0
```

### Skill·에이전트 frontmatter에서 Hook 정의

설정 파일뿐만 아니라 skill/subagent frontmatter에서도 직접 정의 가능. 컴포넌트가 활성화된 동안만 실행되고, 완료 시 정리됨.

```yaml
---
name: secure-operations
description: Perform operations with security checks
hooks:
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "./scripts/security-check.sh"
---
```

`once: true` 필드: skill/에이전트에서만 유효. 설정 파일에서는 무시됨. 세션당 한 번만 실행 후 제거.

## 관련 항목

- [[wiki/ai/claude-code/claude-code-확장기능-개요]]
- [[wiki/ai/claude-code/claude-code-권한모드]]
- [[wiki/ai/claude-code/claude-code-작동방식-에이전트하네스]]
- [[wiki/ai/claude-code/claude-code-MCP-연동]]
