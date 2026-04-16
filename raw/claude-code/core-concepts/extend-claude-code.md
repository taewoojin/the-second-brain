---
title: "Extend Claude Code"
source: "https://code.claude.com/docs/en/features-overview"
author:
published:
created: 2026-04-13
description: "Understand when to use CLAUDE.md, Skills, subagents, hooks, MCP, and plugins."
tags:
  - "clippings"
---
Claude Code combines a model that reasons about your code with [built-in tools](https://code.claude.com/docs/en/how-claude-code-works#tools) for file operations, search, execution, and web access. The built-in tools cover most coding tasks. This guide covers the extension layer: features you add to customize what Claude knows, connect it to external services, and automate workflows.

For how the core agentic loop works, see [How Claude Code works](https://code.claude.com/docs/en/how-claude-code-works).

**New to Claude Code?** Start with [CLAUDE.md](https://code.claude.com/docs/en/memory) for project conventions, then add other extensions [as specific triggers come up](#build-your-setup-over-time).

## Overview

Extensions plug into different parts of the agentic loop:
- **[CLAUDE.md](https://code.claude.com/docs/en/memory)** adds persistent context Claude sees every session
- **[Skills](https://code.claude.com/docs/en/skills)** add reusable knowledge and invocable workflows
- **[MCP](https://code.claude.com/docs/en/mcp)** connects Claude to external services and tools
- **[Subagents](https://code.claude.com/docs/en/sub-agents)** run their own loops in isolated context, returning summaries
- **[Agent teams](https://code.claude.com/docs/en/agent-teams)** coordinate multiple independent sessions with shared tasks and peer-to-peer messaging
- **[Hooks](https://code.claude.com/docs/en/hooks)** run outside the loop entirely as deterministic scripts
- **[Plugins](https://code.claude.com/docs/en/plugins)** and **[marketplaces](https://code.claude.com/docs/en/plugin-marketplaces)** package and distribute these features
[Skills](https://code.claude.com/docs/en/skills) are the most flexible extension. A skill is a markdown file containing knowledge, workflows, or instructions. You can invoke skills with a command like `/deploy`, or Claude can load them automatically when relevant. Skills can run in your current conversation or in an isolated context via subagents.

## Match features to your goal

Features range from always-on context that Claude sees every session, to on-demand capabilities you or Claude can invoke, to background automation that runs on specific events. The table below shows what’s available and when each one makes sense.

| Feature | What it does | When to use it | Example |
| --- | --- | --- | --- |
| **CLAUDE.md** | Persistent context loaded every conversation | Project conventions, “always do X” rules | ”Use pnpm, not npm. Run tests before committing.” |
| **Skill** | Instructions, knowledge, and workflows Claude can use | Reusable content, reference docs, repeatable tasks | `/deploy` runs your deployment checklist; API docs skill with endpoint patterns |
| **Subagent** | Isolated execution context that returns summarized results | Context isolation, parallel tasks, specialized workers | Research task that reads many files but returns only key findings |
| **[Agent teams](https://code.claude.com/docs/en/agent-teams)** | Coordinate multiple independent Claude Code sessions | Parallel research, new feature development, debugging with competing hypotheses | Spawn reviewers to check security, performance, and tests simultaneously |
| **MCP** | Connect to external services | External data or actions | Query your database, post to Slack, control a browser |
| **Hook** | Deterministic script that runs on events | Predictable automation, no LLM involved | Run ESLint after every file edit |

**[Plugins](https://code.claude.com/docs/en/plugins)** are the packaging layer. A plugin bundles skills, hooks, subagents, and MCP servers into a single installable unit. Plugin skills are namespaced (like `/my-plugin:review`) so multiple plugins can coexist. Use plugins when you want to reuse the same setup across multiple repositories or distribute to others via a **[marketplace](https://code.claude.com/docs/en/plugin-marketplaces)**.

### Build your setup over time

You don’t need to configure everything up front. Each feature has a recognizable trigger, and most teams add them in roughly this order:

| Trigger | Add |
| --- | --- |
| Claude gets a convention or command wrong twice | Add it to [CLAUDE.md](https://code.claude.com/docs/en/memory) |
| You keep typing the same prompt to start a task | Save it as a user-invocable [skill](https://code.claude.com/docs/en/skills) |
| You paste the same playbook or multi-step procedure into chat for the third time | Capture it as a [skill](https://code.claude.com/docs/en/skills) |
| You keep copying data from a browser tab Claude can’t see | Connect that system as an [MCP server](https://code.claude.com/docs/en/mcp) |
| A side task floods your conversation with output you won’t reference again | Route it through a [subagent](https://code.claude.com/docs/en/sub-agents) |
| You want something to happen every time without asking | Write a [hook](https://code.claude.com/docs/en/hooks-guide) |
| A second repository needs the same setup | Package it as a [plugin](https://code.claude.com/docs/en/plugins) |

The same triggers tell you when to update what you already have. A repeated mistake or a recurring review comment is a CLAUDE.md edit, not a one-off correction in chat. A workflow you keep tweaking by hand is a skill that needs another revision.

### Compare similar features

Some features can seem similar. Here’s how to tell them apart.

- Skill vs Subagent
- CLAUDE.md vs Skill
- CLAUDE.md vs Rules vs Skills
- Subagent vs Agent team
- MCP vs Skill

Skills and subagents solve different problems:
- **Skills** are reusable content you can load into any context
- **Subagents** are isolated workers that run separately from your main conversation

| Aspect | Skill | Subagent |
| --- | --- | --- |
| **What it is** | Reusable instructions, knowledge, or workflows | Isolated worker with its own context |
| **Key benefit** | Share content across contexts | Context isolation. Work happens separately, only summary returns |
| **Best for** | Reference material, invocable workflows | Tasks that read many files, parallel work, specialized workers |

**Skills can be reference or action.** Reference skills provide knowledge Claude uses throughout your session (like your API style guide). Action skills tell Claude to do something specific (like `/deploy` that runs your deployment workflow).**Use a subagent** when you need context isolation or when your context window is getting full. The subagent might read dozens of files or run extensive searches, but your main conversation only receives a summary. Since subagent work doesn’t consume your main context, this is also useful when you don’t need the intermediate work to remain visible. Custom subagents can have their own instructions and can preload skills.**They can combine.** A subagent can preload specific skills (`skills:` field). A skill can run in isolated context using `context: fork`. See [Skills](https://code.claude.com/docs/en/skills) for details.

### Understand how features layer

Features can be defined at multiple levels: user-wide, per-project, via plugins, or through managed policies. You can also nest CLAUDE.md files in subdirectories or place skills in specific packages of a monorepo. When the same feature exists at multiple levels, here’s how they layer:
- **CLAUDE.md files** are additive: all levels contribute content to Claude’s context simultaneously. Files from your working directory and above load at launch; subdirectories load as you work in them. When instructions conflict, Claude uses judgment to reconcile them, with more specific instructions typically taking precedence. See [how CLAUDE.md files load](https://code.claude.com/docs/en/memory#how-claude-md-files-load).
- **Skills and subagents** override by name: when the same name exists at multiple levels, one definition wins based on priority (managed > user > project for skills; managed > CLI flag > project > user > plugin for subagents). Plugin skills are [namespaced](https://code.claude.com/docs/en/plugins#add-skills-to-your-plugin) to avoid conflicts. See [skill discovery](https://code.claude.com/docs/en/skills#where-skills-live) and [subagent scope](https://code.claude.com/docs/en/sub-agents#choose-the-subagent-scope).
- **MCP servers** override by name: local > project > user. See [MCP scope](https://code.claude.com/docs/en/mcp#scope-hierarchy-and-precedence).
- **Hooks** merge: all registered hooks fire for their matching events regardless of source. See [hooks](https://code.claude.com/docs/en/hooks).

### Combine features

Each extension solves a different problem: CLAUDE.md handles always-on context, skills handle on-demand knowledge and workflows, MCP handles external connections, subagents handle isolation, and hooks handle automation. Real setups combine them based on your workflow. For example, you might use CLAUDE.md for project conventions, a skill for your deployment workflow, MCP to connect to your database, and a hook to run linting after every edit. Each feature handles what it’s best at.

| Pattern | How it works | Example |
| --- | --- | --- |
| **Skill + MCP** | MCP provides the connection; a skill teaches Claude how to use it well | MCP connects to your database, a skill documents your schema and query patterns |
| **Skill + Subagent** | A skill spawns subagents for parallel work | `/audit` skill kicks off security, performance, and style subagents that work in isolated context |
| **CLAUDE.md + Skills** | CLAUDE.md holds always-on rules; skills hold reference material loaded on demand | CLAUDE.md says “follow our API conventions,” a skill contains the full API style guide |
| **Hook + MCP** | A hook triggers external actions through MCP | Post-edit hook sends a Slack notification when Claude modifies critical files |

## Understand context costs

Every feature you add consumes some of Claude’s context. Too much can fill up your context window, but it can also add noise that makes Claude less effective; skills may not trigger correctly, or Claude may lose track of your conventions. Understanding these trade-offs helps you build an effective setup. For an interactive view of how these features combine in a running session, see [Explore the context window](https://code.claude.com/docs/en/context-window).

### Context cost by feature

Each feature has a different loading strategy and context cost:

| Feature | When it loads | What loads | Context cost |
| --- | --- | --- | --- |
| **CLAUDE.md** | Session start | Full content | Every request |
| **Skills** | Session start + when used | Descriptions at start, full content when used | Low (descriptions every request)\* |
| **MCP servers** | Session start | Tool names; full schemas on demand | Low until a tool is used |
| **Subagents** | When spawned | Fresh context with specified skills | Isolated from main session |
| **Hooks** | On trigger | Nothing (runs externally) | Zero, unless hook returns additional context |

\*By default, skill descriptions load at session start so Claude can decide when to use them. Set `disable-model-invocation: true` in a skill’s frontmatter to hide it from Claude entirely until you invoke it manually. This reduces context cost to zero for skills you only trigger yourself.

### Understand how features load

Each feature loads at different points in your session. The tabs below explain when each one loads and what goes into context.![Context loading: CLAUDE.md loads at session start and stays in every request. MCP tool names load at start with full schemas deferred until use. Skills load descriptions at start, full content on invocation. Subagents get isolated context. Hooks run externally.](https://mintcdn.com/claude-code/6yTCYq1p37ZB8-CQ/images/context-loading.svg?w=2500&fit=max&auto=format&n=6yTCYq1p37ZB8-CQ&q=85&s=7807709604d9851e7cba2c604422901c)

Context loading: CLAUDE.md loads at session start and stays in every request. MCP tool names load at start with full schemas deferred until use. Skills load descriptions at start, full content on invocation. Subagents get isolated context. Hooks run externally.

- CLAUDE.md
- Skills
- MCP servers
- Subagents
- Hooks

**When:** Session start **What loads:** Full content of all CLAUDE.md files (managed, user, and project levels).**Inheritance:** Claude reads CLAUDE.md files from your working directory up to the root, and discovers nested ones in subdirectories as it accesses those files. See [How CLAUDE.md files load](https://code.claude.com/docs/en/memory#how-claude-md-files-load) for details.

Keep CLAUDE.md under 200 lines. Move reference material to skills, which load on-demand.

## Learn more

Each feature has its own guide with setup instructions, examples, and configuration options.

## [CLAUDE.md](https://code.claude.com/docs/en/memory)

Store project context, conventions, and instructions

## [Skills](https://code.claude.com/docs/en/skills)

Give Claude domain expertise and reusable workflows

## [Subagents](https://code.claude.com/docs/en/sub-agents)

Offload work to isolated context

## [Agent teams](https://code.claude.com/docs/en/agent-teams)

Coordinate multiple sessions working in parallel

## [MCP](https://code.claude.com/docs/en/mcp)

Connect Claude to external services

## [Hooks](https://code.claude.com/docs/en/hooks-guide)

Automate workflows with hooks

## [Plugins](https://code.claude.com/docs/en/plugins)

Bundle and share feature sets

## [Marketplaces](https://code.claude.com/docs/en/plugin-marketplaces)

Host and distribute plugin collections