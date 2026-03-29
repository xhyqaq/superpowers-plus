# Installing Superpowers Plus for OpenCode

## Prerequisites

- [OpenCode.ai](https://opencode.ai) installed

## Installation

Add superpowers-plus to the `plugin` array in your `opencode.json` (global or project-level):

```json
{
  "plugin": ["superpowers-plus@git+https://github.com/xhyqaq/superpowers-plus.git"]
}
```

Restart OpenCode. That's it — the plugin auto-installs and registers all skills.

Verify by asking: "Tell me about your superpowers plus"

## Migrating from the old symlink-based install

If you previously installed superpowers-plus using `git clone` and symlinks, remove the old setup:

```bash
# Remove old symlinks
rm -f ~/.config/opencode/plugins/superpowers-plus.js
rm -rf ~/.config/opencode/skills/superpowers-plus

# Optionally remove the cloned repo
rm -rf ~/.config/opencode/superpowers-plus

# Remove skills.paths from opencode.json if you added one for superpowers-plus
```

Then follow the installation steps above.

## Usage

Use OpenCode's native `skill` tool:

```
use skill tool to list skills
use skill tool to load superpowers-plus/brainstorming
```

## Updating

Superpowers Plus updates automatically when you restart OpenCode.

To pin a specific version:

```json
{
  "plugin": ["superpowers-plus@git+https://github.com/xhyqaq/superpowers-plus.git#main"]
}
```

## Troubleshooting

### Plugin not loading

1. Check logs: `opencode run --print-logs "hello" 2>&1 | grep -i superpowers-plus`
2. Verify the plugin line in your `opencode.json`
3. Make sure you're running a recent version of OpenCode

### Skills not found

1. Use `skill` tool to list what's discovered
2. Check that the plugin is loading (see above)

### Tool mapping

When skills reference Claude Code tools:
- `TodoWrite` → `todowrite`
- `Task` with subagents → `@mention` syntax
- `Skill` tool → OpenCode's native `skill` tool
- File operations → your native tools

## Getting Help

- Report issues: https://github.com/xhyqaq/superpowers-plus/issues
- Full documentation: https://github.com/xhyqaq/superpowers-plus/blob/main/docs/README.opencode.md
