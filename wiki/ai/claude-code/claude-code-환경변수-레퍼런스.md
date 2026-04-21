# Claude Code 환경변수 레퍼런스

**출처**: `raw/claude code 환경 변수.md` | https://code.claude.com/docs/ko/env-vars
**날짜**: 2026-04-21
**keywords**: 환경변수, ANTHROPIC_API_KEY, settings.json, 인증, 프록시, 컨텍스트 압축, 디버그, MCP, 모델 설정

## 요약

Claude Code 동작을 제어하는 환경변수 완전 레퍼런스. `claude` 실행 전에 셸에서 설정하거나, `settings.json`의 `env` 키 아래에서 구성하여 모든 세션에 적용하거나 팀 전체에 배포할 수 있다. 수백 개 이상의 변수를 카테고리별로 제공하며, 실용적인 핵심 변수를 중심으로 정리한다.

---

## 설정 방법

```bash
# 셸에서 직접 설정 (현재 세션만)
export ANTHROPIC_API_KEY=sk-ant-...
claude

# settings.json에서 영구 설정 (모든 세션)
# ~/.claude/settings.json 또는 .claude/settings.json
{
  "env": {
    "ANTHROPIC_API_KEY": "sk-ant-..."
  }
}
```

---

## 인증 관련

| 변수 | 목적 |
|------|------|
| `ANTHROPIC_API_KEY` | API 키. 설정하면 로그인되어 있더라도 Claude Pro/Max/Team/Enterprise 구독 대신 이 키가 사용됨. 대화형 모드에서 처음 한 번 승인 프롬프트 표시. 구독을 대신 사용하려면 `unset ANTHROPIC_API_KEY` |
| `ANTHROPIC_AUTH_TOKEN` | `Authorization` 헤더의 사용자 정의 값 (앞에 `Bearer ` 자동 추가) |
| `CLAUDE_CODE_OAUTH_TOKEN` | Claude.ai 인증용 OAuth 액세스 토큰. `claude setup-token`으로 생성. 키체인 저장 자격증명보다 우선 |
| `CLAUDE_CODE_OAUTH_REFRESH_TOKEN` | OAuth 새로 고침 토큰. 자동화된 환경에서 브라우저 없이 인증 가능. `CLAUDE_CODE_OAUTH_SCOPES`가 함께 필요 |
| `CLAUDE_CONFIG_DIR` | 구성 디렉토리 재정의 (기본값: `~/.claude`). 여러 계정 나란히 실행 시 유용: `alias claude-work='CLAUDE_CONFIG_DIR=~/.claude-work claude'` |

---

## API 엔드포인트 / 프록시

| 변수 | 목적 |
|------|------|
| `ANTHROPIC_BASE_URL` | API 엔드포인트 재정의. 프록시나 게이트웨이를 통해 요청을 라우팅할 때 사용. 비자사 호스트로 설정하면 MCP 도구 검색이 기본 비활성화 (프록시가 `tool_reference` 블록을 전달하면 `ENABLE_TOOL_SEARCH=true`로 활성화) |
| `HTTP_PROXY` / `HTTPS_PROXY` | HTTP/HTTPS 프록시 서버 |
| `NO_PROXY` | 프록시를 우회할 도메인 및 IP 목록 |
| `API_TIMEOUT_MS` | API 요청 타임아웃 (기본값: 600000 = 10분. 최대: 2147483647). 느린 네트워크나 프록시 환경에서 증가 |

---

## 클라우드 공급자

| 변수 | 목적 |
|------|------|
| `CLAUDE_CODE_USE_BEDROCK` | Amazon Bedrock 사용 |
| `ANTHROPIC_BEDROCK_BASE_URL` | Bedrock 엔드포인트 URL 재정의 |
| `AWS_BEARER_TOKEN_BEDROCK` | Bedrock API 키 인증 |
| `CLAUDE_CODE_USE_VERTEX` | Google Vertex AI 사용 |
| `ANTHROPIC_VERTEX_PROJECT_ID` | Vertex AI용 GCP 프로젝트 ID (Vertex 사용 시 필수) |
| `ANTHROPIC_VERTEX_BASE_URL` | Vertex AI 엔드포인트 URL 재정의 |
| `CLAUDE_CODE_USE_FOUNDRY` | Microsoft Foundry 사용 |
| `ANTHROPIC_FOUNDRY_API_KEY` | Microsoft Foundry 인증용 API 키 |
| `ANTHROPIC_FOUNDRY_RESOURCE` | Foundry 리소스 이름 (예: `my-resource`) |

