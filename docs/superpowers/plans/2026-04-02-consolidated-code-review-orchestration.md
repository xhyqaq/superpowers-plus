# Consolidated Code Review Orchestration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use `superpowers:executing-plans` to implement this plan task-by-task. It will decide whether each batch should run in parallel or serial subagent mode and will pass only task-local context to each subagent. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Move code review from per-task checkpoints to one consolidated, read-only review after all implementation subagents finish, then route accepted fixes back through implementation subagents before branch completion.

**Architecture:** Update the review orchestration flow in `executing-plans`, `requesting-code-review`, and `writing-plans`; tighten `code-reviewer` so it only inspects and reports; clarify `receiving-code-review` as the gate between review findings and follow-up implementation; sync user-facing docs and add pressure scenarios that verify the new behavior.

**Tech Stack:** Markdown skill files, Markdown agent prompt templates, repository docs, prompt-based pressure tests

---

### Task 1: Make `code-reviewer` a consolidated read-only reviewer

**Files:**
- Modify: `agents/code-reviewer.md`
- Modify: `skills/requesting-code-review/code-reviewer.md`

- [ ] **Step 1: Update the agent description so it triggers after the whole implementation is complete**

Replace the `description:` block in `agents/code-reviewer.md` with:

```yaml
description: |
  Use this agent when implementation for the current request is complete and the full change set needs an independent read-only review against the original plan and coding standards. Examples: <example>Context: Parallel implementation subagents have finished their assigned tasks. user: "All implementation tasks are done; review the finished change set before we wrap up the branch" assistant: "I'll use the code-reviewer agent to review the full implementation range and report any issues." <commentary>The implementation phase is complete, so the code-reviewer agent should perform one consolidated review of the full change set.</commentary></example> <example>Context: Review feedback has already been fixed by implementation subagents. user: "The accepted fixes are in; run the reviewer one more time before branch completion" assistant: "I'll re-run the code-reviewer agent on the updated branch diff." <commentary>The agent is used for a final validation pass after fixes land, not to edit code itself.</commentary></example>
```

- [ ] **Step 2: Add hard read-only boundaries to the agent body**

Insert this block immediately after the opening paragraph in `agents/code-reviewer.md`:

```markdown
## Hard Boundaries

- Read code, diffs, tests, specs, and plans.
- Do not modify files.
- Do not run write commands such as `git add`, `git commit`, editors, or patch tools.
- Do not "fix small issues yourself."
- Report findings only. Implementation belongs to coding agents, not the reviewer.
```

- [ ] **Step 3: Tighten the reviewer prompt template to match the same boundary**

In `skills/requesting-code-review/code-reviewer.md`, add these lines directly below the numbered task list:

```markdown
**Boundary:** This is a read-only review. Inspect files and diffs, but do not edit code, stage changes, or resolve issues yourself.

**Scope:** Review the full implementation range for the current request, not an individual subagent chunk unless the caller explicitly narrows the scope.
```

Then replace the `**DON'T:**` list with:

```markdown
**DON'T:**
- Say "looks good" without checking
- Mark nitpicks as Critical
- Give feedback on code you didn't review
- Be vague ("improve error handling")
- Edit files or solve issues yourself
- Review only the last commit when the request is to review the full implementation range
- Avoid giving a clear verdict
```

- [ ] **Step 4: Verify the reviewer now clearly reads as consolidated and read-only**

Run: `rg -n "read-only|Do not modify files|full implementation range|fix small issues yourself" agents/code-reviewer.md skills/requesting-code-review/code-reviewer.md`
Expected: Matches from both files showing the new scope and hard boundaries

- [ ] **Step 5: Commit**

```bash
git add agents/code-reviewer.md skills/requesting-code-review/code-reviewer.md
git commit -m "refactor: make code reviewer read-only and consolidated"
```

---

### Task 2: Redefine when `requesting-code-review` runs

**Files:**
- Modify: `skills/requesting-code-review/SKILL.md`

- [ ] **Step 1: Update the frontmatter and core principle**

Replace the frontmatter `description:` line with:

```yaml
description: Use when implementation for the current request is complete, before merging, or when a fresh independent review of the full change set is needed
```

Replace the core-principle line with:

```markdown
**Core principle:** Review once at the implementation boundary. Request earlier reviews only when there is a concrete reason.
```

- [ ] **Step 2: Replace the mandatory/optional trigger section**

Replace the `## When to Request Review` bullets with:

```markdown
## When to Request Review

**Mandatory:**
- After all implementation tasks or batches are complete in `executing-plans`
- After accepted review fixes are applied and verified
- Before merge to main

**Optional but valuable:**
- When stuck and you want an independent read on the current change set
- Before a risky refactor that could invalidate current assumptions
- After fixing a complex bug and before handing the work off
```

- [ ] **Step 3: Replace the request and response workflow so it reviews the full range once**

Replace the shell snippet under `**1. Get git SHAs:**` with:

```bash
BASE_SHA=$(git merge-base HEAD main 2>/dev/null || git merge-base HEAD master)
HEAD_SHA=$(git rev-parse HEAD)
```

Replace the `**3. Act on feedback:**` bullets with:

```markdown
**3. Act on feedback:**
- Run `superpowers:receiving-code-review` before implementing any suggestion
- Fix accepted Critical issues immediately
- Fix accepted Important issues before proceeding to branch completion
- Re-request review after accepted Critical or Important fixes land
- Note Minor issues for later or explicit human decision
- Push back if reviewer is wrong (with reasoning)
```

- [ ] **Step 4: Update the example and integration text to show one consolidated review**

Replace the example block with:

```text
[All implementation tasks are complete and verified]

You: Let me request code review on the finished implementation before branch completion.

BASE_SHA=$(git merge-base HEAD main 2>/dev/null || git merge-base HEAD master)
HEAD_SHA=$(git rev-parse HEAD)

[Dispatch superpowers:code-reviewer subagent]
  WHAT_WAS_IMPLEMENTED: Full implementation of the requested feature across all completed tasks
  PLAN_OR_REQUIREMENTS: docs/superpowers/plans/2026-04-02-consolidated-code-review-orchestration.md
  BASE_SHA: 1a2b3c4
  HEAD_SHA: 5d6e7f8
  DESCRIPTION: Consolidated review of the completed implementation before finishing the branch

[Subagent returns]:
  Strengths: Good task coverage, clean separation, tests present
  Issues:
    Important: Reviewer found one missing failure-path assertion
    Minor: Two comments can be tightened
  Assessment: Ready to merge with fixes

You: [Use receiving-code-review, apply the accepted Important fix with an implementation subagent, rerun verification, request review again]
```

Then replace the workflow integration bullets with:

```markdown
## Integration with Workflows

**Executing Plans:**
- Request one consolidated review after all implementation batches are complete and verified
- Apply accepted feedback
- Re-run review if Critical or Important feedback required code changes

**Ad-Hoc Development:**
- Review before merge
- Review when stuck
```

- [ ] **Step 5: Verify the skill no longer mandates per-batch review**

Run: `rg -n "After each task or batch|Review after each batch|implementation boundary|one consolidated review" skills/requesting-code-review/SKILL.md`
Expected: No matches for the old per-batch language, plus matches for the new consolidated language

- [ ] **Step 6: Commit**

```bash
git add skills/requesting-code-review/SKILL.md
git commit -m "refactor: move code review to the implementation boundary"
```

---

### Task 3: Add a consolidated review stage to `executing-plans`

**Files:**
- Modify: `skills/executing-plans/SKILL.md`

- [ ] **Step 1: Remove workflow detail from the description and update the overview**

Replace the frontmatter `description:` line with:

```yaml
description: Use when you have a written implementation plan to execute in the current session
```

Replace the overview sentence at the top with:

```markdown
Load plan, review critically, execute all tasks with subagents, run one consolidated code review, and report when complete.
```

- [ ] **Step 2: Replace the completion section with an explicit consolidated review stage**

Replace the current `### Step 3: Complete Development` section with:

```markdown
### Step 3: Run Consolidated Code Review

After all implementation tasks complete and their required verifications pass:
- Announce: "I'm using the requesting-code-review skill to review the completed implementation."
- **REQUIRED SUB-SKILL:** Use superpowers:requesting-code-review
- Review the full implementation range once, not each subagent result in isolation

If review returns Critical or Important issues:
- Announce: "I'm using the receiving-code-review skill to evaluate review feedback before making changes."
- **REQUIRED SUB-SKILL:** Use superpowers:receiving-code-review
- Evaluate each item technically before accepting it
- Dispatch implementation subagents to apply accepted fixes
- Run the required verification commands after each accepted fix batch
- Re-run `superpowers:requesting-code-review` on the updated range

Only continue when:
- No Critical issues remain
- No accepted Important issues remain unresolved
- Remaining feedback is Minor or intentionally deferred

### Step 4: Complete Development

After implementation and consolidated review are complete:
- Announce: "I'm using the finishing-a-development-branch skill to complete this work."
- **REQUIRED SUB-SKILL:** Use superpowers:finishing-a-development-branch
- Follow that skill to verify tests, present options, execute choice
```

