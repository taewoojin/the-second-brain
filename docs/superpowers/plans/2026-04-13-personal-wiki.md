# Personal Knowledge Wiki Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Karpathy LLM Wiki 방식을 기반으로 `the-second-brain`에 개체 중심 개인 지식 위키를 구축한다.

**Architecture:** `raw/`(원본, 불변) → `wiki/`(LLM 관리 개체 위키) → `CLAUDE.md`(스키마) 3계층 구조. `/obsidian-ingest`, `/obsidian-query`, `/obsidian-lint` 세 스킬이 `context: fork`로 워크플로우를 담당한다.

**Tech Stack:** Markdown, Claude Code Skills (context: fork), Obsidian wiki-link 형식(`[[page]]`)

---

## 파일 맵

| 경로 | 역할 | 작업 |
|------|------|------|
| `wiki/articles/.gitkeep` | articles 폴더 유지 | 생성 |
| `wiki/projects/.gitkeep` | projects 폴더 유지 | 생성 |
| `wiki/ai/.gitkeep` | ai 폴더 유지 | 생성 |
| `wiki/concepts/.gitkeep` | concepts 폴더 유지 | 생성 |
| `wiki/index.md` | 전체 위키 네비게이션 (항상 최신) | 생성 |
| `wiki/log.md` | append-only 작업 로그 | 생성 |
| `notes/.gitkeep` | 개인 메모 폴더 유지 | 생성 |
| `deprecated/.gitkeep` | 기존 폴더 이동 대상 | 생성 |
| `CLAUDE.md` | 위키 스키마, 규칙, 워크플로우 | 수정 |
| `.claude/skills/obsidian-ingest/SKILL.md` | Ingest 스킬 | 생성 |
| `.claude/skills/obsidian-query/SKILL.md` | Query 스킬 | 생성 |
| `.claude/skills/obsidian-lint/SKILL.md` | Lint 스킬 | 생성 |
| `deprecated/AI/` | 기존 AI/ 이동 | git mv |
| `deprecated/Insight/` | 기존 Insight/ 이동 | git mv |
| `deprecated/Study/` | 기존 Study/ 이동 | git mv |

---

### Task 1: wiki 디렉토리 구조 생성

**Files:**
- Create: `wiki/articles/.gitkeep`
- Create: `wiki/projects/.gitkeep`
- Create: `wiki/ai/.gitkeep`
- Create: `wiki/concepts/.gitkeep`
- Create: `notes/.gitkeep`
- Create: `deprecated/.gitkeep`

- [ ] **Step 1: 디렉토리 및 .gitkeep 파일 생성**

```bash
mkdir -p wiki/articles wiki/projects wiki/ai wiki/concepts notes deprecated
touch wiki/articles/.gitkeep wiki/projects/.gitkeep wiki/ai/.gitkeep wiki/concepts/.gitkeep
touch notes/.gitkeep deprecated/.gitkeep
```

- [ ] **Step 2: 생성 확인**

```bash
find wiki notes deprecated -name ".gitkeep"
```

Expected output:
```
wiki/articles/.gitkeep
wiki/projects/.gitkeep
wiki/ai/.gitkeep
wiki/concepts/.gitkeep
notes/.gitkeep
deprecated/.gitkeep
```

- [ ] **Step 3: Commit**

```bash
git add wiki/ notes/ deprecated/
git commit -m "chore: wiki 디렉토리 구조 생성"
```

---

### Task 2: wiki 특수 파일 초기화

**Files:**
- Create: `wiki/index.md`
- Create: `wiki/log.md`

- [ ] **Step 1: wiki/index.md 생성**

`wiki/index.md` 내용:

```markdown
# Wiki Index
_마지막 업데이트: 2026-04-13_

## Articles (0)

## Projects (0)

## AI (0)

## Concepts (0)
```

- [ ] **Step 2: wiki/log.md 생성**

`wiki/log.md` 내용:

```markdown
# Wiki Log
<!-- append-only: 수정 금지, 추가만 -->

## [2026-04-13] init | 위키 초기화
```

- [ ] **Step 3: 파일 확인**

```bash
cat wiki/index.md && echo "---" && cat wiki/log.md
```

