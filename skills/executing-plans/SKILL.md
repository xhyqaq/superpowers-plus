---
name: executing-plans
description: Use when you have a written implementation plan to execute in the current session
---

# Executing Plans

## Overview

Load plan, review critically, execute all tasks with subagents, run one consolidated review loop after implementation completes, and report when complete.

**Announce at start:** "I'm using the executing-plans skill to implement this plan."

**CRITICAL PRINCIPLE: Context Preservation**

Your context is precious and limited. Reserve it for coordination, planning, and critical decision-making. **ALL code writing, editing, and implementation work MUST be delegated to subagents**, regardless of task size or complexity.

- **Single task?** Dispatch one subagent
- **Multiple independent tasks?** Dispatch parallel subagents
- **Sequential dependent tasks?** Dispatch serial subagents
- **Never write code yourself** - even "quick fixes" consume context that should be preserved for orchestration

This skill assumes subagent support is available. It chooses between parallel and serial subagent dispatch automatically, based on task independence and shared context boundaries.

## Model Strategy

**Subagents use lower-capability models than the main agent by default.**

Main agent (you) uses high-capability models for planning and coordination. Subagents execute detailed plans with lower-capability models to preserve expensive tokens.

**Default subagent models (by platform):**
- **Claude Code**: `claude-haiku-4-5-20251001` or `haiku`
- **Codex**: `gpt-5.3` or equivalent lower-tier model
- **Gemini**: `gemini-1.5-flash` or `gemini-2.0-flash-exp`
- **Other platforms**: Use the lowest-capability model tier available

**Reviewer exception:**
- Reviewer subagents always use the highest-capability review model available on the platform
- Fixer subagents are separate worker subagents launched by the main agent after accepted findings are returned

**Upgrade policy:**
When a subagent task fails or requires deeper reasoning:
1. Retry with the **same model as the main agent** (your current model)
2. If still fails, escalate to the user

**Rationale**: Well-written plans from high-capability main agents enable cost-effective execution with lower-capability subagents. This strategy can reduce token costs by 10-20x for execution-heavy workloads while maintaining quality.

## The Process

### Step 1: Load and Review Plan
1. Read plan file
2. Review critically - identify any questions or concerns about the plan
3. If concerns: Raise them with your human partner before starting
4. If no concerns: Create TodoWrite and proceed

### Step 2: Execute Tasks

**ALL tasks MUST be executed by subagents.** Your role is orchestration, not implementation.

For each task or batch:
1. **Assess task dependencies:**
   - Single independent task? → Dispatch one subagent
   - Multiple independent tasks? → Dispatch parallel subagents (one per task)
   - Sequential dependent tasks? → Dispatch serial subagents (each gets only upstream context it needs)

2. **Dispatch subagents with minimal context:**
   - Give each subagent only the task-local slice: task text, allowed files, acceptance criteria, and any directly required upstream summary
   - Use lower-capability models by default (see Model Strategy above)
   - Upgrade to main agent's model only when task fails or requires deeper reasoning

3. **Record the review base before implementation starts:**
   - Set `REVIEW_BASE_SHA=$(git rev-parse HEAD)` before dispatching the first implementation batch
   - Keep that base stable for the final consolidated review

4. **Track progress:**
   - Mark task or batch as in_progress before dispatch
   - Subagents follow plan steps exactly (plan has bite-sized steps)
   - Subagents run verifications as specified
   - Mark as completed after subagent returns

**Never execute tasks yourself** - even if it seems faster, preserving your context for coordination is more valuable.

### Step 3: Review Completed Implementation

After all tasks complete and verified:
- Announce: "I'm using the reviewer skill to review the completed implementation."
- **REQUIRED SUB-SKILL:** Use superpowers:reviewer
- Review the full implementation range from `REVIEW_BASE_SHA` to `HEAD`
- Pass the plan path and the spec path or approved requirements source

If review returns accepted `Critical` or `Important` findings:
- Dispatch fixer subagents from the main agent
- Run the required verification commands after each accepted fix batch
- Re-run `superpowers:reviewer` on the updated range

Only continue when no accepted `Critical` or `Important` findings remain.

### Step 4: Complete Development

After implementation and review are complete:
- Announce: "I'm using the finishing-a-development-branch skill to complete this work."
- **REQUIRED SUB-SKILL:** Use superpowers:finishing-a-development-branch
- Follow that skill to verify tests, present options, execute choice

## Anti-Patterns: What NOT to Do

**❌ NEVER do these - they violate the context preservation principle:**

1. **"It's just a small change, I'll do it myself"**
   - NO. Even one-line changes consume context. Dispatch a subagent.

2. **"I already have the file open, let me edit it quickly"**
   - NO. Reading files for review is fine. Editing them is not. Use a subagent.

3. **"There's only one task, subagents seem like overkill"**
   - NO. Single tasks still go to subagents. Your context is for coordination.

4. **"I'll just fix this test failure inline"**
   - NO. Debugging and fixing code is implementation work. Use a subagent.

5. **"The plan says to follow these steps, so I'll execute them"**
   - NO. You orchestrate. Subagents execute. Pass the steps to a subagent.

6. **"A subagent can spawn another subagent for review or fixes"**
   - NO. The main agent controls the review and fix loop.

**✅ Correct approach:**
- Read files to understand and coordinate
- Review subagent output
- Make architectural decisions
- Dispatch all implementation to subagents
- Preserve your context for the big picture

## When to Stop and Ask for Help

**STOP executing immediately when:**
- Hit a blocker (missing dependency, test fails, instruction unclear)
- Plan has critical gaps preventing starting
- You don't understand an instruction
- Verification fails repeatedly

**Ask for clarification rather than guessing.**

## When to Revisit Earlier Steps

**Return to Review (Step 1) when:**
- Partner updates the plan based on your feedback
- Fundamental approach needs rethinking

**Don't force through blockers** - stop and ask.

## Remember
- Review plan critically first
- **NEVER write code yourself** - ALL implementation must go through subagents
- Dispatch subagents for every task, even single tasks
- Your context is for coordination, not implementation
- Give subagents minimal, task-local context only
- Keep `REVIEW_BASE_SHA` stable until the final consolidated review is done
- Don't skip verifications
- Stop when blocked, don't guess
- Never start implementation on main/master branch without explicit user consent

## Integration

**Required workflow skills:**
- **superpowers:using-git-worktrees** - REQUIRED: Set up isolated workspace before starting
- **superpowers:writing-plans** - Creates the plan this skill executes
- **superpowers:reviewer** - Runs the consolidated post-implementation review loop
- **superpowers:finishing-a-development-branch** - Complete development after all tasks
