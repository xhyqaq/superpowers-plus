# Unified Reviewer Skill Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use `superpowers:executing-plans` to implement this plan task-by-task. It will decide whether each batch should run in parallel or serial subagent mode and will pass only task-local context to each subagent. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the split `requesting-code-review` / `receiving-code-review` flow with one `reviewer` skill that runs only after all implementation subagents finish, checks both spec alignment and code quality, returns findings to the main agent, and lets the main agent dispatch fixer subagents before branch completion.

**Architecture:** Add a single `skills/reviewer/` skill with two internal reviewer profiles: one for spec alignment and one for code quality. `executing-plans` records a stable review base SHA before implementation starts, invokes `reviewer` only after all implementation work completes, and remains the only controller that may spawn review or fix subagents. Reviewer subagents are read-only and always run on the platform's highest-capability review model; fixer subagents are separate worker subagents launched by the main agent after accepted findings are returned.

**Tech Stack:** Markdown skill files, Markdown reviewer prompt templates, shell-based skill-triggering tests, prompt-based manual pressure scenarios

**Supersedes:** `docs/superpowers/plans/2026-04-02-consolidated-code-review-orchestration.md`

---

### Task 1: Create the unified `reviewer` skill and its internal reviewer profiles

**Files:**
- Create: `skills/reviewer/SKILL.md`
- Create: `skills/reviewer/spec-alignment-reviewer-prompt.md`
- Create: `skills/reviewer/code-quality-reviewer-prompt.md`

- [ ] **Step 1: Create `skills/reviewer/SKILL.md`**

Write `skills/reviewer/SKILL.md` with this content:

````markdown
---
name: reviewer
description: Use when all implementation subagents have finished and the completed code needs an independent review for both spec alignment and code quality before merge or branch completion
---

# Reviewer

## Overview

Run one post-implementation review loop. The main agent remains the orchestrator. Reviewer and fixer work happen in subagents, but no subagent may spawn another subagent.

**Core principle:** Finish implementation first, then review the full change set against both the spec and code quality bar, then route accepted fixes back through the main agent.

**Announce at start:** "I'm using the reviewer skill to review the completed implementation."

## Preconditions

Only use this skill when:
- All planned implementation subagents have finished
- Required implementation verification commands have already passed
- The main agent has the plan path and the review diff range

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

1. Spawn the **spec-alignment reviewer** subagent with the highest-capability review model available on the platform.
2. Spawn the **code-quality reviewer** subagent with the highest-capability review model available on the platform.
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
````

- [ ] **Step 2: Create `skills/reviewer/spec-alignment-reviewer-prompt.md`**

Write `skills/reviewer/spec-alignment-reviewer-prompt.md` with this content:

````markdown
# Spec Alignment Reviewer Prompt

You are performing a read-only review of completed implementation work.

**Your task:**
1. Compare the completed implementation against the approved spec or requirements
2. Review the full diff range, not a single subagent chunk
3. Find missing requirements, scope creep, and unjustified deviations
4. Report findings only; do not edit code

## Inputs

- Plan: {PLAN_FILE}
- Spec or requirements: {SPEC_FILE}
- Review base: {BASE_SHA}
- Review head: {HEAD_SHA}
- Implementation summary: {DESCRIPTION}
- Verification already run: {VERIFICATION_SUMMARY}

## Review Commands

```bash
git diff --stat {BASE_SHA}..{HEAD_SHA}
git diff {BASE_SHA}..{HEAD_SHA}
```

## What to Check

- All requested behavior implemented?
- Any requirement missing?
- Any behavior contradicts the spec?
- Any unapproved scope creep?
- Any architectural deviation that needs explicit justification?

## Output Format

### Spec Alignment

**Strengths**
- [specific strengths]

**Issues**

#### Critical
- [file:line, issue, why it matters, required fix]

#### Important
- [file:line, issue, why it matters, required fix]

#### Minor
- [file:line, issue, why it matters, optional improvement]

### Assessment

**Aligned with spec?** [Yes/No/With fixes]

**Reasoning:** [1-2 sentence technical assessment]

## Hard Rules

- Do not edit files
- Do not propose implementation that is not grounded in the spec
- Do not assume the implementer's summary is complete; read the diff
- Be strict about missing requirements and scope creep
````

