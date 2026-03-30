# Superpowers Plus

Superpowers Plus 是基于上游 `superpowers` 演进出来的强化版工作流技能集，面向 Claude Code、Codex、OpenCode、Gemini CLI 等编码代理环境。它保留了“先设计、再计划、再执行、再验证”的主线，但把执行路由、子代理上下文控制和安装入口统一到了这个仓库自身，而不是继续依赖上游仓库。

## How it works

It starts from the moment you fire up your coding agent. As soon as it sees that you're building something, it *doesn't* just jump into trying to write code. Instead, it steps back and asks you what you're really trying to do. 

Once it's teased a spec out of the conversation, it shows it to you in chunks short enough to actually read and digest. 

After you've signed off on the design, your agent puts together an implementation plan that's clear enough for an enthusiastic junior engineer with poor taste, no judgement, no project context, and an aversion to testing to follow. It emphasizes true red/green TDD, YAGNI (You Aren't Gonna Need It), and DRY. 

Next up, once you say "go", it launches an *executing-plans* process that automatically chooses parallel or serial subagent routing based on task dependency, then inspects and reviews the work as it goes. It's not uncommon for Claude to be able to work autonomously for a couple hours at a time without deviating from the plan you put together.

There's a bunch more to it, but that's the core of the system. And because the skills trigger automatically, you don't need to do anything special. Your coding agent just has Superpowers Plus.

## 相对上游 Superpowers 的改动

Superpowers Plus 当前相对上游主要做了这些收敛和调整：

- 将计划执行入口统一为 `executing-plans`，不再保留 `subagent-driven-development` 作为独立工作流入口。
- `executing-plans` 改为控制器式执行：自动判断任务是否适合并行子代理，或需要串行子代理，不再要求用户在执行前二选一。
- 子代理默认只接收任务级最小上下文，而不是整段对话历史；执行模型默认优先低成本子模型，必要时再升级。
- 计划交接文案改为直接进入执行，不再在 `writing-plans` 之后插入 “Subagent-Driven / Inline Execution” 选择题。
- 仓库内的测试、示例与活跃文档已经围绕新的单入口执行模型更新，避免 README 说一套、技能说一套、测试再说一套。

这不是一份完整变更日志，而是使用者最需要知道的行为差异。

## Installation

Superpowers Plus 的安装入口统一指向本仓库：

- GitHub: `https://github.com/xhyqaq/superpowers-plus`
- Codex 安装脚本: `https://raw.githubusercontent.com/xhyqaq/superpowers-plus/refs/heads/main/.codex/INSTALL.md`
- OpenCode 安装脚本: `https://raw.githubusercontent.com/xhyqaq/superpowers-plus/refs/heads/main/.opencode/INSTALL.md`

### Claude Code

推荐直接从仓库安装，而不是依赖上游 marketplace：

**快速安装（推荐）：**

```bash
git clone https://github.com/xhyqaq/superpowers-plus.git ~/.claude/superpowers-plus
bash ~/.claude/superpowers-plus/.claude-plugin/install.sh
```

**手动安装：**

```bash
git clone https://github.com/xhyqaq/superpowers-plus.git ~/.claude/superpowers-plus
mkdir -p ~/.claude/skills
cd ~/.claude/superpowers-plus/skills
for skill in */; do
  skill_name="${skill%/}"
  ln -sf "$HOME/.claude/superpowers-plus/skills/$skill_name" "$HOME/.claude/skills/superpowers:$skill_name"
done
```

> **注意**：Claude Code 只扫描 `~/.claude/skills/` 的直接子目录，因此需要为每个 skill 创建独立的软链接，而不是链接整个 skills 目录。

**验证安装：**

```bash
ls ~/.claude/skills/ | grep superpowers:
```

应该看到多个 `superpowers:*` 开头的软链接。

### Cursor

当前建议沿用技能目录方式，把 `skills/` 暴露给 Cursor 可发现的技能路径；如果你的 Cursor 环境支持仓库型技能源，也请直接使用 `xhyqaq/superpowers-plus`。

### Codex

Tell Codex:

```
Fetch and follow instructions from https://raw.githubusercontent.com/xhyqaq/superpowers-plus/refs/heads/main/.codex/INSTALL.md
```

**Detailed docs:** [docs/README.codex.md](docs/README.codex.md)

### OpenCode

Tell OpenCode:

```
Fetch and follow instructions from https://raw.githubusercontent.com/xhyqaq/superpowers-plus/refs/heads/main/.opencode/INSTALL.md
```

**Detailed docs:** [docs/README.opencode.md](docs/README.opencode.md)

### Gemini CLI

```bash
gemini extensions install https://github.com/xhyqaq/superpowers-plus
```

To update:

```bash
gemini extensions update superpowers-plus
```

### Verify Installation

Start a new session in your chosen platform and ask for something that should trigger a skill (for example, "help me plan this feature" or "let's debug this issue"). The agent should automatically invoke the relevant Superpowers Plus skill.

## The Basic Workflow

1. **brainstorming** - Activates before writing code. Refines rough ideas through questions, explores alternatives, presents design in sections for validation. Saves design document.

2. **using-git-worktrees** - Activates after design approval. Creates isolated workspace on new branch, runs project setup, verifies clean test baseline.

3. **writing-plans** - Activates with approved design. Breaks work into bite-sized tasks (2-5 minutes each). Every task has exact file paths, complete code, verification steps.

4. **executing-plans** - Activates with plan. Automatically dispatches parallel subagents when tasks are independent, serial subagents when they are coupled, and keeps review checkpoints inside the workflow.

5. **test-driven-development** - Activates during implementation. Enforces RED-GREEN-REFACTOR: write failing test, watch it fail, write minimal code, watch it pass, commit. Deletes code written before tests.

6. **requesting-code-review** - Activates between tasks. Reviews against plan, reports issues by severity. Critical issues block progress.

7. **finishing-a-development-branch** - Activates when tasks complete. Verifies tests, presents options (merge/PR/keep/discard), cleans up worktree.

**The agent checks for relevant skills before any task.** Mandatory workflows, not suggestions.

## What's Inside

### Skills Library

**Testing**
- **test-driven-development** - RED-GREEN-REFACTOR cycle (includes testing anti-patterns reference)

**Debugging**
- **systematic-debugging** - 4-phase root cause process (includes root-cause-tracing, defense-in-depth, condition-based-waiting techniques)
- **verification-before-completion** - Ensure it's actually fixed

**Collaboration** 
- **brainstorming** - Socratic design refinement
- **writing-plans** - Detailed implementation plans
- **executing-plans** - Automatic parallel/serial subagent routing with in-flow review checkpoints
- **dispatching-parallel-agents** - Concurrent subagent workflows
- **requesting-code-review** - Pre-review checklist
- **receiving-code-review** - Responding to feedback
- **using-git-worktrees** - Parallel development branches
- **finishing-a-development-branch** - Merge/PR decision workflow

**Meta**
- **writing-skills** - Create new skills following best practices (includes testing methodology)
- **using-superpowers** - Introduction to the skills system

## Philosophy

- **Test-Driven Development** - Write tests first, always
- **Systematic over ad-hoc** - Process over guessing
- **Complexity reduction** - Simplicity as primary goal
- **Evidence over claims** - Verify before declaring success

如果你想了解原始理念来源，可以再去看上游 Superpowers 相关文章；但本仓库的安装、行为和执行模型以这里的文档为准。

## Contributing

Skills live directly in this repository. To contribute:

1. Fork the repository
2. Create a branch for your skill
3. Follow the `writing-skills` skill for creating and testing new skills
4. Submit a PR

See `skills/writing-skills/SKILL.md` for the complete guide.

## Updating

Skills update automatically when you update the cloned repository:

```bash
cd ~/.claude/superpowers-plus && git pull
```

## License

MIT License - see LICENSE file for details

## Support

- **Repository**: https://github.com/xhyqaq/superpowers-plus
- **Issues**: https://github.com/xhyqaq/superpowers-plus/issues
