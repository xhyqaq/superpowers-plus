---
name: writing-acceptance-criteria
description: Use when a spec document has been approved during brainstorming and you need to produce testable acceptance criteria before writing the implementation plan - converts spec requirements into a structured acceptance criteria document
---

# Writing Acceptance Criteria

**Announce at start:** "I'm using the writing-acceptance-criteria skill to convert the approved spec into a testable acceptance criteria document."

**Core principle:** Every requirement in the spec must become a criterion with a deterministic pass/fail check. If you cannot write such a check, the requirement is not yet specified well enough.

**Save to:** `docs/superpowers/acceptance/YYYY-MM-DD-<feature>.md`

---

## The Hard Gate

<HARD-GATE>
DO NOT PROCEED TO writing-plans UNTIL THE USER HAS APPROVED THE ACCEPTANCE CRITERIA DOCUMENT.
</HARD-GATE>

Present the document, commit it, then wait for explicit user approval before invoking `writing-plans`. (Skip in autonomous mode — see below.)

---

## Process

### Step 1: Load the Spec

- [ ] Read the spec at `docs/superpowers/specs/YYYY-MM-DD-<topic>-design.md`
- [ ] Identify every distinct requirement, behavior, constraint, and success criterion stated in the spec
- [ ] Group them by feature area or user-facing capability

### Step 2: Draft the Criteria

For each requirement, write one or more rows in the acceptance criteria table.

**Every criterion must include:**

| Field | Meaning |
|-------|---------|
| **ID** | Sequential identifier: `AC-001`, `AC-002`, ... |
| **Description** | One sentence stating the observable behavior being verified |
| **Test type** | One of: `UI interaction` / `API` / `Logic` |
| **Preconditions** | System state, data, or setup required before the test runs |
| **Expected result** | The specific, measurable outcome that constitutes a pass |

**Test type definitions:**
- `UI interaction` — requires a running browser; executed with `superpowers:playwright-cli`
- `API` — HTTP request/response or CLI invocation; executed with `curl`, `httpie`, or the project's test runner
- `Logic` — pure function, data transformation, or unit behavior; executed by running the project's test suite directly

### Step 3: Coverage Check

- [ ] Every section of the spec has at least one criterion
- [ ] Error cases and edge cases from the spec are represented
- [ ] No criterion uses vague language ("works correctly", "behaves as expected") — expected results are specific and measurable
- [ ] No duplicate criteria

### Step 4: Write the Document

Save to `docs/superpowers/acceptance/YYYY-MM-DD-<feature>.md` with this exact header:

```markdown
# Acceptance Criteria: [Feature Name]

**Spec:** `docs/superpowers/specs/YYYY-MM-DD-<topic>-design.md`
**Date:** YYYY-MM-DD
**Status:** Draft

---

## Criteria

| ID | Description | Test Type | Preconditions | Expected Result |
|----|-------------|-----------|---------------|-----------------|
| AC-001 | ... | UI interaction | ... | ... |
| AC-002 | ... | API | ... | ... |
| AC-003 | ... | Logic | ... | ... |
```

### Step 5: Self-Review

- [ ] Placeholder scan: any "TBD", vague phrases, or incomplete rows? Fix them.
- [ ] Every expected result is deterministic (unambiguous pass/fail)
- [ ] Test types are correct (a logic criterion should not require a browser)
- [ ] IDs are sequential with no gaps

Fix inline. No need to re-review after fixing.

### Step 6: Commit and Await User Approval

```bash
git add docs/superpowers/acceptance/YYYY-MM-DD-<feature>.md
git commit -m "docs: add acceptance criteria for <feature>"
```

Announce:
> "Acceptance criteria written and committed to `docs/superpowers/acceptance/<filename>.md`. Please review and let me know if any criteria need adjustment before we proceed to writing the implementation plan."

Wait for explicit user approval. If changes are requested, update the document, re-run self-review, and re-commit. Update `Status:` from `Draft` to `Approved` once the user approves.

---

## Autonomous Mode

If the user previously granted autonomous mode:
- Skip the approval gate in Step 6
- Update `Status:` to `Approved` directly
- Announce: "Acceptance criteria complete. Autonomous mode active — proceeding directly to writing-plans."
- Invoke `superpowers:writing-plans` immediately

---

## No Placeholders Rule

These are failures — never write them:
- "TBD", "TODO", "fill in later"
- "The feature should work as expected"
- "Verify the behavior is correct"
- Any expected result that cannot be checked with a deterministic command or observation

If a requirement cannot be made testable, stop. Return to the spec and clarify with the user before writing the criterion.

---

## Red Flags

- Writing a criterion without a specific expected result
- Using test type `UI interaction` when the behavior is purely server-side
- Proceeding to `writing-plans` before user approval (outside autonomous mode)
- Criteria that cannot be mapped to a concrete test in `acceptance-testing`

---

## Integration

**Called after:**
- `superpowers:brainstorming` — invoke this skill after the spec is approved and committed

**Referenced by:**
- `superpowers:writing-plans` — plan tasks should note which AC IDs they satisfy
- `superpowers:executing-plans` — subagents receive relevant AC IDs in their task-local context
- `superpowers:acceptance-testing` — reads this document to drive the final verification pass

**Proceeds to:**
- `superpowers:writing-plans` — invoke after user approval (or immediately in autonomous mode)