---

## 모델 설정

| 변수 | 목적 |
|------|------|
| `ANTHROPIC_MODEL` | 사용할 모델 설정 이름 |
| `ANTHROPIC_DEFAULT_SONNET_MODEL` / `ANTHROPIC_DEFAULT_OPUS_MODEL` / `ANTHROPIC_DEFAULT_HAIKU_MODEL` | 각 모델 클래스의 기본값 재정의 |
| `CLAUDE_CODE_SUBAGENT_MODEL` | subagent에서 사용할 모델 |
| `ANTHROPIC_CUSTOM_MODEL_OPTION` | `/model` 선택기에 사용자 정의 항목 추가 (비표준 또는 게이트웨이 특정 모델) |
| `ANTHROPIC_CUSTOM_MODEL_OPTION_NAME` | 사용자 정의 모델 항목의 표시 이름 (미설정 시 모델 ID로 기본값) |
| `CLAUDE_CODE_EFFORT_LEVEL` | 노력 수준 설정. 값: `low`, `medium`, `high`, `xhigh`, `max`, `auto`. `/effort` 및 `effortLevel` 설정보다 우선 |
| `MAX_THINKING_TOKENS` | 확장 사고 토큰 예산 재정의. `0`으로 설정하면 사고 완전 비활성화 |
| `CLAUDE_CODE_DISABLE_THINKING` | 확장 사고를 강제로 비활성화 (`MAX_THINKING_TOKENS=0`보다 더 직접적) |
| `CLAUDE_CODE_DISABLE_ADAPTIVE_THINKING` | Opus/Sonnet 4.6의 적응형 추론 비활성화. 고정 사고 예산으로 복귀 |
| `CLAUDE_CODE_DISABLE_1M_CONTEXT` | 1M 컨텍스트 윈도우 지원 비활성화 (규정 준수 요구사항 있는 엔터프라이즈 환경) |

---

## Bash / 명령 실행

| 변수 | 목적 |
|------|------|
| `BASH_DEFAULT_TIMEOUT_MS` | 장시간 실행되는 bash 명령의 기본 타임아웃 (기본값: 120000 = 2분) |
| `BASH_MAX_TIMEOUT_MS` | 모델이 설정할 수 있는 최대 타임아웃 (기본값: 600000 = 10분) |
| `BASH_MAX_OUTPUT_LENGTH` | bash 출력이 중간 잘림되기 전의 최대 문자 수 |
| `CLAUDE_CODE_SHELL` | 자동 셸 감지 재정의. 로그인 셸과 작업 셸이 다를 때 유용 |
| `CLAUDE_CODE_SHELL_PREFIX` | 모든 bash 명령을 래핑할 명령 접두사 (로깅/감사용) |
| `CLAUDE_BASH_MAINTAIN_PROJECT_WORKING_DIR` | 각 Bash 명령 후 원래 작업 디렉토리로 돌아감 |

---

## 컨텍스트 압축 관련

| 변수 | 목적 |
|------|------|
| `DISABLE_AUTO_COMPACT` | 컨텍스트 한계 접근 시 자동 압축 비활성화 (수동 `/compact`는 계속 가능) |
| `DISABLE_COMPACT` | 자동 압축 + 수동 `/compact` 포함 모든 압축 비활성화 |
| `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` | 자동 압축 트리거 임계값 백분율 (1-100. 기본값 약 95%). 낮은 값으로 더 일찍 압축 |
| `CLAUDE_CODE_AUTO_COMPACT_WINDOW` | 자동 압축 계산에 사용되는 컨텍스트 용량 (토큰 단위). 기본값은 모델 컨텍스트 윈도우 (200K 또는 1M) |
| `CLAUDE_CODE_MAX_OUTPUT_TOKENS` | 대부분의 요청에 대한 최대 출력 토큰 수. 증가 시 자동 압축 트리거 전 유효 컨텍스트 윈도우 감소 |
| `CLAUDE_CODE_MAX_CONTEXT_TOKENS` | Claude Code가 가정하는 컨텍스트 윈도우 크기 재정의. `DISABLE_COMPACT`가 설정된 경우에만 적용 |

---

## 메모리 및 세션

