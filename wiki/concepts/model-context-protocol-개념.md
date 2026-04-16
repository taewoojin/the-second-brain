# Model Context Protocol (MCP)

**출처**: https://code.claude.com/docs/ko/mcp | **날짜**: 2026-04-14

## 요약
MCP(Model Context Protocol)는 AI 도구 통합을 위한 오픈 소스 표준으로, AI 어시스턴트(Claude 등)가 외부 서비스, 데이터베이스, API에 일관된 방식으로 연결할 수 있게 한다. MCP 서버를 구현하면 어떤 AI 클라이언트에서도 해당 서비스를 도구로 활용할 수 있다.

## 등장 맥락

LLM이 외부 데이터에 접근하거나 액션을 수행하려면 각 서비스마다 별도 통합이 필요했다. MCP는 이를 표준화하여 "한 번 구현하면 어디서나 사용"이 가능하도록 했다. Anthropic이 설계하고 오픈 소스로 공개.

## 핵심 개념

- **MCP 서버**: 특정 서비스(Linear, Notion, Stripe 등)의 기능을 MCP 표준으로 노출하는 서버
- **MCP 클라이언트**: Claude Code, claude.ai 등 MCP 서버에 연결해 도구를 사용하는 AI 앱
- **도구(Tools)**: MCP 서버가 노출하는 개별 기능 (예: `get_issues`, `create_record`)
- **Transport**: HTTP, stdio 등 통신 방식

## Claude Code에서의 활용

```bash
# HTTP transport로 서버 추가
claude mcp add --transport http <name> <url>
```

프로젝트 공유: `.mcp.json` 파일 (저장소 커밋)
개인 전용: `claude mcp add --scope user` (`~/.claude.json` 저장)

## MCP 채널 기능

MCP 서버는 도구뿐만 아니라 **채널**로도 작동 가능 — 세션에 메시지를 푸시하여 Claude가 Telegram, Discord, webhook 이벤트에 반응할 수 있다.

## 관련 항목
- [[wiki/ai/MCP-claude-code-연결]]
- [[wiki/ai/claude-code/claude-code-확장기능-개요]]
