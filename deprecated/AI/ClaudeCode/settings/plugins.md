---
한눈에 보기:
- `enabledPlugins`로 플러그인을 활성/비활성화하고, `extraKnownMarketplaces`로 마켓플레이스를 추가한다
- `extraKnownMarketplaces`는 팀 편의를 위한 것, `strictKnownMarketplaces`는 조직 정책 강제용 (managed-only)
- 플러그인 관리는 `/plugin` 명령어로 인터랙티브하게 할 수 있다
---

# 플러그인 설정(Plugin Configuration)

Claude Code는 skill, agent, hook, MCP 서버를 번들한 플러그인을 마켓플레이스를 통해 설치할 수 있다.

## enabledPlugins

플러그인의 활성/비활성 상태를 제어한다.

**형식:** `"plugin-name@marketplace-name": true/false`

```json
{
  "enabledPlugins": {
    "formatter@acme-tools": true,
    "deployer@acme-tools": true,
    "experimental-features@personal": false
  }
}
```

**적용 가능한 scope:**

| Scope | 동작 |
|:--|:--|
| User | 개인 플러그인 설정 (모든 프로젝트에 적용) |
| Project | 팀 전체가 공유하는 플러그인 설정 |
| Local | 머신별 오버라이드 (git 커밋 안 됨) |
| Managed | 조직 정책으로 강제 적용. `false`로 설정 시 모든 scope에서 설치 차단 및 마켓플레이스에서 숨김 |

## extraKnownMarketplaces

저장소에 추가 마켓플레이스를 등록한다. 주로 팀 전체가 특정 플러그인 소스에 접근해야 할 때 project settings에 사용한다.

```json
{
  "extraKnownMarketplaces": {
    "acme-tools": {
      "source": {
        "source": "github",
        "repo": "acme-corp/claude-plugins"
      }
    }
  }
}
```

**동작 방식:** 저장소를 신뢰(trust)할 때 팀원에게 마켓플레이스 설치 여부를 묻는다. 원하지 않으면 건너뛸 수 있으며, 선택은 user settings에 저장된다.

### 마켓플레이스 source 타입

| 타입 | 필드 | 예시 |
|:--|:--|:--|
| `github` | `repo` (필수), `ref` (선택: branch/tag/SHA), `path` (선택: 서브디렉토리) | `{"source": "github", "repo": "acme-corp/plugins"}` |
| `git` | `url` (필수), `ref` (선택), `path` (선택) | `{"source": "git", "url": "https://gitlab.example.com/plugins.git"}` |
| `url` | `url` (필수), `headers` (선택: 인증 헤더) | `{"source": "url", "url": "https://plugins.example.com/marketplace.json"}` |
| `npm` | `package` (필수, scoped 패키지 지원) | `{"source": "npm", "package": "@acme-corp/claude-plugins"}` |
| `file` | `path` (필수: `marketplace.json` 절대 경로) | `{"source": "file", "path": "/usr/local/share/claude/marketplace.json"}` |
| `directory` | `path` (필수: `.claude-plugin/marketplace.json`을 포함하는 디렉토리) | `{"source": "directory", "path": "/opt/acme/plugins"}` |
| `settings` | `name`, `plugins` | 별도 호스팅 없이 settings.json에 플러그인 인라인 선언 |

> `url` 타입은 `marketplace.json`만 다운로드한다. 플러그인 파일은 외부 소스(GitHub, npm 등)에서 가져와야 한다. 상대 경로 플러그인은 `git` 타입을 사용할 것.

**`settings` 타입 예시 (인라인 마켓플레이스):**

```json
{
  "extraKnownMarketplaces": {
    "team-tools": {
      "source": {
        "source": "settings",
        "name": "team-tools",
        "plugins": [
          {
            "name": "code-formatter",
            "source": {
              "source": "github",
              "repo": "acme-corp/code-formatter"
            }
          }
        ]
      }
    }
  }
}
```

> `extraKnownMarketplaces`로 마켓플레이스를 추가해도 플러그인이 자동 활성화되지는 않는다. 각 플러그인은 `enabledPlugins`에서 별도로 활성화해야 한다.

## strictKnownMarketplaces (managed-only)

사용자가 **추가할 수 있는** 마켓플레이스를 제한한다. `managed-settings.json`에서만 설정 가능하며 user/project settings에서 덮어쓸 수 없다.

```json
{
  "strictKnownMarketplaces": [
    { "source": "github", "repo": "acme-corp/approved-plugins" },
    { "source": "url", "url": "https://plugins.example.com/marketplace.json" }
  ]
}
```

| 값 | 동작 |
|:--|:--|
| 미설정 (기본) | 사용자가 어떤 마켓플레이스든 추가 가능 |
| 빈 배열 `[]` | 새 마켓플레이스 추가 완전 차단 |
| 소스 목록 | 목록에 있는 마켓플레이스만 추가 가능 |

> 기존에 설치된 마켓플레이스는 영향을 받지 않는다. 제한은 새로 추가하는 경우에만 적용된다.

### extraKnownMarketplaces vs strictKnownMarketplaces

| 항목 | `extraKnownMarketplaces` | `strictKnownMarketplaces` |
|:--|:--|:--|
| 목적 | 팀 편의 (마켓플레이스 자동 등록 제안) | 조직 정책 (추가 가능한 마켓플레이스 제한) |
| 설정 가능 scope | 모든 scope | managed-settings.json만 |
| 동작 | 신뢰 시 설치 여부 물어봄 | 목록 외 마켓플레이스 추가 차단 |
| 오버라이드 | 상위 scope에서 덮어쓸 수 있음 | 불가 (최고 우선순위) |
| 기존 설치 영향 | 없음 | 없음 |

**함께 사용하는 경우:** 팀원에게 마켓플레이스를 자동 제안하면서 동시에 다른 마켓플레이스는 차단하려면 `managed-settings.json`에 둘 다 설정한다:

```json
{
  "strictKnownMarketplaces": [
    { "source": "github", "repo": "acme-corp/plugins" }
  ],
  "extraKnownMarketplaces": {
    "acme-tools": {
      "source": { "source": "github", "repo": "acme-corp/plugins" }
    }
  }
}
```
