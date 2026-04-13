# Personal Knowledge Wiki — Design Spec

**날짜**: 2026-04-13  
**참고**: [Karpathy LLM Wiki](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f)

## 목적

"미래의 내가, 과거의 나에게 질문했을 때 즉시 답을 찾을 수 있는 장소"

`raw/`의 원본 자료를 바탕으로 LLM이 개체 중심 위키를 구축·유지한다. 사용자는 자료 수집과 질의에 집중하고, LLM은 모든 정리·교차참조·일관성 유지를 담당한다.

---

## 디렉토리 구조

```
the-second-brain/
├── raw/              ← Source of Truth (불변, 읽기 전용)
│   └── (아티클, 논문, 스크랩, 이미지 등 원본 자료)
│
├── wiki/             ← LLM이 관리하는 개체 중심 위키
│   ├── articles/     ← 아티클/포스팅 정리
│   ├── projects/     ← 오픈 소스 프로젝트 분석
│   ├── ai/           ← AI 관련 지식 (Claude, LLM, 프롬프트 등)
│   ├── concepts/     ← 아티클/프로젝트에서 추출한 핵심 개념
│   ├── index.md      ← 전체 페이지 목록 (항상 최신 상태 유지)
│   └── log.md        ← append-only 작업 로그 (수정 금지, 추가만)
│
├── notes/            ← 개인 메모/인사이트 (자유 형식, LLM 관리 대상 아님)
├── CLAUDE.md         ← 위키 스키마, 규칙, 워크플로우 명시
├── deprecated/       ← 기존 폴더 이동 (AI/, Insight/, Study/ 등)
└── the-sanctum/      ← 그대로 유지 (프라이빗 서브모듈)
```

---

## 위키 페이지 형식

### 필수 필드 (모든 페이지 공통)

```markdown
# 제목

**출처**: [링크 또는 파일명] | **날짜**: YYYY-MM-DD

## 요약
(2-3문장으로 핵심 압축)

## 관련 항목
- [[wiki-link]]
```

이 3가지(출처/날짜, 요약, 교차참조)만 강제하며, 나머지 섹션은 LLM이 자료 특성에 맞게 자유롭게 구성한다.

### 폴더별 예시

**`articles/karpathy-llm-wiki.md`**
```markdown
# Karpathy LLM Wiki

**출처**: https://gist.github.com/karpathy/... | **날짜**: 2026-04-13

## 요약
LLM이 원본 문서를 매번 재검색하는 대신, 지속적으로 유지되는 마크다운 위키를 점진적으로 구축한다. raw → wiki → schema의 3계층 구조로 지식을 컴파일한다.

## 관련 항목
- [[concepts/rag]]
- [[concepts/markdown-knowledge-base]]
```

**`concepts/quantization.md`**
```markdown
# Quantization

**출처**: [[projects/llama-cpp]], [[articles/gguf-format]] | **날짜**: 2026-04-13

## 요약
모델 가중치를 낮은 비트(4-bit, 8-bit)로 표현해 메모리와 연산량을 줄이는 기법. 추론 속도와 품질 사이의 트레이드오프가 핵심이다.

## 관련 항목
- [[projects/llama-cpp]]
- [[articles/gguf-format]]
```

---

## 특수 파일

### `wiki/index.md`

전체 위키 네비게이션. LLM이 페이지 추가/삭제 시 항상 갱신한다.

```markdown
# Wiki Index
_마지막 업데이트: 2026-04-13_

## Articles (N)
- [[articles/karpathy-llm-wiki]] — LLM 기반 위키 구축 패턴

## Projects (N)
- [[projects/llama-cpp]] — C++ LLM 추론 엔진 분석

## AI (N)
- [[ai/claude-code-hooks]] — Claude Code 훅 시스템

## Concepts (N)
- [[concepts/quantization]] — 모델 경량화 기법
```

### `wiki/log.md`

append-only 작업 로그. 절대 수정하지 않고 추가만 한다.

```markdown
## [YYYY-MM-DD] ingest | 페이지명
## [YYYY-MM-DD] query  | 질의 내용 요약
## [YYYY-MM-DD] lint   | 발견된 이슈 요약
```

---

## 워크플로우 및 스킬

세 스킬 모두 `context: fork`로 실행되어 메인 컨텍스트를 보호한다.

### `/obsidian-ingest`

`raw/`에 새 자료를 추가한 후 실행한다.

```
1. log.md와 비교하여 처리되지 않은 raw/ 자료 감지
2. 자료를 읽고 적절한 wiki/ 폴더에 페이지 생성 또는 업데이트
3. 관련 concepts/ 페이지 교차참조 추가/업데이트
4. index.md 갱신
5. log.md에 작업 기록
```

### `/obsidian-query`

질문과 함께 실행한다. 예: `/obsidian-query quantization이 뭐야?`

```
1. index.md 스캔으로 관련 페이지 식별
2. 관련 wiki 페이지들 읽기
3. [[wiki-link]] 교차참조를 따라 연관 개념 페이지도 참조
4. 종합 답변 생성 (위키 페이지 인용 포함)
5. log.md에 질의 기록
```

### `/obsidian-lint`

주기적으로 또는 수동으로 실행한다.

```
1. index.md vs 실제 파일 목록 비교 → 고아 페이지/누락 항목 탐지
2. [[wiki-link]] 깨진 링크 탐지
3. 필수 필드(출처/날짜/요약/교차참조) 누락 페이지 탐지
4. 같은 개념이 다르게 설명된 모순 플래깅
5. 리포트 출력 + log.md 기록
```

---

## CLAUDE.md 내용 (요약)

`CLAUDE.md`는 위키 운영의 스키마 문서로, 다음을 명시한다:

- 각 디렉토리의 역할과 규칙
- 위키 페이지 필수 필드
- `raw/`는 절대 수정 금지, `log.md`는 추가 전용
- `the-sanctum/`은 건드리지 않음
- 워크플로우별 스킬 명시 (`/obsidian-ingest`, `/obsidian-query`, `/obsidian-lint`)

---

## 구현 범위

이 스펙에서 구현할 항목:

1. **디렉토리 구조 생성** — `wiki/`, `notes/`, `deprecated/` 폴더 및 하위 구조
2. **특수 파일 초기화** — `wiki/index.md`, `wiki/log.md` 초기 템플릿
3. **CLAUDE.md 작성** — 위키 스키마 문서
4. **스킬 파일 작성** — `/obsidian-ingest`, `/obsidian-query`, `/obsidian-lint`
5. **기존 폴더 이동** — `AI/`, `Insight/`, `Study/` → `deprecated/`
