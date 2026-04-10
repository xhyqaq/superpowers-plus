---
name: acceptance-testing
description: Use when requesting-code-review is complete and all Critical/Important issues are resolved, before finishing-a-development-branch - dispatches an acceptance-tester subagent to verify every acceptance criterion
---

# Acceptance Testing

**Announce at start:** "I'm using the acceptance-testing skill to verify the branch against acceptance criteria."

Dispatch `superpowers:acceptance-tester` subagent to verify the completed branch satisfies every acceptance criterion before integration. The tester receives the AC document path and the current git HEAD SHA.

**Core principle:** Implementation is not done until every acceptance criterion has recorded evidence of a pass. A failing criterion is a blocker, not a review comment.

---

## The Iron Law

```
NO BRANCH FINISHING UNTIL ACCEPTANCE TESTING REPORTS ALL CRITERIA PASSED
(OR EXPLICITLY DEFERRED WITH USER APPROVAL).
```

---

## When to Use

**Mandatory:**
- After `requesting-code-review` completes and all Critical and Important issues are resolved
- Before invoking `finishing-a-development-branch`

**If no AC document exists:**
Stop. Invoke `superpowers:writing-acceptance-criteria` to produce the document from the spec, get user approval, then return here.

---

## How to Run

**1. Identify inputs:**

```bash
AC_DOC="docs/superpowers/acceptance/YYYY-MM-DD-<feature>.md"
HEAD_SHA=$(git rev-parse HEAD)
REPO_ROOT=$(git rev-parse --show-toplevel)
```

**2. Dispatch acceptance-tester subagent:**

Use Task tool with `superpowers:acceptance-tester` type, fill template at `acceptance-tester.md`

**Placeholders:**
- `{AC_DOC_PATH}` — path to the acceptance criteria document
- `{HEAD_SHA}` — current git HEAD SHA
- `{REPO_ROOT}` — absolute path to the repository root

**3. Act on the report:**

| Report outcome | Action |
|----------------|--------|
| All criteria PASS | Proceed to `superpowers:finishing-a-development-branch` |
| One or more criteria FAIL | Return to `superpowers:executing-plans`: create fix tasks for each FAIL criterion |
| Criteria Blocked due to failed dependency | Will unblock automatically once their dependency criteria pass; treat as FAIL for fix prioritization |
| Criteria Blocked due to missing infrastructure | Stop and report to user; get explicit deferral approval before proceeding |

---

## On Failure: Fix Loop

When the acceptance-tester reports failures:

- Do NOT return to `brainstorming`
- Do NOT modify the AC document to remove or weaken the failing criterion
- Announce each failing criterion ID and description
- Return to `executing-plans` and create targeted fix tasks
- Re-run `requesting-code-review` on the fixes
- Re-run `acceptance-testing` after fixes are complete

The fix loop is: `executing-plans → requesting-code-review → acceptance-testing`. Repeat until all criteria pass.

---

## Red Flags

- Invoking `finishing-a-development-branch` while any criterion shows FAIL
- Removing or relaxing a criterion because it is hard to pass
- Accepting "should be fine" from the subagent report as a PASS
- Skipping acceptance testing because "tests already pass" — unit tests and acceptance criteria test different things

---

## Integration

**Called after:**
- `superpowers:requesting-code-review` — must complete before acceptance testing begins

**Calls:**
- `superpowers:acceptance-tester` (subagent, via Task tool)
- `superpowers:executing-plans` (on failure, to create fix tasks)
- `superpowers:finishing-a-development-branch` (on full pass)

**If AC document is missing:**
- `superpowers:writing-acceptance-criteria` — produce the document first

**Required external skill:**
- `superpowers:playwright-cli` — needed for `UI interaction` criteria; install from https://github.com/microsoft/playwright-cli (see the `skills/` directory) if unavailable

See subagent template at: `acceptance-testing/acceptance-tester.md`
