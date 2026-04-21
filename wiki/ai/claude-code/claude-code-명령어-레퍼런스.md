# Claude Code 명령어 레퍼런스

**출처**: `raw/claude code 명령어.md`, `raw/claude code CLI 참조.md`
**날짜**: 2026-04-21
**keywords**: slash commands, built-in commands, bundled skills, 세션 관리, 컨텍스트 관리, 권한 관리, MCP, CLI flags, print mode, permission mode, system prompt, headless, agent SDK

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

## CLI 명령어

`claude` 바이너리를 직접 실행할 때 쓰는 서브커맨드.

| 명령어 | 설명 | 예시 |
| --- | --- | --- |
| `claude` | 대화형 세션 시작 | `claude` |
| `claude "query"` | 초기 프롬프트로 대화형 세션 시작 | `claude "explain this project"` |
| `claude -p "query"` | 비대화형(print mode)으로 쿼리 후 종료 | `claude -p "explain this function"` |
| `cat file \| claude -p "query"` | 파이프 입력 처리 | `cat logs.txt \| claude -p "explain"` |
| `claude -c` | 현재 디렉토리에서 가장 최근 대화 계속 | `claude -c` |
| `claude -r "<session>" "query"` | ID 또는 이름으로 세션 재개 | `claude -r "auth-refactor" "Finish this PR"` |
| `claude update` | 최신 버전으로 업데이트 | `claude update` |
| `claude auth login` | Anthropic 계정 로그인. `--email`, `--sso`, `--console` 옵션 사용 가능 | `claude auth login --console` |
| `claude auth logout` | 로그아웃 | `claude auth logout` |
| `claude auth status` | 인증 상태를 JSON으로 출력. `--text`로 사람이 읽는 형식 출력 가능 | `claude auth status` |
| `claude agents` | 소스별로 구성된 모든 subagent 나열 | `claude agents` |
| `claude auto-mode defaults` | 기본 자동 모드 분류기 규칙을 JSON으로 출력. `claude auto-mode config`로 설정 적용된 유효 구성 확인 | `claude auto-mode defaults > rules.json` |
| `claude mcp` | MCP 서버 구성 | - |
| `claude plugin` | Claude Code plugin 관리. 별칭: `claude plugins` | `claude plugin install code-review@claude-plugins-official` |
| `claude remote-control` | Claude.ai 또는 Claude 앱에서 원격 제어를 위한 서버 시작 (서버 모드, 로컬 세션 없음) | `claude remote-control --name "My Project"` |

## CLI 플래그

`claude --help`는 모든 플래그를 나열하지 않으므로 플래그 목록에 없다고 해서 사용할 수 없는 것이 아님.

### 세션 제어

| 플래그 | 설명 | 예시 |
| --- | --- | --- |
| `--print`, `-p` | 대화형 모드 없이 응답 출력 (headless/print mode) | `claude -p "query"` |
| `--continue`, `-c` | 가장 최근 대화 로드 | `claude --continue` |
| `--resume`, `-r` | ID 또는 이름으로 특정 세션 재개, 또는 대화형 선택기 표시 | `claude --resume auth-refactor` |
| `--name`, `-n` | 세션 표시 이름 설정. `/resume <name>`으로 재개 가능. `/rename`으로 세션 중 변경 가능 | `claude -n "my-feature-work"` |
| `--fork-session` | 재개 시 원본 대신 새 세션 ID 생성. `--resume` 또는 `--continue`와 함께 사용 | `claude --resume abc123 --fork-session` |
| `--from-pr` | 특정 GitHub PR에 연결된 세션 재개. PR 번호 또는 URL | `claude --from-pr 123` |
| `--session-id` | 특정 세션 ID 사용 (유효한 UUID여야 함) | `claude --session-id "550e8400-..."` |
| `--no-session-persistence` | 세션을 디스크에 저장하지 않음 (print mode 전용) | `claude -p --no-session-persistence "query"` |

### 권한 및 도구

