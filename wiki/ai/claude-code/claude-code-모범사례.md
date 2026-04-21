# Claude Code 모범 사례 — context 관리, 프롬프팅, 자동화 패턴

**출처**: `raw/claude code 모범 사례.md`
**날짜**: 2026-04-21
**keywords**: context window 관리, Plan Mode, subagent 위임, CLAUDE.md 최적화, 검증 기반 개발, 비대화형 모드, fan-out 패턴

## 요약

context window를 핵심 제약으로 삼아 검증 기준 제공, 탐색→계획→코딩 순서, 구체적 프롬프팅, subagent 위임 등 효율적인 Claude Code 사용 패턴을 정리한다. Anthropic 내부팀과 실전 엔지니어들의 검증된 패턴으로, 대부분의 권장 사항은 "context를 낭비하지 않는 방향"으로 귀결된다.

---

대부분의 모범 사례는 하나의 제약 조건을 기반으로 한다: **Claude의 context window가 빠르게 채워지고, 채워질수록 성능이 저하된다.**

## 작업 검증할 방법 제공하기

**가장 높은 영향력의 단일 작업**. Claude가 자신의 작업을 확인할 수 있도록 테스트, 스크린샷 또는 예상 출력을 포함한다.

| 전략 | 나쁜 예 | 좋은 예 |
| --- | --- | --- |
| **검증 기준 제공** | "이메일 주소를 검증하는 함수를 구현하세요" | "validateEmail 함수를 작성하세요. 예제 테스트 케이스: user@example.com → true, invalid → false. 구현 후 테스트를 실행하세요" |
| **UI 변경 사항을 시각적으로 검증** | "대시보드를 더 좋게 보이게 하세요" | "[스크린샷 붙여넣기] 이 디자인을 구현하세요. 결과의 스크린샷을 찍고 원본과 비교하세요" |
| **증상이 아닌 근본 원인 해결** | "빌드가 실패하고 있습니다" | "빌드가 이 오류로 실패합니다: [오류]. 수정하고 빌드가 성공하는지 확인하세요. 오류를 억제하지 마세요" |

## 먼저 탐색하고, 그 다음 계획하고, 그 다음 코드 작성하기

Claude가 바로 코딩으로 뛰어들면 잘못된 문제를 해결하는 코드가 생성될 수 있다. Plan Mode를 사용하여 탐색을 실행과 분리한다.

권장 4단계: **탐색 → 계획 → 구현 → 검증**

Plan Mode는 다음 경우에 가장 유용하다:
- 접근 방식이 불확실할 때
- 변경이 여러 파일을 수정할 때
- 수정 중인 코드에 익숙하지 않을 때

diff를 한 문장으로 설명할 수 있다면 계획을 건너뛰어도 된다.

## 프롬프트에서 구체적인 컨텍스트 제공하기

| 전략 | 나쁜 예 | 좋은 예 |
| --- | --- | --- |
| **작업 범위 지정** | "foo.py에 대한 테스트 추가" | "사용자가 로그아웃된 경우의 엣지 케이스를 다루는 foo.py에 대한 테스트를 작성하세요. 모의 객체를 피하세요." |
| **소스 지적** | "ExecutionFactory가 왜 이상한 API를 가집니까?" | "ExecutionFactory의 git 히스토리를 살펴보고 API가 어떻게 되었는지 요약하세요" |
| **기존 패턴 참조** | "캘린더 위젯 추가" | "HotDogWidget.php 패턴을 따라 캘린더 위젯을 구현하세요. 코드베이스에서 이미 사용 중인 라이브러리 외에는 사용하지 마세요." |
| **증상 설명** | "로그인 버그 수정" | "세션 시간 초과 후 로그인이 실패합니다. src/auth/의 토큰 새로 고침을 확인하세요. 실패 테스트를 작성한 다음 수정하세요" |

### 풍부한 콘텐츠 제공하기

- **`@`로 파일 참조**: 코드가 어디에 있는지 설명 대신 직접 참조
- **이미지를 직접 붙여넣기**
- **URL 제공**: 문서 및 API 참조
- **데이터 파이프**: `cat error.log | claude`

## 환경 구성하기

### 효과적인 CLAUDE.md 작성하기

`/init`으로 시작 파일 생성 후 개선한다.

| 포함 | 제외 |
| --- | --- |
| Claude가 추측할 수 없는 Bash 명령 | Claude가 코드를 읽어서 파악할 수 있는 것 |
| 기본값과 다른 코드 스타일 규칙 | 표준 언어 규칙 |
| 테스트 지시사항 및 선호하는 테스트 러너 | 상세한 API 문서 (대신 문서 링크) |
| 저장소 에티켓 (브랜치 이름, PR 규칙) | 자주 변경되는 정보 |
| 개발 환경 특이성 (필수 환경 변수) | 자명한 관행 ("깨끗한 코드 작성") |
| 일반적인 함정 또는 명백하지 않은 동작 | 파일별 코드베이스 설명 |

CLAUDE.md가 너무 길면 Claude는 중요한 규칙이 노이즈에 손실되기 때문에 절반을 무시한다. 각 줄에 대해 "이것을 제거하면 Claude가 실수를 할까?"를 물어보고, 그렇지 않으면 삭제한다.

강조(예: "IMPORTANT", "YOU MUST")를 추가하면 준수율이 개선된다.

