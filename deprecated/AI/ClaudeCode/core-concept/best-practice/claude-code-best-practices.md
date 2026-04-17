# Claude Code Best Practices

**출처**: [모범 사례](https://code.claude.com/docs/ko/best-practices) · [일반적인 워크플로우](https://code.claude.com/docs/ko/common-workflows) | **날짜**: 2026-04-17

## 요약

Claude Code는 파일 읽기·명령 실행·변경 수행을 자율적으로 처리하는 에이전트 코딩 환경이다. 모든 모범 사례는 단 하나의 제약에서 출발한다: **context window가 채워질수록 성능이 저하된다.** 검증 수단 제공, 탐색→계획→코드 순서, 세션 관리가 이 제약을 다루는 핵심 전략이다.

---

## 핵심 제약: Context Window

Claude의 context window는 모든 메시지·읽은 파일·명령 출력을 포함한 전체 대화를 보유한다. 단일 디버깅 세션만으로도 수만 토큰을 소비할 수 있으며, context가 가득 찰수록 이전 지시사항을 "잊거나" 실수가 늘어난다.

context window는 관리해야 할 가장 중요한 리소스다.

---

## 검증 수단 제공

Claude가 자신의 작업을 확인할 수 있도록 **테스트, 스크린샷, 예상 출력**을 함께 제공하는 것이 가장 영향력 높은 단일 행동이다. 명확한 성공 기준이 없으면 "올바르게 보이지만 실제로는 작동하지 않는" 결과가 나올 수 있다.

| 전략 | Before | After |
|------|--------|-------|
| 검증 기준 제공 | "이메일 검증 함수 구현" | "validateEmail 작성. 테스트 케이스: user@example.com → true, invalid → false. 구현 후 테스트 실행" |
| UI 시각 검증 | "대시보드를 더 좋게 보이게 하세요" | "[스크린샷] 이 디자인 구현. 결과 스크린샷 찍고 원본과 비교 후 차이점 수정" |
| 근본 원인 해결 | "빌드가 실패합니다" | "빌드가 이 오류로 실패: [오류]. 수정 후 빌드 성공 확인. 오류를 억제하지 말고 근본 원인 해결" |

---

## 워크플로우: 탐색 → 계획 → 코드

Claude를 바로 코딩으로 보내면 잘못된 문제를 해결하는 코드가 나올 수 있다. Plan Mode로 탐색과 실행을 분리한다.

**Plan Mode 진입 방법**
- 세션 중: `Shift+Tab` (Normal → Auto-Accept → Plan Mode 순서)
- 새 세션: `claude --permission-mode plan`
- 헤드리스: `claude --permission-mode plan -p "분석 프롬프트"`
- 기본값 설정: `.claude/settings.json`에 `"defaultMode": "plan"`

**Plan Mode를 skip해도 되는 경우**: 오타 수정, 로그 줄 추가, 변수 이름 바꾸기 등 범위가 명확한 작업. diff를 한 문장으로 설명할 수 있으면 skip.

**Plan Mode가 유용한 경우**: 여러 파일을 수정하는 변경, 익숙하지 않은 코드, 접근 방식이 불확실할 때.

---

## 프롬프트 작성법

| 전략 | Before | After |
|------|--------|-------|
| 작업 범위 지정 | "foo.py에 테스트 추가" | "로그아웃 엣지 케이스를 다루는 foo.py 테스트 작성. mock 사용 금지" |
| 소스 지적 | "왜 이 API가 이상한가?" | "ExecutionFactory의 git 히스토리를 보고 API가 어떻게 변했는지 요약" |
| 기존 패턴 참조 | "캘린더 위젯 추가" | "HotDogWidget.php 패턴을 따라 캘린더 위젯 구현. 코드베이스에 없는 라이브러리 사용 금지" |
| 증상 설명 | "로그인 버그 수정" | "세션 만료 후 로그인 실패 보고. src/auth/ 토큰 갱신 확인. 실패 테스트 작성 후 수정" |

**풍부한 컨텍스트 제공 방법**
- `@파일명`으로 파일 직접 참조
- 이미지 복사/붙여넣기 또는 드래그 앤 드롭
- `cat error.log | claude`로 데이터 파이프
- URL 제공 (자주 쓰는 도메인은 `/permissions`로 허용 목록 추가)

---

## 환경 구성

### CLAUDE.md

모든 대화 시작 시 자동으로 읽히는 파일. 간결하게 유지하고 각 줄마다 "이게 없으면 Claude가 실수를 할까?" 자문하라.

| ✅ 포함 | ❌ 제외 |
|---------|---------|
| Claude가 추측할 수 없는 Bash 명령 | 코드를 읽으면 알 수 있는 것 |
| 기본값과 다른 코드 스타일 규칙 | Claude가 이미 아는 표준 언어 규칙 |
| 테스트 러너 및 지시사항 | 상세한 API 문서 (링크로 대체) |
| 저장소 에티켓 (브랜치 이름, PR 규칙) | 자주 변경되는 정보 |
| 프로젝트 특정 아키텍처 결정 | 자명한 관행 ("깨끗한 코드 작성" 등) |

> 부풀려진 CLAUDE.md는 Claude가 중요한 규칙을 노이즈에 묻어버리게 만든다.

### Hooks

결정론적 자동화. CLAUDE.md의 "권고적 지시사항"과 달리 hooks는 반드시 실행된다. 예: "모든 파일 편집 후 eslint 실행", "migrations 폴더 쓰기 차단".

### Skills

`.claude/skills/`에 SKILL.md 파일로 도메인 지식 주입. 관련 있을 때 자동 적용되거나 `/skill-name`으로 직접 호출.

### Subagents

`.claude/agents/`에 정의. 별도 context window에서 실행되어 **주요 대화의 context를 보호**한다. 많은 파일을 읽어야 하는 조사 작업에 특히 유용.

---

## 세션 관리

### Context 적극 관리

- `Esc`: 작업 중단 (context 보존)
- `/clear`: context 완전 재설정. 관련 없는 작업 간 자주 실행
- `Esc+Esc` 또는 `/rewind`: 이전 대화·코드 상태 복원 메뉴
- `/compact <지시사항>`: 수동 압축 (예: `/compact Focus on API changes`)
- `/btw`: 사이드 질문 — **답변이 대화 기록에 포함되지 않아** context를 증가시키지 않음

> 같은 문제에 두 번 이상 수정을 시도했다면, context가 실패한 접근 방식으로 오염된 것이다. `/clear` 후 더 나은 프롬프트로 새로 시작하는 게 항상 더 낫다.

### 세션 재개

```bash
claude --continue    # 가장 최근 대화 재개
claude --resume      # 최근 대화 목록에서 선택
```

세션 선택기 단축키: `↑↓` 이동, `P` 미리보기, `R` 이름 바꾸기, `/` 검색, `B` 현재 브랜치 필터.

`/rename`으로 세션에 설명적인 이름을 붙여두면 나중에 찾기 쉽다.

---

## 병렬화 & 자동화

### Git Worktree 병렬 세션

각 Claude 세션이 코드베이스의 독립 복사본을 가져 변경 충돌을 방지한다.

```bash
claude --worktree feature-auth    # .claude/worktrees/feature-auth/ 생성
claude --worktree bugfix-123      # 별도 세션
claude --worktree                 # 이름 자동 생성
```

`.worktreeinclude` 파일로 gitignored 파일(`.env` 등)을 worktree에 자동 복사할 수 있다.

**정리**: 변경사항 없으면 자동 삭제. 변경사항 있으면 유지 여부 물음.

### 비대화형 모드

```bash
claude -p "프롬프트"                          # 일회성 쿼리
claude -p "엔드포인트 목록" --output-format json
claude -p "로그 분석" --output-format stream-json
cat error.log | claude -p "근본 원인 설명"
claude --permission-mode auto -p "lint 오류 전부 수정"
```

CI, pre-commit hooks, 자동화 워크플로우에 통합하는 방법이다.

### Writer/Reviewer 패턴

세션 A가 구현하고, 세션 B가 새로운 context에서 검토. 동일 코드를 작성한 Claude는 편향이 생기지만, 새 context의 Claude는 편향 없이 엣지 케이스를 찾는다.

---

## Thinking Mode 구성

확장된 사고는 기본 활성화. Claude가 복잡한 문제를 단계별로 추론할 공간을 제공한다.

| 범위 | 방법 | 설명 |
|------|------|------|
| 노력 수준 | `/effort` 또는 `CLAUDE_CODE_EFFORT_LEVEL` | Opus 4.6 · Sonnet 4.6의 사고 깊이 조정 |
| 일회성 깊은 추론 | 프롬프트에 `ultrathink` 포함 | 해당 턴만 노력 수준을 높음으로 설정 |
| 세션 토글 | `Option+T` (macOS) / `Alt+T` (Windows) | 현재 세션 켜기/끄기 |
| 전역 기본값 | `/config`에서 thinking mode 토글 | `~/.claude/settings.json`에 저장 |
| 예산 제한 | `MAX_THINKING_TOKENS` 환경 변수 | 특정 토큰 수로 제한 |

**모델별 차이**: Opus 4.6 · Sonnet 4.6은 적응형 추론(노력 수준에 따라 동적 할당). 다른 모델은 최대 31,999 토큰 고정 예산.

`Ctrl+O`로 자세한 모드 전환 시 회색 이탤릭으로 내부 추론 확인 가능.

---

## 실패 패턴 5가지

| 패턴 | 증상 | 수정 |
|------|------|------|
| **주방 싱크 세션** | 한 작업 중 관련 없는 것을 물어보다 돌아옴 | 관련 없는 작업 간 `/clear` |
| **반복적 수정** | 수정 → 여전히 잘못됨 → 재수정 | 두 번 실패 후 `/clear`, 더 나은 초기 프롬프트 작성 |
| **과도한 CLAUDE.md** | Claude가 규칙 절반을 무시 | 무자비하게 정리. 이미 올바르게 하면 삭제 또는 hook으로 변환 |
| **신뢰-검증 간격** | 그럴듯하지만 엣지 케이스 미처리 | 항상 검증(테스트/스크린샷) 제공. 검증 불가면 배포 금지 |
| **무한 탐색** | Claude가 수백 개 파일 읽으며 context 소진 | 조사 범위를 좁게 지정하거나 subagents에 위임 |

---

## 관련 항목

- [[wiki/context-window-management]]
