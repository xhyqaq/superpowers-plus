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
