---
name: reviewer
description: Use when all implementation subagents have finished and the completed code needs a consolidated post-implementation review for spec alignment and code quality before branch completion
---

# Reviewer

## Overview

Run one consolidated post-implementation review loop. The main agent remains the only controller. Reviewer and fixer work happen in subagents, and no subagent may spawn another subagent.

**Core principle:** Finish implementation first, then review the full change set against both the spec and the code quality bar, then route accepted fixes back through the main agent.

**Announce at start:** "I'm using the reviewer skill to review the completed implementation."

## Preconditions

Only use this skill when:
- All planned implementation subagents have finished
- Required implementation verification commands have already passed
- The main agent has the plan path, the spec or approved requirements source, and the review diff range

Do not use this skill:
- After only one implementation subagent finishes
- To review a spec document before coding starts
- To let a reviewer directly edit files

## Required Inputs

Before dispatching reviewer subagents, gather:
- `PLAN_FILE`
- `SPEC_FILE` if the plan references one; otherwise the approved requirements source
- `REVIEW_BASE_SHA`
- `HEAD_SHA`
- A short summary of what was implemented
- The verification commands already run by implementation subagents

## The Review Loop

1. Spawn the spec-alignment reviewer subagent with the highest-capability review model available on the platform.
2. Spawn the code-quality reviewer subagent with the highest-capability review model available on the platform.
3. Wait for both reviewer results and merge their findings in the main agent.
4. Evaluate findings in the main agent:
   - Accept, reject, or defer each finding
   - Never let a reviewer decide implementation on its own
5. If accepted `Critical` or `Important` findings require code changes:
   - Spawn one or more fixer subagents from the main agent
   - Pass only the accepted findings, allowed files, and verification commands
   - Run verification after each fix batch returns
   - Re-run both reviewer profiles on the updated range
6. Exit the skill only when:
   - No accepted `Critical` issues remain
   - No accepted `Important` issues remain
   - Remaining feedback is explicitly deferred `Minor` feedback

## Hard Boundaries

- Reviewer subagents are read-only.
- Fixer subagents may edit files, but they do not spawn more subagents.
- The main agent is the only controller allowed to spawn reviewer or fixer subagents.
- Review happens on the whole implementation range, not one subagent result at a time.

## Dispatch Pattern

### Spec Alignment Reviewer

Use the prompt template at `spec-alignment-reviewer-prompt.md`.

### Code Quality Reviewer

Use the prompt template at `code-quality-reviewer-prompt.md`.

### Fixer Subagent

Dispatch a standard worker subagent with:
- Accepted findings only
- Exact file paths it may touch
- The required verification commands
- An instruction that it must not spawn more subagents

## Output Contract

The main agent should summarize:
- Spec alignment findings
- Code quality findings
- Accepted fixes dispatched
- Verification results
- Whether another review round is required

## Red Flags

- Triggering review before all implementation subagents finish
- Letting reviewer subagents edit code
- Letting fixer subagents spawn reviewer subagents
- Running only code-quality review and skipping spec alignment
- Using only the latest commit instead of the full implementation range

## Integration

- `executing-plans` should invoke this skill after all implementation batches finish
- `finishing-a-development-branch` should only run after this skill exits cleanly
