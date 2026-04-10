# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repository Is

**Superpowers Plus** is a workflow skill library for AI coding agents (Claude Code, Codex, OpenCode, Gemini CLI). It implements a unified design → plan → execute → verify workflow. This is not a buildable application — it's a collection of skill modules (each a directory with a `SKILL.md`) that are installed into agent environments via symlinks or plugin installers.

## Running Tests

```bash
# Run all fast skill tests
tests/claude-code/run-skill-tests.sh

# Run integration tests (10-30 min)
tests/claude-code/run-skill-tests.sh --integration

# Run a single test
tests/claude-code/run-skill-tests.sh --test test-executing-plans.sh

# Verbose output
tests/claude-code/run-skill-tests.sh --verbose
```

Tests are bash scripts under `tests/claude-code/`. See `docs/testing.md` for the full guide.

## Architecture

### Skill Structure

Each skill lives in `skills/<skill-name>/` and contains:
- `SKILL.md` — the instruction document loaded by the agent (frontmatter: `name`, `description`)
- Optional `references/`, `examples/`, scripts

Skills are the unit of deployment. When a user installs superpowers-plus, the `skills/` directory gets symlinked/copied into their agent's skill path.

### Core Workflow Skills (in order)

The workflow enforces a strict progression:

1. **brainstorming** — Socratic design refinement; blocks implementation until spec is approved
2. **using-git-worktrees** — Isolated branch/worktree setup before any coding
3. **writing-plans** — Decompose work into 2-5 minute atomic tasks
4. **executing-plans** — Routes tasks to subagents (parallel for independent, serial for dependent)
5. **test-driven-development** — RED → GREEN → REFACTOR cycle; no production code without failing test first
6. **verification-before-completion** — Run verification before claiming anything is done
7. **finishing-a-development-branch** — Guides merge/PR/cleanup decision

### Execution Model

`executing-plans` is the central router:
- Main agent orchestrates; ALL implementation goes to subagents (context preservation principle)
- Subagents default to lower-capability models (Haiku/Flash), upgraded only on failure
- Task granularity: each task = one RED-GREEN-REFACTOR cycle (~2-5 min)

### Plugin Infrastructure

Each platform has its own integration:
- `.claude-plugin/` — Claude Code (install via `install.sh`)
- `.codex/` — Codex App (see `.codex/INSTALL.md`)
- `.opencode/` — OpenCode (see `.opencode/INSTALL.md`)
- `.cursor-plugin/` — Cursor
- `hooks/hooks.json` — Claude Code hook definitions (SessionStart fires `using-superpowers`)
- `gemini-extension.json` — Gemini CLI extension manifest

### Documentation Layout

- `docs/superpowers/specs/YYYY-MM-DD-<topic>-design.md` — design specifications
- `docs/superpowers/plans/YYYY-MM-DD-<feature>.md` — implementation plans
- `docs/superpowers/reuse/` — reusable component docs
- `RELEASE-NOTES.md` — detailed version history

## Adding or Modifying Skills

When creating a new skill, use the `writing-skills` skill — it enforces the correct SKILL.md format and validates the skill before deployment. The frontmatter fields (`name`, `description`) must match what gets registered in the agent's skill index.

When modifying an existing skill's behavior, check `tests/claude-code/` for a corresponding test file and run it after changes.

## Key Conventions

- **Iron Law (TDD):** If production code exists without a failing test, delete it and start fresh.
- **Iron Law (Debugging):** No fixes without root cause investigation. Use `systematic-debugging` before proposing any fix.
- **Self-review:** Skills use inline checklists (not subagent review loops) — faster and sufficient for most changes.
- **Commits:** Granular, after each RED-GREEN-REFACTOR cycle.
- **Plans:** Stored in `docs/superpowers/plans/` following the date-prefixed naming convention.
