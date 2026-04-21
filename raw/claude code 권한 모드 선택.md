---
title: "권한 모드 선택"
source: "https://code.claude.com/docs/ko/permission-modes"
author:
published:
created: 2026-04-20
description: "감독 편집, 읽기 전용 계획, 그리고 백그라운드 분류기가 수동 권한 프롬프트를 대체하는 자동 모드 간에 전환합니다. CLI에서 Shift+Tab으로 모드를 순환하거나 VS Code, Desktop, claude.ai의 모드 선택기를 사용합니다."
tags:
  - "clippings"
---
권한 모드는 Claude가 행동하기 전에 묻는지 여부를 제어합니다. 다양한 작업은 다양한 수준의 자율성을 요구합니다. 민감한 작업에 대해서는 완전한 감시를 원할 수 있고, 긴 리팩토링을 위해서는 최소한의 중단을 원할 수 있으며, 코드베이스를 탐색하는 동안 읽기 전용 액세스를 원할 수 있습니다.

이 페이지에서는 다음을 다룹니다:

## 권한 모드 전환

세션 중, 시작 시 또는 지속적인 기본값으로 언제든지 모드를 전환할 수 있습니다. 메커니즘은 Claude Code를 실행하는 위치에 따라 다릅니다.

**세션 중**: `Shift+Tab` 을 눌러 `default` → `acceptEdits` → `plan` → `auto` 를 순환합니다. 현재 모드는 상태 표시줄에 나타납니다. `auto` 는 시작 시 `--enable-auto-mode` 를 전달할 때까지 순환에 나타나지 않습니다. 자동 모드는 또한 Team, Enterprise, 또는 API 플랜과 Claude Sonnet 4.6 또는 Opus 4.6이 필요하므로, 플래그를 사용하더라도 옵션이 사용 불가능할 수 있습니다. `bypassPermissions` 도 활성화되어 있으면 `plan` 과 `auto` 사이의 순환에 나타납니다.

**시작 시**: CLI 플래그로 모드를 전달합니다:

```shellscript
claude --permission-mode plan
```

