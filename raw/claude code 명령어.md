---
title: "명령어"
source: "https://code.claude.com/docs/ko/commands"
author:
published:
created: 2026-04-21
description: "Claude Code에서 사용 가능한 명령어의 완전한 참조입니다. 기본 제공 명령어 및 번들 skills를 포함합니다."
tags:
  - "clippings"
---
명령어는 세션 내에서 Claude Code를 제어합니다. 모델을 전환하고, 권한을 관리하고, 컨텍스트를 지우고, 워크플로우를 실행하는 등의 빠른 방법을 제공합니다.

`/` 를 입력하면 사용 가능한 모든 명령어를 볼 수 있으며, `/` 다음에 문자를 입력하여 필터링할 수 있습니다.

아래 표는 Claude Code에 포함된 모든 명령어를 나열합니다. \*\* [Skill](https://code.claude.com/docs/ko/skills#bundled-skills) \*\*로 표시된 항목은 번들 skills입니다. 이들은 직접 작성하는 skills와 동일한 메커니즘을 사용합니다. Claude에 전달되는 프롬프트이며, Claude는 관련이 있을 때 자동으로 호출할 수도 있습니다. 그 외의 모든 것은 CLI에 코딩된 동작을 가진 기본 제공 명령어입니다. 자신만의 명령어를 추가하려면 [skills](https://code.claude.com/docs/ko/skills) 를 참조하세요.

모든 명령어가 모든 사용자에게 표시되는 것은 아닙니다. 가용성은 플랫폼, 요금제 및 환경에 따라 달라집니다. 예를 들어, `/desktop` 은 macOS 및 Windows에서만 표시되고, `/upgrade` 는 Pro 및 Max 요금제에서만 표시됩니다.

아래 표에서 `<arg>` 는 필수 인수를 나타내고 `[arg]` 는 선택적 인수를 나타냅니다.

| 명령어 | 목적 |
| --- | --- |
| `/add-dir <path>` | 현재 세션 중에 파일 액세스를 위한 작업 디렉토리를 추가합니다. 대부분의 `.claude/` 구성은 추가된 디렉토리에서 [발견되지 않습니다](https://code.claude.com/docs/ko/permissions#additional-directories-grant-file-access-not-configuration) |
| `/agents` | [agent](https://code.claude.com/docs/ko/sub-agents) 구성을 관리합니다 |
| `/autofix-pr [prompt]` | 현재 브랜치의 PR을 감시하고 CI가 실패하거나 검토자가 댓글을 남길 때 수정 사항을 푸시하는 [Claude Code on the web](https://code.claude.com/docs/ko/claude-code-on-the-web#auto-fix-pull-requests) 세션을 생성합니다. `gh pr view` 를 사용하여 체크아웃된 브랜치에서 열린 PR을 감지합니다. 다른 PR을 감시하려면 먼저 해당 브랜치를 체크아웃하세요. 기본적으로 원격 세션은 모든 CI 실패 및 검토 댓글을 수정하도록 지시받습니다. 프롬프트를 전달하여 다른 지침을 제공합니다. 예를 들어 `/autofix-pr only fix lint and type errors`. `gh` CLI 및 [Claude Code on the web](https://code.claude.com/docs/ko/claude-code-on-the-web#who-can-use-claude-code-on-the-web) 에 대한 액세스가 필요합니다 |
| `/batch <instruction>` | **[Skill](https://code.claude.com/docs/ko/skills#bundled-skills).** 코드베이스 전체에서 대규모 변경 사항을 병렬로 조율합니다. 코드베이스를 연구하고, 작업을 5~30개의 독립적인 단위로 분해하고, 계획을 제시합니다. 승인되면 격리된 [git worktree](https://code.claude.com/docs/ko/common-workflows#run-parallel-claude-code-sessions-with-git-worktrees) 에서 단위당 하나의 백그라운드 agent를 생성합니다. 각 agent는 해당 단위를 구현하고, 테스트를 실행하고, pull request를 엽니다. git 리포지토리가 필요합니다. 예: `/batch migrate src/ from Solid to React` |
| `/branch [name]` | 이 시점에서 현재 대화의 브랜치를 만듭니다. 브랜치로 전환하고 원본을 보존하며, `/resume` 을 사용하여 돌아갈 수 있습니다. 별칭: `/fork` |
| `/btw <question>` | 대화에 추가하지 않고 빠른 [side question](https://code.claude.com/docs/ko/interactive-mode#side-questions-with-btw) 을 합니다 |
| `/chrome` | [Claude in Chrome](https://code.claude.com/docs/ko/chrome) 설정을 구성합니다 |
| `/claude-api` | **[Skill](https://code.claude.com/docs/ko/skills#bundled-skills).** 프로젝트의 언어(Python, TypeScript, Java, Go, Ruby, C#, PHP 또는 cURL) 및 Managed Agents 참조에 대한 Claude API 참조 자료를 로드합니다. 도구 사용, 스트리밍, 배치, 구조화된 출력 및 일반적인 함정을 다룹니다. 또한 코드가 `anthropic` 또는 `@anthropic-ai/sdk` 를 가져올 때 자동으로 활성화됩니다 |
| `/clear` | 빈 컨텍스트로 새 대화를 시작합니다. 이전 대화는 `/resume` 에서 사용 가능하게 유지됩니다. 같은 대화를 계속하면서 컨텍스트를 확보하려면 `/compact` 를 대신 사용하세요. 별칭: `/reset`, `/new` |
| `/color [color\|default]` | 현재 세션의 프롬프트 바 색상을 설정합니다. 사용 가능한 색상: `red`, `blue`, `green`, `yellow`, `purple`, `orange`, `pink`, `cyan`. 초기화하려면 `default` 를 사용합니다 |
| `/compact [instructions]` | 지금까지의 대화를 요약하여 컨텍스트를 확보합니다. 선택적으로 요약에 대한 포커스 지침을 전달합니다. [compaction이 규칙, skills 및 메모리 파일을 처리하는 방법](https://code.claude.com/docs/ko/context-window#what-survives-compaction) 을 참조하세요 |
| `/config` | [Settings](https://code.claude.com/docs/ko/settings) 인터페이스를 열어 테마, 모델, [output style](https://code.claude.com/docs/ko/output-styles) 및 기타 기본 설정을 조정합니다. 별칭: `/settings` |
| `/context` | 현재 컨텍스트 사용량을 색상 그리드로 시각화합니다. 컨텍스트 집약적 도구, 메모리 부풀림 및 용량 경고에 대한 최적화 제안을 표시합니다 |
| `/copy [N]` | 마지막 어시스턴트 응답을 클립보드에 복사합니다. 숫자 `N` 을 전달하여 N번째 최신 응답을 복사합니다: `/copy 2` 는 두 번째 마지막 응답을 복사합니다. 코드 블록이 있을 때는 개별 블록 또는 전체 응답을 선택할 수 있는 대화형 선택기를 표시합니다. 선택기에서 `w` 를 누르면 클립보드 대신 파일에 선택 항목을 작성하며, 이는 SSH를 통해 유용합니다 |
| `/cost` | 토큰 사용 통계를 표시합니다. 구독별 세부 정보는 [cost tracking guide](https://code.claude.com/docs/ko/costs#using-the-cost-command) 를 참조하세요 |
| `/debug [description]` | **[Skill](https://code.claude.com/docs/ko/skills#bundled-skills).** 현재 세션에 대해 디버그 로깅을 활성화하고 세션 디버그 로그를 읽어 문제를 해결합니다. 디버그 로깅은 `claude --debug` 로 시작하지 않는 한 기본적으로 꺼져 있으므로, 세션 중간에 `/debug` 를 실행하면 그 시점부터 로그 캡처를 시작합니다. 선택적으로 분석에 초점을 맞추기 위해 문제를 설명합니다 |
| `/desktop` | 현재 세션을 Claude Code Desktop 앱에서 계속합니다. macOS 및 Windows만 해당. 별칭: `/app` |
| `/diff` | 커밋되지 않은 변경 사항과 턴별 diff를 표시하는 대화형 diff 뷰어를 엽니다. 왼쪽/오른쪽 화살표를 사용하여 현재 git diff와 개별 Claude 턴 사이를 전환하고, 위/아래를 사용하여 파일을 탐색합니다 |
| `/doctor` | Claude Code 설치 및 설정을 진단하고 확인합니다. 결과는 상태 아이콘과 함께 표시됩니다. `f` 를 눌러 Claude가 보고된 문제를 수정하도록 합니다 |
| `/effort [level\|auto]` | 모델 [effort level](https://code.claude.com/docs/ko/model-config#adjust-effort-level) 을 설정합니다. `low`, `medium`, `high`, `xhigh` 또는 `max` 를 허용합니다. 사용 가능한 수준은 모델에 따라 다르며 `max` 는 세션 전용입니다. `auto` 는 모델 기본값으로 재설정합니다. 인수 없이 대화형 슬라이더를 엽니다. 왼쪽 및 오른쪽 화살표를 사용하여 수준을 선택하고 `Enter` 를 눌러 적용합니다. 현재 응답이 완료될 때까지 기다리지 않고 즉시 적용됩니다 |
| `/exit` | CLI를 종료합니다. 별칭: `/quit` |
| `/export [filename]` | 현재 대화를 일반 텍스트로 내보냅니다. 파일 이름이 있으면 해당 파일에 직접 작성합니다. 없으면 클립보드에 복사하거나 파일에 저장할 수 있는 대화 상자를 엽니다 |
| `/extra-usage` | 속도 제한에 도달했을 때 계속 작업할 수 있도록 추가 사용량을 구성합니다 |
| `/fast [on\|off]` | [fast mode](https://code.claude.com/docs/ko/fast-mode) 를 켜거나 끕니다 |
| `/feedback [report]` | Claude Code에 대한 피드백을 제출합니다. 별칭: `/bug` |
| `/fewer-permission-prompts` | **[Skill](https://code.claude.com/docs/ko/skills#bundled-skills).** 트랜스크립트에서 일반적인 읽기 전용 Bash 및 MCP 도구 호출을 스캔한 다음, 권한 프롬프트를 줄이기 위해 프로젝트 `.claude/settings.json` 에 우선순위가 지정된 허용 목록을 추가합니다 |
| `/focus` | 포커스 뷰를 전환합니다. 마지막 프롬프트, 편집 diffstats가 있는 한 줄 도구 호출 요약 및 최종 응답만 표시합니다. 선택 항목은 세션 전체에서 유지됩니다. [fullscreen rendering](https://code.claude.com/docs/ko/fullscreen) 에서만 사용 가능합니다 |
| `/heapdump` | JavaScript 힙 스냅샷 및 메모리 분석을 `~/Desktop` 에 작성하여 높은 메모리 사용량을 진단합니다. [troubleshooting](https://code.claude.com/docs/ko/troubleshooting#high-cpu-or-memory-usage) 을 참조하세요 |
| `/help` | 도움말 및 사용 가능한 명령어를 표시합니다 |
| `/hooks` | 도구 이벤트에 대한 [hook](https://code.claude.com/docs/ko/hooks) 구성을 봅니다 |
| `/ide` | IDE 통합을 관리하고 상태를 표시합니다 |
| `/init` | `CLAUDE.md` 가이드로 프로젝트를 초기화합니다. skills, hooks 및 개인 메모리 파일을 안내하는 대화형 흐름도 진행하려면 `CLAUDE_CODE_NEW_INIT=1` 을 설정하세요 |
| `/insights` | Claude Code 세션을 분석하는 보고서를 생성합니다. 프로젝트 영역, 상호 작용 패턴 및 마찰 지점을 포함합니다 |
| `/install-github-app` | 리포지토리에 대해 [Claude GitHub Actions](https://code.claude.com/docs/ko/github-actions) 앱을 설정합니다. 리포지토리를 선택하고 통합을 구성하는 과정을 안내합니다 |
| `/install-slack-app` | Claude Slack 앱을 설치합니다. OAuth 흐름을 완료하기 위해 브라우저를 엽니다 |
| `/keybindings` | 키바인딩 구성 파일을 열거나 만듭니다 |
| `/login` | Anthropic 계정에 로그인합니다 |
| `/logout` | Anthropic 계정에서 로그아웃합니다 |
| `/loop [interval] [prompt]` | **[Skill](https://code.claude.com/docs/ko/skills#bundled-skills).** 세션이 열려 있는 동안 프롬프트를 반복적으로 실행합니다. 간격을 생략하면 Claude가 반복 사이에 자동으로 속도를 조절합니다. 프롬프트를 생략하면 Claude가 자동 유지 관리 검사를 실행하거나, 있으면 `.claude/loop.md` 의 프롬프트를 실행합니다. 예: `/loop 5m check if the deploy finished`. [Run prompts on a schedule](https://code.claude.com/docs/ko/scheduled-tasks) 을 참조하세요. 별칭: `/proactive` |
| `/mcp` | MCP 서버 연결 및 OAuth 인증을 관리합니다 |
| `/memory` | `CLAUDE.md` 메모리 파일을 편집하고, [auto-memory](https://code.claude.com/docs/ko/memory#auto-memory) 를 활성화 또는 비활성화하며, 자동 메모리 항목을 봅니다 |
| `/mobile` | Claude 모바일 앱을 다운로드할 수 있는 QR 코드를 표시합니다. 별칭: `/ios`, `/android` |
| `/model [model]` | AI 모델을 선택하거나 변경합니다. 이를 지원하는 모델의 경우 왼쪽/오른쪽 화살표를 사용하여 [effort level을 조정](https://code.claude.com/docs/ko/model-config#adjust-effort-level) 합니다. 인수 없이 대화에 이전 출력이 있을 때 확인을 요청하는 선택기를 엽니다. 다음 응답이 캐시된 컨텍스트 없이 전체 기록을 다시 읽기 때문입니다. 확인되면 현재 응답이 완료될 때까지 기다리지 않고 변경 사항이 적용됩니다 |
| `/passes` | 친구들과 Claude Code의 무료 1주일을 공유합니다. 계정이 적격인 경우에만 표시됩니다 |
| `/permissions` | 도구 권한에 대한 허용, 요청 및 거부 규칙을 관리합니다. 범위별로 규칙을 보고, 규칙을 추가 또는 제거하고, 작업 디렉토리를 관리하며, [최근 자동 모드 거부](https://code.claude.com/docs/ko/permissions#review-auto-mode-denials) 를 검토할 수 있는 대화형 대화 상자를 엽니다. 별칭: `/allowed-tools` |
| `/plan [description]` | 프롬프트에서 직접 plan mode로 들어갑니다. 선택적 설명을 전달하여 plan mode로 들어가고 즉시 해당 작업으로 시작합니다. 예를 들어 `/plan fix the auth bug` |
| `/plugin` | Claude Code [plugins](https://code.claude.com/docs/ko/plugins) 를 관리합니다 |
| `/powerup` | 애니메이션 데모가 포함된 빠른 대화형 레슨을 통해 Claude Code 기능을 발견합니다 |
| `/pr-comments [PR]` | v2.1.91에서 제거됨. 대신 Claude에 직접 pull request 댓글을 보도록 요청하세요. 이전 버전에서는 GitHub pull request의 댓글을 가져와 표시합니다. 현재 브랜치의 PR을 자동으로 감지하거나 PR URL 또는 번호를 전달합니다. `gh` CLI가 필요합니다 |
| `/privacy-settings` | 개인정보 보호 설정을 보고 업데이트합니다. Pro 및 Max 요금제 구독자만 사용 가능합니다 |
| `/recap` | 현재 세션의 한 줄 요약을 요청 시 생성합니다. 자동으로 나타나는 [Session recap](https://code.claude.com/docs/ko/interactive-mode#session-recap) 을 참조하세요. 이는 떠난 후 표시됩니다 |
| `/release-notes` | 대화형 버전 선택기에서 변경 로그를 봅니다. 특정 버전을 선택하여 해당 릴리스 노트를 보거나, 모든 버전을 표시하도록 선택합니다 |
| `/reload-plugins` | 모든 활성 [plugins](https://code.claude.com/docs/ko/plugins) 를 다시 로드하여 재시작하지 않고 보류 중인 변경 사항을 적용합니다. 각 다시 로드된 구성 요소의 개수를 보고하고 로드 오류를 표시합니다 |
| `/remote-control` | 이 세션을 claude.ai에서 [remote control](https://code.claude.com/docs/ko/remote-control) 할 수 있도록 합니다. 별칭: `/rc` |
| `/remote-env` | [`--remote` 로 시작된 웹 세션](https://code.claude.com/docs/ko/claude-code-on-the-web#configure-your-environment) 에 대한 기본 원격 환경을 구성합니다 |
| `/rename [name]` | 현재 세션의 이름을 바꾸고 프롬프트 바에 이름을 표시합니다. 이름이 없으면 대화 기록에서 자동으로 생성합니다 |
| `/resume [session]` | ID 또는 이름으로 대화를 재개하거나 세션 선택기를 엽니다. 별칭: `/continue` |
| `/review [PR]` | 현재 세션에서 로컬로 pull request를 검토합니다. 더 깊은 클라우드 기반 검토는 [`/ultrareview`](https://code.claude.com/docs/ko/ultrareview) 를 참조하세요 |
| `/rewind` | 대화 및/또는 코드를 이전 지점으로 되감기하거나 선택한 메시지에서 요약합니다. [checkpointing](https://code.claude.com/docs/ko/checkpointing) 을 참조하세요. 별칭: `/checkpoint`, `/undo` |
| `/sandbox` | [sandbox mode](https://code.claude.com/docs/ko/sandboxing) 를 전환합니다. 지원되는 플랫폼에서만 사용 가능합니다 |
| `/schedule [description]` | [routines](https://code.claude.com/docs/ko/routines) 를 만들거나, 업데이트하거나, 나열하거나, 실행합니다. Claude가 설정 과정을 대화형으로 안내합니다. 별칭: `/routines` |
| `/security-review` | 현재 브랜치의 보류 중인 변경 사항을 보안 취약점에 대해 분석합니다. git diff를 검토하고 주입, 인증 문제 및 데이터 노출과 같은 위험을 식별합니다 |
| `/setup-bedrock` | [Amazon Bedrock](https://code.claude.com/docs/ko/amazon-bedrock) 인증, 지역 및 모델 핀을 대화형 마법사를 통해 구성합니다. `CLAUDE_CODE_USE_BEDROCK=1` 이 설정되어 있을 때만 표시됩니다. 처음 Bedrock을 사용하는 사용자는 로그인 화면에서도 이 마법사에 액세스할 수 있습니다 |
| `/setup-vertex` | [Google Vertex AI](https://code.claude.com/docs/ko/google-vertex-ai) 인증, 프로젝트, 지역 및 모델 핀을 대화형 마법사를 통해 구성합니다. `CLAUDE_CODE_USE_VERTEX=1` 이 설정되어 있을 때만 표시됩니다. 처음 Vertex AI를 사용하는 사용자는 로그인 화면에서도 이 마법사에 액세스할 수 있습니다 |
| `/simplify [focus]` | **[Skill](https://code.claude.com/docs/ko/skills#bundled-skills).** 최근에 변경된 파일을 코드 재사용, 품질 및 효율성 문제에 대해 검토한 다음 수정합니다. 3개의 검토 agent를 병렬로 생성하고, 해당 결과를 집계하고, 수정 사항을 적용합니다. 특정 관심사에 초점을 맞추기 위해 텍스트를 전달합니다: `/simplify focus on memory efficiency` |
| `/skills` | 사용 가능한 [skills](https://code.claude.com/docs/ko/skills) 를 나열합니다. `t` 를 눌러 토큰 수로 정렬합니다 |
| `/stats` | 일일 사용량, 세션 기록, 연속 기록 및 모델 기본 설정을 시각화합니다 |
| `/status` | 버전, 모델, 계정 및 연결성을 표시하는 Settings 인터페이스(Status 탭)를 엽니다. Claude가 응답하는 동안 현재 응답이 완료될 때까지 기다리지 않고 작동합니다 |
| `/statusline` | Claude Code의 [status line](https://code.claude.com/docs/ko/statusline) 을 구성합니다. 원하는 내용을 설명하거나 인수 없이 실행하여 셸 프롬프트에서 자동으로 구성합니다 |
| `/stickers` | Claude Code 스티커를 주문합니다 |
| `/tasks` | 백그라운드 작업을 나열하고 관리합니다. `/bashes` 로도 사용 가능합니다 |
| `/team-onboarding` | Claude Code 사용 기록에서 팀 온보딩 가이드를 생성합니다. Claude는 지난 30일간의 세션, 명령어 및 MCP 서버 사용을 분석하고 팀원이 첫 메시지로 붙여넣어 빠르게 설정할 수 있는 markdown 가이드를 생성합니다 |
| `/teleport` | [Claude Code on the web](https://code.claude.com/docs/ko/claude-code-on-the-web#from-web-to-terminal) 세션을 이 터미널로 가져옵니다. 선택기를 열고 브랜치와 대화를 가져옵니다. `/tp` 로도 사용 가능합니다. claude.ai 구독이 필요합니다 |
| `/terminal-setup` | Shift+Enter 및 기타 바로 가기에 대한 터미널 키바인딩을 구성합니다. VS Code, Cursor, Windsurf, Alacritty 또는 Zed와 같이 필요한 터미널에서만 표시됩니다 |
| `/theme` | 색상 테마를 변경합니다. 터미널의 어두운 또는 밝은 모드를 따르는 `auto` 옵션, 밝은 색과 어두운 색 변형, 색맹 접근 가능(daltonized) 테마 및 터미널의 색상 팔레트를 사용하는 ANSI 테마를 포함합니다 |
| `/tui [default\|fullscreen]` | 터미널 UI 렌더러를 설정하고 대화를 유지하면서 다시 시작합니다. `fullscreen` 은 [flicker-free alt-screen renderer](https://code.claude.com/docs/ko/fullscreen) 를 활성화합니다. 인수 없이 활성 렌더러를 인쇄합니다 |
| `/ultraplan <prompt>` | [ultraplan](https://code.claude.com/docs/ko/ultraplan) 세션에서 계획을 작성하고, 브라우저에서 검토한 다음, 원격으로 실행하거나 터미널로 다시 보냅니다 |
| `/ultrareview [PR]` | [ultrareview](https://code.claude.com/docs/ko/ultrareview) 를 사용하여 클라우드 샌드박스에서 깊은 다중 agent 코드 검토를 실행합니다. Pro 및 Max에서 3회 무료 실행을 포함한 후 [extra usage](https://support.claude.com/en/articles/12429409-extra-usage-for-paid-claude-plans) 가 필요합니다 |
| `/upgrade` | 업그레이드 페이지를 열어 더 높은 요금제로 전환합니다 |
| `/usage` | 요금제 사용 제한 및 속도 제한 상태를 표시합니다 |
| `/vim` | v2.1.92에서 제거됨. Vim과 Normal 편집 모드 사이를 전환하려면 `/config` → Editor mode를 사용하세요 |
| `/voice` | push-to-talk [voice dictation](https://code.claude.com/docs/ko/voice-dictation) 을 전환합니다. Claude.ai 계정이 필요합니다 |
| `/web-setup` | 로컬 `gh` CLI 자격 증명을 사용하여 GitHub 계정을 [Claude Code on the web](https://code.claude.com/docs/ko/web-quickstart#connect-from-your-terminal) 에 연결합니다. `/schedule` 은 GitHub가 연결되지 않은 경우 자동으로 이를 요청합니다 |

## MCP 프롬프트

MCP 서버는 명령어로 나타나는 프롬프트를 노출할 수 있습니다. 이들은 `/mcp__<server>__<prompt>` 형식을 사용하며 연결된 서버에서 동적으로 발견됩니다. 자세한 내용은 [MCP prompts](https://code.claude.com/docs/ko/mcp#use-mcp-prompts-as-commands) 를 참조하세요.

## 참고 항목

- [Skills](https://code.claude.com/docs/ko/skills): 자신만의 명령어 만들기
- [대화형 모드](https://code.claude.com/docs/ko/interactive-mode): 키보드 바로 가기, Vim 모드 및 명령어 기록
- [CLI 참조](https://code.claude.com/docs/ko/cli-reference): 시작 시간 플래그