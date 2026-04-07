---
name: curating-repository-memory
description: Use when a delivery cycle produced durable knowledge that should be preserved in canonical repository memory
---

# Curating Repository Memory

## Overview

Turn durable insights from requirements, design, implementation, and review into canonical repository memory.

**Core principle:** Preserve durable knowledge, not work logs.

This skill chooses the right memory document type and updates existing memory before creating new noise.

## When to Use

Use when:
- a delivery cycle created durable knowledge worth preserving
- a major refactor changed module boundaries or contracts
- a review revealed a stable recurring pitfall
- a team wants to backfill durable memory from existing specs, plans, designs, or reviews

Do not use when:
- ephemeral task notes
- raw implementation logs
- purely local trivia that has no future reuse value

## The Process

Inputs this skill can consume:

- `spec_path`
- `context_path` when available
- `design_path` when available
- `plan_path`
- `plan_review_path` when available
- `code_review_path` when available
- changed paths or diff range
- at least one formal commit id
- existing repository memory docs

1. Read the current cycle artifacts and existing memory in the affected area.
2. Identify durable candidates worth preserving.
3. Pick the right doc type deliberately.
4. Update existing docs before creating new files.
5. Record doc gaps, rejected candidates, and uncertainties explicitly.
6. Save a memory update report.

Choose doc types deliberately:

- **module card**: reusable module boundary, responsibility split, or entrypoint map changed
- **contract doc**: state rule, schema, interface, producer-consumer rule, or compatibility constraint changed
- **decision**: a non-obvious technical choice with future reuse value was made
- **runbook**: a verification, rollout, migration, or recovery sequence became reusable
- **lesson**: a stable cross-task rule or recurring pitfall deserves a durable reminder

## Quality Bar

- Prefer updating existing docs over creating duplicates.
- Tie every durable update back to at least one formal commit id.
- Keep doc gaps explicit instead of hiding them.
- Do not promote claims that cannot be tied to concrete artifacts.
- Return `no_memory_update` when nothing truly durable qualifies.

## Outputs

Write or update canonical docs under `docs/forgeflow/memory/` and save a report under `docs/forgeflow/memory/reports/`.
Use [memory-doc-types.md](references/memory-doc-types.md), [memory-update-report-template.md](references/memory-update-report-template.md), and [return-contract.md](references/return-contract.md).

## Integration

- Usually runs after implementation and review, before branch-finishing work
- Usually invoked after `executing-plans`, code review, or debugging work produced durable knowledge
- Updates the canonical memory initialized by `bootstrapping-repository-memory`
- Should run before `finishing-a-development-branch` presents merge or cleanup options when the cycle changed stable module boundaries, contracts, decisions, runbooks, or lessons