Expected: 위에서 작성한 두 파일 내용이 출력됨.

- [ ] **Step 4: Commit**

```bash
git add wiki/index.md wiki/log.md
git commit -m "chore: wiki 특수 파일 초기화 (index.md, log.md)"
```

---

### Task 3: CLAUDE.md 작성

**Files:**
- Modify: `CLAUDE.md`

- [ ] **Step 1: CLAUDE.md 전체 내용 작성**

`CLAUDE.md` 내용:

```markdown
# The Second Brain

> 미래의 내가, 과거의 나에게 질문했을 때 즉시 답을 찾을 수 있는 장소.

`raw/`의 원본 자료를 바탕으로 LLM이 `wiki/`를 구축하고 유지한다.

---

## 디렉토리 구조

| 경로 | 역할 | 규칙 |
|------|------|------|
| `raw/` | Source of Truth. 원본 자료 | **절대 수정 금지.** 읽기 전용. |
| `wiki/` | LLM이 관리하는 개체 중심 위키 | 아래 규칙 참조 |
| `wiki/articles/` | 아티클/포스팅 정리 | 1파일 = 1아티클 |
| `wiki/projects/` | 오픈 소스 프로젝트 분석 | 1파일 = 1프로젝트 |
| `wiki/ai/` | AI 관련 지식 (Claude, LLM 등) | articles와 중복 시 ai/ 우선 |
| `wiki/concepts/` | 아티클/프로젝트에서 추출한 핵심 개념 | 여러 페이지에서 교차참조되는 개념 |
| `wiki/index.md` | 전체 페이지 목록 | 페이지 추가/삭제 시 항상 갱신 |
| `wiki/log.md` | append-only 작업 로그 | **수정 금지.** 추가만. |
| `notes/` | 개인 메모/인사이트 | 자유 형식. LLM 관리 대상 아님. |
| `deprecated/` | 구 폴더 보관 | 건드리지 않음 |
| `the-sanctum/` | 프라이빗 서브모듈 | **절대 건드리지 않음.** |

---

## 위키 페이지 규칙

### 핵심 원칙
- **1 파일 = 1 개체/개념**. 여러 주제를 하나의 파일에 섞지 않는다.
- 모든 페이지는 `[[wiki-link]]` 형식으로 연관 페이지를 교차참조한다.
- `raw/`의 원본 자료를 참조할 때 파일명 또는 경로를 명시한다.

### 필수 필드 (모든 페이지 공통)

```markdown
# 제목

**출처**: [URL 또는 raw/ 경로] | **날짜**: YYYY-MM-DD

## 요약
(2-3문장으로 핵심 압축. 이 페이지를 처음 보는 사람이 30초 안에 핵심을 파악할 수 있어야 한다.)

## 관련 항목
- [[wiki/concepts/관련개념]]
- [[wiki/articles/관련아티클]]
```

### 나머지 섹션
필수 3개 필드 이외의 섹션은 해당 자료의 특성에 맞게 자유롭게 구성한다.
예: 아티클이면 "주요 논점", 프로젝트면 "아키텍처", 개념이면 "등장 맥락" 등.

### index.md 갱신 규칙
페이지를 추가하거나 삭제할 때마다 `wiki/index.md`를 갱신한다.
형식: `- [[wiki/폴더/파일명]] — 한 줄 설명`
카테고리별로 정렬, 페이지 수를 헤더에 표시.

### log.md 기록 규칙
스킬 실행 결과를 log.md에 기록한다. **파일 수정 금지, 추가만.**
```
## [YYYY-MM-DD] ingest | 파일명
## [YYYY-MM-DD] query  | 질의 요약
## [YYYY-MM-DD] lint   | 이슈 요약
```

---

## 워크플로우

### 수집: `/obsidian-ingest`
`raw/`에 새 자료를 추가한 후 실행한다.
LLM이 자료를 읽고 적절한 `wiki/` 페이지를 생성하거나 업데이트한다.

### 질의: `/obsidian-query`
질문과 함께 실행한다. 예: `/obsidian-query quantization이 뭐야?`
LLM이 `wiki/`를 참조하여 종합 답변을 생성한다.

### 정리: `/obsidian-lint`
위키 일관성을 검사하고 리포트를 출력한다.
깨진 링크, 누락 필드, 고아 페이지 등을 탐지한다.
```

