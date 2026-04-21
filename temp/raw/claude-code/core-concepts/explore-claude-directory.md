# Explore the .claude directory

> Where Claude Code reads CLAUDE.md, settings.json, hooks, skills, commands, subagents, rules, and auto memory. Explore the .claude directory in your project and ~/.claude in your home directory.

**출처**: https://code.claude.com/docs/en/claude-directory | **날짜**: 2026-04-13

---

Claude Code reads instructions, settings, skills, subagents, and memory from your project directory and from `~/.claude` in your home directory. Commit project files to git to share them with your team; files in `~/.claude` are personal configuration that applies across all your projects.

If you set [`CLAUDE_CONFIG_DIR`](/en/env-vars), every `~/.claude` path on this page lives under that directory instead.

Most users only edit `CLAUDE.md` and `settings.json`. The rest of the directory is optional: add skills, rules, or subagents as you need them.

This page is an interactive explorer: click files in the tree to see what each one does, when it loads, and an example. For a quick reference, see the file reference table below.

---

## Project-scope files

### `your-project/CLAUDE.md`

**One-liner**: Project instructions Claude reads every session  
**Badge**: committed  
**When it loads**: Loaded into context at the start of every session

Project-specific instructions that shape how Claude works in this repository. Put your conventions, common commands, and architectural context here so Claude operates with the same assumptions your team does.

**Tips**:
- Target under 200 lines. Longer files still load in full but may reduce adherence
- CLAUDE.md loads into every session. If something only matters for specific tasks, move it to a [skill](/en/skills) or a path-scoped [rule](/en/memory#organize-rules-with-claude/rules/) so it loads only when needed
- List the commands you run most, like build, test, and format, so Claude knows them without you spelling them out each time
- Run `/memory` to open and edit CLAUDE.md from within a session
- Also works at `.claude/CLAUDE.md` if you prefer to keep the project root clean

**Example** (TypeScript and React project):

```markdown
# Project conventions

## Commands
- Build: `npm run build`
- Test: `npm test`
- Lint: `npm run lint`

## Stack
- TypeScript with strict mode
- React 19, functional components only

## Rules
- Named exports, never default exports
- Tests live next to source: `foo.ts` -> `foo.test.ts`
- All API routes return `{ data, error }` shape
```

**Full docs**: [/en/memory](/en/memory)

---

### `your-project/.mcp.json`

**One-liner**: Project-scoped MCP servers, shared with your team  
**Badge**: committed  
**When it loads**: Servers connect when the session begins. Tool schemas are deferred by default and load on demand via [tool search](/en/mcp#scale-with-mcp-tool-search)

Configures Model Context Protocol (MCP) servers that give Claude access to external tools: databases, APIs, browsers, and more. This file holds the project-scoped servers your whole team uses. Personal servers you want to keep to yourself go in `~/.claude.json` instead.

**Tips**:
- Use environment variable references for secrets: `${GITHUB_TOKEN}`
- Lives at the project root, not inside `.claude/`
- For servers only you need, run `claude mcp add --scope user`. This writes to `~/.claude.json` instead of `.mcp.json`

**Example** (GitHub MCP server):

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_TOKEN": "${GITHUB_TOKEN}"
      }
    }
  }
}
```

The `${GITHUB_TOKEN}` reference is read from your shell environment when Claude Code starts the server, so the token never lands in the file.

**Full docs**: [/en/mcp](/en/mcp)

---

### `your-project/.worktreeinclude`

**One-liner**: Gitignored files to copy into new worktrees  
**Badge**: committed  
**When it loads**: Read when Claude creates a git worktree via `--worktree`, the `EnterWorktree` tool, or subagent `isolation: worktree`

Lists gitignored files to copy from your main repository into each new worktree. Worktrees are fresh checkouts, so untracked files like `.env` are missing by default. Patterns here use `.gitignore` syntax. Only files that match a pattern and are also gitignored get copied, so tracked files are never duplicated.

**Tips**:
- Lives at the project root, not inside `.claude/`
- Git-only: if you configure a [WorktreeCreate hook](/en/hooks#worktreecreate) for a different VCS, this file is not read. Copy files inside your hook script instead
- Also applies to parallel sessions in the [desktop app](/en/desktop#work-in-parallel-with-sessions)

**Example**:

```
# Local environment
.env
.env.local

