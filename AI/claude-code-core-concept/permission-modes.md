# 권한 모드 (Permission Modes)

## 모드 비교

| 모드 | 승인 없이 실행되는 것 | 적합한 상황 |
| :--- | :--- | :--- |
| `default` | 읽기 전용 | 처음 시작할 때, 민감한 작업 |
| `acceptEdits` | 읽기 + 파일 편집 | 편집 후 `git diff`로 검토할 때 |
| `plan` | 읽기 전용 | 변경 전 코드베이스 탐색 |
| `auto` | 모든 것 (백그라운드 안전 검사 포함) | 긴 작업, 승인 피로 감소 |
| `dontAsk` | 사전 승인된 도구만 | CI 파이프라인, 잠긴 스크립트 |
| `bypassPermissions` | 보호 경로를 제외한 모든 것 | 격리된 컨테이너/VM 전용 |

[보호 경로](#보호-경로)에 대한 쓰기는 모드에 관계없이 자동 승인하지 않는다.

## CLI에서 전환하기

**세션 중**: `Shift+Tab`으로 `default` → `acceptEdits` → `plan` 순환. 현재 모드는 상태 표시줄에 표시된다.

기본 순환에 포함되지 않는 모드:
- `auto`: `--enable-auto-mode` 플래그로 활성화해야 순환에 추가된다
- `bypassPermissions`: `--permission-mode bypassPermissions` 또는 `--dangerously-skip-permissions`로 시작해야 순환에 추가된다
- `dontAsk`: 순환에 없음, 플래그로만 설정 가능

**시작 시**: 플래그로 모드 지정

```bash
claude --permission-mode plan
```

**기본값으로 설정**: `settings.json`에서 `defaultMode` 지정

```json
{
  "permissions": {
    "defaultMode": "acceptEdits"
  }
}
```

## 각 모드 상세

### acceptEdits

작업 디렉토리 내 파일 생성과 편집을 승인 없이 실행한다. 보호 경로 쓰기와 파일 편집 외 모든 작업은 기본 모드와 동일하게 확인을 요청한다. 활성화 중에는 상태 표시줄에 `⏵⏵ accept edits on`이 표시된다.

편집마다 인라인으로 승인하는 대신 나중에 에디터나 `git diff`로 검토하고 싶을 때 사용한다.

```bash
claude --permission-mode acceptEdits
```

### plan

파일을 읽고 셸 명령으로 탐색하여 계획을 작성하지만, 실제 편집은 하지 않는다. 확인 요청은 기본 모드와 같다.

`Shift+Tab`으로 진입하거나, 단일 프롬프트 앞에 `/plan`을 붙여 사용할 수 있다.

```bash
claude --permission-mode plan
```

계획이 완성되면 Claude가 진행 방법을 제안한다:
- auto 모드로 승인하여 실행
- acceptEdits 모드로 승인하여 실행
- 각 편집을 수동으로 검토하며 실행
- 피드백을 주며 계속 계획

`Shift+Tab`을 다시 누르면 계획을 승인하지 않고 plan 모드를 종료한다.

### auto

> Claude Code v2.1.83 이상 필요

승인 프롬프트 없이 Claude가 실행한다. 별도의 분류기(classifier) 모델이 각 작업을 실행 전에 검토하여, 요청 범위를 벗어나거나 의심스러운 콘텐츠에 의해 유도된 행동을 차단한다.

#### 사용 조건

| 항목 | 요건 |
| :--- | :--- |
| 플랜 | Team, Enterprise, API (Pro/Max 불가) |
| 모델 | Claude Sonnet 4.6 또는 Opus 4.6 (Haiku, claude-3 불가) |
| 제공자 | Anthropic API 전용 (Bedrock, Vertex, Foundry 불가) |
| 관리자 | Team/Enterprise는 관리자가 먼저 활성화해야 함 |

```bash
claude --enable-auto-mode
```

활성화하면 `Shift+Tab` 순환에 `auto`가 추가된다.

#### 분류기가 기본 차단하는 것

- `curl | bash` 같은 외부 코드 다운로드 및 실행
- 외부 엔드포인트로 민감 데이터 전송
- 프로덕션 배포 및 마이그레이션
- 클라우드 스토리지 대량 삭제
- IAM 또는 저장소 권한 부여
- 공유 인프라 수정
- 세션 시작 전 존재했던 파일 영구 삭제
- force push 또는 `main`에 직접 push

#### 분류기가 기본 허용하는 것

- 작업 디렉토리 내 파일 조작
- 잠금 파일/매니페스트에 선언된 의존성 설치
- `.env` 읽기 및 해당 API에 자격증명 전송
- 읽기 전용 HTTP 요청
- 시작 브랜치 또는 Claude가 생성한 브랜치에 push

`claude auto-mode defaults`로 전체 규칙 목록을 확인할 수 있다.

#### fallback 동작

차단된 작업은 알림으로 표시되고 `/permissions`의 '최근 차단됨' 탭에서 `r`을 눌러 수동 승인으로 재시도할 수 있다.

같은 작업이 연속 3번 또는 세션 전체에서 20번 차단되면 auto 모드가 일시 중지되고 프롬프트 방식으로 전환된다. 허용된 작업이 발생하면 연속 카운터는 초기화되지만, 총 카운터는 세션 동안 유지된다.

#### 분류기 평가 방식

각 작업은 다음 순서로 평가되며, 첫 번째 매칭 단계에서 결정된다:

1. 허용/차단 규칙과 일치하면 즉시 결정
2. 작업 디렉토리 내 읽기 전용 작업과 파일 편집은 자동 승인 (보호 경로 제외)
3. 나머지는 분류기로 전달
4. 분류기가 차단하면 Claude가 이유를 받고 대안을 시도

분류기는 사용자 메시지, 도구 호출, CLAUDE.md 내용을 참조한다. 도구 결과는 제외되므로 파일이나 웹 페이지의 악성 콘텐츠가 분류기를 직접 조작할 수 없다.

### dontAsk

명시적으로 허용된 도구만 실행하고, 나머지는 모두 자동 거부한다. 프롬프트가 전혀 없는 완전 비대화형 모드로, CI 파이프라인이나 실행 가능한 작업을 사전에 정의해둔 제한된 환경에 적합하다.

```bash
claude --permission-mode dontAsk
```

### bypassPermissions

권한 프롬프트와 안전 검사를 모두 비활성화하여 도구 호출이 즉시 실행된다. 보호 경로 쓰기만 예외적으로 확인을 요청한다. 인터넷 접근이 없는 컨테이너, VM, devcontainer 같은 격리된 환경에서만 사용해야 한다.

```bash
claude --permission-mode bypassPermissions
```

`--dangerously-skip-permissions` 플래그도 동일하게 동작한다.

> **주의**: `bypassPermissions`는 프롬프트 인젝션이나 의도치 않은 작업을 막지 않는다. 프롬프트 없이 백그라운드 안전 검사가 필요하면 auto 모드를 사용한다.

## 보호 경로

저장소 상태와 Claude 자체 설정의 우발적 손상을 막기 위해, 모든 모드에서 아래 경로에 대한 쓰기는 자동 승인하지 않는다.

**보호 디렉토리**
- `.git`
- `.vscode`
- `.idea`
- `.husky`
- `.claude` (단, `.claude/commands`, `.claude/agents`, `.claude/skills`, `.claude/worktrees`는 제외)

**보호 파일**
- `.gitconfig`, `.gitmodules`
- `.bashrc`, `.bash_profile`, `.zshrc`, `.zprofile`, `.profile`
- `.ripgreprc`
- `.mcp.json`, `.claude.json`
