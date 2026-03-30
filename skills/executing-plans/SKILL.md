---
name: executing-plans
description: Use when you have a written implementation plan to execute in a separate session with review checkpoints
---

# Executing Plans

## Overview

Load plan, review critically, execute all tasks with subagents, report when complete.

**Announce at start:** "I'm using the executing-plans skill to implement this plan."

**CRITICAL PRINCIPLE: Context Preservation**

Your context is precious and limited. Reserve it for coordination, planning, and critical decision-making. **ALL code writing, editing, and implementation work MUST be delegated to subagents**, regardless of task size or complexity.

- **Single task?** Dispatch one subagent
- **Multiple independent tasks?** Dispatch parallel subagents
- **Sequential dependent tasks?** Dispatch serial subagents
- **Never write code yourself** - even "quick fixes" consume context that should be preserved for orchestration

This skill assumes subagent support is available. It chooses between parallel and serial subagent dispatch automatically, based on task independence and shared context boundaries.

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
   - Default to the lowest-capability model that can complete the task reliably
   - Upgrade model only when a task fails, needs broader reasoning, or crosses a risk boundary

3. **Track progress:**
   - Mark task or batch as in_progress before dispatch
   - Subagents follow plan steps exactly (plan has bite-sized steps)
   - Subagents run verifications as specified
   - Mark as completed after subagent returns

**Never execute tasks yourself** - even if it seems faster, preserving your context for coordination is more valuable.

### Step 3: Complete Development

After all tasks complete and verified:
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
- Don't skip verifications
- Stop when blocked, don't guess
- Never start implementation on main/master branch without explicit user consent

## Integration

**Required workflow skills:**
- **superpowers:using-git-worktrees** - REQUIRED: Set up isolated workspace before starting
- **superpowers:writing-plans** - Creates the plan this skill executes
- **superpowers:finishing-a-development-branch** - Complete development after all tasks
