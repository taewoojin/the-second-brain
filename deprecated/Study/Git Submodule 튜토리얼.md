
## 1. Submodule이란?

Git submodule은 **하나의 Git 저장소 안에 다른 Git 저장소를 포함시키는 기능**이다. 외부 저장소를 마치 폴더처럼 넣어두되, 각 저장소는 독립적인 커밋 히스토리를 유지한다.

### 사용 사례

- **공개 레포 + 비공개 콘텐츠 분리**: 공개 저장소(`the-second-brain`)에 비공개 저장소(`the-sanctum`)를 submodule로 연결하면, 공개 레포를 클론한 외부 사용자에게는 비공개 콘텐츠가 보이지 않는다.
- **공통 라이브러리 공유**: 여러 프로젝트에서 같은 라이브러리를 사용할 때, 라이브러리를 submodule로 관리하면 하나의 소스를 여러 곳에서 참조할 수 있다.

### 일반 폴더와의 차이점

| 구분            | 일반 폴더     | Submodule          |
| ------------- | --------- | ------------------ |
| 커밋 히스토리       | 부모 레포에 포함 | 독립적으로 관리           |
| 원격 저장소        | 부모 레포와 동일 | 별도의 원격 저장소를 가짐     |
| 접근 권한         | 부모 레포와 동일 | 각 저장소별 별도 설정 가능    |
| 부모 레포가 저장하는 것 | 파일 내용 전체  | 특정 커밋의 참조(해시값)만 저장 |

핵심은 마지막 줄이다. 부모 레포는 submodule의 파일 내용을 직접 저장하지 않고, **"이 submodule은 현재 어떤 커밋을 가리키고 있는가"**라는 정보만 기록한다.

---

## 2. 사전 준비

### 필요한 것

- GitHub 계정
- Git 설치 (버전 2.13 이상 권장)

### Git 설치 확인

```bash
git --version
```

```
git version 2.39.5
```