### 권한 구성하기

세 가지 방법:
- **Auto mode**: 분류기가 명령을 검토하고 위험해 보이는 것만 차단
- **권한 허용 목록**: 안전하다고 알고 있는 특정 도구 허용 (`npm run lint`, `git commit`)
- **샌드박싱**: OS 수준 격리로 파일 시스템 및 네트워크 액세스를 제한

### Skills 생성하기

`.claude/skills/`에 `SKILL.md`를 생성하여 도메인 지식과 재사용 가능한 워크플로우를 제공한다.

부작용이 있는 워크플로우는 `disable-model-invocation: true`를 사용하여 수동으로만 트리거:

```markdown
---
name: fix-issue
description: GitHub 이슈 수정
disable-model-invocation: true
---
GitHub 이슈를 분석하고 수정하세요: $ARGUMENTS.
1. `gh issue view`를 사용하여 이슈 세부 정보 가져오기
2. 관련 파일에 대한 코드베이스 검색
3. 수정 구현 → 테스트 작성 및 실행 → PR 생성
```

## 세션 관리하기

### 조기에 자주 방향 수정하기

- **`Esc`**: Claude 작업을 중간에 중지 (context 보존)
- **`Esc + Esc` / `/rewind`**: rewind 메뉴를 열어 이전 대화 및 코드 상태 복원
- **`/clear`**: 관련 없는 작업 간에 context 재설정

같은 문제에 대해 두 번 이상 수정했다면 context가 실패한 접근 방식으로 오염된 것이다. `/clear` 후 배운 내용을 통합한 더 구체적인 프롬프트로 새로 시작한다.

### context 적극적으로 관리하기

- `/clear`를 자주 사용하여 context window 재설정
- `/compact <instructions>`: 포커스 지정 압축 (예: `/compact Focus on the API changes`)
- `/btw`: 빠른 질문을 대화 기록 없이 (context를 증가시키지 않는 side question)

CLAUDE.md에 압축 동작 사용자화 가능:
```
"When compacting, always preserve the full list of modified files and any test commands"
```

### subagents를 사용하여 조사하기

```text
subagents를 사용하여 인증 시스템이 토큰 새로 고침을 어떻게 처리하는지,
그리고 재사용해야 할 기존 OAuth 유틸리티가 있는지 조사하세요.
```

subagent는 코드베이스를 탐색하고 요약을 보고 → 주요 대화를 깨끗하게 유지.

## 자동화 및 확장하기

### 비대화형 모드

```shell
# 일회성 쿼리
claude -p "이 프로젝트가 무엇을 하는지 설명하세요"

# 스크립트를 위한 구조화된 출력
claude -p "모든 API 엔드포인트 나열" --output-format json

# 실시간 처리를 위한 스트리밍
claude -p "이 로그 파일 분석" --output-format stream-json
```

### 여러 Claude 세션 병렬 실행

Writer/Reviewer 패턴:

| 세션 A (작성자) | 세션 B (검토자) |
| --- | --- |
| "API 엔드포인트에 대한 속도 제한기 구현" |  |
|  | "@src/middleware/rateLimiter.ts의 속도 제한기를 검토하세요. 엣지 케이스, 경쟁 조건을 찾으세요." |
| "검토 피드백: [세션 B 출력]. 이 문제들을 해결하세요." |  |

### 파일 전체에 fan out하기

```shell
claude -p "<your prompt>" --output-format json | your_command
```

각 파일에 대해 `claude -p`를 호출하는 루프로 대규모 마이그레이션·분석을 분배.

### auto mode로 자율적으로 실행하기

```shell
claude --permission-mode auto -p "fix all lint errors"
```

분류기 모델이 명령을 실행하기 전에 검토하여 범위 확대, 알 수 없는 인프라, 적대적 콘텐츠 기반 작업을 차단.

## 일반적인 실패 패턴

| 패턴 | 문제 | 해결 |
| --- | --- | --- |
| **주방 싱크 세션** | 관련 없는 작업을 섞어 context가 오염됨 | 관련 없는 작업 간에 `/clear` |
| **반복적으로 수정** | 실패한 접근 방식으로 context 오염 | 두 번의 실패 후 `/clear`, 더 나은 초기 프롬프트 작성 |
| **과도하게 지정된 CLAUDE.md** | 너무 길면 중요한 규칙이 노이즈에 손실됨 | 무자비하게 정리. 이미 올바르게 수행하면 삭제하거나 hook으로 변환 |
| **신뢰-검증 간격** | 그럴듯해 보이지만 엣지 케이스를 처리하지 않는 구현 | 항상 검증(테스트, 스크립트, 스크린샷) 제공. 검증할 수 없으면 배포하지 않음 |
| **무한 탐색** | 범위 없이 조사 → 수백 개 파일을 읽어 context를 채움 | 조사를 좁게 범위 지정하거나 subagents 사용 |

## 관련 항목

- [[wiki/ai/claude-code/claude-code-작동방식-에이전트하네스]]
- [[wiki/ai/claude-code/claude-code-확장기능-개요]]
- [[wiki/ai/claude-code/claude-code-컨텍스트윈도우]]
- [[wiki/ai/claude-code/claude-code-일반-워크플로우]]
- [[wiki/ai/claude-code/claude-code-메모리-CLAUDE-md]]
