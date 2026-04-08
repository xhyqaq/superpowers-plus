---
name: distilling-lessons
description: Use when a bug fix, architectural change, interface contract update, or recurring pitfall has been resolved and has clear reuse value — to record a durable lesson in project memory before the context is lost
---

# Distilling Lessons

## Overview

**Every insight fades. Write it down before the context window closes.**

The goal is not to have a record — it is to never repeat the same mistake. Record only when the lesson is genuinely reusable, and always anchor it to the git commit that proves the fix worked.

**Core principle:** A lesson that cannot be acted on by a future agent reading it cold is not worth writing.

## When to Use

Use when **all three** of the following are true:

1. The work involved a non-obvious problem, decision, or pattern
2. The insight would change how you or another agent approaches a similar situation in the future
3. There is a resolved git commit to anchor the lesson to

**High-signal scenarios:**
- Bug fixed where the root cause took investigation (not an obvious typo)
- Architectural decision made with real trade-offs considered
- Interface contract, data schema, or state management convention changed
- A pitfall you hit before, or one that is easy to repeat

**Skip when:**
- The change was mechanical (wording, styling, routine feature by existing pattern)
- No new knowledge was gained — you just did it
- There is no committed state to anchor the lesson to
- The insight is too project-specific to apply anywhere else

## Judgment Gate

Ask yourself: **"Would a fresh agent, reading this lesson cold, make a different decision?"**

| Signal | Record? |
|--------|---------|
| Root cause was non-obvious | Yes |
| Solution required investigation | Yes |
| Pattern will recur in this codebase | Yes |
| Same mistake could be made again | Yes |
| Mechanical change by existing pattern | No |
| Obvious fix, no discovery involved | No |
| No committed state yet | No |

## The Process

### Step 1: Confirm there is a committed state

```bash
git log -1 --format='%H %s'
```

If nothing is committed, finish the commit first. The lesson must be anchored to real work.

### Step 2: Apply the Judgment Gate

If the gate returns **No**, stop here. Do not record.

### Step 3: Identify the target directory

Lessons go in the project's memory directory:

```
docs/superpowers/memory/lessons/
```

If the directory does not exist, create it before writing.

### Step 4: Write the lesson file

Use the template in `references/lesson-template.md`.

File name: short, stable, hyphen-separated description of the problem — not the solution.

```
# Good names (problem-focused, stable)
avoid-mock-timing-in-integration-tests.md
always-migrate-schema-before-seeding.md
check-env-var-scope-before-injecting.md

# Bad names (solution-focused, vague)
fix-for-test-issue.md
bug-fix-2024.md
lesson-learned.md
```

### Step 5: Update the index

If `docs/superpowers/memory/index.md` exists, add or update the lessons section with a one-line entry pointing to the new file.

If the index does not exist, do not create it just for this — note the gap instead.

## Output Format

Follow the template in `references/lesson-template.md`.

The `last_verified_commit` field is **mandatory**. A lesson without a commit hash is unverifiable and not trustworthy.

## Common Rationalizations

| Rationalization | Reality |
|-----------------|---------|
| "The commit message is enough" | Commit messages say *what* changed. Lessons say *why it was non-obvious* and *how to avoid it next time*. They serve different purposes. |
| "I'll add the commit hash later" | Later never comes. A lesson without a hash is unverifiable — it claims knowledge without evidence. Finish the commit first. |
| "I'll write a quick note and formalize next session" | NOTES.md is a graveyard. Context will be gone, the note will never be opened, and the insight will be lost exactly as if you hadn't written it. Either write the lesson properly now, or don't write it at all. |
| "It seems obvious now that I know it" | That feeling is the trap. You found it obvious *after* 45 minutes of investigation. A future agent starts at zero. |
| "The working code is documentation enough" | Code shows the solution. It does not show the failure mode, the non-obvious root cause, or the pattern that caused the problem. |
| "It's too project-specific to be reusable" | If the *same mistake* can recur in this project, the lesson belongs in this project's memory. |

## Red Flags

**Over-recording:**
- Writing a lesson after every commit "just in case"
- Recording lessons with vague rules like "be careful with async code"
- Lessons that duplicate what is already in CLAUDE.md or AGENTS.md

**Under-recording:**
- Closing a complex bug and moving on immediately
- Thinking "I'll remember this" after a painful investigation
- Skipping because "it seems obvious now that I know it"
- Writing a "quick note" in NOTES.md instead of a real lesson doc

**Bad lessons:**
- No `last_verified_commit` field
- Rule so general it applies to everything ("test your code")
- Situation description too vague to recognize on re-encounter
- "When NOT to Apply" section missing, leaving the rule over-broad

## Integration

**Called after:**
- `systematic-debugging` — when a root cause was found and fixed
- `finishing-a-development-branch` — during the memory gate step
- `curating-repository-memory` — as a complement for lesson-type docs

**Pairs with:**
- `curating-repository-memory` for broader memory updates (module cards, decisions, contracts)
- `bootstrapping-repository-memory` when lessons directory does not yet exist

**Does NOT replace:**
- `curating-repository-memory` for module cards, contracts, or decisions
- CLAUDE.md / AGENTS.md for project-level conventions that apply to all future work
