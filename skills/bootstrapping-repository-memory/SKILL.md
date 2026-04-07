---
name: bootstrapping-repository-memory
description: Use when a repository or subsystem lacks usable canonical memory and needs an initial memory baseline
---

# Bootstrapping Repository Memory

## Overview

Create the smallest useful first-pass repository memory for an older repo or an undocumented domain.

**Core principle:** Prefer a useful skeleton over fake completeness.

This skill is for initialization and backfill, not for every routine delivery cycle.

## When to Use

Use when:
- the repository has little or no canonical memory under `docs/superpowers/memory/`
- a legacy subsystem is about to receive repeated work
- context exploration shows that memory is sparse or missing
- a team wants to initialize memory manually instead of waiting for it to emerge task by task

Do not use when:
- pretending to fully document the whole repository in one pass
- replacing targeted context search for a specific task
- writing speculative design docs or unsupported contracts

## The Process

Inputs this skill can consume:
- repository-wide scope, domain scope, or a narrow path set
- current workspace or branch information
- existing repo docs, tests, and stable code paths
- hotspots or domains already identified by the main agent

1. Choose the smallest useful scope.
2. Inspect existing docs, tests, and stable code paths in that scope.
3. Create the highest-value module cards and contract docs first.
4. Create or update `docs/superpowers/memory/index.md` and obvious sub-index pages.
5. Record gaps, uncertainties, and suggested follow-up scopes in a bootstrap report.

## Quality Bar

- Prefer a useful skeleton over fake completeness.
- Prioritize module cards and contract docs first.
- Keep uncertain areas explicit.
- Add decisions or runbooks only when there is strong evidence they are already stable.
- Stop at a useful baseline instead of padding the memory set with noise.

## Outputs

Write memory docs under `docs/superpowers/memory/` and a bootstrap report under `docs/superpowers/memory/reports/`.
Use [memory-doc-types.md](references/memory-doc-types.md), [bootstrap-report-template.md](references/bootstrap-report-template.md), and [return-contract.md](references/return-contract.md).

## Integration

- Usually runs before planning or implementation when the target area lacks usable repository memory
- Usually invoked from `using-superpowers` or `brainstorming` when the target area lacks usable canonical memory
- Creates the initial memory surface that `curating-repository-memory` updates in later cycles
