---
name: til
description: 클로드와 함께한 하루 작업을 TIL로 정리하여 옵시디언에 저장하고 git에 푸시하는 스킬. /til로 수동 호출하며, --loop 옵션으로 자동 반복 예약 가능.
argument-hint: "<날짜> | --loop [HH:MM]"
---

# til

클로드와 함께한 하루 작업을 TIL(Today I Learned)로 정리하여 옵시디언(the-second-brain)에 저장하고 git에 푸시한다.

## 인자

- `/til` — 오늘 날짜로 TIL 작성
- `/til <날짜>` — 지정한 날짜로 TIL 작성
  - 예: `/til 2026-03-08`, `/til 2026.03.08`, `/til 03-08`
- `/til --loop` — 매일 23:59에 자동 실행 예약
- `/til --loop HH:MM` — 지정 시각에 매일 자동 실행 예약
  - 예: `/til --loop 22:00`

## 워크플로우

### 1. 인자 확인

#### `--loop` 옵션 처리

`--loop` 옵션이 있으면:
- `--loop`만 있는 경우: `CronCreate` 도구로 매일 23:57에 `/til` 예약 (cron: `"57 23 * * *"`)
- `--loop HH:MM`인 경우: 지정 시각에서 2분 전으로 cron 예약
- 예약 후 안내 메시지 출력:
  - "매일 HH:MM에 TIL 자동 작성이 예약되었습니다. (세션 내 동작, 최대 3일 유지)"
- **주의**: `CronCreate`는 세션 내에서만 동작하며 3일 후 자동 만료됨을 사용자에게 안내
- 예약 완료 후 종료 (TIL 작성은 하지 않음)

#### 날짜 파싱

`--loop` 옵션이 없으면 날짜 인자를 확인한다:

- 날짜 인자가 있으면 다양한 형식을 허용하여 파싱:
  - `YYYY-MM-DD` (예: `2026-03-08`)
  - `YYYY.MM.DD` (예: `2026.03.08`)
  - `YYYY/MM/DD` (예: `2026/03/08`)
  - `MM-DD` 또는 `MM.DD` (예: `03-08` → 현재 연도 자동 적용)
- 모든 형식은 내부적으로 `YYYY-MM-DD`로 정규화하여 사용
- 날짜 인자가 없으면 현재 시스템 날짜 사용
- 정규화된 날짜에 따라 파일 경로(`TIL/YYYY/MM/DD.md`)와 프론트매터의 `date` 필드 결정

아래 단계를 순서대로 실행한다.

### 2. 해당 날짜 Claude 세션 수집·분석

해당 날짜의 **모든 프로젝트에서의 Claude Code 세션**을 수집하여 종합 분석한다.

#### 단계 2-1: 해당 날짜 세션 파일 찾기

```bash
find ~/.claude/projects -name "*.jsonl" -maxdepth 2 | \
  xargs stat -f "%Sm %N" -t "%Y-%m-%d" | grep "TARGET_DATE"
```

- `TARGET_DATE`는 단계 1에서 결정된 날짜 (예: `2026-03-10`)
- 해당 날짜에 수정된 JSONL 파일들을 모든 프로젝트에서 수집
- 프로젝트 경로에서 프로젝트명 추출 (예: `-Users-theo-Dev-Kmong-Kmong-iOS` → `Kmong_iOS`)
  - 경로의 마지막 디렉토리 세그먼트에서 `-Users-theo-Dev-` 접두사를 제거하고 `-`를 `_`로 변환

#### 단계 2-2: 각 세션에서 핵심 정보 추출 (python3 스크립트)

JSONL 파일이 클 수 있으므로 **python3 스크립트**로 한 번에 파싱하여 요약만 추출한다. 전체 내용을 컨텍스트에 넣지 않는다.

Bash 도구로 python3 인라인 스크립트를 실행하여 각 JSONL 파일에서 다음을 추출:

- **사용자 메시지**: `type: "user"` + `content[].type == "text"` → 어떤 질문/지시를 했는지 (각 메시지 앞 200자만)
- **클로드 텍스트 응답**: `type: "assistant"` + `content[].type == "text"` → 핵심 설명/답변 (각 메시지 앞 200자만)
- **사용한 도구 통계**: `content[].type == "tool_use"` → 도구별 사용 횟수 (Read, Edit, Bash, Agent 등)
- **스킬 호출**: `tool_use.name == "Skill"` → `input.skill` 값 수집 (예: `til`, `loop`)
- **서브에이전트**: `tool_use.name == "Agent"` → `input.subagent_type` + `input.description` 수집
- **슬래시 커맨드**: user 메시지 텍스트에서 `<command-name>` 태그 파싱
- **훅 실행**: `type: "progress"` + `data.type == "hook_progress"` → `hookName`과 `command` 수집.
  - 각 고유한 (hookName, command) 쌍을 한 번씩만 기록 (중복 제거)
  - command가 `callback`이면 생략, 긴 스크립트는 핵심 동작만 요약 (예: "SwiftLint --fix")
- **거부/에러 횟수**: `tool_result`에서 `is_error == true` 카운트

스크립트 출력 형식 (프로젝트별로 그룹핑):

```
=== 프로젝트: Kmong_iOS (세션 2개) ===
[사용자 메시지 요약]
- "빌드 에러 수정해줘..."
- "API 연동 코드 작성..."

[도구 사용] Read:15, Edit:8, Bash:5, Agent:2
[스킬 호출] loop, til
[서브에이전트] Explore(1), Plan(1)
[훅] SessionStart → bd prime, PostToolUse:Edit → SwiftLint --fix, Stop → ralph stop-hook
[에러/거부] 2회
```

#### 단계 2-3: 현재 세션 대화도 함께 분석

현재 대화 컨텍스트도 분석하여 위 결과에 포함한다:
- 어떤 코드를 작성/수정했는지
- 어떤 문제를 해결했는지
- 새로 배운 개념이나 패턴

### 3. TIL 작성

`references/til-template.md` 템플릿에 맞춰 마크다운을 생성한다:

- **작업 요약**: 프로젝트별로 그룹핑하여 클로드와 한 작업 설명 (사용자 메시지 기반)
- **배운 점**: 클로드 활용에서 새로 알게 된 것, 효과적이었던 프롬프팅 패턴, 시행착오와 교훈
- **사용 통계**: 총 세션 수, 도구별 사용 횟수, 스킬/서브에이전트 목록, 실행된 훅 목록, 에러 횟수
- **스킬/에이전트 아이디어**: subagent나 skill로 만들면 좋을 것들 (없으면 생략 가능)

### 4. 파일 저장

- 저장 경로: `/Users/theo/Dev/the-second-brain/TIL/YYYY/MM/DD.md`
  - 예: `TIL/2026/03/11.md`
- 날짜 인자가 지정된 경우 해당 날짜로 경로 결정
  - 예: `/til 2026-03-08` → `TIL/2026/03/08.md`
- 디렉토리가 없으면 자동 생성 (`mkdir -p`)
- 이미 파일이 있으면 기존 내용을 읽고 새 내용을 병합/추가

### 5. Git 커밋 & 푸시

```bash
cd /Users/theo/Dev/the-second-brain
git add "TIL/YYYY/MM/DD.md"
git commit -m "TIL: YYYY-MM-DD 학습 기록 추가"
git push
```

## 주의사항

- 날짜 인자가 없으면 현재 시스템 날짜를 사용한다
- 한글로 작성한다
- 옵시디언 호환 마크다운을 사용한다
- 태그는 YAML 프론트매터에 배열로 작성한다