# API credentials
config/secrets.json
```

**Full docs**: [/en/common-workflows#copy-gitignored-files-to-worktrees](/en/common-workflows#copy-gitignored-files-to-worktrees)

---

### `.claude/` (Project-level)

**One-liner**: Project-level configuration, rules, and extensions

Everything Claude Code reads that is specific to this project. If you use git, commit most files here so your team shares them; a few, like `settings.local.json`, are automatically gitignored. Each file badge shows which.

---

#### `.claude/settings.json`

**One-liner**: Permissions, hooks, and configuration  
**Badge**: committed  
**When it loads**: Overrides global `~/.claude/settings.json`. Local settings, CLI flags, and managed settings override this

Settings that Claude Code applies directly. Permissions control which commands and tools Claude can use; hooks run your scripts at specific points in a session. Unlike CLAUDE.md, which Claude reads as guidance, these are enforced whether Claude follows them or not.

**Common keys**:
- [permissions](/en/permissions): allow, deny, or prompt before Claude uses specific tools or commands
- [hooks](/en/hooks): run your own scripts on events like before a tool call or after a file edit
- [statusLine](/en/statusline): customize the line shown at the bottom while Claude works
- [model](/en/settings#available-settings): pick a default model for this project
- [env](/en/settings#environment-variables): environment variables set in every session
- [outputStyle](/en/output-styles): select a custom system-prompt style from output-styles/

**Tips**:
- Bash permission patterns support wildcards: `Bash(npm test *)` matches any command starting with `npm test`
- Array settings like `permissions.allow` combine across all scopes; scalar settings like `model` use the most specific value

**Example** (allows `npm test` and `npm run`, blocks `rm -rf`, runs Prettier after edits):

```json
{
  "permissions": {
    "allow": [
      "Bash(npm test *)",
      "Bash(npm run *)"
    ],
    "deny": [
      "Bash(rm -rf *)"
    ]
  },
  "hooks": {
    "PostToolUse": [{
      "matcher": "Edit|Write",
      "hooks": [{
        "type": "command",
        "command": "jq -r '.tool_input.file_path' | xargs npx prettier --write"
      }]
    }]
  }
}
```

**Full docs**: [/en/settings](/en/settings)

---

#### `.claude/settings.local.json`

**One-liner**: Your personal settings overrides for this project  
**Badge**: gitignored  
**When it loads**: Highest of the user-editable settings files; CLI flags and managed settings still take precedence

Personal settings that take precedence over the project defaults. Same JSON format as `settings.json`, but not committed. Use this when you need different permissions or defaults than the team config.

**Tips**:
- Same schema as `settings.json`. Array settings like `permissions.allow` combine across scopes; scalar settings like `model` use the local value
- Claude Code adds this file to `~/.config/git/ignore` the first time it writes one. If you use a custom `core.excludesFile`, add the pattern there too. To share the ignore rule with your team, also add it to the project `.gitignore`

**Example** (adds Docker permissions on top of team settings):

```json
{
  "permissions": {
    "allow": [
      "Bash(docker *)"
    ]
  }
}
```

**Full docs**: [/en/settings](/en/settings)

---

#### `.claude/rules/`

**One-liner**: Topic-scoped instructions, optionally gated by file paths  
**When it loads**: Rules without `paths:` load at session start. Rules with `paths:` load when a matching file enters context

Project instructions split into topic files that can load conditionally based on file paths. A rule without `paths:` frontmatter loads at session start like CLAUDE.md; a rule with `paths:` loads only when Claude reads a matching file.

Like CLAUDE.md, rules are guidance Claude reads, not configuration Claude Code enforces. For guaranteed behavior use [hooks](/en/hooks) or [permissions](/en/permissions).

**Tips**:
- Use `paths:` frontmatter with globs to scope rules to directories or file types
- Subdirectories work: `.claude/rules/frontend/react.md` is discovered automatically
- When CLAUDE.md approaches 200 lines, start splitting into rules

**Full docs**: [/en/memory#organize-rules-with-claude/rules/](/en/memory#organize-rules-with-claude/rules/)

**Example — `testing.md`** (test conventions scoped to test files):

```markdown
---
paths:
  - "**/*.test.ts"
  - "**/*.test.tsx"
