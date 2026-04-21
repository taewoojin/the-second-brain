# Claude Code 권한 모드 (Permission Modes)

**출처**: https://code.claude.com/docs/en/permission-modes | **날짜**: 2026-04-13

## 요약
권한 모드는 Claude Code가 파일 편집, 셸 명령, 네트워크 요청 시 승인 요청 빈도를 제어한다. 총 6가지 모드가 있으며, 감독 수준과 자율성 사이에서 필요에 따라 선택한다.

## 권한 모드 비교

| 모드 | 승인 없이 실행되는 것 | 최적 사용 상황 |
| --- | --- | --- |
| `default` | 읽기만 | 처음 시작, 민감한 작업 |
| `acceptEdits` | 읽기, 파일 편집, 기본 파일시스템 명령 | 코드 편집 후 직접 리뷰 |
| `plan` | 읽기만 (편집 없음) | 변경 전 코드베이스 탐색 |
| `auto` | 분류기 검사 후 모든 것 | 긴 태스크, 프롬프트 피로 감소 |
| `dontAsk` | 사전 승인된 도구만 | 잠긴 CI 및 스크립트 |
| `bypassPermissions` | 보호 경로 제외 전부 | 격리된 컨테이너/VM 전용 |

> 모든 모드에서 [protected paths](#protected-paths) 쓰기는 자동 승인 안 됨. 저장소 상태와 Claude 자체 설정 보호.

## 모드 전환 방법

**세션 중**: `Shift+Tab`으로 `default` → `acceptEdits` → `plan` 순환. 상태 표시줄에 현재 모드 표시.

**시작 시**:
```bash
claude --permission-mode plan
```

**기본값 설정** (`settings.json`):
```json
{
  "permissions": {
    "defaultMode": "acceptEdits"
  }
}
```

## acceptEdits 모드

- 작업 디렉토리 내 파일 생성/편집 승인 없이 허용
- 자동 승인 파일시스템 명령: `mkdir`, `touch`, `rm`, `rmdir`, `mv`, `cp`, `sed`
- 작업 디렉토리 외부 경로, protected paths, 다른 모든 Bash 명령은 여전히 프롬프트 필요
- 상태 표시줄: `⏵⏵ accept edits on`

## Plan 모드

- Claude가 읽기만 수행, 소스 파일 편집 없음
- `/plan` 접두사로 단일 프롬프트에 적용 가능
- 계획 완성 후 선택지:
  - 승인 + auto 모드로 시작
  - 승인 + edits 수락
  - 승인 + 수동 리뷰
  - 피드백과 함께 계획 유지
- `Ctrl+G`로 기본 텍스트 에디터에서 계획 직접 편집

## Auto 모드 (v2.1.83+)

별도 분류기 모델이 실행 전 액션 검토. 다음을 차단:
- `curl | bash` 같은 코드 다운로드 후 실행
- 외부 엔드포인트로 민감 데이터 전송
- 프로덕션 배포 및 마이그레이션
- 클라우드 스토리지 대량 삭제
- IAM 또는 저장소 권한 부여
- force push 또는 main 직접 push

허용되는 것:
- 작업 디렉토리 내 로컬 파일 작업
- lock 파일/매니페스트에 선언된 의존성 설치
- 읽기 전용 HTTP 요청

```bash
# Auto 모드 활성화
claude --enable-auto-mode
```

> 사용 가능 조건: Team/Enterprise/API 플랜, Claude Sonnet 4.6 또는 Opus 4.6, Anthropic API (Bedrock/Vertex 불가). Claude Code는 빠르게 업데이트되므로 지원 모델 조건이 변경될 수 있음 — 최신 문서 확인 권장.

## Protected Paths

모든 모드에서 절대 자동 승인 안 되는 경로: `.git/`, Claude Code 설정 파일 등 저장소 상태 관련 경로.

## 관련 항목
- [[wiki/ai/claude-code/claude-code-확장기능-개요]]
- [[wiki/ai/claude-code/claude-code-공통워크플로우]]
- [[wiki/ai/claude-code/claude-code-hooks-활용가이드]]
- [[wiki/ai/claude-code/claude-code-디렉토리-구조]]
