# Claude Code 컨텍스트 윈도우 시각화

**출처**: https://code.claude.com/docs/en/context-window | **날짜**: 2026-04-13

## 요약
Claude Code의 컨텍스트 윈도우(최대 200,000 tokens)에 세션 시작부터 무엇이 어떤 순서로 로드되는지 설명한다. 사용자가 타이핑하기 전에 자동으로 로드되는 항목들이 있으며, 각 항목은 터미널 가시성(full/brief/hidden)이 다르다.

## 세션 시작 자동 로드 항목

| 항목 | 토큰 (예시) | 터미널 표시 |
| --- | --- | --- |
| System prompt | ~4,200 | hidden |
| Auto memory (MEMORY.md) | ~680 | hidden |
| Environment info | ~280 | hidden |
| MCP tools (deferred) | ~120 | hidden |
| CLAUDE.md | 파일 크기에 따라 | hidden |
| Skill 설명 | 등록된 Skill 수에 따라 | hidden |

## 가시성 표시 의미

| 표시 | 의미 |
| --- | --- |
| full (●) | 터미널에 전체 내용 표시 |
| brief (◐) | 터미널에 한 줄만 표시 |
| hidden (○) | 터미널에 보이지 않음 |

## 컨텍스트 항목 카테고리 및 출처

| 카테고리 | 내용 |
| --- | --- |
| System | Claude Code의 핵심 동작 지시 |
| CLAUDE.md | 프로젝트/사용자 영속 지시 |
| Memory | 이전 세션에서 Claude가 저장한 학습 내용 |
| Skills | 등록된 Skill 설명 (full content는 호출 시 로드) |
| MCP | 외부 서비스 도구 스키마 |
| Rules | 경로 조건부 로드되는 규칙 |
| Hooks | 이벤트 트리거 훅 (컨텍스트에 추가 텍스트 반환 시에만 영향) |
| Subagent | 서브에이전트의 별도 컨텍스트 (주 컨텍스트와 격리) |

## 컨텍스트 관리 팁

- 컨텍스트가 가득 차면 Claude의 성능이 저하됨 (초기 지시를 "잊기" 시작)
- `/context` 명령으로 현재 컨텍스트 사용량 카테고리별 확인 가능
- 영속 규칙은 반드시 CLAUDE.md에 저장 (대화에 타이핑한 지시는 compaction 후 사라짐)
- 수동으로만 호출하는 Skill은 `disable-model-invocation: true`로 설정해 설명 로드를 방지
- 컨텍스트가 넘칠 것 같은 사이드 태스크는 Subagent로 위임 (주 컨텍스트에 요약만 반환)
- [Custom status line](https://code.claude.com/docs/en/statusline)으로 컨텍스트 사용량을 실시간 모니터링 가능

## Compaction

컨텍스트 윈도우가 가득 차면 Claude Code가 자동으로 대화를 요약하여 공간을 확보한다. 중요한 컨텍스트가 사라질 수 있으므로, `SessionStart` hook의 `compact` matcher를 사용해 compaction 후 핵심 컨텍스트를 재주입할 수 있다.

```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "compact",
        "hooks": [
          {
            "type": "command",
            "command": "echo 'Reminder: use Bun, not npm. Current sprint: auth refactor.'"
          }
        ]
      }
    ]
  }
}
```

## 관련 항목
- [[wiki/ai/claude-code/claude-code-작동원리-에이전틱루프]]
- [[wiki/ai/claude-code/claude-code-모범사례]]
- [[wiki/ai/claude-code/claude-code-hooks-활용가이드]]
- [[wiki/ai/claude-code/claude-code-메모리-CLAUDE-md]]
