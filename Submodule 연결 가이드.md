# the-sanctum Submodule 연결 가이드

the-second-brain 레포를 public으로 전환하고, 비공개 the-sanctum 레포를 생성하여 submodule로 연결하는 단계별 가이드이다.

> **작업 환경**
> - GitHub 사용자명: `taewoojin`
> - 작업 디렉토리: `~/dev/the-second-brain`

---

## 1. 현재 상태 확인

```bash
# 현재 레포의 visibility 확인
gh repo view taewoojin/the-second-brain --json visibility --jq '.visibility'
```

**예상 출력:**
```
PRIVATE
```

```bash
# 작업 디렉토리 확인
pwd
```

**예상 출력:**
```
/Users/taewoo/dev/the-second-brain
```

---

## 2. the-second-brain을 public으로 변경

```bash
gh repo edit taewoojin/the-second-brain --visibility public --accept-visibility-change-consequences
```

**예상 출력:**
```
✓ Edited repository taewoojin/the-second-brain
```

> **주의:** public으로 전환하면 누구나 이 레포의 내용을 볼 수 있다. 민감한 정보(API 키, 비밀번호 등)가 커밋 히스토리에 포함되어 있지 않은지 반드시 확인한다.

**변경 확인:**

```bash
gh repo view taewoojin/the-second-brain --json visibility --jq '.visibility'
```

**예상 출력:**
```
PUBLIC
```

---

## 3. the-sanctum 비공개 레포 생성

비공개로 유지할 콘텐츠를 담을 레포를 생성한다.

```bash
gh repo create taewoojin/the-sanctum --private --description "Private vault for the-second-brain"
```

**예상 출력:**
```
✓ Created repository taewoojin/the-sanctum on GitHub
```

---

## 4. submodule으로 추가

the-second-brain 루트 디렉토리에서 the-sanctum을 submodule로 추가한다.

```bash
cd ~/dev/the-second-brain
git submodule add git@github.com:taewoojin/the-sanctum.git the-sanctum
```

이 명령어는 다음 두 가지를 수행한다:
- `the-sanctum/` 디렉토리를 생성하고 해당 레포를 클론한다.
- `.gitmodules` 파일을 생성(또는 업데이트)하여 submodule 정보를 기록한다.

**예상 출력:**
```
Cloning into '/Users/taewoo/dev/the-second-brain/the-sanctum'...
warning: You appear to have cloned an empty repository.
```

> **참고:** 새로 만든 빈 레포이므로 `empty repository` 경고가 나오는 것은 정상이다.

---

## 5. submodule 안에서 파일 생성 & 커밋 & 푸시

submodule 디렉토리로 이동하여 초기 파일을 생성하고 푸시한다.

```bash
cd ~/dev/the-second-brain/the-sanctum
```

```bash
# 초기 README 생성
echo "# the-sanctum\n\nPrivate vault for the-second-brain." > README.md
```

```bash
# 커밋 & 푸시
git add README.md
git commit -m "Initial commit"
git branch -M main
git push -u origin main
```

**예상 출력:**
```
[main (root-commit) abc1234] Initial commit
 1 file changed, 3 insertions(+)
 create mode 100644 README.md
...
To github.com:taewoojin/the-sanctum.git
 * [new branch]      main -> main
branch 'main' set up to track 'origin/main'.
```

---

## 6. 부모 레포에서 submodule 참조 커밋 & 푸시

부모 레포(the-second-brain)로 돌아와서 submodule 참조를 커밋한다.

```bash
cd ~/dev/the-second-brain
```

```bash
git add .gitmodules the-sanctum
git commit -m "Add the-sanctum as submodule"
git push
```

이 커밋은 `.gitmodules` 파일과 submodule이 가리키는 커밋 해시를 부모 레포에 기록한다.

**예상 출력:**
```
[master abc5678] Add the-sanctum as submodule
 2 files changed, 4 insertions(+)
 create mode 100644 .gitmodules
 create mode 160000 the-sanctum
...
To github.com:taewoojin/the-second-brain.git
   720282e..abc5678  master -> master
```

---

## 7. 검증

### submodule 상태 확인

```bash
git submodule status
```

**예상 출력:**
```
 abc1234 the-sanctum (heads/main)
```

커밋 해시 앞에 `-`나 `+`가 없으면 정상적으로 초기화된 상태이다.

### GitHub 웹에서 확인

1. `https://github.com/taewoojin/the-second-brain` 에 접속한다.
2. 파일 목록에서 `the-sanctum` 이 폴더 아이콘이 아닌 **submodule 링크**(화살표 아이콘 + 커밋 해시)로 표시되는지 확인한다.
3. 해당 링크를 클릭하면 `https://github.com/taewoojin/the-sanctum` 으로 이동하지만, 비공개 레포이므로 로그인한 본인만 접근할 수 있다.

---

## 참고: 다른 환경에서 클론할 때

이후 다른 머신에서 the-second-brain을 클론할 경우 submodule까지 함께 받으려면:

```bash
git clone --recurse-submodules git@github.com:taewoojin/the-second-brain.git
```

이미 클론한 상태라면:

```bash
git submodule update --init --recursive
```

> **주의:** the-sanctum은 private 레포이므로, 클론하는 머신에서 해당 레포에 대한 SSH 키 또는 인증이 설정되어 있어야 한다.
