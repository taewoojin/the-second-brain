# Claude Code 권한 모드

**출처**: `raw/claude code 권한 모드 선택.md`
**날짜**: 2026-04-20
**keywords**: 권한 모드, auto mode, plan mode, acceptEdits, bypassPermissions, dontAsk, 분류기, 권한 프롬프트

## 요약

권한 모드는 Claude가 행동하기 전에 사용자에게 확인을 요청할지 여부를 제어하는 메커니즘으로, default·acceptEdits·plan·auto·dontAsk·bypassPermissions 6가지 모드를 제공한다. `Shift+Tab`으로 세션 중 순환하거나 CLI 플래그·설정 파일로 기본값을 지정할 수 있으며, auto 모드는 별도 분류기 모델이 각 작업을 평가하여 권한 프롬프트 없이 실행한다.

## 권한 모드 전환

| 방법 | 명령 |
| --- | --- |
| **세션 중 전환** | `Shift+Tab` → `default` → `acceptEdits` → `plan` → (auto) 순환 |
| **시작 시 지정** | `claude --permission-mode plan` |
| **기본값 설정** | `.claude/settings.json`의 `permissions.defaultMode` |
| **비대화형** | `claude -p "..." --permission-mode acceptEdits` |

```json
// .claude/settings.json
{
  "permissions": {
    "defaultMode": "acceptEdits"
  }
}
```

**주의**: `auto` 모드는 `--enable-auto-mode` 플래그를 전달해야 순환에 나타남. Team/Enterprise/API 플랜 + Claude Sonnet 4.6 또는 Opus 4.6 필요.

## 사용 가능한 모드

| 모드 | 묻지 않고 수행 가능한 작업 | 최적 사용 사례 |
| --- | --- | --- |
| `default` | 파일 읽기 | 시작, 민감한 작업 |
| `acceptEdits` | 보호된 디렉토리 제외 파일 읽기·편집 | 코드 반복 중 |
| `plan` | 파일 읽기 (소스 코드 편집 불가) | 코드베이스 탐색, 리팩토링 계획 |
| `auto` | 모든 작업 (분류기 백그라운드 검사 포함) | 장시간 실행 작업, 프롬프트 피로 감소 |
| `bypassPermissions` | 보호된 디렉토리 쓰기 제외 모든 작업 | 격리된 컨테이너·VM만 |
| `dontAsk` | 사전 승인된 도구만 | 잠금된 CI 환경 |

**보호된 위치** (모드 무관하게 자동 승인 안 됨): `.git`, `.vscode`, `.idea`, `.husky`, `.claude` (단, `.claude/commands`, `.claude/agents`, `.claude/skills`는 예외)

## plan 모드

Claude가 파일을 읽고 탐색하지만 소스 코드를 편집하지 않는다. `/plan` 명령으로 단일 요청에 plan 모드 진입 가능:

```shell
claude --permission-mode plan
```

계획이 준비되면 Claude가 제시하고 진행 방법(auto 모드로 시작 / 편집 수락 / 수동 검토 / 추가 피드백)을 묻는다. 각 승인 옵션은 계획 컨텍스트를 지우도록 제안한다.

## auto 모드

### 작동 원리

권한 프롬프트 없이 실행하되, 각 작업 전에 별도의 **분류기 모델**(Claude Sonnet 4.6 고정)이 작업을 평가한다. 분류기는 도구 이름·인수 패턴이 아닌 **산문 설명으로 컨텍스트 기반 추론**을 수행한다.

작업 평가 순서 (첫 번째 일치 우선):
1. 허용/거부 규칙과 일치 → 즉시 해결
2. 읽기 전용 작업 + 작업 디렉토리 파일 편집 → 자동 승인
3. 나머지 → 분류기 평가
4. 분류기 차단 → Claude가 대체 접근 방식 시도

### 기본 차단/허용 항목

**기본 차단**: `curl | bash` 코드 실행, 외부 엔드포인트로 민감한 데이터 전송, 프로덕션 배포, 클라우드 스토리지 대량 삭제, IAM 권한 부여, 강제 푸시/`main` 직접 푸시

**기본 허용**: 작업 디렉토리 로컬 파일 작업, 선언된 의존성 설치, `.env` 읽기, 읽기 전용 HTTP 요청, 직접 만든 브랜치로 푸시

기본 규칙 전체 목록 확인: `claude auto-mode defaults`

신뢰할 수 있는 인프라(조직 리포지토리, 내부 서비스 등)를 분류기에 알리려면 `autoMode.environment` 설정으로 관리자가 구성.

### 분류기 폴백

3회 연속 또는 한 세션에서 20회 이상 차단 시 auto 모드가 일시 중지되고 수동 프롬프트로 복귀. 프롬프트된 작업을 승인하면 거부 카운터가 재설정된다. 비대화형 모드(`-p`)에서는 세션 중단.

### auto 모드와 서브에이전트

서브에이전트 생성 시 분류기가 위임된 작업을 평가. 서브에이전트 내부 도구 호출도 독립적으로 분류기를 통과. 완료 후 분류기가 전체 작업 기록을 검토하며, 이상 징후 발견 시 보안 경고를 결과에 첨부.

**auto 모드 진입 시 삭제되는 허용 규칙**: `Bash(*)` 같은 무제한 셸 액세스, 와일드카드 스크립트 인터프리터, 패키지 관리자 실행 명령, 모든 `Agent` 허용 규칙. `Bash(npm test)`처럼 좁은 규칙은 유지. 모드 종료 시 복원.

## dontAsk 모드

명시적으로 허용되지 않은 모든 도구를 자동 거부. `permissions.allow` 설정 또는 `/permissions` 허용 규칙과 일치하는 작업만 실행 가능. 완전 비대화형이므로 CI 파이프라인에 적합.

```shell
claude --permission-mode dontAsk
```

## bypassPermissions 모드

모든 권한 프롬프트 및 안전 검사 비활성화. **격리된 컨테이너/VM에서만 사용**. 인터넷 없는 환경에서 안전.

```shell
claude --permission-mode bypassPermissions
# 동등한 플래그
claude -p "..." --dangerously-skip-permissions
```

관리자가 `permissions.disableBypassPermissionsMode: "disable"`로 차단 가능.

## 권한 모드 비교

|  | `default` | `acceptEdits` | `auto` | `dontAsk` | `bypassPermissions` |
| --- | --- | --- | --- | --- | --- |
| 권한 프롬프트 | 파일 편집 + 명령 | 명령 + 보호 디렉토리 | 폴백 미발생 시 없음 | 없음 (미허용 시 차단) | 보호 디렉토리만 |
| 안전 검사 | 각 작업 검토 | 명령 + 보호 쓰기 검토 | 분류기 검토 | 사전 승인 규칙만 | 보호 디렉토리 쓰기 |
| 토큰 사용 | 표준 | 표준 | 더 높음 (분류기 호출) | 표준 | 표준 |

## 권한 추가 커스터마이징

권한 모드 위에 추가 계층화:
- **권한 규칙** (`allow`/`ask`/`deny`): 특정 명령 사전 승인 또는 차단. `bypassPermissions` 제외 모든 모드에 적용.
- **Hooks**: 패턴 매칭으로 불가능한 로직 처리. `PreToolUse` hook으로 명령 내용·파일 경로 기반 허용/거부/에스컬레이션. `PermissionRequest` hook으로 권한 대화 자체를 가로채서 응답.

## 관련 항목

- [[wiki/ai/claude-code/claude-code-작동방식-에이전트하네스]]
- [[wiki/ai/claude-code/claude-code-hooks-자동화가이드]]
