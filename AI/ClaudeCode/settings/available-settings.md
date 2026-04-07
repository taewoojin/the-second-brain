---
한눈에 보기:
- 일반 설정은 User/Project/Local scope에서 사용 가능, Managed-only는 별도 섹션으로 분리
- ~/.claude.json은 settings.json과 다른 파일로 UI/세션 설정을 담는다
- `$schema` 추가 시 VS Code 등에서 자동완성 가능
---

# 전체 설정 목록(Available Settings)

`settings.json`에 `$schema`를 추가하면 에디터 자동완성과 유효성 검사를 사용할 수 있다:

```json
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json"
}
```

## 일반 설정

User/Project/Local scope의 `settings.json`에서 사용할 수 있는 필드.

| 키                              | 설명                                                                                       | 예시                                                               |
| :----------------------------- | :--------------------------------------------------------------------------------------- | :--------------------------------------------------------------- |
| `agent`                        | 메인 스레드를 named subagent로 실행. 해당 subagent의 시스템 프롬프트와 툴 제한 적용                               | `"code-reviewer"`                                                |
| `allowedHttpHookUrls`          | HTTP hook이 요청할 수 있는 URL 패턴 허용 목록. `*` 와일드카드 지원. 배열 병합                                    | `["https://hooks.example.com/*"]`                                |
| `alwaysThinkingEnabled`        | 모든 세션에서 extended thinking을 기본으로 활성화                                                      | `true`                                                           |
| `apiKeyHelper`                 | 인증 값을 생성하는 커스텀 스크립트 (`/bin/sh`로 실행). `X-Api-Key`, `Authorization: Bearer`로 전송            | `"/bin/generate_key.sh"`                                         |
| `attribution`                  | git 커밋과 PR에 추가되는 서명 문구. 빈 문자열로 설정하면 숨김                                                   | `{"commit": "", "pr": ""}`                                       |
| `autoMemoryDirectory`          | auto memory 저장 디렉토리 커스텀. `~/` 확장 경로 사용 가능. project settings에서는 사용 불가                     | `"~/my-memory-dir"`                                              |
| `autoMode`                     | auto mode 분류기 동작 커스텀 (`environment`, `allow`, `soft_deny` 배열). project settings에서는 읽지 않음 | `{"environment": ["Trusted repo: ..."]}`                         |
| `autoUpdatesChannel`           | 업데이트 채널. `"stable"` (약 1주 지연) 또는 `"latest"` (기본값)                                        | `"stable"`                                                       |
| `availableModels`              | `/model`, `--model` 등으로 선택 가능한 모델 제한. Default 옵션에는 영향 없음                                 | `["sonnet", "haiku"]`                                            |
| `awsAuthRefresh`               | `.aws` 디렉토리를 수정하는 커스텀 스크립트 (Amazon Bedrock 고급 인증)                                        | `"aws sso login --profile myprofile"`                            |
| `awsCredentialExport`          | AWS 자격증명 JSON을 출력하는 커스텀 스크립트                                                             | `"/bin/generate_aws_grant.sh"`                                   |
| `cleanupPeriodDays`            | 비활성 세션 보관 기간(일). 기본 30일, 최소 1일. 0은 오류                                                    | `20`                                                             |
| `companyAnnouncements`         | 시작 시 표시할 공지. 여러 개면 랜덤 순환                                                                 | `["가이드라인: docs.acme.com"]`                                       |
| `defaultShell`                 | `!` 명령어의 기본 쉘. `"bash"` (기본) 또는 `"powershell"`                                           | `"bash"`                                                         |
| `disableAllHooks`              | 모든 hook과 커스텀 status line 비활성화                                                            | `true`                                                           |
| `disableAutoMode`              | `"disable"` 설정 시 auto mode 진입 불가. Shift+Tab 순환에서 제거                                      | `"disable"`                                                      |
| `disableDeepLinkRegistration`  | `"disable"` 설정 시 `claude-cli://` 프로토콜 핸들러 OS 등록 안 함                                      | `"disable"`                                                      |
| `disabledMcpjsonServers`       | `.mcp.json`의 특정 MCP 서버 거부 목록                                                             | `["filesystem"]`                                                 |
| `disableSkillShellExecution`   | skill과 커스텀 커맨드의 인라인 쉘 실행 비활성화                                                            | `true`                                                           |
| `effortLevel`                  | 사고 깊이를 세션 간 유지. `"low"`, `"medium"`, `"high"`. Opus/Sonnet 4.6 지원                        | `"medium"`                                                       |
| `enableAllProjectMcpServers`   | 프로젝트 `.mcp.json`의 모든 MCP 서버 자동 승인                                                        | `true`                                                           |
| `enabledMcpjsonServers`        | `.mcp.json`의 특정 MCP 서버만 승인                                                               | `["memory", "github"]`                                           |
| `env`                          | 매 세션에 적용할 환경변수                                                                           | `{"NODE_ENV": "development"}`                                    |
| `fastModePerSessionOptIn`      | `true`면 fast mode가 세션 간 유지되지 않음. 매 세션마다 `/fast`로 활성화 필요                                  | `true`                                                           |
| `feedbackSurveyRate`           | 세션 품질 설문 표시 확률 (0–1). `0`으로 완전 억제                                                        | `0.05`                                                           |
| `fileSuggestion`               | `@` 파일 자동완성에 사용할 커스텀 스크립트                                                                | `{"type": "command", "command": "~/.claude/file-suggestion.sh"}` |
| `forceLoginMethod`             | 로그인 방식 제한. `claudeai` 또는 `console`                                                       | `"claudeai"`                                                     |
| `forceLoginOrgUUID`            | 특정 조직 소속 계정으로만 로그인 제한. 단일 UUID 또는 UUID 배열                                                | `"xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"`                         |
| `hooks`                        | 라이프사이클 이벤트에 실행할 커스텀 커맨드. [hooks 문서](https://code.claude.com/docs/en/hooks) 참고            | —                                                                |
| `httpHookAllowedEnvVars`       | HTTP hook 헤더에 사용할 수 있는 환경변수 허용 목록. 배열 병합                                                 | `["MY_TOKEN", "HOOK_SECRET"]`                                    |
| `includeCoAuthoredBy`          | **Deprecated** → `attribution`으로 대체. 커밋/PR에 Co-authored-by 추가 여부                         | `false`                                                          |
| `includeGitInstructions`       | 내장 git 커밋/PR 지시와 git status를 시스템 프롬프트에 포함 여부 (기본 `true`)                                 | `false`                                                          |
| `language`                     | Claude 응답 언어. 음성 받아쓰기 언어도 함께 설정됨                                                         | `"korean"`                                                       |
| `model`                        | 기본 모델 오버라이드                                                                              | `"claude-sonnet-4-6"`                                            |
| `modelOverrides`               | Anthropic 모델 ID를 provider별 ID(예: Bedrock ARN)로 매핑                                        | `{"claude-opus-4-6": "arn:aws:bedrock:..."}`                     |
| `otelHeadersHelper`            | 동적 OpenTelemetry 헤더 생성 스크립트. 시작 시 및 주기적으로 실행                                             | `"/bin/generate_otel_headers.sh"`                                |
| `outputStyle`                  | 시스템 프롬프트 스타일 설정. [output styles 문서](https://code.claude.com/docs/en/output-styles) 참고    | `"Explanatory"`                                                  |
| `permissions`                  | 툴 사용 허용/거부/확인 규칙. [권한 설정](permissions.md) 참고                                             | —                                                                |
| `plansDirectory`               | plan 파일 저장 경로 (프로젝트 루트 기준 상대 경로). 기본: `~/.claude/plans`                                  | `"./plans"`                                                      |
| `prefersReducedMotion`         | 스피너, shimmer 등 UI 애니메이션 축소/비활성화                                                          | `true`                                                           |
| `respectGitignore`             | `@` 파일 선택기에서 `.gitignore` 패턴 제외 여부 (기본 `true`)                                           | `false`                                                          |
| `showClearContextOnPlanAccept` | plan 수락 화면에 "컨텍스트 초기화" 옵션 표시 (기본 `false`)                                                | `true`                                                           |
| `showThinkingSummaries`        | 인터랙티브 세션에서 extended thinking 요약 표시 (기본 `false`, 접힌 상태)                                   | `true`                                                           |
| `spinnerTipsEnabled`           | 작업 중 스피너에 팁 표시 (기본 `true`)                                                               | `false`                                                          |
| `spinnerTipsOverride`          | 스피너 팁 커스텀. `excludeDefault: true`면 기본 팁 대체, `false`면 병합                                  | `{"excludeDefault": true, "tips": ["내부 도구 X를 사용하세요"]}`           |
| `spinnerVerbs`                 | 스피너에 표시되는 동작 동사 커스텀. `"replace"` 또는 `"append"` 모드                                        | `{"mode": "append", "verbs": ["고민 중", "작성 중"]}`                  |
| `statusLine`                   | 컨텍스트를 표시하는 커스텀 status line 스크립트                                                          | `{"type": "command", "command": "~/.claude/statusline.sh"}`      |
| `useAutoModeDuringPlan`        | plan mode에서 auto mode 의미론 사용 여부 (기본 `true`). project settings에서는 읽지 않음                   | `false`                                                          |
| `voiceEnabled`                 | 푸시-투-톡 음성 받아쓰기 활성화. Claude.ai 계정 필요                                                      | `true`                                                           |

## Managed-only 설정

`managed-settings.json`에서만 설정 가능한 필드. user/project/local settings에서 설정하면 무시되거나 오류가 발생한다.

| 키 | 설명 | 예시 |
|:--|:--|:--|
| `allowedChannelPlugins` | 채널 플러그인 허용 목록. `channelsEnabled: true` 필요. 빈 배열이면 모든 채널 플러그인 차단 | `[{"marketplace": "claude-plugins-official", "plugin": "telegram"}]` |
| `allowedMcpServers` | 사용자가 설정할 수 있는 MCP 서버 허용 목록. 빈 배열이면 완전 차단 | `[{"serverName": "github"}]` |
| `allowManagedHooksOnly` | user/project/plugin hook 차단. managed hook과 SDK hook만 허용 | `true` |
| `allowManagedMcpServersOnly` | managed settings의 `allowedMcpServers`만 적용. 사용자가 추가해도 이 목록만 유효 | `true` |
| `allowManagedPermissionRulesOnly` | user/project settings의 allow/ask/deny 규칙 전부 차단. managed 규칙만 적용 | `true` |
| `blockedMarketplaces` | 차단할 플러그인 마켓플레이스 목록. 다운로드 전에 확인 (파일시스템에 닿지 않음) | `[{"source": "github", "repo": "untrusted/plugins"}]` |
| `channelsEnabled` | Team/Enterprise 사용자의 채널 기능 허용. 미설정 또는 `false`면 채널 메시지 차단 | `true` |
| `deniedMcpServers` | 명시적으로 차단할 MCP 서버 목록. 허용 목록보다 우선. 모든 scope에 적용 | `[{"serverName": "filesystem"}]` |
| `forceRemoteSettingsRefresh` | 원격 managed settings를 새로 받기 전까지 CLI 시작 차단. 실패 시 종료 | `true` |
| `pluginTrustMessage` | 플러그인 설치 전 신뢰 경고에 추가할 조직 메시지 | `"IT 승인된 플러그인입니다"` |
| `strictKnownMarketplaces` | 사용자가 추가할 수 있는 플러그인 마켓플레이스 허용 목록. 자세한 내용은 [플러그인 설정](plugins.md) 참고 | `[{"source": "github", "repo": "acme-corp/plugins"}]` |

## ~/.claude.json 필드

`settings.json`이 아닌 `~/.claude.json`에 저장되는 설정. `/config`에서 수정하거나 직접 편집 가능.

> 이 필드들을 `settings.json`에 추가하면 schema 검증 오류가 발생한다.

| 키 | 설명 | 예시 |
|:--|:--|:--|
| `autoConnectIde` | 외부 터미널에서 Claude Code 시작 시 실행 중인 IDE에 자동 연결 (기본 `false`) | `true` |
| `autoInstallIdeExtension` | VS Code 터미널에서 실행 시 Claude Code IDE 확장 자동 설치 (기본 `true`) | `false` |
| `editorMode` | 입력 프롬프트 키 바인딩. `"normal"` (기본) 또는 `"vim"` | `"vim"` |
| `showTurnDuration` | 응답 후 소요 시간 표시 (기본 `true`) | `false` |
| `terminalProgressBarEnabled` | 지원 터미널(Ghostty 1.2+, iTerm2 3.6.6+ 등)에서 진행 바 표시 (기본 `true`) | `false` |
| `teammateMode` | agent team 팀원 표시 방식. `"auto"`, `"in-process"`, `"tmux"` | `"in-process"` |

## Worktree 설정

대형 모노레포에서 `--worktree` 사용 시 디스크 사용량과 시작 시간을 줄이는 설정.

| 키 | 설명 | 예시 |
|:--|:--|:--|
| `worktree.symlinkDirectories` | 각 worktree에 심볼릭 링크로 연결할 디렉토리. 대용량 디렉토리 중복 방지 | `["node_modules", ".cache"]` |
| `worktree.sparsePaths` | git sparse-checkout으로 체크아웃할 디렉토리 (cone mode). 빠른 시작 | `["packages/my-app", "shared/utils"]` |

> gitignore된 `.env` 같은 파일을 worktree에 복사하려면 프로젝트 루트의 `.worktreeinclude` 파일 사용.

## Sandbox 설정

bash 명령어를 파일시스템과 네트워크로부터 격리하는 설정. Claude의 파일 툴뿐 아니라 `kubectl`, `npm` 같은 서브프로세스 전체에 적용된다.

```json
{
  "sandbox": {
    "enabled": true,
    "excludedCommands": ["docker *"],
    "filesystem": {
      "allowWrite": ["/tmp/build", "~/.kube"],
      "denyRead": ["~/.aws/credentials"]
    },
    "network": {
      "allowedDomains": ["github.com", "*.npmjs.org"],
      "allowLocalBinding": true
    }
  }
}
```

| 키                                              | 설명                                                                | 예시                              |
| :--------------------------------------------- | :---------------------------------------------------------------- | :------------------------------ |
| `sandbox.enabled`                              | bash sandboxing 활성화 (macOS, Linux, WSL2). 기본 `false`              | `true`                          |
| `sandbox.failIfUnavailable`                    | sandbox 시작 불가 시 오류로 종료 (기본 `false`, 경고 후 unsandboxed 실행)          | `true`                          |
| `sandbox.autoAllowBashIfSandboxed`             | sandbox 환경에서 bash 명령어 자동 승인 (기본 `true`)                           | `true`                          |
| `sandbox.excludedCommands`                     | sandbox 밖에서 실행할 명령어 패턴 목록                                         | `["docker *"]`                  |
| `sandbox.allowUnsandboxedCommands`             | `dangerouslyDisableSandbox`로 sandbox 우회 허용 여부 (기본 `true`)         | `false`                         |
| `sandbox.filesystem.allowWrite`                | sandbox 명령어가 쓸 수 있는 추가 경로. 배열 병합                                  | `["/tmp/build", "~/.kube"]`     |
| `sandbox.filesystem.denyWrite`                 | sandbox 명령어가 쓸 수 없는 경로. 배열 병합                                     | `["/etc"]`                      |
| `sandbox.filesystem.denyRead`                  | sandbox 명령어가 읽을 수 없는 경로. 배열 병합                                    | `["~/.aws/credentials"]`        |
| `sandbox.filesystem.allowRead`                 | `denyRead` 내에서 재허용할 경로. `denyRead`보다 우선                           | `["."]`                         |
| `sandbox.filesystem.allowManagedReadPathsOnly` | **(managed only)** managed settings의 `allowRead`만 적용 (기본 `false`) | `true`                          |
| `sandbox.network.allowUnixSockets`             | 접근 가능한 Unix 소켓 경로 (SSH agent 등)                                   | `["~/.ssh/agent-socket"]`       |
| `sandbox.network.allowAllUnixSockets`          | 모든 Unix 소켓 연결 허용 (기본 `false`)                                     | `true`                          |
| `sandbox.network.allowLocalBinding`            | localhost 포트 바인딩 허용 (macOS only, 기본 `false`)                      | `true`                          |
| `sandbox.network.allowedDomains`               | 아웃바운드 허용 도메인. 와일드카드(`*.example.com`) 지원                           | `["github.com", "*.npmjs.org"]` |
| `sandbox.network.allowManagedDomainsOnly`      | **(managed only)** managed settings의 도메인만 허용 (기본 `false`)         | `true`                          |
| `sandbox.network.httpProxyPort`                | 직접 제공하는 HTTP 프록시 포트                                               | `8080`                          |
| `sandbox.network.socksProxyPort`               | 직접 제공하는 SOCKS5 프록시 포트                                             | `8081`                          |
| `sandbox.enableWeakerNestedSandbox`            | 권한 없는 Docker 환경용 약한 sandbox (Linux/WSL2. **보안 약화**)               | `true`                          |
| `sandbox.enableWeakerNetworkIsolation`         | **(macOS only)** MITM 프록시 사용 시 TLS 신뢰 서비스 접근 허용 (**보안 약화**)       | `true`                          |

### 경로 접두사 규칙

`filesystem.*` 설정의 경로에 사용하는 접두사:

| 접두사 | 의미 | 예시 |
|:--|:--|:--|
| `/` | 절대 경로 | `/tmp/build` |
| `~/` | 홈 디렉토리 기준 | `~/.kube` → `$HOME/.kube` |
| `./` 또는 접두사 없음 | project settings: 프로젝트 루트 기준 / user settings: `~/.claude` 기준 | `./output` |

## Attribution 설정

Claude가 git 커밋이나 PR을 생성할 때 자동으로 추가하는 서명 문구.

| 키 | 설명 |
|:--|:--|
| `attribution.commit` | 커밋 메시지 하단에 추가되는 git trailer. 빈 문자열이면 숨김 |
| `attribution.pr` | PR 본문 하단에 추가되는 텍스트. 빈 문자열이면 숨김 |

기본값: 커밋 → `Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>`, PR → `🤖 Generated with [Claude Code](https://claude.com/claude-code)`

> `attribution`은 deprecated된 `includeCoAuthoredBy`를 대체한다.

## 파일 제안(File Suggestion) 설정

`@` 파일 자동완성에 커스텀 스크립트를 사용하는 설정. 대형 모노레포에서 프리빌드 인덱스 활용 시 유용.

스크립트는 `CLAUDE_PROJECT_DIR` 등 환경변수와 함께 실행된다. stdin으로 `{"query": "src/comp"}` JSON을 받아 파일 경로를 newline으로 구분하여 stdout 출력 (최대 15개).

## Hook 설정

HTTP hook의 접근 범위를 제한하는 설정. hook 자체 구성은 [hooks 문서](https://code.claude.com/docs/en/hooks) 참고.

| 키 | 설명 |
|:--|:--|
| `allowedHttpHookUrls` | HTTP hook이 요청할 수 있는 URL 패턴. 설정 시 매칭되지 않는 URL 차단 |
| `httpHookAllowedEnvVars` | HTTP hook 헤더에 interpolate할 수 있는 환경변수 이름. 각 hook의 목록과 교집합으로 적용 |