- [ ] **Step 2: 파일 저장 확인**

```bash
head -5 CLAUDE.md
```

Expected: `# The Second Brain` 으로 시작하는 내용 출력.

- [ ] **Step 3: Commit**

```bash
git add CLAUDE.md
git commit -m "docs: CLAUDE.md 위키 스키마 작성"
```

---

### Task 4: /obsidian-ingest 스킬 작성

**Files:**
- Create: `.claude/skills/obsidian-ingest/SKILL.md`

- [ ] **Step 1: 스킬 디렉토리 생성**

```bash
mkdir -p .claude/skills/obsidian-ingest
```

- [ ] **Step 2: SKILL.md 작성**

`.claude/skills/obsidian-ingest/SKILL.md` 내용:

```markdown
---
name: obsidian-ingest
description: raw/에 추가된 자료를 wiki/에 수집·정리하는 스킬. 새 자료마다 실행.
context: fork
---

# obsidian-ingest

`raw/`에 새로 추가된 자료를 읽고 `wiki/`에 개체 페이지를 생성하거나 업데이트한다.

## 실행 절차

### 1. 처리 대상 자료 식별

`wiki/log.md`를 읽어 이미 `ingest` 처리된 파일명 목록을 파악한다.
`raw/` 디렉토리를 재귀적으로 스캔하여 log.md에 없는 파일을 처리 대상으로 선정한다.

처리 대상이 없으면 다음 메시지를 출력하고 종료:
```
처리할 새 자료가 없습니다. raw/에 파일을 추가한 후 다시 실행하세요.
```

### 2. 각 자료 처리

처리 대상 파일별로 순서대로 실행:

#### 2-1. 자료 읽기
파일 전체를 읽는다. 이미지나 PDF처럼 직접 읽기 어려운 경우, 파일명과 위치로 맥락을 추론한다.

#### 2-2. wiki/ 폴더 결정
자료 내용을 기반으로 폴더를 결정한다:
- 블로그 포스트, 뉴스레터, 기사, 논문 요약 → `wiki/articles/`
- GitHub 저장소, 오픈소스 라이브러리, 프레임워크 분석 → `wiki/projects/`
- AI/ML/LLM/Claude/프롬프트 관련 → `wiki/ai/` (articles와 중복 시 ai/ 우선)
- 여러 자료에 걸쳐 반복 등장하는 핵심 개념 → `wiki/concepts/`

#### 2-3. 파일명 결정
영문 소문자, 하이픈 구분. 예: `karpathy-llm-wiki.md`, `llama-cpp.md`

#### 2-4. 위키 페이지 작성
기존 파일이 있으면 내용을 읽고 업데이트. 없으면 새로 생성.

필수 필드를 반드시 포함:
```markdown
# 제목

**출처**: [URL 또는 raw/경로] | **날짜**: YYYY-MM-DD

## 요약
(2-3문장)

## 관련 항목
- [[wiki/concepts/관련개념]]
```

필수 필드 이후 내용은 자료 특성에 맞게 자유롭게 구성한다.

#### 2-5. concepts/ 교차참조
자료에서 핵심 개념을 추출한다. `wiki/concepts/`에 해당 개념 페이지가 있으면 "관련 항목"에 링크를 추가한다. 없고 중요한 개념이라면 개념 페이지를 새로 생성한다.

### 3. wiki/index.md 갱신

처리한 페이지를 해당 카테고리 섹션에 추가:
```markdown
- [[wiki/articles/karpathy-llm-wiki]] — LLM 기반 위키 구축 패턴
```
헤더의 페이지 수도 갱신한다.

### 4. wiki/log.md에 기록 (append only)

처리한 파일마다 추가:
```markdown
## [YYYY-MM-DD] ingest | 파일명
```
log.md의 기존 내용은 절대 수정하지 않는다.

### 5. 완료 리포트 출력

```
[obsidian-ingest] 완료
처리한 자료: N개
생성된 페이지: 파일명1, 파일명2, ...
업데이트된 페이지: 파일명3, ...
생성된 개념 페이지: 개념명1, ...
```
```