---

# Testing Rules

- Use descriptive test names: "should [expected] when [condition]"
- Mock external dependencies, not internal modules
- Clean up side effects in afterEach
```

**Example — `api-design.md`** (API conventions scoped to backend code):

```markdown
---
paths:
  - "src/api/**/*.ts"
---

# API Design Rules

- All endpoints must validate input with Zod schemas
- Return shape: { data: T } | { error: string }
- Rate limit all public endpoints
```

---

#### `.claude/skills/`

**One-liner**: Reusable prompts you or Claude invoke by name  
**When it loads**: Invoked with `/skill-name` or when Claude matches the task to a skill

Each skill is a folder with a `SKILL.md` file plus any supporting files it needs. By default, both you and Claude can invoke a skill. Use frontmatter to control that: `disable-model-invocation: true` for user-only workflows like `/deploy`, or `user-invocable: false` to hide from the `/` menu while Claude can still invoke it.

**Tips**:
- Skills accept arguments: `/deploy staging` passes "staging" as `$ARGUMENTS`. Use `$0`, `$1`, and so on for positional access
- The `description` frontmatter determines when Claude auto-invokes the skill
- Bundle reference docs alongside SKILL.md. Claude knows the skill directory path and can read supporting files when you mention them

**Full docs**: [/en/skills](/en/skills)

**Example — `skills/security-review/SKILL.md`**:

```markdown
---
description: Reviews code changes for security vulnerabilities, authentication gaps, and injection risks
disable-model-invocation: true
argument-hint: <branch-or-path>
---

## Diff to review

!`git diff $ARGUMENTS`

Audit the changes above for:

1. Injection vulnerabilities (SQL, XSS, command)
2. Authentication and authorization gaps
3. Hardcoded secrets or credentials

Use checklist.md in this skill directory for the full review checklist.

Report findings with severity ratings and remediation steps.
```

**Example — `skills/security-review/checklist.md`** (supporting file bundled with the skill):

```markdown
# Security Review Checklist

## Input Validation
- [ ] All user input sanitized before DB queries
- [ ] File upload MIME types validated
- [ ] Path traversal prevented on file operations

## Authentication
- [ ] JWT tokens expire after 24 hours
- [ ] API keys stored in environment variables
- [ ] Passwords hashed with bcrypt or argon2
```

Skills can bundle any supporting files: reference docs, templates, scripts. The skill directory path is prepended to SKILL.md, so Claude can read bundled files by name. For scripts in bash injection commands, use the `${CLAUDE_SKILL_DIR}` placeholder.

---

#### `.claude/commands/`

**One-liner**: Single-file prompts invoked with `/name`

> **Note**: Commands and skills are now the same mechanism. For new workflows, use `skills/` instead: same `/name` invocation, plus you can bundle supporting files.

A file at `commands/deploy.md` creates `/deploy` the same way a skill at `skills/deploy/SKILL.md` does, and both can be auto-invoked by Claude. Skills use a directory with SKILL.md, letting you bundle reference docs, templates, or scripts alongside the prompt.

**When it loads**: User types `/command-name`

**Tips**:
- Use `$ARGUMENTS` in the file to accept parameters: `/fix-issue 123`
- If a skill and command share a name, the skill takes precedence
- New commands should usually be skills instead; commands remain supported

**Example — `commands/fix-issue.md`**:

```markdown
---
argument-hint: <issue-number>
---

!`gh issue view $ARGUMENTS`

Investigate and fix the issue above.

