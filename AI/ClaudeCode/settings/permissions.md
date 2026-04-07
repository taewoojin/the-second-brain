---
한눈에 보기:
- 규칙 평가 순서: deny → ask → allow, 첫 번째 매칭 규칙이 적용된다
- 규칙 형식: `Tool` (전체 매칭) 또는 `Tool(specifier)` (패턴 매칭)
- defaultMode로 Claude Code 시작 시 기본 권한 모드를 설정할 수 있다
---

# 권한 설정(Permissions)

## 권한 설정 필드

`settings.json`의 `permissions` 객체 내에 설정한다.

| 키                                   | 설명                                                                                      | 예시                                       |
| :---------------------------------- | :-------------------------------------------------------------------------------------- | :--------------------------------------- |
| `allow`                             | 자동으로 허용할 툴 사용 규칙 배열                                                                     | `["Bash(git *)", "Read(~/.zshrc)"]`      |
| `ask`                               | 사용 전 확인을 요청할 규칙 배열                                                                      | `["Bash(git push *)"]`                   |
| `deny`                              | 항상 거부할 규칙 배열. 민감 파일 보호에 활용                                                              | `["Read(./.env)", "Read(./secrets/**)"]` |
| `additionalDirectories`             | 파일 접근을 허용할 추가 작업 디렉토리. 설정은 해당 디렉토리에서 로드되지 않음                                            | `["../docs/"]`                           |
| `defaultMode`                       | Claude Code 시작 시 기본 권한 모드. [모드 설명](#권한-모드) 참고                                           | `"acceptEdits"`                          |
| `disableBypassPermissionsMode`      | `"disable"` 설정 시 bypassPermissions 모드 진입 불가. `--dangerously-skip-permissions` 플래그도 비활성화 | `"disable"`                              |
| `skipDangerousModePermissionPrompt` | bypass permissions 모드 진입 전 확인 프롬프트 생략. project settings에서는 무시됨                          | `true`                                   |

### 설정 예시

```json
{
  "permissions": {
    "allow": [
      "Bash(npm run lint)",
      "Bash(npm run test *)",
      "Bash(git *)",
      "Read(~/.zshrc)"
    ],
    "deny": [
      "Read(./.env)",
      "Read(./.env.*)",
      "Read(./secrets/**)"
    ],
    "defaultMode": "acceptEdits"
  }
}
```

## 권한 모드(Permission Mode)

`defaultMode`에서 사용 가능한 값:

| 모드 | 설명 |
|:--|:--|
| `default` | 기본값. 대부분의 작업에서 확인 요청 |
| `acceptEdits` | 파일 편집 자동 수락. bash 실행은 여전히 확인 요청 |
| `plan` | plan 모드로 시작. 코드 작성 전 계획을 먼저 작성 |
| `auto` | 자동 모드. 안전하다고 판단되는 작업은 확인 없이 진행 |
| `bypassPermissions` | 모든 권한 확인 건너뜀. **신뢰할 수 있는 자동화 환경에서만 사용** |

> `--permission-mode` CLI 플래그를 사용하면 단일 세션에 한해 `defaultMode` 설정을 오버라이드할 수 있다.

## 규칙 문법(Rule Syntax)

### 기본 형식

```
Tool                  # 해당 툴의 모든 사용 매칭
Tool(specifier)       # specifier 패턴과 매칭되는 경우만
```

### 평가 순서

규칙은 항상 이 순서로 평가되며, **첫 번째 매칭 규칙이 적용**된다:

```
deny → ask → allow
```

### 툴별 규칙 예시

**Bash:**
```json
"Bash"                    // 모든 bash 명령어
"Bash(npm run *)"         // npm run으로 시작하는 명령어
"Bash(git *)"             // git으로 시작하는 모든 명령어
"Bash(git push *)"        // git push로 시작하는 명령어
```

**Read / Edit:**
```json
"Read(./.env)"            // 프로젝트 루트의 .env 파일
"Read(./.env.*)"          // .env.local, .env.production 등
"Read(./secrets/**)"      // secrets 디렉토리 전체
"Read(~/.zshrc)"          // 홈 디렉토리의 .zshrc
"Edit(./src/**)"          // src 디렉토리 내 파일 편집
```

**WebFetch:**
```json
"WebFetch"                // 모든 웹 요청
"WebFetch(domain:example.com)"  // example.com으로의 요청만
```

**MCP:**
```json
"mcp__server-name__tool-name"   // 특정 MCP 서버의 특정 툴
"mcp__github__*"                // github MCP 서버의 모든 툴
```

### 와일드카드 동작

`*`는 단일 경로 세그먼트, `**`는 여러 경로 세그먼트와 매칭된다:

```
./src/*.ts       → src 바로 아래의 .ts 파일
./src/**/*.ts    → src 하위 모든 디렉토리의 .ts 파일
```

> **주의**: Bash 규칙의 패턴 매칭은 명령어 문자열 전체를 대상으로 하지 않는다. `Bash(rm *)` 규칙은 `rm -rf /`를 차단하지 못할 수 있다. 민감한 작업은 `deny`에 명시적으로 추가할 것.
