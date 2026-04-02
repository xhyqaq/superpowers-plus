---
name: maintaining-code-standards
description: Use when code reviews, brainstorming, or planning reveal reusable patterns that should become project conventions, or when existing code demonstrates standards worth documenting - records design principles, naming conventions, interface patterns, and architectural guidelines directly in CLAUDE.md
---

# Maintaining Code Standards

## Overview

Record project-level design principles, naming conventions, interface patterns, and architectural guidelines as they emerge from development. Core principle: capture **design decisions and rationales** that guide future work, not specific code implementations.

**This skill maintains the "Code Standards" section in CLAUDE.md only.** It does NOT create separate documentation directories.

**Relationship with reusable-assets-index:**
- reusable-assets-index → Records **concrete code** (components, functions, utilities)
- maintaining-code-standards → Records **design guidance** (principles, conventions, patterns)

## When to Use

**Implicit triggers:**
- During code review: You notice a pattern that should be standardized
- During brainstorming: Design decisions worth recording as conventions
- During planning: Architectural choices that apply beyond this feature
- Observing existing code: Consistent patterns that should be documented

**Explicit triggers:**
- User asks to record/update code standards or conventions
- User asks to document design principles or architectural guidelines
- User requests to initialize the code standards section

**When NOT to use:**
- Recording specific code implementations → Use reusable-assets-index instead
- One-off decisions specific to a single feature
- Implementation details without broader applicability
- Content that belongs in API documentation

## Scope

This skill operates ONLY on:
- The "Code Standards" section in `CLAUDE.md`

