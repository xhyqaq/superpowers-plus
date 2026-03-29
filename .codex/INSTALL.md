# Installing Superpowers Plus for Codex

Enable Superpowers Plus skills in Codex via native skill discovery. Just clone and symlink.

## Prerequisites

- Git

## Installation

1. **Clone the superpowers-plus repository:**
   ```bash
   git clone https://github.com/xhyqaq/superpowers-plus.git ~/.codex/superpowers-plus
   ```

2. **Create the skills symlink:**
   ```bash
   mkdir -p ~/.agents/skills
   ln -s ~/.codex/superpowers-plus/skills ~/.agents/skills/superpowers-plus
   ```

   **Windows (PowerShell):**
   ```powershell
   New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.agents\skills"
   cmd /c mklink /J "$env:USERPROFILE\.agents\skills\superpowers-plus" "$env:USERPROFILE\.codex\superpowers-plus\skills"
   ```

3. **Restart Codex** (quit and relaunch the CLI) to discover the skills.

## Migrating from old bootstrap

If you installed superpowers-plus before native skill discovery, you need to:

1. **Update the repo:**
   ```bash
   cd ~/.codex/superpowers-plus && git pull
   ```

2. **Create the skills symlink** (step 2 above) — this is the new discovery mechanism.

3. **Remove the old bootstrap block** from `~/.codex/AGENTS.md` — any block referencing `superpowers-codex bootstrap` is no longer needed.

4. **Restart Codex.**

## Verify

```bash
ls -la ~/.agents/skills/superpowers-plus
```

You should see a symlink (or junction on Windows) pointing to your Superpowers Plus skills directory.

## Updating

```bash
cd ~/.codex/superpowers-plus && git pull
```

Skills update instantly through the symlink.

## Uninstalling

```bash
rm ~/.agents/skills/superpowers-plus
```

Optionally delete the clone: `rm -rf ~/.codex/superpowers-plus`.