| 변수 | 목적 |
|------|------|
| `CLAUDE_CODE_DISABLE_AUTO_MEMORY` | 자동 메모리 비활성화 (`1`). 점진적 롤아웃 중 강제 활성화 시 `0` |
| `CLAUDE_CODE_DISABLE_CLAUDE_MDS` | 사용자, 프로젝트, 자동 메모리 파일 포함 모든 CLAUDE.md 메모리 파일을 컨텍스트에 로드하지 않음 |
| `CLAUDE_CODE_SKIP_PROMPT_HISTORY` | 프롬프트 기록 및 세션 트랜스크립트를 디스크에 쓰지 않음. 이 세션은 `--resume`, `--continue`, 위쪽 화살표 히스토리에 나타나지 않음 |
| `CLAUDE_CODE_RESUME_INTERRUPTED_TURN` | 이전 세션이 중간에 끝난 경우 자동 재개 (SDK 모드에서 사용) |
| `CLAUDE_CODE_EXIT_AFTER_STOP_DELAY` | 쿼리 루프가 유휴 상태가 된 후 자동 종료 전 대기 시간 (밀리초). 자동화된 스크립트에 유용 |

---

## 파일 관련

| 변수 | 목적 |
|------|------|
| `CLAUDE_CODE_DISABLE_FILE_CHECKPOINTING` | 파일 체크포인팅 비활성화. `/rewind` 명령이 코드 변경사항 복원 불가 |
| `CLAUDE_CODE_FILE_READ_MAX_OUTPUT_TOKENS` | 파일 읽기의 기본 토큰 제한 재정의. 전체 파일을 읽어야 할 때 유용 |
| `CLAUDE_CODE_GLOB_HIDDEN` | `false`로 설정하면 Glob 도구 호출 시 결과에서 dotfile 제외 (기본적으로 포함) |
| `CLAUDE_CODE_GLOB_NO_IGNORE` | `false`로 설정하면 Glob 도구가 `.gitignore` 패턴을 존중 (기본적으로 gitignored 파일 포함) |
| `CLAUDE_CODE_GLOB_TIMEOUT_SECONDS` | Glob 도구 파일 검색 타임아웃 (기본값: 대부분 플랫폼 20초, WSL 60초) |

---

## MCP 관련

| 변수 | 목적 |
|------|------|
| `ENABLE_TOOL_SEARCH` | MCP 도구 검색 제어. 값: `true` (항상 연기), `auto` (임계값 모드), `auto:N` (사용자 정의 임계값%), `false` (모두 미리 로드) |
| `MCP_TIMEOUT` | MCP 서버 시작 타임아웃 (기본값: 30000 = 30초) |
| `MCP_TOOL_TIMEOUT` | MCP 도구 실행 타임아웃 (기본값: 100000000 ≈ 28시간) |
| `MCP_CONNECTION_NONBLOCKING` | 비대화형 모드에서 MCP 연결 대기 완전히 건너뜀. MCP 도구가 필요 없는 스크립트 파이프라인에 유용 |
| `MCP_SERVER_CONNECTION_BATCH_SIZE` | 시작 중 병렬로 연결할 로컬 MCP 서버(stdio) 최대 수 (기본값: 3) |
| `MAX_MCP_OUTPUT_TOKENS` | MCP 도구 응답에서 허용되는 최대 토큰 수 (기본값: 25000) |
| `CLAUDE_AGENT_SDK_MCP_NO_PREFIX` | SDK에서 생성한 MCP 서버의 도구 이름에서 `mcp__<server>__` 접두사를 건너뜀 (`1`로 설정) |

---

## 보안 관련

| 변수 | 목적 |
|------|------|
| `CLAUDE_CODE_SUBPROCESS_ENV_SCRUB` | Anthropic 및 클라우드 공급자 자격증명을 subprocess 환경(Bash 도구, 훅, MCP stdio 서버)에서 제거 (`1`). 프롬프트 주입 공격 노출 감소 |
| `CLAUDE_CODE_SCRIPT_CAPS` | `CLAUDE_CODE_SUBPROCESS_ENV_SCRUB`이 설정된 경우 세션당 특정 스크립트 호출 횟수 제한하는 JSON 객체. 예: `{"deploy.sh": 2}` |
| `CLAUDE_CODE_DISABLE_GIT_INSTRUCTIONS` | 시스템 프롬프트에서 기본 제공 커밋/PR 워크플로우 지침과 git 상태 스냅샷 제거. 자신의 git 워크플로우 skill 사용 시 유용 |
| `CLAUDE_CODE_PERFORCE_MODE` | Perforce 인식 쓰기 보호 활성화 (`1`). Claude Code가 Perforce 변경 추적을 우회하지 않도록 방지 |