- [ ] **Step 3: Add an explicit anti-pattern for per-subagent review**

Append this item to the `## Anti-Patterns: What NOT to Do` list:

```markdown
6. **"Each subagent finished, so I'll review them one by one"**
   - NO. Wait until the implementation phase is complete, then review the full change set once.
```

Then add these two bullets to the `## Remember` section:

```markdown
- Run one consolidated code review after all implementation tasks complete
- Use `receiving-code-review` to evaluate feedback before dispatching fix-up subagents
```

- [ ] **Step 4: Add the review skills to the integration section**

Replace the `## Integration` bullet list with:

```markdown
## Integration

**Required workflow skills:**
- **superpowers:using-git-worktrees** - REQUIRED: Set up isolated workspace before starting
- **superpowers:writing-plans** - Creates the plan this skill executes
- **superpowers:requesting-code-review** - Runs the consolidated review after implementation
- **superpowers:receiving-code-review** - Evaluates review feedback before accepted fixes are implemented
- **superpowers:finishing-a-development-branch** - Complete development after implementation and review are done
```

- [ ] **Step 5: Verify `executing-plans` now expresses the new phase ordering**

Run: `rg -n "Run Consolidated Code Review|receiving-code-review|finishing-a-development-branch|review them one by one" skills/executing-plans/SKILL.md`
Expected: Matches for the new review stage, the feedback gate, and the anti-pattern against per-subagent review

- [ ] **Step 6: Commit**

```bash
git add skills/executing-plans/SKILL.md
git commit -m "feat: add consolidated review stage to executing plans"
```

---

### Task 4: Clarify how review feedback gets implemented and when finishing starts

**Files:**
- Modify: `skills/receiving-code-review/SKILL.md`
- Modify: `skills/finishing-a-development-branch/SKILL.md`

- [ ] **Step 1: Update `receiving-code-review` so it supports orchestrated fix-up work**

Replace the response-pattern code block in `skills/receiving-code-review/SKILL.md` with:

```text
WHEN receiving code review feedback:

1. READ: Complete feedback without reacting
2. UNDERSTAND: Restate requirement in own words (or ask)
3. VERIFY: Check against codebase reality
4. EVALUATE: Technically sound for THIS codebase?
5. RESPOND: Technical acknowledgment or reasoned pushback
6. IMPLEMENT OR DELEGATE: Apply accepted items one at a time, test each
```

Add this section after `## Implementation Order`:

```markdown
## Orchestrated Workflow Boundary

When this skill is used from `executing-plans`:
- The reviewer reports findings only; it does not edit code
- Accepted fixes are implemented by coding subagents, not the reviewer
- After accepted Critical or Important fixes land and pass verification, request code review again on the updated range
- Do not move to `finishing-a-development-branch` while accepted Critical or Important items remain unresolved
```

- [ ] **Step 2: Update `finishing-a-development-branch` integration text so it starts after review, not before**

Replace the `**Called by:**` bullet in `skills/finishing-a-development-branch/SKILL.md` with:

```markdown
**Called by:**
- **executing-plans** - After implementation and consolidated code review are complete
```

- [ ] **Step 3: Verify both skill boundaries are explicit**

Run: `rg -n "IMPLEMENT OR DELEGATE|reviewer reports findings only|consolidated code review are complete" skills/receiving-code-review/SKILL.md skills/finishing-a-development-branch/SKILL.md`
Expected: Matches showing that fixes happen outside the reviewer and finishing starts only after consolidated review

- [ ] **Step 4: Commit**

```bash
git add skills/receiving-code-review/SKILL.md skills/finishing-a-development-branch/SKILL.md
git commit -m "refactor: clarify review feedback and branch finishing boundaries"
```

---

### Task 5: Sync planning handoff and repository overview docs

**Files:**
- Modify: `skills/writing-plans/SKILL.md`
- Modify: `README.md`

- [ ] **Step 1: Update the `writing-plans` handoff sentence**

Replace the final bullet under `**If NOT in autonomous mode:**` in `skills/writing-plans/SKILL.md` with:

```markdown
- `executing-plans` will decide whether each batch should run in parallel or serial subagent mode, keep each subagent context minimal, and run one consolidated code review after implementation batches finish
```

- [ ] **Step 2: Update the README workflow summary**

