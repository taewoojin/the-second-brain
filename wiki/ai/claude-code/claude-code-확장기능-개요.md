# Claude Code 확장하기: CLAUDE.md, Skills, MCP, Subagents, Hooks, Plugins

**출처**: `raw/claude code 확장하기.md`
**날짜**: 2026-04-20
**keywords**: CLAUDE.md, skills, subagents, agent teams, MCP, hooks, plugins, 컨텍스트 비용

## 요약

Claude Code의 7가지 확장 계층(CLAUDE.md·Skills·MCP·Subagents·Agent Teams·Hooks·Plugins)은 에이전트 루프의 다른 부분에 연결되며 목적에 따라 조합하여 사용한다. 각 확장은 고유한 컨텍스트 비용과 로딩 전략을 가지므로 이를 이해하고 적절히 선택하는 것이 효율적인 설정의 핵심이다.

## 확장 계층 비교

| 기능 | 수행 작업 | 사용 시기 | 예시 |
| --- | --- | --- | --- |
| **CLAUDE.md** | 모든 대화에서 로드되는 지속적인 컨텍스트 | 프로젝트 규칙, "항상 X를 수행" 규칙 | "npm이 아닌 pnpm을 사용하세요" |
| **Skill** | 재사용 가능한 지침, 지식, 워크플로우 | 반복 가능한 작업, 참조 문서 | `/deploy` 배포 체크리스트, API 문서 skill |
| **Subagent** | 격리된 컨텍스트에서 실행, 요약 반환 | 컨텍스트 격리, 병렬 작업, 특화된 워커 | 많은 파일 읽기 후 주요 결과만 반환 |
| **Agent teams** | 여러 독립 Claude Code 세션 조정 | 병렬 연구, 경쟁하는 가설 디버깅 | 보안·성능·테스트를 동시에 확인 |
| **MCP** | 외부 서비스에 연결 | 외부 데이터 또는 작업 | 데이터베이스 쿼리, Slack 게시, 브라우저 제어 |
| **Hook** | 이벤트에서 실행되는 결정론적 스크립트 | 예측 가능한 자동화 (LLM 없음) | 모든 파일 편집 후 ESLint 실행 |

**Plugins**는 패키징 계층: skill·hook·subagent·MCP 서버를 단일 설치 가능한 단위로 번들. Plugin skill은 `/my-plugin:review` 형태로 네임스페이스됨.

## 유사한 기능 구분

### Skill vs Subagent

| 측면 | Skill | Subagent |
| --- | --- | --- |
| **정의** | 재사용 가능한 지침·지식·워크플로우 | 자신의 컨텍스트를 가진 격리된 워커 |
| **주요 이점** | 컨텍스트 간 콘텐츠 공유 | 컨텍스트 격리. 작업은 별도로 실행되고 요약만 반환 |
| **최적 용도** | 참조 자료, 호출 가능한 워크플로우 | 많은 파일을 읽는 작업, 병렬 작업, 특화된 워커 |

- Skill은 **참조** 또는 **작업** 타입일 수 있다. 참조 skill은 지식을 제공하고, 작업 skill은 특정 워크플로우를 실행한다.
- **컨텍스트 격리가 필요하거나 컨텍스트 윈도우가 가득 찰 때** subagent를 사용한다.
- 결합 가능: Subagent는 특정 skill을 미리 로드(`skills:` 필드), Skill은 `context: fork`로 격리 실행 가능.

### CLAUDE.md vs Skill

- **CLAUDE.md**: 항상 켜진 컨텍스트 (모든 세션에 자동 로드)
- **Skill**: 온디맨드 로드 (호출 시 또는 Claude가 관련 있다고 판단 시)

CLAUDE.md는 "항상 X 규칙"에, Skill은 전체 API 스타일 가이드처럼 필요할 때만 로드하는 참조 자료에 적합.

### Subagent vs Agent team

- **Subagent**: 오케스트레이터가 생성·관리하는 격리된 워커
- **Agent team**: 여러 독립적인 Claude Code 세션을 조율, 공유 작업 및 peer-to-peer 메시징

## 기능 계층화 규칙

동일한 기능이 여러 수준에 존재할 때:

- **CLAUDE.md 파일**: 추가적(additive). 모든 수준이 동시에 컨텍스트에 기여
- **Skill과 Subagent**: 이름으로 재정의. 우선순위: 관리 > 사용자 > 프로젝트
- **MCP 서버**: 이름으로 재정의. 우선순위: 로컬 > 프로젝트 > 사용자
- **Hooks**: 병합(merge). 모든 등록된 hook이 일치하는 이벤트에서 실행

## 컨텍스트 비용

추가하는 모든 기능은 Claude의 컨텍스트를 소비한다. 과도하면 컨텍스트 윈도우를 채울 수 있고 Claude를 덜 효과적으로 만들 수 있다.

| 기능 | 로드 시기 | 로드되는 내용 | 컨텍스트 비용 |
| --- | --- | --- | --- |
| **CLAUDE.md** | 세션 시작 | 전체 콘텐츠 | 모든 요청 |
| **Skill** | 세션 시작 + 사용 시 | 시작 시 설명, 사용 시 전체 콘텐츠 | 낮음 (설명만) |
| **MCP 서버** | 세션 시작 | 모든 도구 정의 및 스키마 | 모든 요청 |
| **Subagent** | 생성 시 | 신선한 컨텍스트 | 주 세션에서 격리됨 |
| **Hooks** | 트리거 시 | 없음 (외부 실행) | 0 |

**컨텍스트 비용 최적화**:
- Skill frontmatter에 `disable-model-invocation: true` → 수동 호출 전까지 컨텍스트 비용 0
- CLAUDE.md는 200줄 이하 유지, 참조 자료는 skill로 이동
- MCP tool search로 도구 정의 지연 로드 (`/mcp`로 서버별 비용 확인)

## 기능 결합 패턴

| 패턴 | 작동 방식 | 예시 |
| --- | --- | --- |
| **Skill + MCP** | MCP는 연결 제공, skill은 사용법 교육 | MCP는 DB 연결, skill은 스키마·쿼리 패턴 문서화 |
| **Skill + Subagent** | Skill이 병렬 작업을 위해 subagent 생성 | `/audit` skill이 보안·성능·스타일 subagent 병렬 실행 |
| **CLAUDE.md + Skill** | CLAUDE.md는 항상 켜진 규칙, skill은 온디맨드 참조 | CLAUDE.md: "API 규칙을 따르세요", skill: 전체 API 가이드 |
| **Hook + MCP** | Hook이 MCP를 통해 외부 작업 트리거 | 중요 파일 수정 시 Slack 알림 전송 |

## 관련 항목

- [[wiki/ai/claude-code/claude-code-작동방식-에이전트하네스]]
- [[wiki/ai/claude-code/claude-code-메모리-CLAUDE-md]]
- [[wiki/ai/claude-code/claude-code-hooks-자동화가이드]]
