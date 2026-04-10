# Repository Guidelines

## Project Structure & Module Organization
This repository is documentation- and skill-first. Core skills live in `skills/<skill-name>/SKILL.md`, with supporting scripts beside them when needed. Command entry docs live in `commands/`. Long-form design and execution records belong under `docs/superpowers/specs/` and `docs/superpowers/plans/`. Platform-specific integration material lives in `.codex/`, `.claude-plugin/`, `.cursor-plugin/`, and `.opencode/`. Tests are grouped by environment in `tests/claude-code/`, `tests/opencode/`, `tests/skill-triggering/`, `tests/explicit-skill-requests/`, and `tests/brainstorm-server/`.

## Build, Test, and Development Commands
There is no single build pipeline at the repo root; validate the part you changed.

- `bash tests/claude-code/run-skill-tests.sh`: run the default Claude Code skill checks.
- `bash tests/claude-code/run-skill-tests.sh --integration`: run slow end-to-end Claude workflow tests.
- `bash tests/opencode/run-tests.sh`: run the default OpenCode plugin checks.
- `bash tests/skill-triggering/run-all.sh`: verify skill auto-triggering prompts.
- `cd tests/brainstorm-server && npm test`: run the Node-based brainstorm server test.

## Coding Style & Naming Conventions
Match the surrounding file style instead of reformatting unrelated content. JavaScript and JSON use 2-space indentation; shell scripts use `set -euo pipefail` and descriptive uppercase variables like `SCRIPT_DIR`. Keep skill folders in kebab-case, for example `skills/verification-before-completion/`. Name docs with date-prefixed kebab-case files such as `docs/superpowers/specs/2026-04-04-example-design.md`. No repo-wide formatter or linter is configured, so keep Markdown concise and shell commands copy-pasteable.

## Testing Guidelines
Add or update tests in the nearest relevant suite to the changed surface area. Shell tests should remain executable and focused on observable behavior. JavaScript tests in `tests/brainstorm-server/` use Node plus `ws`; keep filenames aligned with the existing `*.test.sh` and `*.test.js` patterns. When changing workflow behavior, prefer the targeted runner first, then the slower integration path if the change affects full execution.

## Commit & Pull Request Guidelines
Recent history uses Conventional Commit-style prefixes such as `feat:`, `refactor:`, and `docs:`. Keep subjects short and imperative, and scope them to one logical change. PRs should explain the affected skill or platform, list verification commands run, and link any related issue or design/plan doc. Include screenshots only when changing browser-facing or rendered documentation flows.

## Agent-Specific Notes
Repository-level instructions live in `CLAUDE.md`; read them before broad edits. If you add reusable patterns or project conventions, update the appropriate `docs/superpowers/reuse/` or standards documentation rather than leaving the knowledge only in code.