---

## 디버그 / 로깅

| 변수 | 목적 |
|------|------|
| `CLAUDE_CODE_DEBUG_LOGS_DIR` | 디버그 로그 파일 경로 재정의 (기본값: `~/.claude/debug/<session-id>.txt`). 이름과 달리 파일 경로임. 디버그 모드는 `--debug` 또는 `/debug`로 별도 활성화 필요 |
| `CLAUDE_CODE_DEBUG_LOG_LEVEL` | 디버그 로그 최소 수준. 값: `verbose`, `debug` (기본값), `info`, `warn`, `error` |
| `CLAUDE_CODE_ENABLE_TELEMETRY` | OpenTelemetry 데이터 수집 활성화 (`1`). OTel 내보내기 구성 전에 필수 |

---

## UI / 터미널 동작

| 변수 | 목적 |
|------|------|
| `CLAUDE_CODE_NO_FLICKER` | 전체 화면 렌더링 활성화 (`1`). `tui` 설정과 동일. `/tui fullscreen`으로도 전환 가능 |
| `CLAUDE_CODE_DISABLE_MOUSE` | 전체 화면 렌더링에서 마우스 추적 비활성화. 터미널의 기본 선택 시 복사 동작 유지 시 사용 |
| `CLAUDE_CODE_SCROLL_SPEED` | 전체 화면 렌더링에서 마우스 휠 스크롤 배수 (1-20). vim과 일치시키려면 `3`으로 설정 |
| `CLAUDE_CODE_ACCESSIBILITY` | macOS Zoom 같은 화면 확대기가 커서 위치를 추적할 수 있도록 기본 터미널 커서 표시 (`1`) |
| `CLAUDE_CODE_SYNTAX_HIGHLIGHT` | diff 출력에서 구문 강조 비활성화 (`false`) |
| `CLAUDE_CODE_DISABLE_TERMINAL_TITLE` | 대화 컨텍스트 기반 자동 터미널 제목 업데이트 비활성화 |

---

## 비대화형 모드 / 자동화

| 변수 | 목적 |
|------|------|
| `CLAUDECODE` | Claude Code가 생성하는 셸 환경(Bash 도구, tmux 세션)에서 `1`로 설정됨. Claude Code가 생성한 셸 내에서 스크립트가 실행 중인지 감지 |
| `CLAUDE_CODE_REMOTE` | 클라우드 세션으로 실행 중일 때 자동으로 `true`. 훅 또는 설정 스크립트에서 클라우드 환경 감지 |
| `CLAUDE_CODE_ENABLE_TASKS` | 비대화형 모드(`-p` 플래그)에서 작업 추적 시스템 활성화 (`1`). 대화형 모드에서는 기본 활성화 |
| `CLAUDE_AGENT_SDK_DISABLE_BUILTIN_AGENTS` | 모든 기본 subagent 유형(Explore, Plan 등) 비활성화 (`1`). 비대화형 모드(`-p`)에만 적용 |
| `CLAUDE_CODE_SIMPLE` | 최소 시스템 프롬프트 및 Bash, 파일 읽기, 파일 편집 도구만으로 실행 (`1`). `--bare` CLI 플래그가 이를 설정 |

---

## 프롬프트 캐싱

| 변수 | 목적 |
|------|------|
| `DISABLE_PROMPT_CACHING` | 모든 모델에 대해 프롬프트 캐싱 비활성화 |
| `ENABLE_PROMPT_CACHING_1H` | 기본 5분 대신 1시간 프롬프트 캐시 TTL 요청 (API 키, Bedrock, Vertex, Foundry 사용자). 구독 사용자는 자동으로 1시간 TTL 수신. 1시간 캐시 쓰기는 더 높은 요금으로 청구 |
| `FORCE_PROMPT_CACHING_5M` | 1시간 TTL이 적용되는 경우에도 5분 프롬프트 캐시 TTL 강제 |

---

## 자동 업데이트 / 피드백

