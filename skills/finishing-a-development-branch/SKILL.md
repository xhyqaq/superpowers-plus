---
name: finishing-a-development-branch
description: Use when implementation is complete, all tests pass, and you need to decide how to integrate the work - guides completion of development work by presenting structured options for merge, PR, or cleanup
---

# Finishing a Development Branch

## Overview

Guide completion of development work by presenting clear options and handling chosen workflow.

**Core principle:** Verify tests → Check reusable assets → Present options → Execute choice → Clean up.

**Announce at start:** "I'm using the finishing-a-development-branch skill to complete this work."

## The Process

### Step 1: Verify Tests

**Before presenting options, verify tests pass:**

```bash
# Run project's test suite
npm test / cargo test / pytest / go test ./...
```

**If tests fail:**
```
Tests failing (<N> failures). Must fix before completing:

[Show failures]

Cannot proceed with merge/PR until tests pass.
```

Stop. Don't proceed to Step 2.

**If tests pass:** Continue to Step 1.5.

### Step 1.5: Check for Reusable Assets (Optional)

**Scan the current branch for potentially reusable assets.**

```bash
# Get files changed in this branch
git diff --name-only --diff-filter=A $(git merge-base HEAD main)..HEAD
```

**Apply heuristic detection rules:**

Look for these patterns in newly added files (--diff-filter=A):

1. **UI components**: `**/components/**/*.{tsx,jsx,vue,svelte}`
2. **Hooks/composables**: `**/hooks/**/*.{ts,js}` or `**/composables/**/*.{ts,js}`
3. **Utilities**: `**/utils/**/*.{ts,js}`, `**/lib/**/*.{ts,js}`, `**/helpers/**/*.{ts,js}`
4. **API wrappers**: `**/*Client.{ts,js}`, `**/*Service.{ts,js}`, `**/*API.{ts,js}`

**Exclude test files and build artifacts:**
- Skip: `**/*.{test,spec}.{ts,js}`, `**/__tests__/**`, `**/dist/**`, `**/build/**`

**Example detection script:**

```bash
# Get new files
NEW_FILES=$(git diff --name-only --diff-filter=A $(git merge-base HEAD main)..HEAD)

# Filter by patterns
COMPONENTS=$(echo "$NEW_FILES" | grep -E '(components?|ui)/.*\.(tsx|jsx|vue|svelte)$' || true)
HOOKS=$(echo "$NEW_FILES" | grep -E '(hooks?|composables?)/.*\.(ts|js)$' || true)
UTILS=$(echo "$NEW_FILES" | grep -E '(utils?|lib|helpers?)/.*\.(ts|js)$' || true)
APIS=$(echo "$NEW_FILES" | grep -E '(Client|Service|API)\.(ts|js)$' || true)

# Exclude tests
CANDIDATES=$(echo -e "$COMPONENTS\n$HOOKS\n$UTILS\n$APIS" | grep -v -E '\.(test|spec)\.(ts|js)$' | grep -v '^$' | sort -u)
```

**If candidates detected:**

```
I found potentially reusable assets in this branch:

  - src/components/Toast.tsx (UI component)
  - src/hooks/useLock.ts (concurrency hook)

Would you like to document these for future reuse? (y/n)
```

**If user answers 'y':**

1. Announce: "I'm using the superpowers:reusable-assets-index skill to document these assets."
2. **REQUIRED SUB-SKILL:** Call `superpowers:reusable-assets-index` via Skill tool
3. The skill will:
   - Create/update index in CLAUDE.md
   - Create documentation files under `docs/superpowers/reuse/<name>/`
4. Stage the new documentation files:
   ```bash
   git add CLAUDE.md docs/superpowers/reuse/
   git commit -m "docs: add reusable asset documentation

   - <asset-name-1>: <brief description>
   - <asset-name-2>: <brief description>

   Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
   ```

**If user answers 'n' or no candidates detected:**
- Continue to Step 2 immediately

**Note:** This step is **optional and non-blocking**. If unsure, skip. Assets can be documented later.

### Step 2: Determine Base Branch

```bash
# Try common base branches
git merge-base HEAD main 2>/dev/null || git merge-base HEAD master 2>/dev/null
```

Or ask: "This branch split from main - is that correct?"

### Step 3: Present Options

Present exactly these 4 options:

```
Implementation complete. What would you like to do?

1. Merge back to <base-branch> locally
2. Push and create a Pull Request
3. Keep the branch as-is (I'll handle it later)
4. Discard this work

Which option?
```

**Don't add explanation** - keep options concise.

### Step 4: Execute Choice

**Note:** If Step 1.5 created reusable asset docs, they should already be committed before merging.

#### Option 1: Merge Locally

```bash
# Switch to base branch
git checkout <base-branch>

# Pull latest
git pull

# Merge feature branch
git merge <feature-branch>

# Verify tests on merged result
<test command>

# If tests pass
git branch -d <feature-branch>
```

Then: Cleanup worktree (Step 5)

#### Option 2: Push and Create PR

```bash
# Push branch
git push -u origin <feature-branch>

# Create PR
gh pr create --title "<title>" --body "$(cat <<'EOF'
## Summary
<2-3 bullets of what changed>

## Reusable Assets
<If Step 1.5 documented assets, list them here>

## Test Plan
- [ ] <verification steps>
EOF
)"
```

Then: Cleanup worktree (Step 5)

#### Option 3: Keep As-Is

Report: "Keeping branch <name>. Worktree preserved at <path>."

**Don't cleanup worktree.**

#### Option 4: Discard

**Confirm first:**
```
This will permanently delete:
- Branch <name>
- All commits: <commit-list>
- Worktree at <path>

Type 'discard' to confirm.
```

Wait for exact confirmation.

If confirmed:
```bash
git checkout <base-branch>
git branch -D <feature-branch>
```

Then: Cleanup worktree (Step 5)

### Step 5: Cleanup Worktree

**For Options 1, 2, 4:**

Check if in worktree:
```bash
git worktree list | grep $(git branch --show-current)
```

If yes:
```bash
git worktree remove <worktree-path>
```

**For Option 3:** Keep worktree.

## Quick Reference

| Option | Merge | Push | Keep Worktree | Cleanup Branch |
|--------|-------|------|---------------|----------------|
| 1. Merge locally | ✓ | - | - | ✓ |
| 2. Create PR | - | ✓ | ✓ | - |
| 3. Keep as-is | - | - | ✓ | - |
| 4. Discard | - | - | - | ✓ (force) |

## Common Mistakes

**Skipping test verification**
- **Problem:** Merge broken code, create failing PR
- **Fix:** Always verify tests before offering options

**Open-ended questions**
- **Problem:** "What should I do next?" → ambiguous
- **Fix:** Present exactly 4 structured options

**Automatic worktree cleanup**
- **Problem:** Remove worktree when might need it (Option 2, 3)
- **Fix:** Only cleanup for Options 1 and 4

**No confirmation for discard**
- **Problem:** Accidentally delete work
- **Fix:** Require typed "discard" confirmation

## Red Flags

**Never:**
- Proceed with failing tests
- Merge without verifying tests on result
- Delete work without confirmation
- Force-push without explicit request

**Always:**
- Verify tests before offering options
- Present exactly 4 options
- Get typed confirmation for Option 4
- Clean up worktree for Options 1 & 4 only

## Integration

**Called by:**
- **executing-plans** (Step 5) - After all batches complete

**Pairs with:**
- **using-git-worktrees** - Cleans up worktree created by that skill
