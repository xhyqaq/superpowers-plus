# Superpowers Plus

[English](README.md) | [中文](README.zh-CN.md)

Superpowers Plus is an enhanced workflow skill set evolved from upstream `superpowers`, designed for coding agent environments like Claude Code, Codex, OpenCode, and Gemini CLI. It retains the "design → plan → execute → verify" core workflow but unifies execution routing, subagent context control, and installation entry points within this repository instead of relying on the upstream.

## How it works

It starts from the moment you fire up your coding agent. As soon as it sees that you're building something, it *doesn't* just jump into trying to write code. Instead, it steps back and asks you what you're really trying to do.

Once it's teased a spec out of the conversation, it shows it to you in chunks short enough to actually read and digest.

After you've signed off on the design, your agent puts together an implementation plan that's clear enough for an enthusiastic junior engineer with poor taste, no judgement, no project context, and an aversion to testing to follow. It emphasizes true red/green TDD, YAGNI (You Aren't Gonna Need It), and DRY.

Next up, once you say "go", it launches an *executing-plans* process that automatically chooses parallel or serial subagent routing based on task dependency, then inspects and reviews the work as it goes. It's not uncommon for Claude to be able to work autonomously for a couple hours at a time without deviating from the plan you put together.

There's a bunch more to it, but that's the core of the system. And because the skills trigger automatically, you don't need to do anything special. Your coding agent just has Superpowers Plus.

## Key Changes from Upstream Superpowers

Superpowers Plus has made the following consolidations and adjustments relative to the upstream:

**Execution Model Unification:**
- Unified the plan execution entry point to `executing-plans`, no longer maintaining `subagent-driven-development` as a separate workflow entry.
- `executing-plans` now operates as a controller-style executor: automatically determines whether tasks are suitable for parallel subagents or require serial subagents, eliminating the need for users to choose between the two before execution.
- Subagents now receive only task-level minimal context by default, not the entire conversation history; execution models default to lower-cost sub-models, upgrading only when necessary.
- Plan handoff messaging now leads directly to execution, no longer inserting a "Subagent-Driven / Inline Execution" choice after `writing-plans`.

**Simplified Subagent Workflow:**
- Removed mandatory spec and code review requirements for subagent execution.
- Eliminated upstream's prescriptive subagent development conventions.
- Design philosophy: Since `brainstorming` and `writing-plans` already provide thorough design and planning, the execution phase should trust and follow that plan rather than repeat design processes at the subagent level.
- Enforces frequent, granular commits: every RED-GREEN-REFACTOR cycle commits independently, creating a clear implementation audit trail.

**Enhanced Documentation Management:**
- Introduced structured documentation tracking system:
  - Design specs → `docs/superpowers/specs/YYYY-MM-DD-<topic>-design.md`
  - Implementation plans → `docs/superpowers/plans/YYYY-MM-DD-<feature-name>.md`
  - Commit documentation → `docs/superpowers/commits/<module>/`
- Built-in self-review mechanisms for both specs and plans before user review, catching placeholders, contradictions, and ambiguities early.
- Added `reusable-assets-index` skill for managing reusable code/component documentation.
- Strengthened repository-level documentation indexing in AGENTS.md and CLAUDE.md.

**Repository Consistency:**
- Tests, examples, and active documentation within the repository have been updated around the new single-entry execution model, avoiding discrepancies between README, skills, and tests.

This is not a complete changelog, but rather the behavioral differences users need to know.

## Installation

Superpowers Plus installation entry points are unified to this repository:

- GitHub: `https://github.com/xhyqaq/superpowers-plus`
- Codex install script: `https://raw.githubusercontent.com/xhyqaq/superpowers-plus/refs/heads/main/.codex/INSTALL.md`
- OpenCode install script: `https://raw.githubusercontent.com/xhyqaq/superpowers-plus/refs/heads/main/.opencode/INSTALL.md`

### Claude Code

We recommend installing directly from the repository rather than relying on the upstream marketplace:

**Quick Install (Recommended):**

```bash
git clone https://github.com/xhyqaq/superpowers-plus.git ~/.claude/superpowers-plus
bash ~/.claude/superpowers-plus/.claude-plugin/install.sh
```

**Manual Install:**

```bash
git clone https://github.com/xhyqaq/superpowers-plus.git ~/.claude/superpowers-plus
mkdir -p ~/.claude/skills
cd ~/.claude/superpowers-plus/skills
for skill in */; do
  skill_name="${skill%/}"
  ln -sf "$HOME/.claude/superpowers-plus/skills/$skill_name" "$HOME/.claude/skills/superpowers:$skill_name"
done
```

> **Note**: Claude Code only scans direct subdirectories under `~/.claude/skills/`, so you need to create individual symlinks for each skill rather than linking the entire skills directory.

**Verify Installation:**

```bash
ls ~/.claude/skills/ | grep superpowers:
```

You should see multiple symlinks starting with `superpowers:`.

### Cursor

Currently, we recommend using the skill directory approach, exposing `skills/` to Cursor's discoverable skill path. If your Cursor environment supports repository-type skill sources, please use `xhyqaq/superpowers-plus` directly.

### Codex

Tell Codex:

```
Fetch and follow instructions from https://raw.githubusercontent.com/xhyqaq/superpowers-plus/refs/heads/main/.codex/INSTALL.md
```

**Detailed docs:** [docs/README.codex.md](docs/README.codex.md)

### OpenCode

Tell OpenCode:

```
Fetch and follow instructions from https://raw.githubusercontent.com/xhyqaq/superpowers-plus/refs/heads/main/.opencode/INSTALL.md
```

**Detailed docs:** [docs/README.opencode.md](docs/README.opencode.md)

### Gemini CLI

```bash
gemini extensions install https://github.com/xhyqaq/superpowers-plus
```

To update:

```bash
gemini extensions update superpowers-plus
```

### Verify Installation

Start a new session in your chosen platform and ask for something that should trigger a skill (for example, "help me plan this feature" or "let's debug this issue"). The agent should automatically invoke the relevant Superpowers Plus skill.

## The Basic Workflow

1. **brainstorming** - Activates before writing code. Refines rough ideas through questions, explores alternatives, presents design in sections for validation. Saves design document.

2. **using-git-worktrees** - Activates after design approval. Creates isolated workspace on new branch, runs project setup, verifies clean test baseline.

3. **writing-plans** - Activates with approved design. Breaks work into bite-sized tasks (2-5 minutes each). Every task has exact file paths, complete code, verification steps.

4. **executing-plans** - Activates with plan. Automatically dispatches parallel subagents when tasks are independent, serial subagents when they are coupled, and keeps review checkpoints inside the workflow.

5. **test-driven-development** - Activates during implementation. Enforces RED-GREEN-REFACTOR: write failing test, watch it fail, write minimal code, watch it pass, commit. Deletes code written before tests.

6. **requesting-code-review** - Activates between tasks. Reviews against plan, reports issues by severity. Critical issues block progress.

7. **finishing-a-development-branch** - Activates when tasks complete. Verifies tests, presents options (merge/PR/keep/discard), cleans up worktree.

**The agent checks for relevant skills before any task.** Mandatory workflows, not suggestions.

## What's Inside

### Skills Library

**Testing**
- **test-driven-development** - RED-GREEN-REFACTOR cycle (includes testing anti-patterns reference)

**Debugging**
- **systematic-debugging** - 4-phase root cause process (includes root-cause-tracing, defense-in-depth, condition-based-waiting techniques)
- **verification-before-completion** - Ensure it's actually fixed

**Collaboration**
- **brainstorming** - Socratic design refinement
- **writing-plans** - Detailed implementation plans
- **executing-plans** - Automatic parallel/serial subagent routing with in-flow review checkpoints
- **dispatching-parallel-agents** - Concurrent subagent workflows
- **requesting-code-review** - Pre-review checklist
- **receiving-code-review** - Responding to feedback
- **using-git-worktrees** - Parallel development branches
- **finishing-a-development-branch** - Merge/PR decision workflow

**Meta**
- **writing-skills** - Create new skills following best practices (includes testing methodology)
- **using-superpowers** - Introduction to the skills system
- **reusable-assets-index** - Manage reusable code/component documentation in AGENTS.md/CLAUDE.md indexes

## Philosophy

- **Test-Driven Development** - Write tests first, always
- **Systematic over ad-hoc** - Process over guessing
- **Complexity reduction** - Simplicity as primary goal
- **Evidence over claims** - Verify before declaring success

If you want to learn about the original philosophy, you can check the upstream Superpowers related articles. However, the installation, behavior, and execution model of this repository are governed by the documentation here.

## Contributing

Skills live directly in this repository. To contribute:

1. Fork the repository
2. Create a branch for your skill
3. Follow the `writing-skills` skill for creating and testing new skills
4. Submit a PR

See `skills/writing-skills/SKILL.md` for the complete guide.

## Updating

Skills update automatically when you update the cloned repository:

```bash
cd ~/.claude/superpowers-plus && git pull
```

## License

MIT License - see LICENSE file for details

## Support

- **Repository**: https://github.com/xhyqaq/superpowers-plus
- **Issues**: https://github.com/xhyqaq/superpowers-plus/issues
