# Superpowers 项目

这是一个为 Claude Code 提供增强技能系统的项目。

## 可复用资产索引使用指南

在实现任何新组件、函数或模式之前，Claude 应该：

1. 检查本文件中的"可复用资产索引"章节（如果存在）
2. 如果发现相似的资产，使用 Read 工具读取 `docs/superpowers/reuse/<name>/README.md` 获取详细信息
3. 优先复用或扩展现有实现，而不是创建重复代码

**常见场景提示**：
- 添加 UI 组件时（按钮、弹窗、提示等）
- 实现并发控制时（锁、队列、防抖等）
- 编写工具函数时（日期格式化、验证、API 封装等）
- 创建数据结构时（缓存、状态机、事件总线等）

**注意**：此索引是纯导航目录，实际代码和详细文档在对应的路径下。按需读取可以节省上下文窗口。

---

# 可复用资产索引

目前暂无已记录的可复用资产。当项目中出现明显可复用的代码时，使用 `superpowers:reusable-assets-index` 技能记录到此处。

---

# 代码规范

本章节记录项目级别的设计原则、命名约定、接口模式和架构指南。这些是指导性内容（WHY/WHAT），而非具体实现（HOW）。

**使用指南**：
- 在代码审查、设计讨论或架构决策时参考本章节
- 优先遵循已记录的规范，确保一致性
- 如发现规范需要更新或补充，使用 `superpowers:maintaining-code-standards` 技能

**与可复用资产索引的区别**：
- **代码规范**：设计原则和约定（例如："所有 API 应遵循 RESTful 规范"）
- **可复用资产索引**：具体代码实现（例如："使用 `docs/superpowers/reuse/api-wrapper/` 中的 HTTP 客户端"）

---

## API Design

目前暂无已记录的 API 设计规范。

## Naming Conventions

目前暂无已记录的命名约定。

## Architecture Patterns

目前暂无已记录的架构模式。

## Error Handling

目前暂无已记录的错误处理规范。

## Testing Practices

目前暂无已记录的测试实践规范。

## Performance Guidelines

目前暂无已记录的性能指南。

## Security Practices

目前暂无已记录的安全实践规范。

---

## 项目结构索引

### Skills (技能定义)
- **位置**: `skills/*/SKILL.md`
- **核心技能目录**:
  - `skills/brainstorming/` - 头脑风暴技能
  - `skills/executing-plans/` - 执行计划技能
  - `skills/writing-plans/` - 编写计划技能
  - `skills/systematic-debugging/` - 系统化调试技能
  - `skills/test-driven-development/` - TDD 技能
  - `skills/writing-skills/` - 编写技能的技能
  - `skills/requesting-code-review/` - 请求代码审查技能
  - `skills/receiving-code-review/` - 接收代码审查技能
  - `skills/finishing-a-development-branch/` - 完成开发分支技能
  - `skills/dispatching-parallel-agents/` - 并行代理调度技能
  - `skills/using-superpowers/` - 使用超能力技能
  - `skills/using-git-worktrees/` - 使用 Git 工作树技能
  - `skills/reusable-assets-index/` - 可复用资产索引技能
  - `skills/maintaining-code-standards/` - 代码规范维护技能
  - `skills/verification-before-completion/` - 完成前验证技能

### Agents (代理定义)
- **位置**: `agents/*.md`
- **文件**: `agents/code-reviewer.md` - 代码审查代理

### Commands (命令定义)
- **位置**: `commands/*.md`
- **核心命令**:
  - `commands/brainstorm.md` - 头脑风暴命令
  - `commands/write-plan.md` - 编写计划命令
  - `commands/execute-plan.md` - 执行计划命令

### Tests (测试)
- **位置**: `tests/**/*`
- **主要测试目录**:
  - `tests/claude-code/` - Claude Code 集成测试（shell 脚本）
  - `tests/explicit-skill-requests/` - 显式技能请求测试
  - `tests/skill-triggering/` - 技能触发测试
  - `tests/brainstorm-server/` - 头脑风暴服务器测试（JavaScript）
  - `tests/subagent-driven-dev/` - 子代理驱动开发测试

### Documentation (文档)
- **位置**: `docs/`
- **核心文档**:
  - `docs/testing.md` - 测试文档
  - `docs/plans/` - 计划文档
  - `docs/superpowers/` - 超能力相关文档
  - `docs/README.codex.md` - Codex 集成文档
  - `docs/README.opencode.md` - OpenCode 集成文档

### Hooks (钩子)
- **位置**: `hooks/`
- **文件**:
  - `hooks/hooks.json` - 钩子配置
  - `hooks/session-start` - 会话启动钩子脚本

### Plugin Code (插件代码)
- **位置**: `.opencode/plugins/superpowers.js`
- **说明**: OpenCode 插件实现

### 根目录文件
- `README.md` / `README.zh-CN.md` - 项目说明
- `RELEASE-NOTES.md` - 发布说明
- `CHANGELOG.md` - 变更日志
- `package.json` - npm 包配置

## 搜索指南

### ✅ 推荐的搜索方式

1. **查找技能定义**:
   ```
   Glob: skills/*/SKILL.md
   Grep: pattern="关键词", path="skills"
   ```

2. **查找测试**:
   ```
   Glob: tests/**/*.sh (Shell 测试)
   Glob: tests/**/*.js (JavaScript 测试)
   ```

3. **搜索代码内容**:
   ```
   Grep: pattern="函数名或关键词", path="skills" 或 "tests"
   ```

### ⚠️ 注意事项

- 技能定义文件名统一为 `SKILL.md`
- 测试主要是 shell 脚本（.sh）和少量 JavaScript（.js）
- 项目没有 node_modules，无需担心依赖包干扰
- 大部分内容是 markdown 文档，使用 Grep 搜索内容更高效

### 🚫 避免搜索

- `.git/` - Git 内部文件
- `.DS_Store` - macOS 系统文件
- `.claude/`, `.codex/`, `.cursor-plugin/` - 工具配置目录
