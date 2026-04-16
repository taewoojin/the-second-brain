# Explore the Context Window

> An interactive simulation of how Claude Code's context window fills during a session. See what loads automatically, what each file read costs, and when rules and hooks fire.

출처: https://code.claude.com/docs/en/context-window

---

Claude Code's context window holds everything Claude knows about your session: your instructions, the files it reads, its own responses, and content that never appears in your terminal. The timeline below walks through what loads and when.

---

## 인터랙티브 컴포넌트: ContextWindow 시뮬레이션

최대 컨텍스트 창: **200,000 tokens** (수치는 예시 값)

### 배지(Badge) 종류

| 배지 | 설명 |
|:---|:---|
| `auto` | Auto-loaded — Claude가 자동으로 컨텍스트에 넣는 항목 |
| `you` | You typed this — 사용자가 입력 |
| `claude` | Claude's work — Claude의 작업 결과 |
| `hook` | Hook (automatic) — 자동 실행 훅 |
| `subagent` | In subagent's context — 서브에이전트의 별도 컨텍스트 |
| `compact` | Compaction — 압축 |

### 가시성(Visibility) 표시

| 표시 | 의미 |
|:---|:---|
| ● (full) | Shown in your terminal — 터미널에 전체 내용 표시 |
| ◐ (brief) | One-liner in your terminal — 터미널에 한 줄만 표시 |
| ○ (hidden) | Invisible in your terminal — 터미널에 보이지 않음 |

### 색상 범례 (Legend)

