---
name: obsidian-lint
description: 위키 일관성 검사. 깨진 링크, 누락 필드, 고아 페이지, 내용 모순을 탐지하고 리포트 출력.
context: fork
disable-model-invocation: true
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
