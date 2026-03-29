---
name: executing-plans
description: Use when you have a written implementation plan to execute in a separate session with review checkpoints
---

# Executing Plans

## Overview

Load plan, review critically, execute all tasks with subagents, report when complete.

**Announce at start:** "I'm using the executing-plans skill to implement this plan."

**Note:** This skill assumes subagent support is available. It chooses between parallel and serial subagent dispatch automatically, based on task independence and shared context boundaries.

## The Process

### Step 1: Load and Review Plan
1. Read plan file
2. Review critically - identify any questions or concerns about the plan
3. If concerns: Raise them with your human partner before starting
4. If no concerns: Create TodoWrite and proceed

### Step 2: Execute Tasks

For each task or batch:
1. Decide whether the tasks are independent enough for parallel subagents.
2. If they are, dispatch one subagent per independent task.
3. If they are not, dispatch subagents serially so each task receives only the upstream context it needs.
4. Give each subagent only the task-local slice of context: its task text, allowed files, acceptance criteria, and any directly required upstream summary.
5. Default to the lowest-capability mini-class model that can complete the task reliably; upgrade only when a task fails, needs broader reasoning, or crosses a risk boundary.
6. Mark the task or batch as in_progress.
7. Follow each step exactly (plan has bite-sized steps).
8. Run verifications as specified.
9. Mark as completed.

### Step 3: Complete Development

After all tasks complete and verified:
- Announce: "I'm using the finishing-a-development-branch skill to complete this work."
- **REQUIRED SUB-SKILL:** Use superpowers:finishing-a-development-branch
- Follow that skill to verify tests, present options, execute choice

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
- Follow plan steps exactly
- Don't skip verifications
- Use subagents for execution rather than inline task work
- Stop when blocked, don't guess
- Never start implementation on main/master branch without explicit user consent

## Integration

**Required workflow skills:**
- **superpowers:using-git-worktrees** - REQUIRED: Set up isolated workspace before starting
- **superpowers:writing-plans** - Creates the plan this skill executes
- **superpowers:finishing-a-development-branch** - Complete development after all tasks