| 플래그 | 설명 | 예시 |
| --- | --- | --- |
| `--permission-mode` | 지정된 권한 모드로 시작. `default`, `acceptEdits`, `plan`, `auto`, `dontAsk`, `bypassPermissions` | `claude --permission-mode plan` |
| `--allowedTools` | 권한 프롬프트 없이 실행할 도구 목록 | `"Bash(git log *)" "Read"` |
| `--disallowedTools` | 컨텍스트에서 제거하여 사용 불가로 만들 도구 목록 | `"Edit" "Write"` |
| `--tools` | Claude가 사용할 수 있는 기본 도구 제한. `""`로 모두 비활성화, `"default"`로 모두 허용 | `claude --tools "Bash,Edit,Read"` |
| `--dangerously-skip-permissions` | 모든 권한 프롬프트 건너뜀. `--permission-mode bypassPermissions`와 동일 | `claude --dangerously-skip-permissions` |
| `--allow-dangerously-skip-permissions` | `Shift+Tab` 모드 사이클에 `bypassPermissions` 추가 | `claude --permission-mode plan --allow-dangerously-skip-permissions` |
| `--permission-prompt-tool` | 비대화형 모드에서 권한 프롬프트를 처리할 MCP 도구 지정 | `claude -p --permission-prompt-tool mcp_auth_tool "query"` |

### 모델 및 출력

| 플래그 | 설명 | 예시 |
| --- | --- | --- |
| `--model` | 모델 설정. 별칭(`sonnet`, `opus`) 또는 전체 이름 | `claude --model claude-sonnet-4-6` |
| `--effort` | 노력 수준 설정: `low`, `medium`, `high`, `max` (Opus 4.6만 해당). 세션 범위이며 설정 파일에 저장 안 됨 | `claude --effort high` |
| `--output-format` | print mode 출력 형식: `text`, `json`, `stream-json` | `claude -p "query" --output-format json` |
| `--input-format` | print mode 입력 형식: `text`, `stream-json` | `claude -p --output-format json --input-format stream-json` |
| `--json-schema` | JSON Schema와 일치하는 검증된 JSON 출력 (print mode 전용) | `claude -p --json-schema '{"type":"object",...}' "query"` |
| `--max-turns` | 에이전트 턴 수 제한 (print mode 전용). 기본 무제한 | `claude -p --max-turns 3 "query"` |
| `--max-budget-usd` | API 호출 최대 예산 (print mode 전용) | `claude -p --max-budget-usd 5.00 "query"` |
| `--fallback-model` | 기본 모델 과부하 시 폴백 모델 (print mode 전용) | `claude -p --fallback-model sonnet "query"` |
| `--verbose` | 자세한 로깅 활성화, 전체 턴별 출력 표시 | `claude --verbose` |

### 시스템 프롬프트

4가지 플래그 모두 대화형 및 비대화형 모드에서 작동. 바꾸기 플래그(`--system-prompt`, `--system-prompt-file`)는 상호 배타적.

| 플래그 | 동작 |
| --- | --- |
| `--system-prompt "text"` | 기본 프롬프트 전체 교체 |
| `--system-prompt-file ./file.txt` | 파일 내용으로 기본 프롬프트 교체 |
| `--append-system-prompt "text"` | 기본 프롬프트에 추가 |
| `--append-system-prompt-file ./file.txt` | 파일 내용을 기본 프롬프트에 추가 |

대부분의 경우 추가 플래그(`--append-*`)를 사용. Claude Code의 기본 기능을 유지하면서 요구 사항 추가. 완전한 프롬프트 제어가 필요할 때만 교체 플래그 사용.

### 환경 및 디렉토리