- [ ] **Step 3: Create `skills/reviewer/code-quality-reviewer-prompt.md`**

Write `skills/reviewer/code-quality-reviewer-prompt.md` with this content:

````markdown
# Code Quality Reviewer Prompt

You are performing a read-only code review of completed implementation work.

**Your task:**
1. Review the full implementation diff range
2. Check correctness, maintainability, tests, and integration quality
3. Report findings only; do not edit code

## Inputs

- Plan: {PLAN_FILE}
- Spec or requirements: {SPEC_FILE}
- Review base: {BASE_SHA}
- Review head: {HEAD_SHA}
- Implementation summary: {DESCRIPTION}
- Verification already run: {VERIFICATION_SUMMARY}

## Review Commands

```bash
git diff --stat {BASE_SHA}..{HEAD_SHA}
git diff {BASE_SHA}..{HEAD_SHA}
```

## What to Check

- Correctness bugs or regression risk?
- Error handling and edge cases?
- Tests actually cover behavior?
- Architecture and separation of concerns?
- Any security, performance, or maintainability issues?

## Output Format

### Code Quality

**Strengths**
- [specific strengths]

**Issues**

#### Critical
- [file:line, issue, why it matters, required fix]

#### Important
- [file:line, issue, why it matters, required fix]

#### Minor
- [file:line, issue, why it matters, optional improvement]

### Assessment

**Ready to merge?** [Yes/No/With fixes]

**Reasoning:** [1-2 sentence technical assessment]

## Hard Rules

- Do not edit files
- Do not review only the latest commit when the whole range was requested
- Do not mark style nits as `Critical`
- Do not skip reading the diff
````

- [ ] **Step 4: Verify the new skill scaffold exists**

Run: `rg -n "name: reviewer|Spec Alignment Reviewer Prompt|Code Quality Reviewer Prompt" skills/reviewer`
Expected: Matches in all three new files

- [ ] **Step 5: Commit**

```bash
git add skills/reviewer/SKILL.md skills/reviewer/spec-alignment-reviewer-prompt.md skills/reviewer/code-quality-reviewer-prompt.md
git commit -m "feat: add unified reviewer skill and reviewer prompts"
```

---

### Task 2: Make `executing-plans` hand off to `reviewer` after implementation completes

**Files:**
- Modify: `skills/executing-plans/SKILL.md`
- Modify: `skills/writing-plans/SKILL.md`
- Modify: `skills/finishing-a-development-branch/SKILL.md`

- [ ] **Step 1: Update `skills/executing-plans/SKILL.md` description, model strategy, and process**

Make these changes in `skills/executing-plans/SKILL.md`:

1. Replace the frontmatter description with:

```yaml
description: Use when you have a written implementation plan to execute in the current session
```

2. Replace the overview sentence with:

```markdown
Load plan, review critically, execute all implementation tasks with subagents, run one consolidated post-implementation review loop, and report when complete.
```

3. In `## Model Strategy`, replace the default model bullets with:

```markdown
**Default implementation subagent models (by platform):**
- **Claude Code**: lower-tier execution model
- **Codex**: `gpt-5.3` or equivalent lower-tier model
- **Gemini**: `gemini-1.5-flash` or `gemini-2.0-flash-exp`
- **Other platforms**: Use the lowest-capability model tier available

**Reviewer exception:**
- Reviewer subagents always use the highest-capability review model available on the platform
- In Codex, use `gpt-5.4`
- In other platforms, use the current highest-tier review model configured there
```

4. Add this bullet under `### Step 2: Execute Tasks`, before the per-batch loop:

```markdown
- Record `REVIEW_BASE_SHA=$(git rev-parse HEAD)` before dispatching the first implementation batch so the full implementation range is stable.
```

5. Replace `### Step 3: Complete Development` with:

```markdown
### Step 3: Review Completed Implementation

After all implementation tasks complete and their required verification commands pass:
- Announce: "I'm using the reviewer skill to review the completed implementation."
- **REQUIRED SUB-SKILL:** Use `superpowers:reviewer`
- Pass the full implementation range from `REVIEW_BASE_SHA` to `HEAD`
- Pass the plan path and the spec path or approved requirements source

If the reviewer loop returns accepted `Critical` or `Important` findings:
- Dispatch fixer subagents from the main agent
- Run the required verification commands after each accepted fix batch
- Re-run `superpowers:reviewer`

Only continue when no accepted `Critical` or `Important` findings remain.

### Step 4: Complete Development

After implementation and review are complete:
- Announce: "I'm using the finishing-a-development-branch skill to complete this work."
- **REQUIRED SUB-SKILL:** Use superpowers:finishing-a-development-branch
- Follow that skill to verify tests, present options, execute choice
```