- [ ] **Step 3: 파일 확인**

```bash
head -5 .claude/skills/obsidian-ingest/SKILL.md
```

Expected: `---`로 시작하는 frontmatter 출력.

- [ ] **Step 4: Commit**

```bash
git add .claude/skills/obsidian-ingest/
git commit -m "feat: /obsidian-ingest 스킬 추가"
```

---

### Task 5: /obsidian-query 스킬 작성

**Files:**
- Create: `.claude/skills/obsidian-query/SKILL.md`

- [ ] **Step 1: 스킬 디렉토리 생성**

```bash
mkdir -p .claude/skills/obsidian-query
```

- [ ] **Step 2: SKILL.md 작성**

`.claude/skills/obsidian-query/SKILL.md` 내용:

```markdown
---
name: obsidian-query
description: 위키를 참조하여 질문에 답변하는 스킬. 예: /obsidian-query quantization이란?
context: fork
argument-hint: "<질문 내용>"
---

# obsidian-query

`wiki/`를 참조하여 사용자의 질문에 종합적으로 답변한다.

## 실행 절차

### 1. 질문 파악

인자로 받은 질문을 분석하여 핵심 키워드와 주제를 추출한다.
인자가 없으면 다음을 출력하고 종료:
```
질문을 입력하세요. 예: /obsidian-query quantization이란?
```

### 2. 관련 페이지 탐색

`wiki/index.md`를 읽어 전체 페이지 목록을 파악한다.
키워드와 관련된 페이지를 최대 10개 선별한다:
- 파일명에 키워드 포함
- 카테고리가 질문 주제와 일치

### 3. 페이지 읽기 및 교차참조 추적

선별한 페이지들을 읽는다.
각 페이지의 "관련 항목" 섹션에서 `[[wiki-link]]`를 추출하여 연관 페이지도 추가로 읽는다. (최대 2단계 깊이)

### 4. 답변 생성

읽은 페이지들을 종합하여 답변을 작성한다.

답변 형식:
```markdown
## [질문 내용]에 대한 답변

[종합 답변]

### 참조한 위키 페이지
- [[wiki/concepts/관련개념]] — 관련 이유
- [[wiki/articles/관련아티클]] — 관련 이유
```

답변은 위키에 있는 내용만 기반으로 한다. 위키에 없는 내용은 "위키에 관련 내용이 없습니다"라고 명시한다.

### 5. wiki/log.md에 기록 (append only)

```markdown
## [YYYY-MM-DD] query | 질문 요약 (30자 이내)
```
```

- [ ] **Step 3: 파일 확인**

```bash
head -5 .claude/skills/obsidian-query/SKILL.md
```

Expected: `---`로 시작하는 frontmatter 출력.

- [ ] **Step 4: Commit**

```bash
git add .claude/skills/obsidian-query/
git commit -m "feat: /obsidian-query 스킬 추가"
```

---

### Task 6: /obsidian-lint 스킬 작성

**Files:**
- Create: `.claude/skills/obsidian-lint/SKILL.md`

- [ ] **Step 1: 스킬 디렉토리 생성**

```bash
mkdir -p .claude/skills/obsidian-lint
```

- [ ] **Step 2: SKILL.md 작성**

`.claude/skills/obsidian-lint/SKILL.md` 내용:

```markdown
---
name: obsidian-lint
description: 위키 일관성 검사. 깨진 링크, 누락 필드, 고아 페이지, 내용 모순을 탐지하고 리포트 출력.
context: fork
---

# obsidian-lint

`wiki/`의 일관성을 검사하고 이슈 리포트를 출력한다.

## 실행 절차

### 1. 실제 파일 목록 수집

```bash
find wiki -name "*.md" ! -name "index.md" ! -name "log.md"
```

로 실제 위키 페이지 파일 목록을 수집한다.

### 2. index.md 정합성 검사

`wiki/index.md`를 읽어 링크 목록을 파싱한다.
실제 파일 목록과 비교:
- **고아 파일**: 실제 파일은 있는데 index.md에 없는 것
- **유령 링크**: index.md에 있는데 실제 파일이 없는 것

### 3. 깨진 wiki-link 검사

모든 위키 페이지를 읽어 `[[wiki/경로]]` 패턴을 추출한다.
각 링크가 실제 파일로 이어지는지 확인한다.
이어지지 않는 링크 목록을 수집한다.

### 4. 필수 필드 누락 검사

모든 위키 페이지에서 다음 3가지 필수 필드 존재 여부를 확인:
- `**출처**:` 패턴 (첫 번째 헤더 이후 5줄 이내)
- `## 요약` 섹션
- `## 관련 항목` 섹션

