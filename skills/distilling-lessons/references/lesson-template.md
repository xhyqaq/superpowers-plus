# Lesson Template

Copy this template when creating a new lesson doc in `docs/superpowers/memory/lessons/`.

File name: short, hyphen-separated description of the **problem** (not the solution).

---

```markdown
---
type: lesson
title: [short-stable-hyphenated-title]
summary: [one sentence on why this lesson matters — what mistake it prevents]
tags:
  - [domain: testing | api | state | schema | auth | build | infra | ...]
last_verified_commit: [full 40-char git commit hash — MANDATORY]
status: active
---

## Situation

[Describe the context where the problem appeared. Be specific enough that a future agent
reading this cold can recognize the same situation. Include: what was being built, what
failed or went wrong, and what made it non-obvious.]

## Why It Mattered

[What was the cost of not knowing this? What would have happened if the lesson had been
ignored or unknown? Keep it concrete — time lost, breakage caused, contract violated, etc.]

## Rule

[State the actionable rule in 1–2 sentences. Make it prescriptive and specific enough to
change behavior. Avoid rules so general they apply to everything.]

## When to Apply

[Describe the specific conditions under which this rule should be followed. Be precise —
what signals tell you this situation is the one the rule covers?]

## When NOT to Apply

[Describe the boundaries. When does this rule not apply, or when would applying it cause
harm? This section prevents the rule from being over-generalized.]
```

---

## Checklist Before Saving

- [ ] `last_verified_commit` is a real, full 40-character hash
- [ ] File name describes the **problem**, not the solution
- [ ] `summary` is one sentence that answers: "what mistake does this prevent?"
- [ ] `Situation` is specific enough to recognize on re-encounter
- [ ] `Rule` is actionable — it changes what you do, not just what you know
- [ ] `When NOT to Apply` is present and non-trivial
- [ ] Tags reflect the actual domain, not generic labels
