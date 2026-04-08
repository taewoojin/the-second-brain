# 코딩 워크플로우

> **한눈에 보기**
> 버그 수정, 리팩토링, 테스트 작성 등 일상적인 코딩 작업에서 Claude Code를 활용하는 방법을 다룬다. Subagent에 작업을 위임하거나, 이미지(스크린샷, 다이어그램)를 활용해 더 정확한 컨텍스트를 전달할 수도 있다.

---

## 버그 수정

에러 메시지를 발견했을 때 원인을 찾고 수정하는 흐름이다.

**1단계: 에러 공유**

```
I'm seeing an error when I run npm test
```

**2단계: 수정 방안 요청**

```
suggest a few ways to fix the @ts-ignore in user.ts
```

**3단계: 수정 적용**

```
update user.ts to add the null check you suggested
```

> **팁**
> - 에러를 재현할 수 있는 명령어와 스택 트레이스를 함께 제공한다
> - 에러 재현 단계를 알려준다
> - 에러가 간헐적인지 일관적인지 알려주면 진단에 도움이 된다

---

## 리팩토링

레거시 코드를 최신 패턴으로 업데이트하는 흐름이다.

**1단계: 리팩토링 대상 식별**

```
find deprecated API usage in our codebase
```

**2단계: 리팩토링 방안 확인**

```
suggest how to refactor utils.js to use modern JavaScript features
```

**3단계: 변경 적용**

```
refactor utils.js to use ES2024 features while maintaining the same behavior
```

**4단계: 검증**

```
run tests for the refactored code
```

> **팁**
> - 최신 접근 방식의 이점을 설명해달라고 요청한다
> - 필요한 경우 하위 호환성 유지를 요청한다
> - 작고 테스트 가능한 단위로 리팩토링한다

---

## 테스트 작성과 실행

테스트가 없는 코드에 테스트를 추가하는 흐름이다. Claude는 프로젝트의 기존 테스트 파일을 분석해서 스타일, 프레임워크, assertion 패턴을 맞춘다.

**1단계: 테스트 미작성 코드 식별**

```
find functions in NotificationsService.swift that are not covered by tests
```

**2단계: 테스트 스캐폴딩 생성**

```
add tests for the notification service
```

**3단계: 엣지 케이스 추가**

```
add test cases for edge conditions in the notification service
```

**4단계: 실행 및 검증**

```
run the new tests and fix any failures
```

> **팁**: 포괄적인 커버리지를 위해 놓친 엣지 케이스를 찾아달라고 요청한다. Claude는 코드 경로를 분석해서 에러 조건, 경계값, 예상치 못한 입력에 대한 테스트를 제안할 수 있다.

---

## Subagent 활용

Subagent는 특정 작업을 전담하는 전문화된 AI 에이전트다. Claude Code는 적절한 작업을 자동으로 Subagent에 위임하거나, 사용자가 명시적으로 요청할 수 있다.

### 사용 가능한 Subagent 확인

```
/agents
```

### 자동 위임

Claude Code가 작업 성격에 맞는 Subagent에 자동으로 위임한다:

```
review my recent code changes for security issues
```

```
run all tests and fix any failures
```

### 명시적 요청

```
use the code-reviewer subagent to check the auth module
```

```
have the debugger subagent investigate why users can't log in
```

### 커스텀 Subagent 생성

`/agents`를 실행한 뒤 "Create New subagent"를 선택하면 다음을 정의할 수 있다:

- **식별자**: Subagent의 목적을 설명하는 고유 이름 (예: `code-reviewer`, `api-designer`)
- **트리거 조건**: 언제 이 Subagent를 사용할지
- **도구 접근 권한**: 어떤 도구를 사용할 수 있는지
- **시스템 프롬프트**: Subagent의 역할과 행동을 정의하는 지침

> **팁**
> - 팀 공유를 위해 `.claude/agents/`에 프로젝트 전용 Subagent를 만든다
> - `description` 필드를 구체적으로 작성하면 자동 위임이 잘 작동한다
> - 각 Subagent에 실제로 필요한 도구만 허용한다

---

## 이미지 활용

에러 스크린샷, UI 디자인, 다이어그램 등 이미지를 Claude에게 전달해서 더 정확한 컨텍스트를 제공할 수 있다.

### 이미지 추가 방법

1. Claude Code 창에 이미지를 **드래그 앤 드롭**
2. 이미지를 복사한 뒤 `Ctrl+V`로 붙여넣기 (macOS에서도 `Cmd+V`가 아닌 `Ctrl+V`)
3. 이미지 경로를 직접 제공: `Analyze this image: /path/to/image.png`

### 활용 예시

**이미지 분석**:

```
What does this image show?
```

```
Describe the UI elements in this screenshot
```

**에러 디버깅에 활용**:

```
Here's a screenshot of the error. What's causing it?
```

**디자인 구현에 활용**:

```
Generate CSS to match this design mockup
```

```
What HTML structure would recreate this component?
```

> **팁**
> - 텍스트 설명이 번거롭거나 불명확할 때 이미지를 사용한다
> - 한 대화에서 여러 이미지를 다룰 수 있다
> - 다이어그램, 스크린샷, 목업 등 다양한 형태의 이미지를 분석할 수 있다
> - Claude가 참조하는 이미지 링크(예: `[Image #1]`)를 `Cmd+Click` (Mac) / `Ctrl+Click` (Windows/Linux)하면 기본 뷰어로 열린다