Do NOT:
- Create separate documentation files (single-layer structure only)
- Modify code or tests
- Create docs/superpowers/reuse/ entries (that's reusable-assets-index territory)
- Document specific code implementations

## Rules

1. **Trigger implicitly** when recognizing patterns worth standardizing, OR when user explicitly requests it.

2. **Record only design-level guidance**, not implementation code:
   - ✅ "API endpoints follow RESTful conventions: GET for retrieval, POST for creation"
   - ❌ "Use this exact code: `app.get('/api/users', handler)`"

3. **Keep entries concise** (2-3 sentences per standard):
   - State the convention clearly
   - Explain WHY (rationale) if not obvious
   - Provide 1-2 brief examples if helpful

4. **Organize by category** using the predefined structure:
   - API Design
   - Naming Conventions
   - Architecture Patterns
   - Error Handling
   - Testing Practices
   - Performance Guidelines
   - Security Practices

5. **Use incremental updates**:
   - Add new standards to appropriate category
   - Update existing standards if refined
   - Do NOT reorganize unrelated sections

6. **Mark unknowns explicitly**:
   - If unsure about a detail: "TBD: [specific question]"
   - If pattern is emerging but not mature: "Experimental: [note]"

7. **Align with reusable-assets-index**:
   - If recording both a standard AND an implementation, use BOTH skills
   - Example: "Follow lock pattern for concurrency" (standard) + document Lock utility (asset)

8. **Preserve existing structure**:
   - Don't remove categories even if empty
   - Add categories only if genuinely needed (rare)
   - Maintain consistent formatting

## Index Format in CLAUDE.md

The Code Standards section should appear **after** the reusable assets index section and **before** the project structure index section.

### Recommended Structure

Note: CLAUDE.md uses Chinese, so the section headers and guidance are in Chinese. Adapt the language as needed for your project.

```markdown
---

# Code Standards

This section records project-level design principles, naming conventions, interface patterns, and architectural guidelines. These are guiding content (WHY/WHAT), not specific implementations (HOW).

**Usage guidelines**:
- Reference this section during code reviews, design discussions, or architectural decisions
- Follow recorded standards to ensure consistency
- Use `superpowers:maintaining-code-standards` skill to update or add standards

**Distinction from reusable assets index**:
- **Code Standards**: Design principles and conventions (e.g., "All APIs follow RESTful conventions")
- **Reusable Assets Index**: Concrete code implementations (e.g., "Use HTTP client in `docs/superpowers/reuse/api-wrapper/`")

---

## API Design

No API design standards recorded yet.

## Naming Conventions

No naming conventions recorded yet.

## Architecture Patterns

No architecture patterns recorded yet.

## Error Handling

No error handling standards recorded yet.

## Testing Practices

No testing practices recorded yet.

## Performance Guidelines

No performance guidelines recorded yet.

## Security Practices

No security practices recorded yet.

---
```

### Example with Content

```markdown
## API Design

**RESTful endpoints**: All HTTP APIs follow REST conventions - GET for retrieval, POST for creation, PUT for updates, DELETE for removal. Use plural nouns for collections (`/users` not `/user`).

**Response format**: API responses use consistent envelope: `{ data: T, error?: string, meta?: object }`. Success responses have `data`, error responses have `error` field.

**Status codes**: 200 for success, 201 for creation, 400 for client errors, 500 for server errors. Avoid creative status codes.

## Naming Conventions

**Files and directories**: All file and directory names use kebab-case (`user-profile.ts` not `UserProfile.ts`). Exception: React components use PascalCase.

**Functions**: Function names use verb-noun pattern (`getUserById`, `createPost`, `validateInput`). Avoid generic names like `handle`, `process`, `do`.

**Constants**: True constants use SCREAMING_SNAKE_CASE (`MAX_RETRIES`, `API_BASE_URL`). Config objects use camelCase.

## Architecture Patterns

**Component structure**: Follow container/presentational pattern - containers handle logic and state, presentational components receive props only. Keep presentational components pure when possible.

**Dependency injection**: Pass dependencies through constructor/parameters, not global imports. Makes testing easier and dependencies explicit.

## Error Handling

**Error propagation**: Let errors bubble up to boundary handlers. Don't catch-and-ignore unless you have specific recovery logic.

**Error messages**: Include context in error messages - what operation failed, what input caused it. "Failed to parse JSON in user config file" not "Parse error".

## Testing Practices

**Test file location**: Co-locate test files with source: `user-service.ts` → `user-service.test.ts` in same directory. Makes tests easier to find and maintain.

**Test naming**: Use "should [expected behavior] when [condition]" pattern. `should return null when user not found` not `test_get_user_2`.
```

## Quick Reference

| Aspect | Policy |
|--------|--------|
| Trigger mode | Implicit (recognize patterns) or explicit (user request) |
| Location | CLAUDE.md "Code Standards" section only |
| Structure | Single-layer (no separate docs) |
| Entry length | 2-3 sentences per standard |
| Categories | 7 predefined (see Index Format) |
| Updates | Incremental only |
| Format | Concise guidance with brief examples |

## Common Mistakes

**Recording implementation code**
- **Problem**: Blurs boundary with reusable-assets-index, duplicates information
- **Fix**: Record the principle/pattern only, reference assets for code

**Overly detailed standards**
- **Problem**: Creates maintenance burden, becomes stale quickly
- **Fix**: Keep entries to 2-3 sentences, focus on "what" and "why"

**Creating new documentation files**
- **Problem**: Violates single-layer structure, increases context load
- **Fix**: Everything goes in CLAUDE.md section only

**Recording one-off decisions**
- **Problem**: Clutters standards with non-reusable information
- **Fix**: Only record patterns that apply to multiple features

**Vague or abstract standards**
- **Problem**: "Use good naming" - provides no actionable guidance
- **Fix**: Be specific: "Functions use verb-noun pattern: `getUserById`"

**Reorganizing entire section for one update**
- **Problem**: Creates noise in git history, wastes time
- **Fix**: Incremental updates only - add/modify specific entries

## Integration with Other Skills

### brainstorming

During design discussions, if architectural decisions or design patterns are made that should apply project-wide, `brainstorming` should invoke this skill before moving to `writing-plans`.

**Example**: After deciding on a consistent error handling approach, record it as a standard.

### writing-plans

When writing implementation plans, reference existing code standards. If the plan establishes new patterns worth standardizing, note this for recording after implementation is proven.

**Flow**: brainstorming → writing-plans → executing-plans → (if pattern works) → maintaining-code-standards

### reviewer

Reviewer subagents should:
1. Check code against recorded standards
2. Flag violations with references to specific standards
3. Suggest recording new patterns if consistent across multiple files

### finishing-a-development-branch

After completing a feature, if new design patterns emerged and were consistently applied, `finishing-a-development-branch` should ask:

> "I noticed [pattern] was used consistently in this work. Should we record this as a code standard?"

If user agrees, invoke this skill to record it.

### executing-plans

When subagents encounter unclear conventions during implementation, they can check the Code Standards section for guidance. If standards are missing or unclear, flag this for the main agent to address.

## Workflow Examples

### Example 1: Implicit trigger during code review

```
[During code review]
Agent: "I notice this error handling pattern is used consistently across
        user-service.ts, auth-service.ts, and payment-service.ts. This
        appears to be a project standard worth documenting."

[Agent invokes maintaining-code-standards]
[Updates CLAUDE.md with error handling standard]

Agent: "Recorded error handling pattern to Code Standards."
```

### Example 2: Explicit user request

```
User: "We've decided all APIs should use RESTful conventions. Please record this in the code standards."

Agent: "I'm using the maintaining-code-standards skill to record this."
[Adds RESTful API standard to CLAUDE.md]

Agent: "RESTful API standard recorded in Code Standards → API Design section."
```

### Example 3: During brainstorming

```
[In brainstorming session, after discussing component architecture]

Agent: "We've decided on container/presentational pattern for components.
        This is a project-wide architectural decision - I'll record it as
        a code standard."

[Invokes maintaining-code-standards]
[Adds architecture pattern to CLAUDE.md]

Agent: "Standard recorded. Now moving to implementation planning..."
```

## Red Flags

**Never:**
- Record specific code implementations (that's reusable-assets-index)
- Create separate documentation files
- Record temporary or experimental decisions without marking them as such
- Skip updating standards when patterns clearly emerge
- Remove categories even if empty

**Always:**
- Keep entries concise (2-3 sentences)
- Explain rationale (WHY) when not obvious
- Use incremental updates
- Maintain consistent formatting
- Mark uncertainties explicitly (TBD/Experimental)

## The Bottom Line

Code standards capture **design-level guidance** that ensures consistency across the project. They answer "what conventions should we follow?" not "what code should we use?"

Keep them concise, actionable, and focused on principles that apply broadly. When in doubt: if it's about design decisions, it's a standard. If it's about specific code, it's a reusable asset.
