# Repository Memory Doc Types

## Shared metadata

Every repository memory doc should begin with concise frontmatter.

```yaml
---
type: module_card | contract | decision | runbook | lesson
title: short-stable-title
summary: one sentence on why this doc matters
tags:
  - area
owned_paths:
  - path/pattern
related_docs:
  - docs/superpowers/memory/...
entrypoints:
  - path/to/file
last_verified_commit: abc1234
status: active | accepted | draft | superseded
---
```

Use only fields that are actually supported by the evidence.

## Module card template

- Responsibilities
- Entry points
- Invariants
- Extension points
- Common pitfalls

## Contract doc template

- Scope
- Producers and consumers
- States, schema, or interface rules
- Invariants
- Compatibility notes

## Decision template

- Context
- Decision
- Alternatives considered
- Trade-offs
- Revisit signals

## Runbook template

- Preconditions
- Step-by-step procedure
- Verification
- Rollback or recovery notes

## Lesson template

- Situation
- Why it mattered
- Rule
- When to apply
- When not to apply