**기본값으로**: [설정 파일](https://code.claude.com/docs/ko/settings#settings-files) 에서 `defaultMode` 를 설정합니다:

```json
{
  "permissions": {
    "defaultMode": "acceptEdits"
  }
}
```

**비대화형으로**: 스크립트 실행을 위해 `-p` 와 함께 동일한 플래그를 사용합니다:

```shellscript
claude -p "refactor auth" --permission-mode acceptEdits
```

`dontAsk` 는 `Shift+Tab` 순환에 절대 나타나지 않습니다. `bypassPermissions` 는 `--permission-mode bypassPermissions`, `--dangerously-skip-permissions` 또는 `--allow-dangerously-skip-permissions` 로 세션을 시작한 경우에만 순환에 나타납니다. 세 번째 플래그는 활성화하지 않고 순환에 모드를 추가하므로 `--permission-mode plan` 과 같은 다른 시작 모드와 함께 구성할 수 있습니다. 시작 시 또는 설정 파일에서 이들 중 하나를 설정합니다.

권한 모드는 UI, CLI 플래그 또는 설정 파일을 통해 설정됩니다. 채팅에서 Claude에게 “권한 요청을 중단하세요”라고 말하는 것은 모드를 변경하지 않습니다. 모드가 허용, 요청 및 거부 규칙과 상호 작용하는 방식은 [권한](https://code.claude.com/docs/ko/permissions) 을 참조하세요.

## 사용 가능한 모드

각 모드는 편의성과 감시 사이에서 다른 절충을 합니다. 작업과 일치하는 모드를 선택하세요.

| 모드 | Claude가 묻지 않고 수행할 수 있는 작업 | 최적 사용 사례 |
| --- | --- | --- |
| `default` | 파일 읽기 | 시작, 민감한 작업 |
| `acceptEdits` | 보호된 디렉토리를 제외한 파일 읽기 및 편집 | 검토 중인 코드 반복 |
| [`plan`](#analyze-before-you-edit-with-plan-mode) | 파일 읽기 | 코드베이스 탐색, 리팩토링 계획 |
| [`auto`](#eliminate-prompts-with-auto-mode) | 모든 작업, 백그라운드 안전 검사 포함 | 장시간 실행 작업, 프롬프트 피로 감소 |
| [`bypassPermissions`](#skip-all-checks-with-bypasspermissions-mode) | 보호된 디렉토리에 대한 쓰기를 제외한 모든 작업 | 격리된 컨테이너 및 VM만 |
| [`dontAsk`](#allow-only-pre-approved-tools-with-dontask-mode) | 사전 승인된 도구만 | 잠금된 환경 |

관계없이 모드, `.git`, `.vscode`, `.idea`, `.husky`, `.claude` 에 대한 쓰기는 자동으로 승인되지 않습니다. 단, `.claude/commands`, `.claude/agents`, `.claude/skills` 는 예외입니다. Claude는 이러한 위치에서 정기적으로 스킬, 서브에이전트, 명령을 만듭니다. 이는 리포지토리 상태, 편집기 구성, git 훅, Claude의 자체 설정을 우발적인 손상으로부터 보호합니다.

## 계획 모드로 편집 전에 분석

계획 모드는 Claude에게 변경 사항을 연구하고 제안하도록 지시하지만 변경하지는 않습니다. Claude는 파일을 읽고, 셸 명령을 실행하여 탐색하고, 명확한 질문을 하고, 계획 파일을 작성하지만 소스 코드를 편집하지는 않습니다. 권한 프롬프트는 기본 모드와 동일하게 작동합니다. 여전히 Bash 명령, 네트워크 요청 및 일반적으로 프롬프트를 표시하는 기타 작업을 승인합니다.

### 계획 모드를 사용할 때

계획 모드는 Claude가 변경 사항을 만들기 전에 연구하고 접근 방식을 제안하기를 원할 때 유용합니다:

- **다단계 구현**: 기능이 많은 파일에 걸쳐 편집이 필요할 때
- **코드 탐색**: 무엇이든 변경하기 전에 코드베이스를 연구하고 싶을 때
- **대화형 개발**: Claude와 방향을 반복하고 싶을 때

### 계획 모드 시작 및 사용

단일 요청에 대해 프롬프트 앞에 `/plan` 을 붙여 계획 모드에 들어가거나, `Shift+Tab` 을 눌러 [권한 모드를 순환](#switch-permission-modes) 하여 전체 세션을 계획 모드로 전환합니다. CLI에서 계획 모드로 시작할 수도 있습니다:

```shellscript
claude --permission-mode plan
```

이 예제는 복잡한 리팩토링을 위한 계획 세션을 시작합니다:

```text
I need to refactor our authentication system to use OAuth2. Create a detailed migration plan.
```

Claude는 현재 구현을 분석하고 계획을 만듭니다. 후속 질문으로 개선합니다:

```text
What about backward compatibility?
How should we handle database migration?
```

계획이 준비되면 Claude는 이를 제시하고 진행 방법을 묻습니다. 해당 프롬프트에서 다음을 수행할 수 있습니다:

- 승인하고 자동 모드로 시작
- 승인하고 편집 수락
- 승인하고 각 편집을 수동으로 검토
- 계획을 계속하여 피드백을 Claude에게 다시 보내 다른 라운드 진행

각 승인 옵션은 먼저 계획 컨텍스트를 지우도록 제안합니다.

## 자동 모드로 프롬프트 제거

자동 모드는 Team, Enterprise, 및 API 플랜에서 사용 가능합니다. Team 및 Enterprise에서 관리자는 사용자가 켜기 전에 [Claude Code 관리자 설정](https://claude.ai/admin-settings/claude-code) 에서 이를 활성화해야 합니다. Claude Sonnet 4.6 또는 Claude Opus 4.6이 필요하며, Haiku, claude-3 모델 또는 타사 제공자(Bedrock, Vertex, Foundry)에서는 사용할 수 없습니다.

자동 모드를 사용하면 Claude가 권한 프롬프트를 표시하지 않고 작업을 실행할 수 있습니다. 각 작업이 실행되기 전에 별도의 분류기 모델이 대화를 검토하고 작업이 요청한 내용과 일치하는지 결정합니다. 분류기는 작업 범위를 초과하는 작업, 분류기가 신뢰할 수 있는 것으로 인식하지 못하는 인프라를 대상으로 하는 작업, 또는 파일이나 웹 페이지에 포함된 악의적인 지시사항에 의해 주도되는 것으로 보이는 작업을 차단합니다. 악의적인 지시사항은 파일, 웹 페이지 또는 도구 결과에 포함된 적대적인 지시사항으로, Claude를 요청하지 않은 작업으로 리다이렉트하려고 시도합니다. 방어는 계층화되어 있습니다: 서버 측 프로브는 들어오는 도구 결과를 스캔하고 Claude가 읽기 전에 의심스러운 콘텐츠에 플래그를 지정하는 반면, 분류기 자체는 도구 결과를 표시하지 않으므로 주입된 지시사항이 승인 결정에 영향을 미칠 수 없습니다. 이러한 계층이 함께 작동하는 방식에 대한 더 깊은 이해는 [자동 모드 공지](https://claude.com/blog/auto-mode) 및 [엔지니어링 심층 분석](https://www.anthropic.com/engineering/claude-code-auto-mode) 을 참조하세요.

자동 모드는 연구 미리보기입니다. 프롬프트를 줄이지만 안전을 보장하지는 않습니다. `bypassPermissions` 보다 더 많은 보호를 제공하지만 각 작업을 수동으로 검토하는 것만큼 철저하지는 않습니다. 일반적인 방향을 신뢰하는 작업에 사용하고, 민감한 작업에 대한 검토 대체로 사용하지 마세요.

**모델**: 분류기는 주 세션이 다른 모델을 사용하더라도 Claude Sonnet 4.6에서 실행됩니다.

**비용**: 분류기 호출은 주 세션 호출과 동일하게 토큰 사용량으로 계산됩니다. 각 확인된 작업은 대화 기록의 일부와 보류 중인 작업을 분류기에 보냅니다. 추가 비용은 주로 셸 명령 및 네트워크 작업에서 발생합니다. 읽기 전용 작업 및 작업 디렉토리의 파일 편집은 분류기 호출을 트리거하지 않기 때문입니다.

**지연**: 각 분류기 검사는 작업이 실행되기 전에 왕복을 추가합니다.

### 작업 평가 방식

각 작업은 고정된 결정 순서를 거칩니다. 첫 번째 일치 단계가 승리합니다:

1. [허용 또는 거부 규칙](https://code.claude.com/docs/ko/permissions#manage-permissions) 과 일치하는 작업은 즉시 해결됩니다
2. 읽기 전용 작업 및 작업 디렉토리의 파일 편집은 자동 승인됩니다. 보호된 디렉토리에 대한 쓰기는 제외됩니다
3. 나머지는 모두 분류기로 이동합니다
4. 분류기가 차단하면 Claude는 이유를 받고 대체 접근 방식을 시도합니다

자동 모드에 들어가면 Claude Code는 임의의 코드 실행을 부여하는 것으로 알려진 허용 규칙을 삭제합니다: `Bash(*)` 와 같은 무제한 셸 액세스, `Bash(python*)` 또는 `Bash(node*)` 와 같은 와일드카드 스크립트 인터프리터, 패키지 관리자 실행 명령, 그리고 모든 `Agent` 허용 규칙. 이러한 규칙은 분류기가 이를 보기 전에 가장 손상을 일으킬 수 있는 명령 및 서브에이전트 위임을 자동 승인합니다. `Bash(npm test)` 와 같은 좁은 규칙은 유지됩니다. 삭제된 규칙은 자동 모드를 종료할 때 복원됩니다.

분류기는 사용자 메시지 및 도구 호출을 입력으로 받으며, Claude의 자체 텍스트 및 도구 결과는 제거됩니다. 또한 CLAUDE.md 콘텐츠를 받으므로 프로젝트 지침에 설명된 작업이 허용 및 차단 결정에 고려됩니다. 도구 결과가 분류기에 도달하지 않으므로 파일이나 웹 페이지의 악의적인 콘텐츠는 이를 직접 조작할 수 없습니다. 분류기는 보류 중인 작업을 사용자 정의 가능한 차단 및 허용 규칙 집합에 대해 평가하여 작업이 요청한 것을 초과하는 과도한 확대, 안전하게 건드릴 수 있는 것에 대한 실수, 또는 Claude가 읽은 것에 의해 조종되었을 수 있음을 시사하는 명시된 의도에서의 갑작스러운 이탈인지 확인합니다.

권한 규칙과 달리 분류기는 도구 이름 및 인수 패턴과 일치하는 규칙과 달리 차단 및 허용할 항목의 산문 설명을 읽습니다. 구문 일치보다는 컨텍스트에서 작업을 추론합니다.

### 자동 모드가 서브에이전트를 처리하는 방식

Claude가 [서브에이전트](https://code.claude.com/docs/ko/sub-agents) 를 생성할 때, 분류기는 서브에이전트가 시작되기 전에 위임된 작업을 평가합니다. “이 패턴과 일치하는 모든 원격 분기 삭제”와 같이 자체적으로 위험해 보이는 작업 설명은 생성 시점에 차단됩니다.

서브에이전트 내에서 자동 모드는 부모 세션과 동일한 차단 및 허용 규칙으로 실행됩니다. 서브에이전트가 자체 프론트매터에서 정의하는 모든 `permissionMode` 는 무시됩니다. 서브에이전트의 자체 도구 호출은 분류기를 통해 독립적으로 진행됩니다.

서브에이전트가 완료되면 분류기는 전체 작업 기록을 검토합니다. 생성 시점에 무해했던 서브에이전트는 실행 중에 읽은 콘텐츠에 의해 손상될 수 있습니다. 반환 검사가 우려 사항을 표시하면 보안 경고가 서브에이전트의 결과에 앞에 붙어 주 에이전트가 진행 방법을 결정할 수 있습니다.

### 분류기가 기본적으로 차단하는 항목

기본적으로 분류기는 작업 디렉토리와 git 리포지토리에 있는 경우 해당 리포지토리의 구성된 원격을 신뢰합니다. 다른 모든 것은 외부로 취급됩니다: 회사의 소스 제어 조직, 클라우드 버킷, 내부 서비스는 사용자가 분류기에 알릴 때까지 알려지지 않습니다.

**기본적으로 차단됨**:

- `curl | bash` 또는 복제된 리포지토리의 스크립트와 같은 코드 다운로드 및 실행
- 외부 엔드포인트로 민감한 데이터 전송
- 프로덕션 배포 및 마이그레이션
- 클라우드 스토리지의 대량 삭제
- IAM 또는 리포지토리 권한 부여
- 공유 인프라 수정
- 세션 시작 전에 존재했던 파일을 되돌릴 수 없게 삭제
- 강제 푸시 또는 `main` 에 직접 푸시와 같은 파괴적인 소스 제어 작업

**기본적으로 허용됨**:

- 작업 디렉토리의 로컬 파일 작업
- 잠금 파일 또는 매니페스트에 이미 선언된 종속성 설치
- `.env` 읽기 및 자격 증명을 일치하는 API로 전송
- 읽기 전용 HTTP 요청
- 시작한 분기 또는 Claude가 만든 분기로 푸시

분류기가 받는 전체 기본 규칙 목록을 보려면 `claude auto-mode defaults` 를 실행합니다.

자동 모드가 팀에 일상적인 것을 차단하는 경우, 예를 들어 자신의 조직의 리포지토리로 푸시하거나 회사 버킷에 쓰는 경우, 분류기가 이들이 신뢰할 수 있다는 것을 모르기 때문입니다. 관리자는 `autoMode.environment` 설정을 통해 신뢰할 수 있는 리포지토리, 버킷, 내부 서비스를 추가할 수 있습니다: 전체 구성 가이드는 [자동 모드 분류기 구성](https://code.claude.com/docs/ko/permissions#configure-the-auto-mode-classifier) 을 참조하세요.

### 자동 모드가 폴백할 때

폴백 설계는 거짓 긍정이 세션을 탈선시키는 것을 방지합니다: 잘못된 차단은 Claude에게 재시도 비용이 들지만 진행 상황에는 영향을 주지 않습니다. 분류기가 한 행에서 3번 또는 한 세션에서 총 20번 작업을 차단하면 자동 모드가 일시 중지되고 Claude Code는 각 작업에 대해 프롬프트를 다시 시작합니다. 이러한 임계값은 구성할 수 없습니다.

- **CLI**: 상태 영역에 알림이 표시됩니다. 거부된 작업은 `/permissions` 아래의 최근 거부됨 탭에 나타납니다. 프롬프트된 작업을 승인하면 거부 카운터가 재설정되므로 자동 모드를 계속할 수 있습니다
- **`-p` 플래그를 사용한 비대화형 모드**: 프롬프트할 사용자가 없으므로 세션을 중단합니다

반복된 차단은 일반적으로 두 가지 중 하나를 의미합니다: 작업이 분류기가 중지하도록 구축된 작업을 진정으로 필요로 하거나, 분류기가 신뢰할 수 있는 인프라에 대한 컨텍스트가 부족하여 안전한 작업을 위험한 것으로 취급합니다. 차단이 거짓 긍정처럼 보이거나 분류기가 놓친 것이 있으면 `/feedback` 을 사용하여 보고합니다. 분류기가 리포지토리 또는 서비스를 신뢰할 수 있는 것으로 인식하지 못하기 때문에 차단이 발생하는 경우 관리자가 관리 설정에서 [신뢰할 수 있는 인프라를 구성](https://code.claude.com/docs/ko/permissions#configure-the-auto-mode-classifier) 하도록 합니다.

## dontAsk 모드로 사전 승인된 도구만 허용

`dontAsk` 모드는 명시적으로 허용되지 않은 모든 도구를 자동으로 거부합니다. `/permissions` 허용 규칙 또는 `permissions.allow` 설정과 일치하는 작업만 실행할 수 있습니다. 도구에 명시적 `ask` 규칙이 있으면 프롬프트 대신 작업도 거부됩니다. 이는 모드를 완전히 비대화형으로 만들어 CI 파이프라인 또는 Claude가 정확히 수행할 수 있는 작업을 사전 정의하는 제한된 환경에 적합합니다.

```shellscript
claude --permission-mode dontAsk
```

## bypassPermissions 모드로 모든 검사 건너뛰기

`bypassPermissions` 모드는 모든 권한 프롬프트 및 안전 검사를 비활성화합니다. 도구 호출은 `.git`, `.vscode`, `.idea`, `.husky` 에 대한 쓰기를 제외하고 즉시 실행되며, 이는 리포지토리 상태, 편집기 구성, git 훅의 우발적인 손상을 방지하기 위해 여전히 프롬프트합니다. `.claude` 에 대한 쓰기도 프롬프트하지만, `.claude/commands`, `.claude/agents`, `.claude/skills` 는 제외됩니다. Claude는 이러한 위치에서 정기적으로 스킬, 서브에이전트, 명령을 만듭니다. 이 모드는 인터넷 액세스 없이 컨테이너, VM 또는 devcontainer와 같은 격리된 환경에서만 사용하세요. Claude Code가 호스트 시스템에 손상을 줄 수 없습니다.

```shellscript
claude --permission-mode bypassPermissions
```

`--dangerously-skip-permissions` 플래그는 `--permission-mode bypassPermissions` 과 동등합니다:

```shellscript
claude -p "refactor the auth module" --dangerously-skip-permissions
```

`bypassPermissions` 모드는 프롬프트 주입 또는 의도하지 않은 작업에 대한 보호를 제공하지 않습니다. 여전히 백그라운드 안전 검사를 유지하는 더 안전한 대체 방법은 [자동 모드](#eliminate-prompts-with-auto-mode) 를 사용합니다. 관리자는 [관리 설정](https://code.claude.com/docs/ko/permissions#managed-settings) 에서 `permissions.disableBypassPermissionsMode` 를 `"disable"` 로 설정하여 이 모드를 차단할 수 있습니다.

## 권한 접근 방식 비교

아래 표는 각 모드가 승인을 처리하는 방식의 주요 차이점을 요약합니다. `plan` 은 승인 작동 방식보다는 Claude가 수행할 수 있는 작업을 제한하므로 생략됩니다.

|  | `default` | `acceptEdits` | `auto` | `dontAsk` | `bypassPermissions` |
| --- | --- | --- | --- | --- | --- |
| 권한 프롬프트 | 파일 편집 및 명령 | 명령 및 보호된 디렉토리 | 폴백이 트리거되지 않는 한 없음 | 없음, 사전 허용되지 않으면 차단됨 | 보호된 디렉토리만 |
| 안전 검사 | 각 작업 검토 | 명령 및 보호된 디렉토리 쓰기 검토 | 분류기가 명령 및 보호된 디렉토리 쓰기 검토 | 사전 승인된 규칙만 | 보호된 디렉토리 쓰기 검토 |
| 토큰 사용 | 표준 | 표준 | 더 높음, 분류기 호출에서 | 표준 | 표준 |

## 권한을 추가로 사용자 정의

권한 모드는 기본 승인 동작을 설정합니다. 개별 도구 또는 명령에 대한 제어를 위해 활성 모드 위에 추가 구성을 계층화합니다.

**권한 규칙** 이 첫 번째 중지점입니다. 설정 파일에 `allow`, `ask` 또는 `deny` 항목을 추가하여 안전한 명령을 사전 승인하고, 위험한 명령에 대해 프롬프트를 강제하거나, 특정 도구를 완전히 차단합니다. 규칙은 `bypassPermissions` 를 제외한 모든 모드에서 적용되며, 이는 권한 계층을 완전히 건너뜁니다. 도구 이름 및 인수 패턴으로 일치합니다. 구문 및 예제는 [권한 관리](https://code.claude.com/docs/ko/permissions#manage-permissions) 를 참조하세요.

**Hooks** 는 패턴 일치 규칙이 표현할 수 없는 논리를 다룹니다. [`PreToolUse` hook](https://code.claude.com/docs/ko/hooks#pretooluse-decision-control) 은 모든 도구 호출 전에 실행되며 명령 콘텐츠, 파일 경로, 시간 또는 외부 정책 서비스의 응답을 기반으로 허용, 거부 또는 확대할 수 있습니다. [`PermissionRequest` hook](https://code.claude.com/docs/ko/hooks#permissionrequest) 은 권한 대화 자체를 가로채고 대신 응답합니다. 구성은 [Hooks](https://code.claude.com/docs/ko/hooks) 를 참조하세요.

## 참고 항목

- [권한](https://code.claude.com/docs/ko/permissions): 권한 규칙, 구문, 관리 정책
- [Hooks](https://code.claude.com/docs/ko/hooks): 사용자 정의 권한 논리, 라이프사이클 스크립팅
- [보안](https://code.claude.com/docs/ko/security): 보안 보호 및 모범 사례
- [샌드박싱](https://code.claude.com/docs/ko/sandboxing): Bash 명령에 대한 파일 시스템 및 네트워크 격리
- [비대화형 모드](https://code.claude.com/docs/ko/headless): `-p` 플래그를 사용하여 프로그래밍 방식으로 Claude Code 실행