누락된 페이지와 누락된 필드를 기록한다.

### 5. 리포트 출력

```markdown
## [obsidian-lint] 리포트 — YYYY-MM-DD

### 고아 파일 (index.md 미등록)
- wiki/articles/some-article.md

### 유령 링크 (파일 없음)
- index.md → [[wiki/concepts/missing-concept]]

### 깨진 wiki-link
- wiki/articles/karpathy-llm-wiki.md → [[wiki/concepts/rag]] (파일 없음)

### 필수 필드 누락
- wiki/projects/some-project.md: 요약 없음, 관련 항목 없음

---
총 이슈: N개
이슈 없음: ✓ (이슈가 0개인 경우)
```

### 6. wiki/log.md에 기록 (append only)

```markdown
## [YYYY-MM-DD] lint | 총 N개 이슈 (고아:N, 유령:N, 깨진링크:N, 누락필드:N)
```

이슈가 0개면:
```markdown
## [YYYY-MM-DD] lint | 이슈 없음 ✓
```
```

- [ ] **Step 3: 파일 확인**

```bash
head -5 .claude/skills/obsidian-lint/SKILL.md
```

Expected: `---`로 시작하는 frontmatter 출력.

- [ ] **Step 4: Commit**

```bash
git add .claude/skills/obsidian-lint/
git commit -m "feat: /obsidian-lint 스킬 추가"
```

---

### Task 7: 기존 폴더 deprecated/로 이동

**Files:**
- git mv: `AI/` → `deprecated/AI/`
- git mv: `Insight/` → `deprecated/Insight/`
- git mv: `Study/` → `deprecated/Study/`

> **주의**: `the-sanctum/`은 프라이빗 서브모듈이므로 절대 건드리지 않는다.
> `raw/`도 이동 대상이 아니다.

- [ ] **Step 1: 이동 대상 폴더 확인**

```bash
ls -la
```

`AI/`, `Insight/`, `Study/` 폴더가 있는지 확인한다.
없는 폴더는 건너뛴다.

- [ ] **Step 2: git mv로 이동**

```bash
git mv AI deprecated/AI
git mv Insight deprecated/Insight
git mv Study deprecated/Study
```

존재하지 않는 폴더에 대해 오류가 나면 해당 폴더만 건너뛴다.

- [ ] **Step 3: 이동 확인**

```bash
ls deprecated/
```

Expected: `AI  Insight  Study` (존재했던 폴더들)

- [ ] **Step 4: Commit**

```bash
git add -A
git commit -m "chore: 기존 폴더 deprecated/로 이동 (AI, Insight, Study)"
```

---

## 구현 완료 기준

- [ ] `wiki/articles/`, `wiki/projects/`, `wiki/ai/`, `wiki/concepts/` 폴더 존재
- [ ] `wiki/index.md` — 카테고리별 섹션, 페이지 수 표시
- [ ] `wiki/log.md` — init 항목 포함, append-only
- [ ] `CLAUDE.md` — 디렉토리 구조, 위키 규칙, 워크플로우 명시
- [ ] `.claude/skills/obsidian-ingest/SKILL.md` — `context: fork` 포함
- [ ] `.claude/skills/obsidian-query/SKILL.md` — `context: fork` 포함, `argument-hint` 포함
- [ ] `.claude/skills/obsidian-lint/SKILL.md` — `context: fork` 포함
- [ ] `deprecated/` — 기존 폴더들 이동 완료
- [ ] `the-sanctum/` — 변경 없음
