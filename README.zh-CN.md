# Superpowers Plus

[English](README.md) | [中文](README.zh-CN.md)

Superpowers Plus 是基于上游 `superpowers` 演进出来的强化版工作流技能集，面向 Claude Code、Codex、OpenCode、Gemini CLI 等编码代理环境。它保留了"先设计、再计划、再执行、再验证"的主线，但把执行路由、子代理上下文控制和安装入口统一到了这个仓库自身，而不是继续依赖上游仓库。

## 工作原理

它从你启动编码代理的那一刻就开始工作。一旦它发现你在构建某些东西，它*不会*直接跳进去尝试编写代码。相反，它会退后一步，询问你真正想要做什么。

一旦它从对话中提炼出规格说明，它会以足够短的块向你展示，让你能够真正阅读和理解。

在你批准设计后，你的代理会制定一个实施计划，这个计划清晰到足以让一个热情但品味不佳、没有判断力、没有项目上下文且厌恶测试的初级工程师也能遵循。它强调真正的红-绿 TDD、YAGNI（你不会需要它）和 DRY 原则。

接下来，一旦你说"开始"，它会启动一个 *executing-plans* 进程，根据任务依赖性自动选择并行或串行子代理路由，然后在工作进行时检查和审查。Claude 能够一次自主工作几个小时而不偏离你制定的计划，这并不罕见。

还有更多内容，但这就是系统的核心。而且因为技能会自动触发，你不需要做任何特殊的事情。你的编码代理就拥有了 Superpowers Plus。

## 相对上游 Superpowers 的改动

Superpowers Plus 当前相对上游主要做了这些收敛和调整：

**执行模型统一：**
- 将计划执行入口统一为 `executing-plans`，不再保留 `subagent-driven-development` 作为独立工作流入口。
- `executing-plans` 改为控制器式执行：自动判断任务是否适合并行子代理，或需要串行子代理，不再要求用户在执行前二选一。
- 子代理默认只接收任务级最小上下文，而不是整段对话历史；执行模型默认优先低成本子模型，必要时再升级。
- 计划交接文案改为直接进入执行，不再在 `writing-plans` 之后插入 "Subagent-Driven / Inline Execution" 选择题。

**简化子代理工作流：**
- 移除了子代理执行时的强制 spec 和 code review 要求。
- 去掉了上游对子代理的规范性开发约束。
- 设计理念：既然 `brainstorming` 和 `writing-plans` 已经提供了充分的设计和规划，执行阶段应该信赖并遵循这个计划，而不是在子代理层面重复设计流程。
- 强制执行频繁的细粒度提交：每个 RED-GREEN-REFACTOR 循环都独立提交，创建清晰的实施审计轨迹。

**增强文档管理：**
- 引入结构化文档追踪系统：
  - 设计规格 → `docs/superpowers/specs/YYYY-MM-DD-<topic>-design.md`
  - 实施计划 → `docs/superpowers/plans/YYYY-MM-DD-<feature-name>.md`
  - 提交文档 → `docs/superpowers/commits/<module>/`
- 为 spec 和 plan 内置自审查机制，在用户审查前提前发现占位符、矛盾和歧义。
- 新增 `reusable-assets-index` 技能，用于管理可复用代码/组件文档。
- 强化了 AGENTS.md 和 CLAUDE.md 中的仓库级文档索引。

**仓库一致性：**
- 仓库内的测试、示例与活跃文档已经围绕新的单入口执行模型更新，避免 README 说一套、技能说一套、测试再说一套。

这不是一份完整变更日志，而是使用者最需要知道的行为差异。

## 安装

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

告诉 Codex：

```
Fetch and follow instructions from https://raw.githubusercontent.com/xhyqaq/superpowers-plus/refs/heads/main/.codex/INSTALL.md
```

**详细文档：** [docs/README.codex.md](docs/README.codex.md)

### OpenCode

告诉 OpenCode：