| 플래그 | 설명 | 예시 |
| --- | --- | --- |
| `--add-dir` | Claude가 읽고 편집할 추가 작업 디렉토리 추가. 파일 접근 부여 (`.claude/` 구성 검색 안 됨) | `claude --add-dir ../apps ../lib` |
| `--mcp-config` | JSON 파일 또는 문자열에서 MCP 서버 로드 | `claude --mcp-config ./mcp.json` |
| `--strict-mcp-config` | `--mcp-config`의 MCP 서버만 사용, 다른 모든 MCP 구성 무시 | `claude --strict-mcp-config --mcp-config ./mcp.json` |
| `--settings` | 추가 설정 JSON 파일 또는 문자열 경로 | `claude --settings ./settings.json` |
| `--setting-sources` | 로드할 설정 소스 목록: `user`, `project`, `local` | `claude --setting-sources user,project` |
| `--plugin-dir` | 이 세션에만 디렉토리에서 plugins 로드. 여러 디렉토리는 플래그 반복 | `claude --plugin-dir ./my-plugins` |

### 에이전트 및 서브에이전트

| 플래그 | 설명 | 예시 |
| --- | --- | --- |
| `--agent` | 현재 세션 에이전트 지정 (`agent` 설정 재정의) | `claude --agent my-custom-agent` |
| `--agents` | JSON으로 사용자 정의 subagents 동적 정의. frontmatter와 동일한 필드 + `prompt` 필드 | `claude --agents '{"reviewer":{"description":"...","prompt":"You are a code reviewer"}}'` |
| `--teammate-mode` | 에이전트 팀 표시 방식: `auto`(기본값), `in-process`, `tmux` | `claude --teammate-mode in-process` |
| `--worktree`, `-w` | `<repo>/.claude/worktrees/<name>`의 격리된 git worktree에서 시작 | `claude -w feature-auth` |
| `--tmux` | worktree에 대한 tmux 세션 생성. `--worktree` 필요. 기존 tmux는 `--tmux=classic` | `claude -w feature-auth --tmux` |

### 기타 유용한 플래그

| 플래그 | 설명 |
| --- | --- |
| `--bare` | 최소 모드: hooks, skills, plugins, MCP, auto-memory, CLAUDE.md 자동 검색 건너뜀. 스크립트 호출 빠른 시작. `CLAUDE_CODE_SIMPLE` 설정 |
| `--chrome` | Chrome 브라우저 통합 활성화 |
| `--no-chrome` | 이 세션에서 Chrome 통합 비활성화 |
| `--ide` | 유효한 IDE가 하나일 때 시작 시 자동 연결 |
| `--init` | 초기화 hooks 실행 후 대화형 모드 시작 |
| `--init-only` | 초기화 hooks 실행 후 종료 (세션 없음) |
| `--maintenance` | 유지보수 hooks 실행 후 대화형 모드 시작 |
| `--debug "api,hooks"` | 디버그 모드 활성화. 카테고리 필터 지원 (`"!statsig,!file"` 형식으로 제외 가능) |
| `--debug-file <path>` | 디버그 로그를 특정 파일에 저장. 암묵적으로 디버그 모드 활성화. `CLAUDE_CODE_DEBUG_LOGS_DIR`보다 우선 |
| `--enable-auto-mode` | `Shift+Tab` 사이클에서 자동 모드 잠금 해제. Team/Enterprise/API 플랜 + Sonnet 4.6 or Opus 4.6 필요 |
| `--disable-slash-commands` | 이 세션에서 모든 skills 및 명령어 비활성화 |
| `--remote "description"` | claude.ai에서 새 웹 세션 생성 |
| `--remote-control`, `--rc` | claude.ai 또는 Claude 앱에서도 제어 가능한 대화형 세션 시작 |
| `--teleport` | 로컬 터미널에서 웹 세션 재개 |
| `--include-hook-events` | 모든 hook 이벤트를 출력 스트림에 포함. `--output-format stream-json` 필요 |
| `--include-partial-messages` | 부분 스트리밍 이벤트를 출력에 포함. `--print`와 `--output-format stream-json` 필요 |
| `--version`, `-v` | 버전 번호 출력 |

## 관련 항목

- [[wiki/ai/claude-code/claude-code-작동방식-에이전트하네스]]
- [[wiki/ai/claude-code/claude-code-권한모드]]
- [[wiki/ai/claude-code/claude-code-확장기능-개요]]
- [[wiki/ai/claude-code/claude-code-MCP-연동]]
