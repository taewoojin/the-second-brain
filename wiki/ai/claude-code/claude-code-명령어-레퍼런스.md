# Claude Code 명령어 레퍼런스

**출처**: `raw/claude code 명령어.md`
**날짜**: 2026-04-21
**keywords**: slash commands, built-in commands, bundled skills, 세션 관리, 컨텍스트 관리, 권한 관리, MCP

## 요약

`/`로 시작하는 명령어로 Claude Code 세션을 제어하며, CLI에 코딩된 **built-in 명령어**와 skill 메커니즘을 사용하는 **번들 skill 명령어** 두 종류가 있다. `/`를 입력하면 전체 목록을 볼 수 있고, 뒤에 문자를 입력하면 필터링된다. 가용성은 플랫폼, 요금제, 환경에 따라 다르다.

## 핵심 명령어

### 세션 관리

| 명령어 | 설명 |
| --- | --- |
| `/clear` | 빈 컨텍스트로 새 대화 시작. 별칭: `/reset`, `/new` |
| `/resume [session]` | ID·이름으로 대화 재개, 또는 세션 선택기 열기. 별칭: `/continue` |
| `/branch [name]` | 현재 대화를 이 시점부터 포크. 별칭: `/fork` |
| `/rewind` | 대화 및/또는 코드를 이전 지점으로 되감기. 별칭: `/checkpoint`, `/undo` |
| `/rename [name]` | 현재 세션 이름 변경 |
| `/recap` | 현재 세션 한 줄 요약 생성 |
| `/export [filename]` | 현재 대화를 일반 텍스트로 내보내기 |

### 컨텍스트 관리

| 명령어 | 설명 |
| --- | --- |
| `/compact [instructions]` | 대화를 요약하여 컨텍스트 확보. 선택적 포커스 지침 전달 가능 |
| `/context` | 현재 컨텍스트 사용량을 색상 그리드로 시각화, 최적화 제안 표시 |
| `/model [model]` | AI 모델 선택·변경. 화살표로 effort level 조정 가능 |
| `/effort [level\|auto]` | 모델 effort level 설정: `low`, `medium`, `high`, `xhigh`, `max` |
| `/btw <question>` | 대화에 추가하지 않고 빠른 side question 하기 |

### 권한 및 보안

| 명령어 | 설명 |
| --- | --- |
| `/permissions` | 허용/요청/거부 규칙 관리 대화상자. 자동 모드 거부 내역 검토 가능 |
| `/plan [description]` | plan mode로 즉시 진입 (예: `/plan fix the auth bug`) |
| `/hooks` | Hook 구성 보기 |
| `/sandbox` | sandbox mode 전환 |

### 설정 및 초기화

| 명령어 | 설명 |
| --- | --- |
| `/config` | Settings 인터페이스 열기. 별칭: `/settings` |
| `/init` | `CLAUDE.md` 가이드로 프로젝트 초기화. `CLAUDE_CODE_NEW_INIT=1` 설정 시 대화형 흐름 활성화 |
| `/memory` | CLAUDE.md 파일 편집, auto-memory 활성화/비활성화, 메모리 항목 보기 |
| `/add-dir <path>` | 세션 중 작업 디렉토리 추가 (`.claude/` 구성은 발견 안 됨) |

### 개발 도구

| 명령어 | 설명 |
| --- | --- |
| `/diff` | 커밋되지 않은 변경사항과 턴별 diff 대화형 뷰어 |
| `/doctor` | Claude Code 설치·설정 진단. `f` 눌러 문제 자동 수정 |
| `/status` | 버전, 모델, 계정, 연결성 표시 |
| `/cost` | 토큰 사용 통계 표시 |
| `/skills` | 사용 가능한 skills 목록. `t` 눌러 토큰 수 정렬 |

### MCP 및 통합

| 명령어 | 설명 |
| --- | --- |
| `/mcp` | MCP 서버 연결·OAuth 인증 관리 |
| `/chrome` | Claude in Chrome 설정 |
| `/ide` | IDE 통합 관리 및 상태 표시 |

## 번들 Skill 명령어

번들 skill은 Claude에게 전달되는 프롬프트이며 직접 작성하는 skills와 동일한 메커니즘을 사용한다. 관련이 있을 때 Claude가 자동으로 호출할 수도 있다.

| 명령어 | 설명 |
| --- | --- |
| `/batch <instruction>` | 코드베이스 전체 대규모 변경을 병렬 조율. 5~30개 독립 단위로 분해 후 git worktree에서 agent 병렬 실행 |
| `/simplify [focus]` | 최근 변경 파일을 코드 재사용·품질·효율성 측면에서 검토 후 수정. 3개 검토 agent 병렬 실행 |
| `/loop [interval] [prompt]` | 세션이 열려 있는 동안 프롬프트를 반복 실행. 간격 생략 시 Claude가 자동 조절. 별칭: `/proactive` |
| `/debug [description]` | 디버그 로깅 활성화 및 세션 로그 분석 |
| `/claude-api` | Claude API 참조 자료 로드 (도구 사용, 스트리밍, 배치 등) |
| `/fewer-permission-prompts` | 트랜스크립트 스캔 후 권한 프롬프트 감소를 위한 허용 목록 추가 |
| `/review [PR]` | 현재 세션에서 PR 로컬 검토 |

## 원격·클라우드 명령어

| 명령어 | 설명 |
| --- | --- |
| `/autofix-pr [prompt]` | 현재 브랜치 PR 감시 → CI 실패/리뷰 댓글 수정 자동화 |
| `/ultraplan <prompt>` | 계획 작성 후 브라우저에서 검토, 원격 실행 또는 터미널로 전송 |
| `/ultrareview [PR]` | 클라우드 샌드박스에서 다중 agent 코드 검토 |
| `/remote-control` | 현재 세션을 claude.ai에서 원격 제어 가능하게 함. 별칭: `/rc` |
| `/teleport` | claude.ai 웹 세션을 터미널로 가져오기. 별칭: `/tp` |
| `/schedule [description]` | routines 생성·업데이트·나열·실행. 별칭: `/routines` |

## MCP 프롬프트

MCP 서버가 노출하는 프롬프트는 `/mcp__<server>__<prompt>` 형식으로 명령어로 나타남. 연결된 서버에서 동적으로 발견된다.

## 관련 항목

- [[wiki/ai/claude-code/claude-code-작동방식-에이전트하네스]]
- [[wiki/ai/claude-code/claude-code-권한모드]]
- [[wiki/ai/claude-code/claude-code-확장기능-개요]]