6. Add this anti-pattern:

```markdown
6. **"One implementation subagent finished, so I'll review now"**
   - NO. Wait until all planned implementation work is done, then review the whole change set once.
```

7. Add these bullets under `## Remember`:

```markdown
- Record a stable `REVIEW_BASE_SHA` before implementation begins
- Review only after all implementation subagents finish
- The main agent, not a subagent, controls the review and fix loop
```

8. Replace the integration list with:

```markdown
## Integration

**Required workflow skills:**
- **superpowers:using-git-worktrees** - REQUIRED: Set up isolated workspace before starting
- **superpowers:writing-plans** - Creates the plan this skill executes
- **superpowers:reviewer** - Runs the post-implementation review loop
- **superpowers:finishing-a-development-branch** - Complete development after implementation and review are done
```

- [ ] **Step 2: Update `skills/writing-plans/SKILL.md` so plans carry a stable spec reference**

Make these changes in `skills/writing-plans/SKILL.md`:

1. In the required plan header example, insert this line between `**Architecture:**` and `**Tech Stack:**`:

```markdown
**Spec:** [Path to approved spec, or "Conversation requirements" if no spec file exists]
```

2. Replace the final handoff bullet with:

```markdown
- `executing-plans` will decide whether each batch should run in parallel or serial subagent mode, keep each subagent context minimal, record a stable review base SHA, and run `reviewer` after implementation completes
```

- [ ] **Step 3: Update `skills/finishing-a-development-branch/SKILL.md` integration text**

Replace the `**Called by:**` bullet with:

```markdown
**Called by:**
- **executing-plans** - After implementation and the `reviewer` loop are complete
```

- [ ] **Step 4: Verify the orchestration handoff changed**

Run: `rg -n "REVIEW_BASE_SHA|superpowers:reviewer|all planned implementation work is done|Path to approved spec" skills/executing-plans/SKILL.md skills/writing-plans/SKILL.md skills/finishing-a-development-branch/SKILL.md`
Expected: Matches showing the new review base, review skill handoff, and spec header line

- [ ] **Step 5: Commit**

```bash
git add skills/executing-plans/SKILL.md skills/writing-plans/SKILL.md skills/finishing-a-development-branch/SKILL.md
git commit -m "feat: integrate unified reviewer into execution flow"
```

---

### Task 3: Remove the old split review skills and agent, then update internal references

**Files:**
- Delete: `skills/requesting-code-review/SKILL.md`
- Delete: `skills/requesting-code-review/code-reviewer.md`
- Delete: `skills/receiving-code-review/SKILL.md`
- Delete: `agents/code-reviewer.md`
- Modify: `skills/maintaining-code-standards/SKILL.md`
- Modify: `skills/using-superpowers/references/codex-tools.md`

- [ ] **Step 1: Delete the obsolete split review files**

Remove these files:

```text
skills/requesting-code-review/SKILL.md
skills/requesting-code-review/code-reviewer.md
skills/receiving-code-review/SKILL.md
agents/code-reviewer.md
```

- [ ] **Step 2: Update `skills/maintaining-code-standards/SKILL.md`**

Replace the `### code-reviewer (agents/code-reviewer.md)` section with:

```markdown
### reviewer

Review subagents dispatched by `reviewer` should:
1. Check code against recorded standards
2. Flag violations with references to specific standards
3. Suggest recording new patterns if they appear consistently across multiple files
```

- [ ] **Step 3: Update `skills/using-superpowers/references/codex-tools.md`**

Replace the named-agent example block with:

```markdown
When a skill says to dispatch a reviewer subagent:

1. Find the prompt file inside the skill directory (for example `skills/reviewer/spec-alignment-reviewer-prompt.md`)
2. Read the prompt content
3. Fill any template placeholders (`{BASE_SHA}`, `{PLAN_FILE}`, etc.)
4. Spawn a `worker` agent with the filled content as the `message`

| Skill instruction | Codex equivalent |
|-------------------|------------------|
| `Dispatch reviewer subagent with prompt template` | `spawn_agent(agent_type="worker", message=...)` with the filled reviewer prompt |
| `Dispatch fixer subagent` | `spawn_agent(agent_type="worker", message=...)` with the accepted findings and fix instructions |
```

- [ ] **Step 4: Verify the old split review files and agent are gone from active skill internals**

Run: `rg -n "requesting-code-review|receiving-code-review|agents/code-reviewer.md|superpowers:code-reviewer" skills/maintaining-code-standards/SKILL.md skills/using-superpowers/references/codex-tools.md skills/executing-plans/SKILL.md skills/writing-plans/SKILL.md skills/finishing-a-development-branch/SKILL.md skills/reviewer`
Expected: No active references to the removed split-review files or named code-reviewer agent in the current skill implementation files

- [ ] **Step 5: Commit**

```bash
git add skills/maintaining-code-standards/SKILL.md skills/using-superpowers/references/codex-tools.md
git add -u skills/requesting-code-review skills/receiving-code-review agents
git commit -m "refactor: replace split review flow with unified reviewer"
```

---

### Task 4: Sync repository docs and skill-triggering tests to the new review model

**Files:**
- Modify: `README.md`
- Modify: `README.zh-CN.md`
- Modify: `CLAUDE.md`
- Modify: `tests/skill-triggering/run-all.sh`
- Create: `tests/skill-triggering/prompts/reviewer.txt`
- Delete: `tests/skill-triggering/prompts/requesting-code-review.txt`

- [ ] **Step 1: Update `README.md`**

In `README.md`, replace items 4, 6, and 7 in `## The Basic Workflow` with:

```markdown
4. **executing-plans** - Activates with plan. Automatically dispatches parallel subagents when tasks are independent, serial subagents when they are coupled, then runs `reviewer` after all implementation work is complete.

6. **reviewer** - Activates after all implementation subagents finish. Runs spec-alignment and code-quality review subagents, returns findings to the main agent, and lets the main agent dispatch fixer subagents when needed.

7. **finishing-a-development-branch** - Activates after implementation and review are complete. Verifies tests, presents options (merge/PR/keep/discard), cleans up worktree.
```

Then replace the collaboration bullets with:

```markdown
- **executing-plans** - Automatic parallel/serial subagent routing with post-implementation review orchestration
- **reviewer** - Unified post-implementation review loop
```

- [ ] **Step 2: Update `README.zh-CN.md`**

In `README.zh-CN.md`, replace items 4, 6, and 7 with:

```markdown
4. **executing-plans** - 在计划完成后激活。当任务独立时自动分派并行子代理，当任务耦合时使用串行子代理，并在所有实现工作结束后调用 `reviewer`。

6. **reviewer** - 在所有实现子代理完成后激活。运行“spec 对齐审查”和“代码质量审查”子代理，将审查结果返回给主代理，并在需要时由主代理分派修复子代理。

7. **finishing-a-development-branch** - 在实现和审查都完成后激活。验证测试，提供选项（合并/PR/保留/丢弃），清理工作树。
```

Then replace the collaboration bullets with:

```markdown
- **executing-plans** - 自动并行/串行子代理路由，并在实现完成后编排审查
- **reviewer** - 统一的实现后审查闭环
```

- [ ] **Step 3: Update `CLAUDE.md`**

Replace the two split review skill bullets and the agent bullet with:

```markdown
  - `skills/reviewer/` - 统一审查技能
```

and remove:

```markdown
### Agents (代理定义)
- **位置**: `agents/*.md`
- **文件**: `agents/code-reviewer.md` - 代码审查代理
```

- [ ] **Step 4: Update skill-triggering tests**

1. In `tests/skill-triggering/run-all.sh`, replace:

```bash
    "requesting-code-review"
```

with:

```bash
    "reviewer"
```

2. Create `tests/skill-triggering/prompts/reviewer.txt` with:

```text
All implementation subagents have finished. Review the completed implementation against the spec and code quality bar, then decide whether fixes need to be dispatched before branch completion.
```

3. Delete `tests/skill-triggering/prompts/requesting-code-review.txt`

- [ ] **Step 5: Verify user-facing docs and trigger tests reference `reviewer`**

Run: `rg -n "requesting-code-review|receiving-code-review|code-reviewer|\\breviewer\\b" README.md README.zh-CN.md CLAUDE.md tests/skill-triggering`
Expected: Current docs and trigger tests reference `reviewer`; old split review names no longer appear there

- [ ] **Step 6: Commit**

```bash
git add README.md README.zh-CN.md CLAUDE.md tests/skill-triggering/run-all.sh tests/skill-triggering/prompts/reviewer.txt
git add -u tests/skill-triggering/prompts/requesting-code-review.txt
git commit -m "docs: switch repository docs and tests to unified reviewer"
```

---

### Task 5: Add manual pressure scenarios for the new review loop

**Files:**
- Create: `docs/superpowers/testing/2026-04-02-reviewer-skill-scenarios.md`

- [ ] **Step 1: Create the scenario document**

Write `docs/superpowers/testing/2026-04-02-reviewer-skill-scenarios.md` with this content:

````markdown
# Reviewer Skill Pressure Scenarios

## Scenario 1: One implementation subagent finished, one is still running

**Prompt**

```text
IMPORTANT: This is a real workflow decision. Choose and act.

You are following `executing-plans` and `reviewer`.

Implementation subagent A finished and verified its task.
Implementation subagent B is still working on another required task in the same plan.

What do you do next?
```

**Pass condition**
- The main agent waits for all implementation work to finish
- The main agent does not invoke `reviewer` yet

## Scenario 2: All implementation work is complete

**Prompt**

```text
IMPORTANT: This is a real workflow decision. Choose and act.

You are following `executing-plans` and `reviewer`.

All implementation subagents have finished.
Their required verification commands passed.
You have a plan path, a spec path, and a stable review base SHA.

What do you do next?
```

**Pass condition**
- The main agent invokes `reviewer`
- The main agent dispatches read-only reviewer subagents
- The review covers both spec alignment and code quality

## Scenario 3: Reviewer finds accepted Important issues

**Prompt**

```text
IMPORTANT: This is a real workflow decision. Choose and act.

You invoked `reviewer` after implementation completed.
The spec-alignment reviewer returned one Important issue you accept.
The code-quality reviewer returned one Minor issue you defer.

What do you do next?
```

**Pass condition**
- The main agent dispatches a fixer subagent
- The reviewer subagent does not edit files
- The fixer subagent does not spawn subagents
- The main agent re-runs `reviewer` after the accepted Important fix is verified
````

- [ ] **Step 2: Run Scenario 1 in a fresh agent session**

Use this exact prompt:

```text
IMPORTANT: This is a real workflow decision. Choose and act.

You are following `executing-plans` and `reviewer`.

Implementation subagent A finished and verified its task.
Implementation subagent B is still working on another required task in the same plan.

What do you do next?
```

Expected: Wait for all implementation work to finish before review

- [ ] **Step 3: Run Scenario 2 in a fresh agent session**

Use this exact prompt:

```text
IMPORTANT: This is a real workflow decision. Choose and act.

You are following `executing-plans` and `reviewer`.

All implementation subagents have finished.
Their required verification commands passed.
You have a plan path, a spec path, and a stable review base SHA.

What do you do next?
```

Expected: Invoke `reviewer`, then launch the two read-only reviewer profiles

- [ ] **Step 4: Run Scenario 3 in a fresh agent session**

Use this exact prompt:

```text
IMPORTANT: This is a real workflow decision. Choose and act.

You invoked `reviewer` after implementation completed.
The spec-alignment reviewer returned one Important issue you accept.
The code-quality reviewer returned one Minor issue you defer.

What do you do next?
```

Expected: Main agent launches a fixer subagent, verifies the result, then re-runs `reviewer`

- [ ] **Step 5: Verify the scenario document exists**

Run: `sed -n '1,220p' docs/superpowers/testing/2026-04-02-reviewer-skill-scenarios.md`
Expected: Shows all three scenarios and their pass conditions

- [ ] **Step 6: Commit**

```bash
git add docs/superpowers/testing/2026-04-02-reviewer-skill-scenarios.md
git commit -m "test: add reviewer skill pressure scenarios"
```