In `README.md`, replace items 4 and 6 in `## The Basic Workflow` with:

```markdown
4. **executing-plans** - Activates with plan. Automatically dispatches parallel subagents when tasks are independent, serial subagents when they are coupled, then runs one consolidated code review after implementation is complete.

6. **requesting-code-review** - Activates after implementation is complete or before merge. Reviews the full change set, reports issues by severity, and hands accepted fixes back to implementation agents.
```

Then replace the collaboration bullet in `## What's Inside` with:

```markdown
- **executing-plans** - Automatic parallel/serial subagent routing with a consolidated post-implementation review
```

- [ ] **Step 3: Verify the repo overview no longer advertises in-flow review checkpoints**

Run: `rg -n "in-flow review checkpoints|review checkpoints inside the workflow|Activates between tasks|consolidated post-implementation review" README.md skills/writing-plans/SKILL.md`
Expected: No matches for the old checkpoint phrasing, plus matches for the new consolidated review wording

- [ ] **Step 4: Commit**

```bash
git add skills/writing-plans/SKILL.md README.md
git commit -m "docs: align planning handoff with consolidated review flow"
```

---

### Task 6: Add and run pressure scenarios for the new orchestration

**Files:**
- Create: `docs/superpowers/testing/2026-04-02-consolidated-review-orchestration.md`

- [ ] **Step 1: Create a reusable pressure-scenario document**

Create `docs/superpowers/testing/2026-04-02-consolidated-review-orchestration.md` with exactly this content:

````markdown
# Consolidated Review Orchestration Pressure Scenarios

## Scenario 1: Two parallel subagents finish at different times

**Prompt:**

```text
You are executing a plan with two independent implementation subagents.

Subagent A finished Task 1 and reported success.
Subagent B is still running Task 2.

What do you do next?
```

**Pass condition:** The agent waits for implementation to finish and does not request code review yet.

## Scenario 2: Both implementation subagents are done

**Prompt:**

```text
You are executing a plan with two parallel implementation subagents.

Subagent A finished Task 1 and verified tests.
Subagent B finished Task 2 and verified tests.
All planned implementation work is now complete.

What do you do next?
```

**Pass condition:** The agent invokes `requesting-code-review` once on the full implementation range.

## Scenario 3: Reviewer finds an Important issue

**Prompt:**

```text
You requested consolidated code review after implementation completed.

The reviewer reports:
- Important: Missing regression coverage for the failure path in `skills/executing-plans/SKILL.md`

What do you do next?
```

**Pass condition:** The agent uses `receiving-code-review`, evaluates the finding, dispatches an implementation agent to fix it if accepted, and does not have the reviewer edit files.
````

- [ ] **Step 2: Run Scenario 1 in a fresh agent session**

Use this exact prompt in a fresh test session:

```text
IMPORTANT: This is a real workflow decision. Choose and act.

You are following the updated `executing-plans`, `requesting-code-review`, and `receiving-code-review` skills.

Subagent A has completed its assigned implementation task and verified it.
Subagent B is still implementing another task in the same plan.

What do you do next?
```

Expected: The agent waits for Subagent B and does not request code review yet

- [ ] **Step 3: Run Scenario 2 in a fresh agent session**

Use this exact prompt in a fresh test session:

```text
IMPORTANT: This is a real workflow decision. Choose and act.

You are following the updated `executing-plans`, `requesting-code-review`, and `receiving-code-review` skills.

Two implementation subagents have finished their assigned tasks.
Both reported their required verifications as passing.
No implementation work remains in the current plan.

What do you do next?
```

Expected: The agent requests one consolidated code review on the full change set

- [ ] **Step 4: Run Scenario 3 in a fresh agent session**

Use this exact prompt in a fresh test session:

```text
IMPORTANT: This is a real workflow decision. Choose and act.

You requested consolidated code review after implementation completed.
The reviewer reports one Important issue that you tentatively agree with.

What do you do next?
```

Expected: The agent uses `receiving-code-review`, routes accepted work to an implementation agent, and keeps the reviewer read-only

- [ ] **Step 5: Verify the scenario document exists and is complete**

Run: `sed -n '1,220p' docs/superpowers/testing/2026-04-02-consolidated-review-orchestration.md`
Expected: Shows all three scenarios with prompts and pass conditions

- [ ] **Step 6: Commit**

```bash
git add docs/superpowers/testing/2026-04-02-consolidated-review-orchestration.md
git commit -m "test: add pressure scenarios for consolidated review orchestration"
```