| 색상 | 카테고리 |
|:---|:---|
| 회색 (#6B6964) | System |
| 파란색 (#6A9BCC) | CLAUDE.md |
| 주황색-노란색 (#E8A45C) | Memory |
| 황금색 (#D4A843) | Skills |
| 보라색 (#9B7BC4) | MCP |
| 청록색 (#4A9B8E) | Rules |
| 초록색 (#558A42) | You |
| 회색-갈색 (#8A8880) | Files |
| 연한 회색 (#A09E96) | Output |
| 주황색 (#D97757) | Claude |
| 진한 노란색 (#B8860B) | Hooks |

---

## 세션 타임라인 이벤트 (EVENTS)

### Before You Type Anything (시작 자동 로드)

---

**[auto] System prompt** — ~4,200 tokens | hidden (터미널에 보이지 않음)

Core instructions for behavior, tool use, and response formatting. Always loaded first. You never see it.

---

**[auto] Auto memory (MEMORY.md)** — ~680 tokens | hidden

Claude's notes to itself from previous sessions: build commands it learned, patterns it noticed, mistakes to avoid. The first 200 lines or 25KB, whichever comes first, are loaded into the conversation context.

→ 링크: /en/memory#auto-memory

---

**[auto] Environment info** — ~280 tokens | hidden

Working directory, platform, shell, OS version, and whether this is a git repo. Git branch, status, and recent commits load as a separate block at the very end of the system prompt.

---

**[auto] MCP tools (deferred)** — ~120 tokens | hidden

MCP tool names listed so Claude knows what is available. By default, full schemas stay deferred and Claude loads specific ones on demand via tool search when a task needs them. Set `ENABLE_TOOL_SEARCH=auto` to load schemas upfront when they fit within 10% of the context window, or `ENABLE_TOOL_SEARCH=false` to load everything.

→ 링크: /en/mcp#scale-with-mcp-tool-search

---

**[auto] Skill descriptions** — ~450 tokens | hidden | noSurviveCompact: true

One-line descriptions of available skills so Claude knows what it can invoke. Full skill content loads only when Claude actually uses one. Skills with `disable-model-invocation: true` are not in this list. They stay completely out of context until you invoke them with `/name`. Unlike the rest of the startup content, this listing is not re-injected after `/compact`. Only skills you actually invoked get preserved.

→ 링크: /en/skills

---

**[auto] ~/.claude/CLAUDE.md** — ~320 tokens | hidden

Your global preferences. Applies to every project. Loaded alongside project instructions at the start of every conversation.

→ 링크: /en/memory#choose-where-to-put-claude-md-files

---

**[auto] Project CLAUDE.md** — ~1,800 tokens | hidden

Project conventions, build commands, architecture notes. The most important file you can create. Lives in your project root, so your whole team gets the same instructions.

> **💡 Save context tip**: Keep it under 200 lines. Move reference content to skills or path-scoped rules so it only loads when needed.

→ 링크: /en/memory

---

### You (사용자 입력)

---

**[you] Your prompt** — ~45 tokens | full (터미널에 전체 표시)

"Fix the auth bug where users get 401 after token refresh"

---

### Claude Works (Claude 작업)

---

**[claude] Read src/api/auth.ts** — ~2,400 tokens | brief (터미널에 한 줄 표시)

Main auth file. You see "Read auth.ts" in your terminal, but the 2,400 tokens of file content only Claude sees.

> **💡 Save context tip**: File reads dominate context usage. Be specific in prompts ("fix the bug in auth.ts") so Claude reads fewer files. For research-heavy tasks, use a subagent.

---

**[claude] Read src/lib/tokens.ts** — ~1,100 tokens | brief

Following imports to the token module. Shown as a one-liner in your terminal.

---

**[auto] Rule: api-conventions.md** — ~380 tokens | brief

This rule in `.claude/rules/` has a `paths:` pattern matching `src/api/**`. It loaded automatically when Claude read a file in that directory. You see "Loaded .claude/rules/api-conventions.md" in your terminal, but not the rule content.

→ 링크: /en/memory#path-specific-rules

---

**[claude] Read middleware.ts** — ~1,800 tokens | brief

Tracing the auth flow deeper.

---

**[claude] Read auth.test.ts** — ~1,600 tokens | brief

Checking existing tests for expected behavior.

---

**[auto] Rule: testing.md** — ~290 tokens | brief

Another path-scoped rule, this one matching `*.test.ts` files. Triggered when Claude read auth.test.ts. Shown as a one-line "Loaded" notice.

→ 링크: /en/memory#path-specific-rules

---

**[claude] grep "refreshToken"** — ~600 tokens | brief

Search results across the codebase. You see the command ran, not the full output.

---

**[claude] Claude's analysis** — ~800 tokens | full

Explains the bug: token invalidated too early in the rotation. This text appears in your terminal.

---

**[claude] Edit auth.ts** — ~400 tokens | full

Fixes the token rotation order. The diff appears in your terminal.

---

**[hook] Hook: prettier** — ~120 tokens | hidden

A PostToolUse hook in `settings.json` runs prettier after every file edit and reports back via `hookSpecificOutput.additionalContext`. That field enters Claude's context. Plain stdout on exit 0 does not. It is written to the debug log only.

> **💡 Save context tip**: Output JSON with `additionalContext` to send info to Claude. For PostToolUse hooks, exit code 2 surfaces stderr as an error but cannot block since the tool already ran. Keep output concise since it enters context without truncation.

→ 링크: /en/hooks-guide

---

**[claude] Edit auth.test.ts** — ~600 tokens | full

Adds a regression test for the fix. The diff appears in your terminal.

---

**[hook] Hook: prettier** — ~100 tokens | hidden

The same hook fires again for the test file. Every matching tool event triggers it.

→ 링크: /en/hooks-guide

---

**[claude] npm test output** — ~1,200 tokens | brief

Runs the test suite. You see "Running npm test..." and the pass count, not the full 1,200 tokens of output.

---

**[claude] Summary** — ~400 tokens | full

"Fixed token rotation. Added regression test. All tests pass."

---

### You (후속 입력)

---

**[you] Your follow-up** — ~40 tokens | full

"Use a subagent to research session timeout handling, then fix it"

> **💡 Save context tip**: Follow-ups add to the same context. Delegating research to a subagent keeps large file reads out of your main window.

→ 링크: /en/interactive-mode#bash-mode-with-prefix

---

**[claude] Spawn research subagent** — ~80 tokens | brief

Claude delegates the research to a subagent with a fresh, separate context window. It loads CLAUDE.md and the same MCP and skill setup, but starts without your conversation history or the main session's auto memory.

→ 링크: /en/sub-agents

---

### Subagent's Separate Context Window (서브에이전트 별도 컨텍스트)

> 아래 항목들은 서브에이전트 자체의 컨텍스트 창에서 소비된다. 메인 세션 토큰에 영향을 주지 않는다.

---

**[subagent] System prompt** — 0 tokens (main) / ~900 tokens (subagent) | hidden

The subagent gets its own system prompt, shorter than the main session's. For the general-purpose agent, it's a brief prompt plus environment details. The main session's auto memory is not included. If a custom agent has `memory:` in its frontmatter, it loads its own separate MEMORY.md here instead.

→ 링크: /en/sub-agents#enable-persistent-memory

---

**[subagent] Project CLAUDE.md (own copy)** — 0 tokens (main) / ~1,800 tokens (subagent) | hidden

The subagent loads CLAUDE.md too. Same file, same content, but it counts against the subagent's context, not yours. The built-in Explore and Plan agents skip this for a smaller context.

→ 링크: /en/sub-agents

---

**[subagent] MCP tools + skills** — 0 tokens (main) / ~970 tokens (subagent) | hidden

The subagent has access to the same MCP servers and skills. It gets most of the parent's tools, minus several that don't apply in a nested context, including plan-mode controls, background-task tools, and by default the Agent tool itself to prevent recursion.

→ 링크: /en/sub-agents

---

**[subagent] Task prompt from main** — 0 tokens (main) / ~120 tokens (subagent) | hidden

Instead of a user prompt, the subagent receives the task Claude wrote for it: "Research session timeout handling in this codebase."

→ 링크: /en/sub-agents

---

**[subagent] Read session.ts** — 0 tokens (main) / ~2,200 tokens (subagent) | hidden

Now the subagent does its work. This file read fills the subagent's context, not yours.

→ 링크: /en/sub-agents

---

**[subagent] Read timeouts.ts** — 0 tokens (main) / ~800 tokens (subagent) | hidden

Another file read in the subagent's separate context.

→ 링크: /en/sub-agents

---

**[subagent] Read config/*.ts** — 0 tokens (main) / ~3,100 tokens (subagent) | hidden

The subagent can read as many files as it needs. None of this touches your main context.

→ 링크: /en/sub-agents

---

**[claude] Subagent returns summary** — ~420 tokens | brief

Only the subagent's final text response comes back to your context, plus a small metadata trailer with token counts and duration. The subagent read 6,100 tokens of files. You got a 420-token result. That's the context savings.

→ 링크: /en/sub-agents

---

**[claude] Claude's response** — ~1,200 tokens | full

Analysis and fix for session timeouts. This text appears in your terminal.

---

### You (셸 명령 + 스킬 호출)

---

**[you] !git status** — ~180 tokens | full

You ran a shell command with the `!` prefix to see which files Claude modified. The command and its output both enter context as part of your message. Useful for grounding Claude in command output without Claude running it.

→ 링크: /en/interactive-mode#bash-mode-with-prefix

---

**[you] /commit-push** — ~620 tokens | brief

You invoked a skill that has `disable-model-invocation: true`. Its description was not in the skill index at startup, so it cost zero context until this moment. Now the full skill content loads and Claude follows its instructions to stage, commit, and push your changes.

> **💡 Save context tip**: Set `disable-model-invocation: true` on skills with side effects like committing, deploying, or sending messages. They stay out of context entirely until you need them.

→ 링크: /en/skills#control-who-invokes-a-skill

---

### Compaction

---

**[compact] /compact** | brief

Replaces the conversation with a structured summary. You see a "Conversation compacted" message. The summarization happens without appearing in your terminal.

→ 링크: /en/how-claude-code-works#the-context-window

**After /compact — Conversation summary block:**

All conversation events condensed into one structured summary. The summary keeps: your requests and intent, key technical concepts, files examined or modified with important code snippets, errors and how they were fixed, pending tasks, and current work. It replaces the verbatim conversation: full tool outputs and intermediate reasoning are gone. Claude can still reference the work but won't have the exact code it read earlier.

→ 링크: /en/how-claude-code-works#the-context-window

---

## Key Takeaways (단계별 핵심 메시지)

- **시작 전 (~20% 이전)**: A lot loads before you type anything. CLAUDE.md, memory, skills, and MCP tools are all in context before your first prompt.
- **첫 프롬프트 직후**: Your prompt is tiny compared to what's already loaded. Most of Claude's context is project knowledge, not your words.
- **파일 읽는 중 (~28%–50%)**: Each file Claude reads grows the context. Path-scoped rules load automatically alongside matching files.
- **훅 발동 후 (~50%–71%)**: Hooks fire automatically on tool events. Output reaches Claude via `additionalContext` JSON. Exit code 2 surfaces stderr to Claude. Plain stdout on exit 0 goes to the debug log, not the transcript.
- **후속 입력 (~71%–79%)**: Follow-up questions keep building on the same context. Everything from earlier is still there.
- **서브에이전트 (~79%–87%)**: The subagent works in its own separate context window. None of its file reads touch yours. Only the final summary comes back.
- **Bang command (~87%–88%)**: Bang commands run in your shell and prefix the output to your next message. Useful for grounding Claude in command results without it running them.
- **User-only skill (~88%–90%)**: User-only skills stay out of context entirely until you invoke them. The skill index at startup only lists skills Claude can call on its own.
- **After /compact**: Compaction replaces the conversation with a structured summary. System prompt, CLAUDE.md, memory, and MCP tools reload automatically. The skill listing is the one exception. Only skills you actually invoked are preserved.

---

## What the Timeline Shows

The session walks through a realistic flow with representative token counts:

* **Before you type anything**: CLAUDE.md, auto memory, MCP tool names, and skill descriptions all load into context. Your own setup may add more here, like an [output style](/en/output-styles) or text from [`--append-system-prompt`](/en/cli-reference), which both go into the system prompt the same way.
* **As Claude works**: each file read adds to context, [path-scoped rules](/en/memory#path-specific-rules) load automatically alongside matching files, and a [PostToolUse hook](/en/hooks-guide) fires after each edit.
* **The follow-up prompt**: a [subagent](/en/sub-agents) handles the research in its own separate context window, so the large file reads stay out of yours. Only the summary and a small metadata trailer come back.
* **At the end**: `/compact` replaces the conversation with a structured summary. Most startup content reloads automatically; the table below shows what happens to each mechanism.

---

## What Survives Compaction

When a long session compacts, Claude Code summarizes the conversation history to fit the context window. What happens to your instructions depends on how they were loaded:

| Mechanism | After compaction |
|:---|:---|
| System prompt and output style | Unchanged; not part of message history |
| Project-root CLAUDE.md and unscoped rules | Re-injected from disk |
| Auto memory | Re-injected from disk |
| Rules with `paths:` frontmatter | Lost until a matching file is read again |
| Nested CLAUDE.md in subdirectories | Lost until a file in that subdirectory is read again |
| Invoked skill bodies | Re-injected, capped at 5,000 tokens per skill and 25,000 tokens total; oldest dropped first |
| Hooks | Not applicable; hooks run as code, not context |

Path-scoped rules and nested CLAUDE.md files load into message history when their trigger file is read, so compaction summarizes them away with everything else. They reload the next time Claude reads a matching file. If a rule must persist across compaction, drop the `paths:` frontmatter or move it to the project-root CLAUDE.md.

Skill bodies are re-injected after compaction, but large skills are truncated to fit the per-skill cap, and the oldest invoked skills are dropped once the total budget is exceeded. Truncation keeps the start of the file, so put the most important instructions near the top of `SKILL.md`.

---

## Check Your Own Session

The visualization uses representative numbers. To see your actual context usage at any point, run `/context` for a live breakdown by category with optimization suggestions. Run `/memory` to check which CLAUDE.md and auto memory files loaded at startup.

---

## Related Resources

* [Extend Claude Code](/en/features-overview): when to use CLAUDE.md vs skills vs rules vs hooks vs MCP
* [Store instructions and memories](/en/memory): CLAUDE.md hierarchy and auto memory
* [Subagents](/en/sub-agents): delegate research to a separate context window
* [Best practices](/en/best-practices): managing context as your primary constraint
* [Reduce token usage](/en/costs#reduce-token-usage): strategies for keeping context usage low
