# 세션 관리와 자동화

> **TL;DR**
> 이전 대화를 이어가거나, Git Worktree로 병렬 작업을 하거나, PR을 생성하거나, Claude Code를 Unix 파이프라인에 통합하는 방법을 다룬다. 스케줄 실행과 알림 설정도 포함한다.

---

## 세션 이어가기

Claude Code를 시작할 때 이전 세션을 이어갈 수 있다.

| 명령 | 동작 |
|------|------|
| `claude --continue` | 현재 디렉토리의 가장 최근 세션을 이어간다 |
| `claude --resume` | 세션 목록을 열어 선택한다 |
| `claude --resume 세션이름` | 이름으로 특정 세션을 바로 이어간다 |
| `claude --from-pr 123` | 특정 PR에 연결된 세션을 이어간다 |
| `/resume` | 실행 중인 세션에서 다른 세션으로 전환한다 |

세션은 프로젝트 디렉토리별로 저장된다. `/resume` 목록에는 같은 git 저장소의 세션이 표시된다 (worktree 포함).

### 세션 이름 지정

세션에 이름을 붙여두면 나중에 쉽게 찾을 수 있다. 여러 작업을 동시에 진행할 때 특히 유용하다.

**시작 시 이름 지정**:

```bash
claude -n auth-refactor
```

**실행 중 이름 변경**:

```
/rename auth-refactor
```

**이름으로 이어가기**:

```bash
claude --resume auth-refactor
```

### 세션 목록 (Session Picker)

`/resume` 또는 `claude --resume` (인자 없이)을 실행하면 세션 목록이 열린다.

**단축키**:

| 키 | 동작 |
|:---|:-----|
| `↑` / `↓` | 세션 간 이동 |
| `→` / `←` | 그룹 열기/닫기 |
| `Enter` | 선택한 세션 이어가기 |
| `P` | 세션 내용 미리보기 |
| `R` | 세션 이름 변경 |
| `/` | 검색 필터 |
| `A` | 현재 디렉토리 / 전체 프로젝트 전환 |
| `B` | 현재 git 브랜치 세션만 필터링 |
| `Esc` | 목록 또는 검색 닫기 |

세션 목록에는 세션 이름(또는 첫 프롬프트), 마지막 활동 후 경과 시간, 메시지 수, git 브랜치가 표시된다. `/branch`, `/rewind`, `--fork-session`으로 분기된 세션은 루트 세션 아래에 그룹화된다.

> **팁**
> - 스크립트에서는 `claude --continue --print "prompt"`로 비대화형 모드로 이어갈 수 있다
> - 이어간 세션은 원래 세션의 모델, 설정, 도구 상태, 전체 대화 기록이 복원된다

---

## Git Worktree로 병렬 작업

여러 작업을 동시에 진행할 때, 각 Claude 세션이 자체 코드베이스 복사본을 가져야 변경 사항이 충돌하지 않는다. Git Worktree는 같은 저장소 히스토리와 리모트를 공유하면서도 별도의 작업 디렉토리와 브랜치를 가지는 구조다.

### 사용 방법

`--worktree` (`-w`) 플래그로 격리된 worktree를 생성하고 Claude를 실행한다:

```bash
# "feature-auth"라는 이름의 worktree 생성
claude --worktree feature-auth

# 별도의 worktree에서 다른 세션 시작
claude --worktree bugfix-123
```

이름을 생략하면 자동 생성된다:

```bash
# "bright-running-fox" 같은 이름이 자동 생성
claude --worktree
```

Worktree는 `<repo>/.claude/worktrees/<이름>/`에 생성되며, 기본 리모트 브랜치에서 분기한다. 브랜치 이름은 `worktree-<이름>`이 된다.

세션 중에 "work in a worktree"라고 요청해도 자동으로 worktree가 생성된다.

### Subagent Worktree

Subagent도 worktree 격리를 사용할 수 있다. "use worktrees for your agents"라고 요청하거나, 커스텀 Subagent의 frontmatter에 `isolation: worktree`를 추가하면 된다. 각 Subagent는 자체 worktree를 가지며, 변경 사항 없이 완료되면 자동 정리된다.

### 정리

세션 종료 시 Claude가 상태에 따라 처리한다:

- **변경 사항 없음**: worktree와 브랜치 자동 삭제
- **변경 사항 있음**: 유지/삭제를 묻는다. 유지하면 나중에 돌아올 수 있고, 삭제하면 커밋되지 않은 변경 사항과 커밋이 모두 제거된다

> **팁**: `.claude/worktrees/`를 `.gitignore`에 추가하면 worktree 내용이 메인 저장소에서 untracked 파일로 표시되지 않는다.

### 수동 관리

위치나 브랜치를 더 세밀하게 제어하려면 Git 명령을 직접 사용한다:

```bash
# 새 브랜치로 worktree 생성
git worktree add ../project-feature-a -b feature-a

# 기존 브랜치로 worktree 생성
git worktree add ../project-bugfix bugfix-123

# worktree에서 Claude 시작
cd ../project-feature-a && claude

# 정리
git worktree list
git worktree remove ../project-feature-a
```

