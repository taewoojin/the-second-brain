# 코드베이스 탐색과 이해

> **한눈에 보기**
> 새 프로젝트에 투입됐을 때 Claude Code로 구조를 빠르게 파악하는 방법을 다룬다. 넓은 질문에서 좁은 질문으로 좁혀가는 것이 핵심이며, Plan Mode와 Extended Thinking을 활용하면 더 깊은 분석이 가능하다.

---

## 프로젝트 전체 구조 파악하기

새 프로젝트에 합류했을 때 가장 먼저 할 일은 전체 구조를 파악하는 것이다.

**1단계: 프로젝트 루트에서 Claude Code 실행**

```bash
cd /path/to/project
claude
```

**2단계: 넓은 질문으로 시작**

```
give me an overview of this codebase
```

**3단계: 관심 영역으로 좁혀가기**

```
explain the main architecture patterns used here
```

```
what are the key data models?
```

```
how is authentication handled?
```

> **팁**
> - 넓은 질문 → 좁은 질문 순서로 진행한다
> - 프로젝트에서 사용하는 코딩 컨벤션과 패턴을 물어본다
> - 프로젝트 고유 용어의 용어집(glossary)을 요청하면 이후 소통이 쉬워진다

---

## 특정 기능 관련 코드 찾기

특정 기능이 어떻게 구현되어 있는지 찾아야 할 때 사용한다.

**1단계: 관련 파일 찾기**

```
find the files that handle user authentication
```

**2단계: 컴포넌트 간 관계 파악**

```
how do these authentication files work together?
```

**3단계: 실행 흐름 추적**

```
trace the login process from front-end to database
```

> **팁**
> - 찾고자 하는 것을 구체적으로 설명한다
> - 프로젝트에서 쓰는 도메인 용어를 그대로 사용한다
> - 코드 인텔리전스 플러그인을 설치하면 "정의로 이동", "참조 찾기" 같은 정밀한 탐색이 가능하다

---

## Plan Mode로 안전하게 분석하기

Plan Mode는 Claude가 코드를 **읽기만 하고 수정하지 않는** 모드다. 코드베이스를 탐색하거나, 복잡한 변경을 계획하거나, 코드를 안전하게 리뷰할 때 적합하다. Plan Mode에서 Claude는 `AskUserQuestion` 도구를 사용해 요구사항을 수집하고 목표를 명확히 한 뒤 계획을 제안한다.

### 언제 쓰는가

- **다단계 구현**: 여러 파일을 수정해야 하는 기능 개발
- **코드 탐색**: 변경 전에 코드베이스를 충분히 조사하고 싶을 때
- **대화형 개발**: Claude와 방향을 반복적으로 조율하고 싶을 때

### 사용 방법

**세션 중 전환**: `Shift+Tab`을 눌러 권한 모드를 순환한다.
- Normal Mode → Auto-Accept Mode(`⏵⏵ accept edits on`) → Plan Mode(`⏸ plan mode on`)

**새 세션을 Plan Mode로 시작**:

```bash
claude --permission-mode plan
```

**헤드리스 모드에서 Plan Mode 사용** (스크립트 등에서 결과만 받을 때):

```bash
claude --permission-mode plan -p "Analyze the authentication system and suggest improvements"
```

### 예시: 복잡한 리팩토링 계획

```bash
claude --permission-mode plan
```

```
I need to refactor our authentication system to use OAuth2. Create a detailed migration plan.
```

Claude가 현재 구현을 분석하고 종합적인 계획을 생성한다. 후속 질문으로 다듬을 수 있다:

```
What about backward compatibility?
```

```
How should we handle database migration?
```

> **팁**
> - `Ctrl+G`를 누르면 기본 텍스트 에디터에서 계획을 직접 편집할 수 있다
> - 계획을 수락하면 Claude가 계획 내용을 기반으로 세션 이름을 자동 지정한다
> - `--name`이나 `/rename`으로 이미 이름을 지정했다면 덮어쓰지 않는다

### 기본값으로 설정

```json
// .claude/settings.json
{
  "permissions": {
    "defaultMode": "plan"
  }
}
```

---

## 파일과 디렉토리 참조 (`@`)

`@`를 사용하면 Claude가 직접 파일을 읽을 때까지 기다리지 않고 즉시 내용을 포함시킬 수 있다.

**파일 참조**:

```
Explain the logic in @src/utils/auth.js
```

파일 전체 내용이 대화에 포함된다.

**디렉토리 참조**:

```
What's the structure of @src/components?
```

디렉토리의 파일 목록이 표시된다 (파일 내용은 포함되지 않음).

**MCP 리소스 참조**:

```
Show me the data from @github:repos/owner/repo/issues
```

연결된 MCP 서버에서 데이터를 가져온다. `@서버명:리소스` 형식을 사용한다.

> **팁**
> - 파일 경로는 상대 경로, 절대 경로 모두 사용 가능
> - `@` 파일 참조 시 해당 파일의 디렉토리와 상위 디렉토리에 있는 `CLAUDE.md`도 함께 컨텍스트에 포함된다
> - 한 메시지에서 여러 파일을 참조할 수 있다 (예: `@file1.js and @file2.js`)

---

## Extended Thinking 활용

Extended Thinking은 기본적으로 활성화되어 있으며, Claude가 응답하기 전에 복잡한 문제를 단계별로 추론할 수 있는 공간을 제공한다. `Ctrl+O`로 verbose 모드를 켜면 추론 과정을 볼 수 있다.

Opus 4.6과 Sonnet 4.6은 **적응형 추론(adaptive reasoning)**을 지원한다. 고정된 thinking 토큰 예산 대신, effort level 설정에 따라 모델이 동적으로 thinking을 할당한다.

### 언제 유용한가

- 복잡한 아키텍처 결정
- 어려운 버그 디버깅
- 다단계 구현 계획
- 여러 접근 방식 간의 트레이드오프 평가

### 설정 방법

| 설정 | 방법 | 설명 |
|------|------|------|
| Effort level | `/effort`, `/model`에서 조정, 또는 `CLAUDE_CODE_EFFORT_LEVEL` 환경변수 | Opus 4.6, Sonnet 4.6에서 thinking 깊이 조절 |
| `ultrathink` 키워드 | 프롬프트에 "ultrathink" 포함 | 해당 턴에서만 effort를 high로 설정 |
| 토글 단축키 | `Option+T` (macOS) / `Alt+T` (Windows/Linux) | 현재 세션에서 thinking on/off 전환 |
| 글로벌 기본값 | `/config`에서 thinking mode 토글 | 모든 프로젝트에 적용. `~/.claude/settings.json`의 `alwaysThinkingEnabled`에 저장 |
| 토큰 예산 제한 | `MAX_THINKING_TOKENS` 환경변수 | thinking 예산을 특정 토큰 수로 제한 |

> **주의**: "think", "think hard" 같은 문구는 일반 프롬프트 지시로 해석되며 thinking 토큰을 할당하지 않는다. thinking 토큰을 실제로 활성화하려면 위 설정을 사용해야 한다.

> **비용**: thinking 토큰은 요약된 형태로 표시되더라도 모두 과금된다.
