# Claude Code MCP 연동

**출처**: `raw/MCP를 통해 Claude Code를 도구에 연결하기.md`
**날짜**: 2026-04-21
**keywords**: MCP, Model Context Protocol, MCP server, stdio, SSE, HTTP transport, OAuth, scope, Tool Search, plugin MCP, .mcp.json, 환경 변수 확장

## 요약

Claude Code는 Model Context Protocol(MCP)을 통해 외부 도구·API·데이터베이스에 연결할 수 있다. local/project/user 3가지 범위로 서버를 구성하며, HTTP·SSE·stdio 전송 방식을 지원한다. Tool Search 기능으로 MCP 도구 정의를 지연 로드하여 컨텍스트 윈도우 영향을 최소화한다.

## MCP 서버 설치

### 옵션 1: 원격 HTTP 서버 (권장)

클라우드 기반 서비스에 가장 널리 지원되는 전송 방식.

```shellscript
# 기본 구문
claude mcp add --transport http <name> <url>

# Notion에 연결
claude mcp add --transport http notion https://mcp.notion.com/mcp

# Bearer 토큰 인증
claude mcp add --transport http secure-api https://api.example.com/mcp \
  --header "Authorization: Bearer your-token"
```

### 옵션 2: 원격 SSE 서버

SSE(Server-Sent Events) 전송은 더 이상 사용되지 않음. 가능하면 HTTP 서버 사용 권장.

```shellscript
claude mcp add --transport sse asana https://mcp.asana.com/sse
```

### 옵션 3: 로컬 stdio 서버

컴퓨터에서 로컬 프로세스로 실행. 직접 시스템 접근이나 사용자 정의 스크립트에 적합.

```shellscript
# 기본 구문: 서버 이름 뒤에 -- 로 명령어 구분
claude mcp add [options] <name> -- <command> [args...]

# Airtable 서버 추가
claude mcp add --transport stdio --env AIRTABLE_API_KEY=YOUR_KEY airtable \
  -- npx -y airtable-mcp-server
```

**중요: 옵션 순서** — `--transport`, `--env`, `--scope`, `--header` 등 모든 옵션은 서버 이름 **앞에** 와야 함. `--` 이중 대시가 서버 이름과 MCP 서버 명령을 구분.

**Windows**: `npx` 사용 시 `cmd /c` 래퍼 필요. 없으면 "Connection closed" 오류 발생.
```shellscript
claude mcp add --transport stdio my-server -- cmd /c npx -y @some/package
```

### 서버 관리

```shellscript
claude mcp list          # 구성된 모든 서버 나열
claude mcp get github    # 특정 서버 세부 정보
claude mcp remove github # 서버 제거
/mcp                     # (Claude Code 내에서) 서버 상태 확인 및 OAuth 인증
```

## MCP 설치 범위

| 범위 | 저장 위치 | 설명 | 사용 시나리오 |
| --- | --- | --- | --- |
| **로컬** (기본값) | `~/.claude.json` (프로젝트 경로 아래) | 현재 프로젝트에서만, 개인 전용 | 개인 서버, 민감한 자격 증명, 실험적 구성 |
| **프로젝트** | `.mcp.json` (프로젝트 루트) | 버전 제어에 체크인 가능, 팀 공유 | 팀 공유 서버, 프로젝트 특정 도구 |
| **사용자** | `~/.claude.json` | 모든 프로젝트에서 개인 접근 | 개인 유틸리티, 여러 프로젝트에서 공통 서비스 |

```shellscript
# 범위 지정 예시
claude mcp add --transport http stripe --scope local https://mcp.stripe.com    # 로컬
claude mcp add --transport http paypal --scope project https://mcp.paypal.com  # 프로젝트
claude mcp add --transport http hubspot --scope user https://mcp.hubspot.com   # 사용자
```

**우선순위**: 로컬 > 프로젝트 > 사용자. 동일 이름 서버 충돌 시 로컬이 우선.

**보안**: 프로젝트 범위 서버(`.mcp.json`) 사용 전 Claude Code가 승인 요청. `claude mcp reset-project-choices`로 승인 선택 재설정.

### `.mcp.json` 환경 변수 확장

팀 구성을 공유하면서 민감한 값(API 키, 경로)을 유연하게 관리.

```json
{
  "mcpServers": {
    "api-server": {
      "type": "http",
      "url": "${API_BASE_URL:-https://api.example.com}/mcp",
      "headers": {
        "Authorization": "Bearer ${API_KEY}"
      }
    }
  }
}
```

지원 구문: `${VAR}` (변수 값으로 확장), `${VAR:-default}` (설정 안 된 경우 default 사용). `command`, `args`, `env`, `url`, `headers`에서 사용 가능. 필수 환경 변수가 없고 기본값도 없으면 구성 파싱 실패.

## 원격 MCP 서버 인증

### OAuth 2.0

`/mcp` 메뉴에서 "인증" 선택으로 OAuth 흐름 시작. 인증 토큰은 안전하게 저장되고 자동 갱신됨.

**고정 OAuth 콜백 포트**: 일부 서버는 사전 등록된 특정 리디렉션 URI 필요. `--callback-port`로 포트 고정.

```shellscript
claude mcp add --transport http --callback-port 8080 my-server https://mcp.example.com/mcp
```