> **주의**: 새 worktree에서는 프로젝트 설정(의존성 설치, 가상 환경 등)을 다시 수행해야 할 수 있다.

### Git 이외의 버전 관리

SVN, Perforce, Mercurial 등 다른 버전 관리 시스템을 사용하는 경우, WorktreeCreate와 WorktreeRemove 훅을 설정해서 커스텀 worktree 생성/정리 로직을 제공할 수 있다. 설정하면 `--worktree` 사용 시 기본 git 동작을 대체한다.

---

## PR 생성

Claude에게 직접 요청하거나 단계별로 진행할 수 있다.

**한 번에 요청**:

```
create a pr for my changes
```

**단계별 진행**:

```
summarize the changes I've made to the authentication module
```

```
create a pr
```

```
enhance the PR description with more context about the security improvements
```

`gh pr create`로 PR을 생성하면 해당 세션이 PR에 자동 연결된다. 나중에 `claude --from-pr <번호>`로 해당 세션을 이어갈 수 있다.

> **팁**: Claude가 생성한 PR을 제출하기 전에 리뷰하고, 잠재적 위험이나 고려사항을 강조해달라고 요청한다.

---

## Unix 유틸리티로 활용

Claude Code를 셸 파이프라인, 빌드 스크립트, 자동화에 통합할 수 있다.

### 린터/리뷰어로 사용

```json
// package.json
{
  "scripts": {
    "lint:claude": "claude -p 'you are a linter. please look at the changes vs. main and report any issues related to typos. report the filename and line number on one line, and a description of the issue on the second line. do not return any other text.'"
  }
}
```

### 파이프 입출력

```bash
cat build-error.txt | claude -p 'concisely explain the root cause of this build error' > output.txt
```

### 출력 형식 제어

| 형식 | 명령 | 용도 |
|------|------|------|
| text (기본값) | `--output-format text` | 단순 통합. Claude의 텍스트 응답만 출력 |
| JSON | `--output-format json` | 메타데이터(비용, 소요 시간) 포함 전체 대화 로그 |
| Streaming JSON | `--output-format stream-json` | 실시간으로 각 대화 턴을 JSON 객체로 출력 |

```bash
# 텍스트 출력
cat data.txt | claude -p 'summarize this data' --output-format text > summary.txt

# JSON 출력
cat code.py | claude -p 'analyze this code for bugs' --output-format json > analysis.json

# 스트리밍 JSON 출력
cat log.txt | claude -p 'parse this log file for errors' --output-format stream-json
```

---

## 스케줄 실행

Claude가 정기적으로 자동 실행되도록 설정할 수 있다. 예: 매일 아침 열린 PR 리뷰, 주간 의존성 감사, 야간 CI 실패 확인.

| 옵션 | 실행 위치 | 적합한 상황 |
|------|-----------|-------------|
| 클라우드 스케줄 작업 | Anthropic 관리 인프라 | 컴퓨터가 꺼져 있어도 실행해야 할 때. claude.ai/code에서 설정 |
| 데스크톱 스케줄 작업 | 로컬 머신 (데스크톱 앱) | 로컬 파일, 도구, 커밋되지 않은 변경에 접근해야 할 때 |
| GitHub Actions | CI 파이프라인 | PR 오픈 등 저장소 이벤트에 연동하거나 cron 스케줄이 필요할 때 |
| `/loop` | 현재 CLI 세션 | 세션이 열려 있는 동안의 빠른 폴링. 세션 종료 시 취소됨 |

> **팁**: 스케줄 작업의 프롬프트는 성공 기준과 결과 처리 방법을 명확히 작성한다. 작업이 자율적으로 실행되므로 명확한 질문을 할 수 없다. 예: "needs-review 라벨이 붙은 열린 PR을 리뷰하고, 문제가 있으면 인라인 코멘트를 남기고, #eng-reviews Slack 채널에 요약을 포스트하라."

---

## 알림 설정 (Notification Hook)

오래 걸리는 작업을 실행한 뒤 다른 창으로 전환했을 때, Claude가 완료되거나 입력이 필요한 시점에 데스크톱 알림을 받을 수 있다. `Notification` 훅 이벤트를 사용한다.

### 설정 방법

`~/.claude/settings.json`에 `Notification` 훅을 추가한다:

**macOS**:

```json
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

**Linux**:

```json
{
  "hooks": {
    "Notification": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "notify-send 'Claude Code' 'Claude Code needs your attention'"
          }
        ]
      }
    ]
  }
}
```

기존 설정에 `hooks` 키가 이미 있다면 `Notification` 항목만 병합한다.

### matcher로 알림 범위 좁히기

기본적으로 모든 알림 유형에서 훅이 실행된다. 특정 이벤트에서만 실행하려면 `matcher` 값을 설정한다:

| matcher | 발생 시점 |
|:--------|:----------|
| `permission_prompt` | Claude가 도구 사용 승인을 요청할 때 |
| `idle_prompt` | Claude가 완료되고 다음 프롬프트를 기다릴 때 |
| `auth_success` | 인증이 완료될 때 |
| `elicitation_dialog` | Claude가 질문을 할 때 |

### 확인

`/hooks`를 입력하고 `Notification`을 선택하면 훅이 정상 등록되었는지 확인할 수 있다.
