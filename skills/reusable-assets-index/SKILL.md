---
name: reusable-assets-index
description: Use when code, components, functions, or patterns are clearly reusable and should be recorded in AGENTS.md or CLAUDE.md indexes and documented under docs/superpowers/reuse/<name>.
---

# Reusable Assets Index

## When Claude Should Consult This Index

**Before implementing any new component, function, or pattern, Claude should:**

1. Read the Reusable Asset Index in CLAUDE.md or AGENTS.md
2. Check if a similar asset already exists
3. If exists, read the detailed documentation under `docs/superpowers/reuse/<name>/`
4. Reuse or extend existing implementation instead of creating duplicates

**Common scenarios to check the index:**
- Adding UI components (buttons, modals, toasts, forms)
- Implementing concurrency patterns (locks, queues, debouncing)
- Writing utility functions (date formatting, validation, API wrappers)
- Creating data structures (caches, state machines, event emitters)
- Setting up authentication/authorization patterns

**Guideline:**
This skill manages the index and documentation surfaces. The trigger conditions guide above should be copied to CLAUDE.md/AGENTS.md so Claude knows when to consult the index during coding sessions.

## Overview

This skill manages repository-owned reusable asset documentation. Core
principle: when existing code or newly generated code is clearly reusable, the
repository should capture it in a lightweight instruction-file index and keep
the detailed guidance under `docs/superpowers/reuse/<name>/`.

## When to Use

- Existing code, components, functions, or patterns are clearly reusable and
  should be discoverable later
- Newly generated code has become a reusable asset and should be documented
- The user asks to initialize reusable asset indexes
- The user asks to add or update entries such as `toast` or `lock`
- `AGENTS.md` or `CLAUDE.md` needs a reusable asset index block
- A reusable asset doc directory must be created or refreshed under
  `docs/superpowers/reuse/`

Do not use this skill to define how agents read those docs during coding. Do
not use it as a general code reuse enforcement skill.

## Scope

Stay scoped to these surfaces only:

- `AGENTS.md`
- `CLAUDE.md`
- `docs/superpowers/reuse/<name>/`

This skill owns initialization, incremental updates, and reusable-asset
capture. It does not own runtime lookup behavior or full-repository reuse
audits unless the user explicitly asks for those.

## Rules

1. Trigger when code is clearly reusable or when the user asks to initialize or
   incrementally update reusable asset docs.
2. When newly generated code is obviously reusable, record it instead of
   leaving it undocumented.
3. Limit changes to initialization, reusable-asset capture, or the requested
   incremental update. Do not reorganize unrelated reusable asset entries.
4. Instruction-file indexes must contain only reusable asset labels plus
   directory paths. Do not place code snippets, long explanations, or file
   paths in the index.
5. Store detailed reusable asset docs under
   `docs/superpowers/reuse/<name>/README.md` by default.
6. Use kebab-case for `<name>` directory names. Keep user-facing labels such as
   `lock` or `toast` in the index entry text when needed.
7. If both `AGENTS.md` and `CLAUDE.md` exist for the same repository, keep the
   reusable asset index structure aligned across both files unless the user
   asks for a platform-specific difference.
8. Each reusable asset doc should record only minimum truthful information:
   purpose, implementation entry points, preferred reuse surfaces, extension
   points, and anti-duplication notes. Leave explicit gap notes instead of
   inventing missing project facts.
9. Do not define or modify how coding sessions should consume these docs. This
   skill only maintains the index and documentation surfaces.

## Index Format

Use a dedicated reusable asset block in CLAUDE.md or AGENTS.md. Keep entries short and directory-level only:

```md
# 可复用资产索引

在实现新组件、函数或模式之前，先检查此索引。如果资产已存在，读取对应路径下的详细文档后再决定是复用还是创建新实现。

**常见检查场景**：添加 UI 组件、实现并发控制、编写工具函数、创建数据结构、设置认证模式。

## UI Components
- `toast`: `docs/superpowers/reuse/toast/` - Toast 通知系统
- `modal`: `docs/superpowers/reuse/modal/` - 模态对话框组件

## Concurrency Patterns
- `lock`: `docs/superpowers/reuse/lock/` - 异步互斥锁
- `task-queue`: `docs/superpowers/reuse/task-queue/` - 顺序任务执行器

## Utilities
- `api-wrapper`: `docs/superpowers/reuse/api-wrapper/` - 带重试的 HTTP 客户端
```

**Recommended categories** (expand as needed):
- UI Components - React/Vue/Angular components
- Concurrency Patterns - Locks, queues, debouncing
- Utilities - Pure functions, helpers
- Data Structures - Caches, trees, state machines
- API Integrations - Third-party service wrappers
- Authentication - Auth patterns, session management

## Asset Doc Skeleton

Default file: `docs/superpowers/reuse/<name>/README.md`

Use this detailed template:

```md
# <asset-name>

## Purpose

Describe what this asset does and what problem it solves. Be specific about use cases.

## Existing Implementation Locations

List the primary implementation files and their roles:
- `src/components/Toast.tsx` - Main component implementation
- `src/hooks/useToast.ts` - React hook wrapper
- `tests/toast.test.ts` - Test suite

## API / Public Interface

Document the public API (functions, props, methods):

```typescript
// Example
function showToast(message: string, options?: ToastOptions): void
interface ToastOptions { duration?: number; type?: 'info' | 'error' }
```

## Usage Examples

Provide 1-2 minimal working examples:

```typescript
// Basic usage
showToast('Operation completed');

// With options
showToast('Error occurred', { type: 'error', duration: 5000 });
```

## Preferred Reuse Entry Points

How should other code use this asset?

- Import `useToast` hook for React components
- Use `showToast` for imperative calls
- Avoid directly instantiating `ToastManager`

## Allowed Extension Paths

What can be customized or extended?

- Add new toast types via `registerToastType(name, config)`
- Custom styling via `className` prop
- Do NOT modify the internal queue logic

## Anti-Duplication Notes

Common mistakes to avoid:

- Do NOT create `Alert` component - use `toast` with `type: 'error'`
- Do NOT implement custom notification queue - reuse `ToastManager`
- If you need positioning, extend `ToastOptions` instead of creating new component

## Known Gaps

Mark unknown information explicitly:

- [ ] Does not support rich HTML content yet (only plain text)
- [ ] Performance with 100+ simultaneous toasts not tested
```

Add more files inside the asset directory only when needed (e.g., `examples/`, `migrations.md`).

## Quick Reference

| Concern | Policy |
|---------|--------|
| Trigger mode | Implicit or explicit |
| Index location | `AGENTS.md` / `CLAUDE.md` |
| Detail location | `docs/superpowers/reuse/<name>/` |
| Index entry detail | Label + directory path only |
| Default detail file | `README.md` |
| Ownership | Initialization, incremental updates, and reusable-asset capture |

## Common Mistakes

- Writing the full reusable asset rules into `AGENTS.md` or `CLAUDE.md`
- Storing file-level paths instead of asset directory paths in the index
- Seeing clearly reusable code and failing to record it
- Reorganizing every reusable asset entry when the user asked for one small
  incremental update
- Inventing implementation details instead of marking gaps explicitly