```
Fetch and follow instructions from https://raw.githubusercontent.com/xhyqaq/superpowers-plus/refs/heads/main/.opencode/INSTALL.md
```

**详细文档：** [docs/README.opencode.md](docs/README.opencode.md)

### Gemini CLI

```bash
gemini extensions install https://github.com/xhyqaq/superpowers-plus
```

更新：

```bash
gemini extensions update superpowers-plus
```

### 验证安装

在你选择的平台上启动一个新会话，并请求一些应该触发技能的内容（例如，"帮我规划这个功能"或"让我们调试这个问题"）。代理应该会自动调用相关的 Superpowers Plus 技能。

## 基本工作流

1. **brainstorming** - 在编写代码之前激活。通过提问细化粗略想法，探索替代方案，分段展示设计以供验证。保存设计文档。

2. **using-git-worktrees** - 在设计批准后激活。在新分支上创建隔离工作空间，运行项目设置，验证干净的测试基线。

3. **writing-plans** - 在设计获批后激活。将工作分解为小任务（每个 2-5 分钟）。每个任务都有确切的文件路径、完整的代码和验证步骤。

4. **executing-plans** - 在计划完成后激活。当任务独立时自动分派并行子代理，当任务耦合时使用串行子代理，并在工作流中保持审查检查点。

5. **test-driven-development** - 在实施期间激活。强制执行 RED-GREEN-REFACTOR：编写失败测试，观察其失败，编写最少代码，观察其通过，提交。删除测试前编写的代码。

6. **requesting-code-review** - 在任务之间激活。根据计划审查，按严重程度报告问题。严重问题会阻止进度。

7. **finishing-a-development-branch** - 在任务完成时激活。验证测试，提供选项（合并/PR/保留/丢弃），清理工作树。

**代理在任何任务之前都会检查相关技能。** 强制工作流，而不是建议。

## 内容概览

### 技能库

**测试**
- **test-driven-development** - RED-GREEN-REFACTOR 循环（包含测试反模式参考）

**调试**
- **systematic-debugging** - 4 阶段根本原因流程（包含根本原因追踪、深度防御、基于条件的等待技术）
- **verification-before-completion** - 确保实际修复

**协作**
- **brainstorming** - 苏格拉底式设计细化
- **writing-plans** - 详细实施计划
- **executing-plans** - 自动并行/串行子代理路由，内置审查检查点
- **dispatching-parallel-agents** - 并发子代理工作流
- **requesting-code-review** - 审查前检查清单
- **receiving-code-review** - 响应反馈
- **using-git-worktrees** - 并行开发分支
- **finishing-a-development-branch** - 合并/PR 决策工作流

**元技能**
- **writing-skills** - 按照最佳实践创建新技能（包含测试方法论）
- **using-superpowers** - 技能系统介绍
- **reusable-assets-index** - 管理可复用代码/组件文档的 AGENTS.md/CLAUDE.md 索引

## 理念

- **测试驱动开发** - 始终先编写测试
- **系统化优于临时性** - 流程优于猜测
- **降低复杂性** - 简单性作为首要目标
- **证据优于声明** - 在宣布成功之前先验证

如果你想了解原始理念来源，可以再去看上游 Superpowers 相关文章；但本仓库的安装、行为和执行模型以这里的文档为准。

## 贡献

技能直接存储在此仓库中。要贡献：

1. Fork 此仓库
2. 为你的技能创建一个分支
3. 遵循 `writing-skills` 技能来创建和测试新技能
4. 提交 PR

完整指南请参见 `skills/writing-skills/SKILL.md`。

## 更新

当你更新克隆的仓库时，技能会自动更新：

```bash
cd ~/.claude/superpowers-plus && git pull
```

## 许可证

MIT 许可证 - 详见 LICENSE 文件

## 支持

- **仓库**: https://github.com/xhyqaq/superpowers-plus
- **问题**: https://github.com/xhyqaq/superpowers-plus/issues
