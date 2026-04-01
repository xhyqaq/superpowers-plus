---
name: reusable-assets-index
description: Use when code, components, functions, or patterns are clearly reusable and should be recorded in AGENTS.md or CLAUDE.md indexes and documented under docs/superpowers/reuse/<name>.
---

# Reusable Assets Index

## Overview

This skill manages repository-owned reusable asset documentation. Core
principle: when existing code or newly generated code is clearly reusable, the
repository should capture it in a lightweight instruction-file index and keep
the detailed guidance under `docs/superpowers/reuse/<name>/`.

## When to Use

- Existing code, components, functions, or patterns are clearly reusable and
  should be discoverable later
- Newly generated code has become a reusable asset and should be documented
- The user asks to initialize reusable asset indexes
- The user asks to add or update entries such as `toast` or `lock`
- `AGENTS.md` or `CLAUDE.md` needs a reusable asset index block
- A reusable asset doc directory must be created or refreshed under
  `docs/superpowers/reuse/`

Do not use this skill to define how agents read those docs during coding. Do
not use it as a general code reuse enforcement skill.

## Scope

Stay scoped to these surfaces only:

- `AGENTS.md`
- `CLAUDE.md`
- `docs/superpowers/reuse/<name>/`

This skill owns initialization, incremental updates, and reusable-asset
capture. It does not own runtime lookup behavior or full-repository reuse
audits unless the user explicitly asks for those.

## Delegation

Dispatch all work in this skill to **Beaver**, a subagent invoked via the
Agent tool with `model: "haiku"`. Pass the full task context (asset name,
relevant file paths, language signal). Beaver handles all file writes and the
git commit. The main agent only invokes Beaver and reports the result.

## Rules

1. Trigger when code is clearly reusable or when the user asks to initialize or
   incrementally update reusable asset docs.
2. When newly generated code is obviously reusable, record it instead of
   leaving it undocumented.
3. Limit changes to initialization, reusable-asset capture, or the requested
   incremental update. Do not reorganize unrelated reusable asset entries.
4. Instruction-file indexes must contain only reusable asset labels plus
   directory paths. Do not place code snippets, long explanations, or file
   paths in the index.
5. Store detailed reusable asset docs under
   `docs/superpowers/reuse/<name>/README.md` by default.
6. Use kebab-case for `<name>` directory names. Keep user-facing labels such as
   `lock` or `toast` in the index entry text when needed.
7. If both `AGENTS.md` and `CLAUDE.md` exist for the same repository, keep the
   reusable asset index structure aligned across both files unless the user
   asks for a platform-specific difference.
8. Each reusable asset doc should record only minimum truthful information:
   purpose, implementation entry points, preferred reuse surfaces, extension
   points, and anti-duplication notes. Leave explicit gap notes instead of
   inventing missing project facts.
9. Do not define or modify how coding sessions should consume these docs. This
   skill only maintains the index and documentation surfaces.
10. Match the language of generated documentation to the language already used
    in the project's existing docs (README, CLAUDE.md, AGENTS.md, docs/).
    When no signal is found, default to English.
11. After all index and asset doc changes are written, stage and commit them
    with a concise message such as
    `docs: add reusable asset index for <name>`. Do not skip this step.

## Index Format

Use a dedicated reusable asset block. Keep entries short and directory-level
only:

```md
# Reusable Asset Index

## UI Interaction
- `toast`: `docs/superpowers/reuse/toast/`
- `modal`: `docs/superpowers/reuse/modal/`

## Concurrency
- `lock`: `docs/superpowers/reuse/lock/`
```

## Asset Doc Skeleton

Default file: `docs/superpowers/reuse/<name>/README.md`

Use this minimum shape:

```md
# <asset-name>

## Purpose

## Existing Implementation Locations

## Preferred Reuse Entry Points

## Allowed Extension Paths

## Anti-Duplication Notes
```

Add more files inside the asset directory only when the repository already
needs them.

## Quick Reference

| Concern | Policy |
|---------|--------|
| Trigger mode | Implicit or explicit |
| Index location | `AGENTS.md` / `CLAUDE.md` |
| Detail location | `docs/superpowers/reuse/<name>/` |
| Index entry detail | Label + directory path only |
| Default detail file | `README.md` |
| Ownership | Initialization, incremental updates, and reusable-asset capture |

## Common Mistakes

- Writing the full reusable asset rules into `AGENTS.md` or `CLAUDE.md`
- Storing file-level paths instead of asset directory paths in the index
- Seeing clearly reusable code and failing to record it
- Reorganizing every reusable asset entry when the user asked for one small
  incremental update
- Inventing implementation details instead of marking gaps explicitly
