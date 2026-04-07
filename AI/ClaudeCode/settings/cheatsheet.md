---
한눈에 보기:
  - 개인/팀에서 자주 사용하는 settings.json 필드 빠른 참조
---

# 설정 치트 시트(Settings Cheat Sheet)

## 권한 제어

| 키                                   | 한 줄 설명           | 예시                                       |
| :---------------------------------- | :--------------- | :--------------------------------------- |
| `permissions.allow`                 | 자동 허용할 툴/명령어 패턴  | `["Bash(npm run *)", "Bash(git *)"]`     |
| `permissions.deny`                  | 항상 차단 (민감 파일 보호) | `["Read(./.env)", "Read(./secrets/**)"]` |
| `permissions.ask`                   | 실행 전 확인 요청       | `["Bash(git push *)"]`                   |
| `permissions.defaultMode`           | 기본 권한 모드         | `"acceptEdits"`                          |
| `permissions.additionalDirectories` | 파일 접근 허용 추가 디렉토리 | `["../docs/"]`                           |

## 모델/성능

| 키                       | 한 줄 설명                                 | 예시                    |
| :---------------------- | :------------------------------------- | :-------------------- |
| `agent`                 | 메인 스레드를 named subagent로 실행            | `"code-reviewer"`     |
| `model`                 | 기본 모델 지정                               | `"claude-sonnet-4-6"` |
| `effortLevel`           | 사고 깊이. `"low"` / `"medium"` / `"high"` | `"medium"`            |
| `alwaysThinkingEnabled` | Extended Thinking 항상 켜기                | `true`                |

## 언어/UI

| 키                      | 한 줄 설명                            | 예시                                                          |
| :--------------------- | :-------------------------------- | :---------------------------------------------------------- |
| `language`             | 응답 언어 설정                          | `"korean"`                                                  |
| `outputStyle`          | 시스템 프롬프트 스타일                      | `"Explanatory"`                                             |
| `statusLine`           | 커스텀 status line 스크립트              | `{"type": "command", "command": "~/.claude/statusline.sh"}` |
| `autoUpdatesChannel`   | 업데이트 채널. `"stable"` 또는 `"latest"` | `"stable"`                                                  |
| `companyAnnouncements` | 시작 시 표시할 공지. 여러 개면 랜덤 순환           | `["가이드라인: docs.acme.com"]`                                  |


## Git

| 키                        | 한 줄 설명                      | 예시      |
| :----------------------- | :-------------------------- | :------ |
| `attribution.commit`     | 커밋 메시지 하단 서명 문구. 빈 문자열이면 제거 | `""`    |
| `attribution.pr`         | PR 본문 하단 서명 문구. 빈 문자열이면 제거  | `""`    |

## 환경/개발

| 키                   | 한 줄 설명                | 예시                                                   |
| :------------------ | :-------------------- | :--------------------------------------------------- |
| `env`                  | 매 세션 환경변수 주입                               | `{"ANTHROPIC_MODEL": "claude-opus-4-6"}`             |
| `hooks`                | 라이프사이클 훅 설정                               | [hooks 문서](https://code.claude.com/docs/en/hooks) 참고 |
| `allowedHttpHookUrls`  | HTTP hook이 요청 가능한 URL 패턴 허용 목록           | `["https://hooks.example.com/*"]`                    |
| `autoMemoryDirectory`  | auto memory 저장 디렉토리 커스텀 (project settings 불가) | `"~/my-memory-dir"`                                  |
| `plansDirectory`       | plan 파일 저장 경로                               | `"./plans"`                                          |
| `cleanupPeriodDays`    | 비활성 세션 보관 기간 (기본 30일)                    | `20`                                                 |

## MCP 서버

| 키                            | 한 줄 설명                       | 예시                     |
| :--------------------------- | :--------------------------- | :--------------------- |
| `enableAllProjectMcpServers` | `.mcp.json`의 모든 MCP 서버 자동 승인 | `true`                 |
| `enabledMcpjsonServers`      | 특정 MCP 서버만 승인                | `["memory", "github"]` |
| `disabledMcpjsonServers`     | 특정 MCP 서버 거부                 | `["filesystem"]`       |

## 플러그인

| 키                        | 한 줄 설명                                | 예시                                                          |
| :----------------------- | :------------------------------------ | :---------------------------------------------------------- |
| `enabledPlugins`         | 플러그인 활성/비활성 (`plugin@marketplace` 형식) | `{"formatter@acme-tools": true}`                            |
| `extraKnownMarketplaces` | 팀 마켓플레이스 등록                           | `{"acme": {"source": {"source": "github", "repo": "..."}}}` |

## Worktree

| 키 | 한 줄 설명 | 예시 |
|:--|:--|:--|
| `worktree.symlinkDirectories` | worktree에 심볼릭 링크로 연결할 디렉토리 | `["node_modules", ".cache"]` |
| `worktree.sparsePaths` | sparse-checkout으로 체크아웃할 디렉토리 | `["packages/my-app"]` |

## ~/.claude.json 필드

> `settings.json`이 아닌 별도 파일에 저장됨. `/config`로 수정하거나 직접 편집.

| 키 | 한 줄 설명 | 예시 |
|:--|:--|:--|
| `editorMode` | 입력창 키 바인딩. `"normal"` 또는 `"vim"` | `"vim"` |
| `showTurnDuration` | 응답 소요 시간 표시 | `false` |
| `autoConnectIde` | 외부 터미널에서 IDE 자동 연결 | `true` |

---

## 자주 쓰는 설정 스니펫

```json
{
  "permissions": {
    "allow": [
      "Bash(find *)",
      "Bash(ls *)",
      "Bash(cat *)",
      "Bash(head *)",
      "Bash(grep *)",
      "Bash(mkdir *)",
      "Bash(git status)",
      "Bash(git status *)",
      "Bash(git log *)",
      "Bash(git diff *)",
      "Bash(xcodebuild *)",
      "Bash(xcrun *)",
      "Bash(gh auth status)",
      "Bash(gh pr view *)",
      "Bash(gh issue view *)",
      "Read",
      "Glob",
      "Grep",
      "WebFetch"
    ],
    "ask": [
      "Bash(git commit *)",
      "Bash(git push *)",
      "Bash(gh pr create *)",
      "Bash(gh issue create *)"
    ],
    "deny": [
      "Bash(rm -rf *)",
      "Bash(rm -r *)",
      "Bash(git push --force *)",
      "Bash(git reset --hard *)",
      "Bash(git clean -f *)",
      "Bash(git commit --amend *)"
    ]
  },
  "attribution": { "commit": "", "pr": "" }
}
```

