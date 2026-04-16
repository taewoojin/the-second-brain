# MCP — Claude Code 도구 연결

**출처**: https://code.claude.com/docs/ko/mcp | **날짜**: 2026-04-14

## 요약
Model Context Protocol(MCP)은 Claude Code를 외부 도구, 데이터베이스, API에 연결하는 오픈 소스 표준이다. MCP 서버가 연결되면 Claude Code가 이슈 트래커 구현, 모니터링 데이터 분석, DB 쿼리, 디자인 통합, 워크플로우 자동화 등을 수행할 수 있다.

## MCP로 가능한 것

- **이슈 구현**: "JIRA 이슈 ENG-4521에 설명된 기능 추가하고 GitHub PR 생성해줘"
- **모니터링 분석**: "Sentry와 Statsig 확인해서 기능 사용량 보여줘"
- **DB 쿼리**: "PostgreSQL에서 기능 사용한 무작위 10명 이메일 찾아줘"
- **디자인 통합**: "Slack에 올라온 새 Figma 디자인으로 이메일 템플릿 업데이트해줘"
- **워크플로우 자동화**: "이 10명에게 피드백 세션 초대 Gmail 초안 만들어줘"
- **외부 이벤트 반응**: MCP 서버가 채널로도 작동 — Telegram, Discord, webhook 이벤트에 반응

## MCP 서버 설치

```bash
# HTTP transport MCP 서버 추가
claude mcp add --transport http <name> <url>

# 예시
claude mcp add --transport http linear https://mcp.linear.app/mcp
claude mcp add --transport http notion https://mcp.notion.com/mcp
claude mcp add --transport http figma-remote-mcp https://mcp.figma.com/mcp
```

프로젝트 팀 공유 서버는 `.mcp.json`:
```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_TOKEN": "${GITHUB_TOKEN}"
      }
    }
  }
}
```

개인 서버(팀 공유 안 됨)는 `claude mcp add --scope user`로 `~/.claude.json`에 저장.

## 인기 MCP 서버 예시

| 서비스 | 용도 | 설치 명령 |
| --- | --- | --- |
| Linear | 이슈, 프로젝트, 팀 워크플로우 | `claude mcp add --transport http linear https://mcp.linear.app/mcp` |
| Notion | 워크스페이스 검색/업데이트 | `claude mcp add --transport http notion https://mcp.notion.com/mcp` |
| Figma | 다이어그램 생성, 코드 향상 | `claude mcp add --transport http figma-remote-mcp https://mcp.figma.com/mcp` |
| Supabase | DB, 인증, 스토리지 관리 | `claude mcp add --transport http supabase https://mcp.supabase.com/mcp` |
| Stripe | 결제 처리 도구 | `claude mcp add --transport http stripe https://mcp.stripe.com` |
| Vercel | 프로젝트/배포 분석 및 관리 | `claude mcp add --transport http vercel https://mcp.vercel.com` |
| Hugging Face | Hub 및 Gradio 앱 접근 | MCP hub에서 설치 |

> **보안 주의**: 타사 MCP 서버는 Anthropic이 검증하지 않음. 신뢰하는 서버만 설치. 신뢰할 수 없는 콘텐츠를 가져오는 서버는 프롬프트 주입 위험 노출 가능.

## MCP와 다른 확장 비교

| 기능 | MCP | Skill | Hook |
| --- | --- | --- | --- |
| **연결 대상** | 외부 서비스/DB/API | 내부 지식/워크플로우 | 라이프사이클 이벤트 |
| **LLM 관여** | 도구 호출을 통해 | 컨텍스트로 로드 | 결정론적 실행 |
| **패턴** | DB 쿼리, API 호출 | 배포 체크리스트, 문서 | 파일 편집 후 포맷 |

## 관련 항목
- [[wiki/ai/claude-code/claude-code-확장기능-개요]]
- [[wiki/ai/claude-code/claude-code-디렉토리-구조]]
- [[wiki/concepts/model-context-protocol-개념]]