위와 같이 버전이 출력되면 정상이다. 설치되어 있지 않다면 [git-scm.com](https://git-scm.com)에서 설치한다.

### 실습용 레포 준비

이 튜토리얼에서는 다음 두 저장소를 사용한다.

| 저장소 | 공개 여부 | 역할 |
|--------|-----------|------|
| `the-second-brain` | 공개 | 부모 레포 (submodule을 포함하는 쪽) |
| `the-sanctum` | 비공개 | 자식 레포 (submodule로 추가될 쪽) |

GitHub 웹사이트에서 직접 생성하거나, `gh` CLI를 사용하여 터미널에서 생성할 수 있다.

#### gh CLI로 레포 생성하기

`gh`(GitHub CLI)가 설치되어 있다면 다음 명령어로 레포를 생성할 수 있다.

```bash
# gh 설치 확인
gh --version
```

```
gh version 2.65.0 (2025-01-20)
```

설치되어 있지 않다면 `brew install gh`(macOS) 또는 [cli.github.com](https://cli.github.com)에서 설치한다.

```bash
# 공개 레포 생성 (현재 디렉토리를 레포로 연결)
gh repo create the-second-brain --public --source . --push

# 비공개 레포 생성 후 바로 클론
gh repo create the-sanctum --private --clone
```

**`the-sanctum` 생성 예상 출력:**

```
✓ Created repository <사용자명>/the-sanctum on GitHub
  https://github.com/<사용자명>/the-sanctum
Cloning into 'the-sanctum'...
```

`the-sanctum`에는 아무 파일이나 하나 이상 커밋되어 있어야 한다. 빈 레포를 생성했다면 초기 커밋을 만들어 둔다.

```bash
cd the-sanctum
echo "# The Sanctum" > README.md
git add README.md
git commit -m "Initial commit"
git push -u origin main
cd ..
```

---

## 3. 기본 사용법

### 3-1. Submodule 추가

부모 레포(`the-second-brain`)의 루트 디렉토리에서 다음 명령어를 실행한다.

```bash
cd ~/dev/the-second-brain
git submodule add git@github.com:<사용자명>/the-sanctum.git the-sanctum
```

> `<사용자명>`은 본인의 GitHub 사용자명으로 대체한다.

**예상 출력:**

```
Cloning into '/Users/<사용자명>/dev/the-second-brain/the-sanctum'...
remote: Enumerating objects: 3, done.
remote: Counting objects: 100% (3/3), done.
remote: Total 3 (delta 0), reused 0 (delta 0), pack-reused 0
Receiving objects: 100% (3/3), done.
```

### 3-2. 생성된 파일 확인

submodule을 추가하면 두 가지가 생성된다.

```bash
git status
```

**예상 출력:**

```
On branch master
Changes to be committed:
  (use "git restore --staged <file>..." to unstage)
        new file:   .gitmodules
        new file:   the-sanctum
```

#### `.gitmodules` 파일

submodule의 경로와 원격 URL을 기록하는 설정 파일이다.

```bash
cat .gitmodules
```

**예상 출력:**

```ini
[submodule "the-sanctum"]
    path = the-sanctum
    url = git@github.com:<사용자명>/the-sanctum.git
```

#### `the-sanctum` 디렉토리

`the-sanctum` 저장소의 내용이 클론된 디렉토리이다. 부모 레포 입장에서는 이 디렉토리 전체가 **하나의 커밋 참조**로 관리된다.

### 3-3. Submodule 추가를 커밋

```bash
git add .gitmodules the-sanctum
git commit -m "Add the-sanctum as submodule"
git push
```

**예상 출력:**

```
[master abc1234] Add the-sanctum as submodule
 2 files changed, 4 insertions(+)
 create mode 100644 .gitmodules
 create mode 160000 the-sanctum
```

> `160000`은 submodule을 나타내는 특수 파일 모드이다.

### 3-4. Submodule 안에서 작업하기

submodule 디렉토리로 이동하면 독립적인 Git 저장소처럼 동작한다.

```bash
cd the-sanctum
```

먼저 작업할 브랜치를 체크아웃한다. (submodule은 기본적으로 detached HEAD 상태이므로 브랜치를 명시적으로 체크아웃해야 한다.)

```bash
git checkout main
```

**예상 출력:**

```
Switched to branch 'main'
Your branch is up to date with 'origin/main'.
```

파일을 수정하고 커밋한다.

```bash
echo "비공개 메모" > secret-note.md
git add secret-note.md
git commit -m "Add secret note"
git push
```

**예상 출력:**

```
[main def5678] Add secret note
 1 file changed, 1 insertion(+)
 create mode 100644 secret-note.md
```

### 3-5. 부모 레포에서 Submodule 참조 업데이트

부모 레포 디렉토리로 돌아온다.

```bash
cd ~/dev/the-second-brain
```

submodule 안에서 커밋이 발생했으므로, 부모 레포에서 변경 사항이 감지된다.

```bash
git status
```

**예상 출력:**

```
On branch master
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)

        modified:   the-sanctum (new commits)
```

부모 레포는 "submodule이 새 커밋을 가리키게 되었다"는 사실을 감지한 것이다. 이 변경을 커밋하여 참조를 업데이트한다.

```bash
git add the-sanctum
git commit -m "Update the-sanctum submodule reference"
git push
```

**예상 출력:**

```
[master ghi9012] Update the-sanctum submodule reference
 1 file changed, 1 insertion(+), 1 deletion(-)
```

> **중요**: submodule 안에서 먼저 커밋 & 푸시 → 그 다음 부모 레포에서 참조 업데이트 & 푸시. 이 순서를 지키지 않으면 부모 레포가 아직 원격에 존재하지 않는 커밋을 참조하게 되어 다른 사람이 클론할 때 오류가 발생한다.

---

## 4. 다른 컴퓨터에서 클론할 때

### 방법 1: 클론 시 submodule도 함께 가져오기 (권장)

```bash
git clone --recurse-submodules git@github.com:<사용자명>/the-second-brain.git
```

**예상 출력:**

```
Cloning into 'the-second-brain'...
remote: Enumerating objects: 10, done.
remote: Counting objects: 100% (10/10), done.
remote: Compressing objects: 100% (7/7), done.
Receiving objects: 100% (10/10), done.
Submodule 'the-sanctum' (git@github.com:<사용자명>/the-sanctum.git) registered for path 'the-sanctum'
Cloning into '/Users/<사용자명>/dev/the-second-brain/the-sanctum'...
Submodule path 'the-sanctum': checked out 'def5678...'
```

### 방법 2: 클론 후 submodule을 별도로 초기화

이미 `git clone`을 한 상태라면 다음 명령어로 submodule을 가져올 수 있다.

```bash
cd the-second-brain
git submodule init
git submodule update
```

**`git submodule init` 예상 출력:**

```
Submodule 'the-sanctum' (git@github.com:<사용자명>/the-sanctum.git) registered for path 'the-sanctum'
```

**`git submodule update` 예상 출력:**

```
Cloning into '/Users/<사용자명>/dev/the-second-brain/the-sanctum'...
Submodule path 'the-sanctum': checked out 'def5678...'
```

> 비공개 저장소를 submodule로 사용하는 경우, 클론하는 머신에 해당 저장소에 대한 접근 권한(SSH 키 또는 토큰)이 설정되어 있어야 한다.

---

## 5. 자주 쓰는 명령어 치트시트

| 작업 | 명령어 |
|------|--------|
| submodule 추가 | `git submodule add <URL> <경로>` |
| submodule 초기화 | `git submodule init` |
| submodule 업데이트 (부모가 기록한 커밋으로) | `git submodule update` |
| submodule의 최신 커밋 가져오기 | `git submodule update --remote` |
| 클론 시 submodule 포함 | `git clone --recurse-submodules <URL>` |
| 모든 submodule에서 명령 실행 | `git submodule foreach '<명령어>'` |
| submodule 상태 확인 | `git submodule status` |
| submodule 삭제 | 아래 FAQ 참조 |

---

## 6. 주의사항 / FAQ

### Q. Submodule 안에서 커밋하지 않고 부모 레포만 커밋하면?

submodule 디렉토리 안의 변경 사항은 부모 레포의 `git add`에 포함되지 않는다. 부모 레포가 추적하는 것은 submodule의 **커밋 해시값**뿐이다. 따라서 submodule 안의 변경 사항을 보존하려면 반드시 submodule 안에서 먼저 커밋해야 한다.

커밋하지 않은 채 `git submodule update`를 실행하면 **submodule 안의 변경 사항이 사라질 수 있으므로** 주의한다.

### Q. Detached HEAD 상태란?

submodule을 처음 클론하거나 `git submodule update`를 실행하면, submodule은 특정 커밋에 체크아웃된 **detached HEAD** 상태가 된다. 이 상태에서는 브랜치가 아닌 커밋 해시를 직접 가리키고 있어서, 커밋을 만들어도 어떤 브랜치에도 속하지 않는다.

**해결 방법**: submodule에서 작업하기 전에 항상 브랜치를 체크아웃한다.

```bash
cd the-sanctum
git checkout main
```

만약 detached HEAD 상태에서 커밋을 이미 만들어버렸다면, 다음과 같이 복구한다.

```bash
# 현재 커밋 해시를 확인
git log --oneline -1
# 예: abc1234 My commit message

# 브랜치로 체크아웃한 뒤 해당 커밋을 가져오기
git checkout main
git cherry-pick abc1234
```

### Q. Submodule을 삭제하려면?

submodule 삭제는 단순히 폴더를 지우는 것으로는 완료되지 않는다. 다음 단계를 모두 수행해야 한다.

```bash
# 1. submodule 등록 해제
git submodule deinit -f the-sanctum

# 2. .git/modules에서 관련 데이터 삭제
rm -rf .git/modules/the-sanctum

# 3. 작업 디렉토리에서 submodule 제거
git rm -f the-sanctum

# 4. 변경 사항 커밋
git commit -m "Remove the-sanctum submodule"
```

**예상 출력 (각 단계별):**

```
# 1단계
Cleared directory 'the-sanctum'
Submodule 'the-sanctum' (git@github.com:<사용자명>/the-sanctum.git) unregistered for path 'the-sanctum'

# 3단계
rm 'the-sanctum'

# 4단계
[master xyz7890] Remove the-sanctum submodule
 2 files changed, 4 deletions(-)
 delete mode 160000 the-sanctum
 delete mode 100644 .gitmodules
```

### Q. Submodule의 원격 최신 변경 사항을 가져오려면?

submodule이 원격에서 다른 사람에 의해 업데이트되었을 때, 최신 커밋을 가져오려면 다음과 같이 한다.

```bash
# 방법 1: submodule 디렉토리에서 직접 pull
cd the-sanctum
git pull origin main
cd ..

# 방법 2: 부모 레포에서 한 번에 업데이트
git submodule update --remote the-sanctum
```

이후 부모 레포에서 변경된 참조를 커밋하는 것을 잊지 않는다.

```bash
git add the-sanctum
git commit -m "Update the-sanctum to latest"
git push
```