1. Trace the bug to its root cause
2. Implement the fix
3. Write or update tests
4. Summarize what you changed and why
```

Type `/fix-issue 123` and the `!`...`` line runs `gh issue view 123` in your shell, injecting the output into the prompt before Claude sees it.

**Full docs**: [/en/skills](/en/skills)

---

#### `.claude/output-styles/`

**One-liner**: Project-scoped output styles, if your team shares any  
**When it loads**: Applied at session start when selected via the `outputStyle` setting

Output styles are usually personal, so most live in `~/.claude/output-styles/`. Put one here if your team shares a style, like a review mode everyone uses. See the Global tab for the full explanation and example.

**Full docs**: [/en/output-styles](/en/output-styles)

---

#### `.claude/agents/`

**One-liner**: Specialized subagents with their own context window  
**When it loads**: Runs in its own context window when you or Claude invoke it

Each markdown file defines a subagent with its own system prompt, tool access, and optionally its own model. Subagents run in a fresh context window, keeping the main conversation clean. Useful for parallel work or isolated tasks.

**Tips**:
- Each agent gets a fresh context window, separate from your main session
- Restrict tool access per agent with the `tools:` frontmatter field
- Type @ and pick an agent from the autocomplete to delegate directly

**Full docs**: [/en/sub-agents](/en/sub-agents)

**Example — `agents/code-reviewer.md`**:

```markdown
---
name: code-reviewer
description: Reviews code for correctness, security, and maintainability
tools: Read, Grep, Glob
---

You are a senior code reviewer. Review for:

1. Correctness: logic errors, edge cases, null handling
2. Security: injection, auth bypass, data exposure
3. Maintainability: naming, complexity, duplication

Every finding must include a concrete fix.
```

---

#### `.claude/agent-memory/` (auto-generated)

**One-liner**: Subagent persistent memory, separate from your main session auto memory  
**Badge**: committed (Claude writes)  
**When it loads**: First 200 lines (capped at 25KB) of MEMORY.md loaded into the subagent system prompt when it runs

Subagents with `memory: project` in their frontmatter get a dedicated memory directory here. This is distinct from your main session auto memory at `~/.claude/projects/`: each subagent reads and writes its own MEMORY.md, not yours.

**Tips**:
- Only created for subagents that set the `memory:` frontmatter field
- This directory holds project-scoped subagent memory, meant to be shared with your team. To keep memory out of version control use `memory: local`, which writes to `.claude/agent-memory-local/` instead. For cross-project memory use `memory: user`, which writes to `~/.claude/agent-memory/`
- The main session auto memory is a different feature; see `~/.claude/projects/` in the Global tab

**Full docs**: [/en/sub-agents#enable-persistent-memory](/en/sub-agents#enable-persistent-memory)

**Example — `.claude/agent-memory/<agent-name>/MEMORY.md`**:

```markdown
# code-reviewer memory

## Patterns seen
- Project uses custom Result<T, E> type, not exceptions
- Auth middleware expects Bearer token in Authorization header
- Tests use factory functions in test/factories/