**사전 구성된 OAuth 자격 증명**: 동적 클라이언트 등록을 지원하지 않는 서버("does not support dynamic client registration" 오류 시) 사용. 클라이언트 시크릿은 설정 파일이 아닌 시스템 키체인(macOS) 또는 자격 증명 파일에 저장.

### 사용자 정의 헤더를 통한 동적 인증

OAuth가 아닌 인증 체계(Kerberos, 단기 토큰, 내부 SSO)에 사용. `.mcp.json`에 `headersHelper` 설정:

```json
{
  "mcpServers": {
    "internal-api": {
      "type": "http",
      "url": "https://mcp.internal.example.com",
      "headersHelper": "/opt/bin/get-mcp-auth-headers.sh"
    }
  }
}
```

- 명령은 JSON 객체(문자열 키-값 쌍)를 stdout에 출력해야 함
- 10초 타임아웃으로 셸 실행. 캐싱 없음 (스크립트가 토큰 재사용 담당)
- 각 연결(세션 시작 및 재연결)마다 새로 실행
- 환경 변수: `CLAUDE_CODE_MCP_SERVER_NAME`, `CLAUDE_CODE_MCP_SERVER_URL` 제공

## 고급 기능

### Tool Search (도구 지연 로드)

기본적으로 활성화. MCP 도구 정의를 세션 시작까지 연기하여 컨텍스트 윈도우 영향 최소화. Claude가 필요할 때 검색 도구로 관련 도구 검색.

`ENABLE_TOOL_SEARCH` 환경 변수로 동작 제어:

| 값 | 동작 |
| --- | --- |
| (설정 안 됨) | 모든 MCP 도구 연기. 비 자사 `ANTHROPIC_BASE_URL`이면 미리 로드로 전환 |
| `true` | 모든 MCP 도구 연기 (비 자사 URL 포함) |
| `auto` | 임계값 모드: 컨텍스트 윈도우 10% 이내면 미리 로드, 초과 시 연기 |
| `auto:<N>` | 사용자 정의 백분율 (예: `auto:5` = 5%) |
| `false` | 모든 MCP 도구 미리 로드 (연기 없음) |

Haiku 모델은 Tool Search 미지원. Sonnet 4 이상 또는 Opus 4 이상 필요.

`ToolSearch` 도구만 특정 비활성화:
```json
{ "permissions": { "deny": ["ToolSearch"] } }
```

### 동적 도구 업데이트

Claude Code는 MCP `list_changed` 알림을 지원. 서버가 `list_changed` 알림을 보내면 재연결 없이 사용 가능한 도구·프롬프트·리소스 자동 새로 고침.

### 채널을 통한 메시지 푸시

MCP 서버가 세션에 메시지를 직접 푸시 가능. CI 결과, 모니터링 경고, 채팅 메시지 등 외부 이벤트에 Claude가 반응. 서버가 `claude/channel` 기능을 선언하고 시작 시 `--channels` 플래그로 옵트인.

### MCP 출력 제한

- 기본 경고 임계값: 10,000 토큰 초과 시 경고
- 기본 최대값: 25,000 토큰
- `MAX_MCP_OUTPUT_TOKENS` 환경 변수로 조정: `export MAX_MCP_OUTPUT_TOKENS=50000`

### Claude Code를 MCP 서버로 사용

Claude Code 자체를 다른 애플리케이션이 연결하는 MCP 서버로 실행 가능.

```shellscript
claude mcp serve
```

Claude Desktop 연결 구성 (`claude_desktop_config.json`):
```json
{
  "mcpServers": {
    "claude-code": {
      "type": "stdio",
      "command": "/full/path/to/claude",
      "args": ["mcp", "serve"],
      "env": {}
    }
  }
}
```

`command`에 전체 경로 필요. PATH에 없으면 `spawn claude ENOENT` 오류 발생. `which claude`로 경로 확인.

### Claude.ai MCP 서버 동기화

Claude.ai 계정으로 로그인한 경우 Claude.ai에서 추가한 MCP 서버가 Claude Code에서 자동 사용 가능. 비활성화하려면:
```shellscript
ENABLE_CLAUDEAI_MCP_SERVERS=false claude
```

### 플러그인 제공 MCP 서버

플러그인은 MCP 서버를 번들로 제공 가능. 플러그인 활성화 시 자동 연결. 플러그인 루트의 `.mcp.json` 또는 `plugin.json`에서 정의. `${CLAUDE_PLUGIN_ROOT}`, `${CLAUDE_PLUGIN_DATA}` 환경 변수 지원.

세션 중 플러그인 활성화/비활성화 후 `/reload-plugins` 실행으로 MCP 서버 연결/해제.

## MCP 사용 예시

```shellscript
# Sentry 오류 모니터링
claude mcp add --transport http sentry https://mcp.sentry.dev/mcp

# GitHub 코드 검토
claude mcp add --transport http github https://api.githubcopilot.com/mcp/

# PostgreSQL 데이터베이스 쿼리
claude mcp add --transport stdio db -- npx -y @bytebase/dbhub \
  --dsn "postgresql://readonly:pass@prod.db.com:5432/analytics"
```

## 관련 항목

- [[wiki/ai/claude-code/claude-code-작동방식-에이전트하네스]]
- [[wiki/ai/claude-code/claude-code-확장기능-개요]]
- [[wiki/ai/claude-code/claude-code-hooks-자동화가이드]]
- [[wiki/ai/claude-code/claude-code-명령어-레퍼런스]]