| 변수 | 목적 |
|------|------|
| `DISABLE_AUTOUPDATER` | 자동 업데이트 비활성화 (`1`) |
| `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` | `DISABLE_AUTOUPDATER`, `DISABLE_FEEDBACK_COMMAND`, `DISABLE_ERROR_REPORTING`, `DISABLE_TELEMETRY` 설정과 동일 |
| `IS_DEMO` | 데모 모드 활성화 (`1`): 헤더에서 이메일·조직 이름 숨기기, 온보딩 건너뜀. 세션 스트리밍/녹화 시 유용 |

---

## 에이전트 팀 / 병렬 실행

| 변수 | 목적 |
|------|------|
| `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` | 에이전트 팀 활성화 (`1`). 에이전트 팀은 실험적이며 기본 비활성화 |
| `CLAUDE_CODE_MAX_TOOL_USE_CONCURRENCY` | 병렬로 실행할 수 있는 읽기 전용 도구 및 subagent 최대 수 (기본값: 10) |
| `CLAUDE_AUTO_BACKGROUND_TASKS` | 장시간 실행되는 에이전트 작업의 자동 백그라운드 처리 강제 활성화 (`1`). 약 2분 실행 후 백그라운드로 이동 |
| `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS` | 백그라운드 작업 기능 전체 비활성화 (`1`): `run_in_background` 매개변수, 자동 백그라운드 처리, Ctrl+B 단축키 |
| `TASK_MAX_OUTPUT_LENGTH` | subagent 출력의 최대 문자 수 (기본값: 32000, 최대: 160000) |

---

## OpenTelemetry (모니터링)

표준 OTel 내보내기 변수 지원: `OTEL_METRICS_EXPORTER`, `OTEL_LOGS_EXPORTER`, `OTEL_EXPORTER_OTLP_ENDPOINT`, `OTEL_EXPORTER_OTLP_PROTOCOL`, `OTEL_EXPORTER_OTLP_HEADERS`, `OTEL_METRIC_EXPORT_INTERVAL`, `OTEL_RESOURCE_ATTRIBUTES` 등.

| 변수 | 목적 |
|------|------|
| `OTEL_LOG_RAW_API_BODIES` | 전체 Anthropic Messages API 요청/응답 JSON을 OTel 로그 이벤트로 내보냄 (`1`). 본문에는 전체 대화 기록 포함 |
| `OTEL_LOG_TOOL_CONTENT` | 도구 입력/출력 내용을 OTel 스팬 이벤트에 포함 (`1`). 기본 비활성화 |
| `OTEL_LOG_TOOL_DETAILS` | 도구 입력 인수, MCP 서버 이름, 도구 세부 정보를 OTel 추적/로그에 포함 (`1`). PII 보호를 위해 기본 비활성화 |
| `OTEL_LOG_USER_PROMPTS` | 사용자 프롬프트 텍스트를 OTel 추적/로그에 포함 (`1`). 기본 비활성화 |

---

## 기타 유용한 변수

| 변수 | 목적 |
|------|------|
| `CLAUDE_ENV_FILE` | Claude Code가 각 Bash 명령 전에 실행하는 셸 스크립트 경로. virtualenv나 conda 활성화를 명령 간에 유지하는 데 사용 |
| `CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD` | `--add-dir`로 지정된 디렉토리에서도 메모리 파일 로드 (`1`). 기본적으로 추가 디렉토리는 메모리 파일 미로드 |
| `CLAUDE_CODE_NEW_INIT` | `/init`이 대화형 설정 흐름 실행 (`1`). 미설정 시 `/init`은 프롬프트 없이 자동으로 CLAUDE.md 생성 |
| `CCR_FORCE_BUNDLE` | `claude --remote`가 GitHub 접근이 가능한 경우에도 로컬 저장소를 번들로 업로드하도록 강제 (`1`) |
| `CLAUDE_CODE_TASK_LIST_ID` | 세션 간에 작업 목록 공유. 여러 Claude Code 인스턴스에서 동일한 ID 설정 시 공유 작업 목록에서 조정 |
| `CLAUDE_CODE_TMUX_TRUECOLOR` | tmux 내에서 24비트 truecolor 출력 허용 (`1`). `~/.tmux.conf`에 `set -ga terminal-overrides ',*:Tc'` 추가 후 설정 |

## 관련 항목

- [[wiki/ai/claude-code/claude-code-디렉토리-가이드]]
- [[wiki/ai/claude-code/claude-code-작동방식-에이전트하네스]]
- [[wiki/ai/claude-code/claude-code-권한모드]]
- [[wiki/ai/claude-code/claude-code-메모리-CLAUDE-md]]