## Recurring issues
- Missing null checks on API responses (src/api/*)
- Unhandled promise rejections in background jobs
```

---

## Global-scope files (`~/`)

### `~/.claude.json`

**One-liner**: App state and UI preferences  
**Badge**: local only  
**When it loads**: Read at session start for your preferences and MCP servers. Claude Code writes back to it when you change settings in `/config` or approve trust prompts

Holds state that does not belong in `settings.json`: theme, OAuth session, per-project trust decisions, your personal MCP servers, and UI toggles. Mostly managed through `/config` rather than editing directly.

**Tips**:
- UI toggles like `showTurnDuration` and `terminalProgressBarEnabled` live here, not in `settings.json`
- The `projects` key tracks per-project state like trust-dialog acceptance and last-session metrics. Permission rules you approve in-session go to `.claude/settings.local.json` instead
- MCP servers here are yours only: user scope applies across all projects, local scope is per-project but not committed. Team-shared servers go in `.mcp.json` at the project root instead

**Example**:

```json
{
  "editorMode": "vim",
  "showTurnDuration": false,
  "mcpServers": {
    "my-tools": {
      "command": "npx",
      "args": ["-y", "@example/mcp-server"]
    }
  }
}
```

**Full docs**: [/en/settings#global-config-settings](/en/settings#global-config-settings)

---

### `~/.claude/` (Global-level)

**One-liner**: Your personal configuration across all projects

The global counterpart to your project `.claude/` directory. Files here apply to every project you work in and are never committed to any repository.

---

#### `~/.claude/CLAUDE.md`

**One-liner**: Personal preferences across every project  
**Badge**: local only  
**When it loads**: Loaded at the start of every session, in every project

Your global instruction file. Loaded alongside the project CLAUDE.md at session start, so both are in context together. When instructions conflict, project-level instructions take priority. Keep this to preferences that apply everywhere: response style, commit format, personal conventions.

**Tips**:
- Keep it short since it loads into context for every project, alongside that project's own CLAUDE.md
- Good for response style, commit format, and personal conventions

**Example**:

```markdown
# Global preferences

- Keep explanations concise
- Use conventional commit format
- Show the terminal command to verify changes
- Prefer composition over inheritance
```

**Full docs**: [/en/memory](/en/memory)

---

#### `~/.claude/settings.json`

**One-liner**: Default settings for all projects  
**Badge**: local only  
**When it loads**: Your defaults. Project and local `settings.json` override any keys you also set there

Same keys as project `settings.json`: permissions, hooks, model, environment variables, and the rest. Put settings here that you want in every project, like permissions you always allow, a preferred model, or a notification hook that runs regardless of which project you're in.

Settings follow a precedence order: project `settings.json` overrides any matching keys you set here. This is different from CLAUDE.md, where global and project files are both loaded into context rather than merged key by key.

**Example**:

```json
{
  "permissions": {
    "allow": [
      "Bash(git log *)",
      "Bash(git diff *)"
    ]
  }
}
```

**Full docs**: [/en/settings](/en/settings)

---

#### `~/.claude/keybindings.json`

**One-liner**: Custom keyboard shortcuts  
**Badge**: local only  
**When it loads**: Read at session start and hot-reloaded when you edit the file

Rebind keyboard shortcuts in the interactive CLI. Run `/keybindings` to create or open this file with a schema reference. Ctrl+C, Ctrl+D, and Ctrl+M are reserved and cannot be rebound.

**Example** (binds `Ctrl+E` to open external editor, unbinds `Ctrl+U`):

```json
{
  "$schema": "https://www.schemastore.org/claude-code-keybindings.json",
  "$docs": "https://code.claude.com/docs/en/keybindings",
  "bindings": [
    {
      "context": "Chat",
      "bindings": {
        "ctrl+e": "chat:externalEditor",
        "ctrl+u": null
      }
    }
  ]
}
```

**Full docs**: [/en/keybindings](/en/keybindings)

---

#### `~/.claude/projects/` (auto-generated)

**One-liner**: Auto memory: Claude's notes to itself, per project  
**Badge**: local only (Claude writes)  
**When it loads**: MEMORY.md loaded at session start; topic files read on demand

Auto memory lets Claude accumulate knowledge across sessions without you writing anything. Claude saves notes as it works: build commands, debugging insights, architecture notes. Each project gets its own memory directory keyed by the repository path.

**Tips**:
- On by default. Toggle with `/memory` or `autoMemoryEnabled` in settings
- MEMORY.md is the index loaded each session. The first 200 lines, or 25KB, whichever comes first, are read
- Topic files like `debugging.md` are read on demand, not at startup
- These are plain markdown. Edit or delete them anytime

**Full docs**: [/en/memory#auto-memory](/en/memory#auto-memory)

**Example — `~/.claude/projects/<project>/memory/MEMORY.md`**:

```markdown
# Memory Index

## Project
- [build-and-test.md](build-and-test.md): npm run build (~45s), Vitest, dev server on 3001
- [architecture.md](architecture.md): API client singleton, refresh-token auth

## Reference
- [debugging.md](debugging.md): auth token rotation and DB connection troubleshooting
```

**Example — `~/.claude/projects/<project>/memory/debugging.md`** (topic file):

```markdown
---
name: Debugging patterns
description: Auth token rotation and database connection troubleshooting for this project
type: reference
---

## Auth Token Issues
- Refresh token rotation: old token invalidated immediately
- If 401 after refresh: check clock skew between client and server

## Database Connection Drops
- Connection pool: max 10 in dev, 50 in prod
- Always check `docker compose ps` first
```

---

#### `~/.claude/rules/`

**One-liner**: User-level rules that apply to every project  
**When it loads**: Rules without `paths:` load at session start. Rules with `paths:` load when a matching file enters context

Same as project `.claude/rules/` but applies everywhere. Use this for conventions you want across all your work, like personal code style or commit message format.

**Full docs**: [/en/memory#organize-rules-with-claude/rules/](/en/memory#organize-rules-with-claude/rules/)

---

#### `~/.claude/skills/`

**One-liner**: Personal skills available in every project  
**When it loads**: Invoked with `/skill-name` in any project

Skills you built for yourself that work everywhere. Same structure as project skills: each is a folder with SKILL.md, scoped to your user account instead of a single project.

**Full docs**: [/en/skills](/en/skills)

---

#### `~/.claude/commands/`

**One-liner**: Personal single-file commands available in every project  
**When it loads**: User types `/command-name` in any project

Same as project `commands/` but scoped to your user account. Each markdown file becomes a command available everywhere.

> **Note**: Commands and skills are now the same mechanism. For new workflows, use `skills/` instead.

**Full docs**: [/en/skills](/en/skills)

---

#### `~/.claude/output-styles/`

**One-liner**: Custom system-prompt sections that adjust how Claude works  
**When it loads**: Applied at session start when selected via the `outputStyle` setting

Each markdown file defines an output style: a section appended to the system prompt that, by default, also drops the built-in software-engineering task instructions. Use this to adapt Claude Code for uses beyond coding, or to add teaching or review modes.

Select a built-in or custom style with `/config` or the `outputStyle` key in settings. Styles here are available in every project; project-level styles with the same name take precedence.

**Tips**:
- Built-in styles Explanatory and Learning are included with Claude Code; custom styles go here
- Set `keep-coding-instructions: true` in frontmatter to keep the default task instructions alongside your additions
- Changes take effect on the next session since the system prompt is fixed at startup for caching

**Full docs**: [/en/output-styles](/en/output-styles)

**Example — `~/.claude/output-styles/teaching.md`**:

```markdown
---
description: Explains reasoning and asks you to implement small pieces
keep-coding-instructions: true
---

After completing each task, add a brief "Why this approach" note
explaining the key design decision.

When a change is under 10 lines, ask the user to implement it
themselves by leaving a TODO(human) marker instead of writing it.
```

---

#### `~/.claude/agents/`

**One-liner**: Personal subagents available in every project  
**When it loads**: Claude delegates or you @-mention in any project

Subagents defined here are available across all your projects. Same format as project agents.

**Full docs**: [/en/sub-agents](/en/sub-agents)

---

#### `~/.claude/agent-memory/` (auto-generated)

**One-liner**: Persistent memory for subagents with `memory: user`  
**When it loads**: Loaded into the subagent system prompt when the subagent starts

Subagents with `memory: user` in their frontmatter store knowledge here that persists across all projects. For project-scoped subagent memory, see `.claude/agent-memory/` instead.

**Full docs**: [/en/sub-agents#enable-persistent-memory](/en/sub-agents#enable-persistent-memory)

---

## What's not shown

The explorer covers files you author and edit. A few related files live elsewhere:

| File                    | Location                   | Purpose |
| ----------------------- | -------------------------- | ------- |
| `managed-settings.json` | System-level, varies by OS | Enterprise-enforced settings that you can't override. See [server-managed settings](/en/server-managed-settings). |
| `CLAUDE.local.md`       | Project root               | Your private preferences for this project, loaded alongside CLAUDE.md. Create it manually and add it to `.gitignore`. |
| Installed plugins       | `~/.claude/plugins/`       | Cloned marketplaces, installed plugin versions, and per-plugin data, managed by `claude plugin` commands. Orphaned versions are deleted 7 days after a plugin update or uninstall. See [plugin caching](/en/plugins-reference#plugin-caching-and-file-resolution). |

`~/.claude` also holds data Claude Code writes as you work: transcripts, prompt history, file snapshots, caches, and logs. See Application data below.

---

## File reference

This table lists every file the explorer covers. Project-scope files live in your repo under `.claude/` (or at the root for `CLAUDE.md`, `.mcp.json`, and `.worktreeinclude`). Global-scope files live in `~/.claude/` and apply across all projects.

> **Note**: Several things can override what you put in these files:
> - [Managed settings](/en/server-managed-settings) deployed by your organization take precedence over everything
> - CLI flags like `--permission-mode` or `--settings` override `settings.json` for that session
> - Some environment variables take precedence over their equivalent setting, but this varies: check the [environment variables reference](/en/env-vars) for each one
>
> See [settings precedence](/en/settings#settings-precedence) for the full order.

| File                                        | Scope              | Commit | What it does                                          | Reference |
| ------------------------------------------- | ------------------ | ------ | ----------------------------------------------------- | --------- |
| `CLAUDE.md`                                 | Project and global | ✓      | Instructions loaded every session                     | [Memory](/en/memory) |
| `rules/*.md`                                | Project and global | ✓      | Topic-scoped instructions, optionally path-gated      | [Rules](/en/memory#organize-rules-with-claude/rules/) |
| `settings.json`                             | Project and global | ✓      | Permissions, hooks, env vars, model defaults          | [Settings](/en/settings) |
| `settings.local.json`                       | Project only       |        | Your personal overrides, auto-gitignored              | [Settings scopes](/en/settings#settings-files) |
| `.mcp.json`                                 | Project only       | ✓      | Team-shared MCP servers                               | [MCP scopes](/en/mcp#mcp-installation-scopes) |
| `.worktreeinclude`                          | Project only       | ✓      | Gitignored files to copy into new worktrees           | [Worktrees](/en/common-workflows#copy-gitignored-files-to-worktrees) |
| `skills/<name>/SKILL.md`                    | Project and global | ✓      | Reusable prompts invoked with `/name` or auto-invoked | [Skills](/en/skills) |
| `commands/*.md`                             | Project and global | ✓      | Single-file prompts; same mechanism as skills         | [Skills](/en/skills) |
| `output-styles/*.md`                        | Project and global | ✓      | Custom system-prompt sections                         | [Output styles](/en/output-styles) |
| `agents/*.md`                               | Project and global | ✓      | Subagent definitions with their own prompt and tools  | [Subagents](/en/sub-agents) |
| `agent-memory/<name>/`                      | Project and global | ✓      | Persistent memory for subagents                       | [Persistent memory](/en/sub-agents#enable-persistent-memory) |
| `~/.claude.json`                            | Global only        |        | App state, OAuth, UI toggles, personal MCP servers    | [Global config](/en/settings#global-config-settings) |
| `projects/<project>/memory/`                | Global only        |        | Auto memory: Claude's notes to itself across sessions | [Auto memory](/en/memory#auto-memory) |
| `keybindings.json`                          | Global only        |        | Custom keyboard shortcuts                             | [Keybindings](/en/keybindings) |

---

## Check what loaded

The explorer shows what files can exist. To see what actually loaded in your current session, use these commands:

| Command        | Shows |
| -------------- | ----- |
| `/context`     | Token usage by category: system prompt, memory files, skills, MCP tools, and messages |
| `/memory`      | Which CLAUDE.md and rules files loaded, plus auto-memory entries |
| `/agents`      | Configured subagents and their settings |
| `/hooks`       | Active hook configurations |
| `/mcp`         | Connected MCP servers and their status |
| `/skills`      | Available skills from project, user, and plugin sources |
| `/permissions` | Current allow and deny rules |
| `/doctor`      | Installation and configuration diagnostics |

Run `/context` first for the overview, then the specific command for the area you want to investigate.

---

## Application data

Beyond the config you author, `~/.claude` holds data Claude Code writes during sessions. These files are plaintext. Anything that passes through a tool lands in a transcript on disk: file contents, command output, pasted text.

### Cleaned up automatically

Files in the paths below are deleted on startup once they're older than [`cleanupPeriodDays`](/en/settings#available-settings). The default is 30 days.

| Path under `~/.claude/`                      | Contents |
| -------------------------------------------- | -------- |
| `projects/<project>/<session>.jsonl`         | Full conversation transcript: every message, tool call, and tool result |
| `projects/<project>/<session>/tool-results/` | Large tool outputs spilled to separate files |
| `file-history/<session>/`                    | Pre-edit snapshots of files Claude changed, used for [checkpoint restore](/en/checkpointing) |
| `plans/`                                     | Plan files written during [plan mode](/en/permission-modes#analyze-before-you-edit-with-plan-mode) |
| `debug/`                                     | Per-session debug logs, written only when you start with `--debug` or run `/debug` |
| `paste-cache/`, `image-cache/`               | Contents of large pastes and attached images |
| `session-env/`                               | Per-session environment metadata |

### Kept until you delete them

The following paths are not covered by automatic cleanup and persist indefinitely.

| Path under `~/.claude/` | Contents |
| ----------------------- | -------- |
| `history.jsonl`         | Every prompt you've typed, with timestamp and project path. Used for up-arrow recall. |
| `stats-cache.json`      | Aggregated token and cost counts shown by `/cost` |
| `backups/`              | Timestamped copies of `~/.claude.json` taken before config migrations |
| `todos/`                | Legacy per-session task lists. No longer written by current versions; safe to delete. |

`shell-snapshots/` holds runtime files removed when the session exits cleanly. Other small cache and lock files appear depending on which features you use and are safe to delete.

### Plaintext storage

Transcripts and history are not encrypted at rest. OS file permissions are the only protection. If a tool reads a `.env` file or a command prints a credential, that value is written to `projects/<project>/<session>.jsonl`. To reduce exposure:

- Lower `cleanupPeriodDays` to shorten how long transcripts are kept
- In non-interactive mode, pass `--no-session-persistence` alongside `-p` to skip writing transcripts entirely. In the Agent SDK, set `persistSession: false`. There is no interactive-mode equivalent.
- Use [permission rules](/en/permissions) to deny reads of credential files

### Clear local data

You can delete any of the application-data paths above at any time. New sessions are unaffected. The table below shows what you lose for past sessions.

| Delete | You lose |
| ------ | -------- |
| `~/.claude/projects/` | Resume, continue, and rewind for past sessions |
| `~/.claude/history.jsonl` | Up-arrow prompt recall |
| `~/.claude/file-history/` | Checkpoint restore for past sessions |
| `~/.claude/stats-cache.json` | Historical totals shown by `/cost` |
| `~/.claude/backups/` | Rollback copies of `~/.claude.json` from past config migrations |
| `~/.claude/debug/`, `~/.claude/plans/`, `~/.claude/paste-cache/`, `~/.claude/image-cache/`, `~/.claude/session-env/` | Nothing user-facing |
| `~/.claude/todos/` | Nothing. Legacy directory not written by current versions. |

Don't delete `~/.claude.json`, `~/.claude/settings.json`, or `~/.claude/plugins/`: those hold your auth, preferences, and installed plugins.

---

## Related resources

- [Manage Claude's memory](/en/memory): write and organize CLAUDE.md, rules, and auto memory
- [Configure settings](/en/settings): set permissions, hooks, environment variables, and model defaults
- [Create skills](/en/skills): build reusable prompts and workflows
- [Configure subagents](/en/sub-agents): define specialized agents with their own context
