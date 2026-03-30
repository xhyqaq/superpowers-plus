#!/bin/bash

# Superpowers Plus - Claude Code Installation Script
# Creates individual symlinks for each skill in ~/.claude/skills/

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
SKILLS_SRC="$REPO_DIR/skills"
SKILLS_DEST="$HOME/.claude/skills"

echo "🚀 Installing Superpowers Plus for Claude Code..."
echo ""

# Check if source directory exists
if [ ! -d "$SKILLS_SRC" ]; then
    echo "❌ Error: Skills directory not found: $SKILLS_SRC"
    exit 1
fi

# Create destination directory
mkdir -p "$SKILLS_DEST"
echo "✓ Created directory: $SKILLS_DEST"

# Counters
installed_count=0
updated_count=0
skipped_count=0

# Create symlink for each skill
cd "$SKILLS_SRC"
for skill_dir in */; do
    # Remove trailing slash
    skill_name="${skill_dir%/}"

    # Check if SKILL.md exists
    if [ ! -f "$SKILLS_SRC/$skill_name/SKILL.md" ]; then
        echo "⚠ Skipped: $skill_name (no SKILL.md found)"
        ((skipped_count++))
        continue
    fi

    # Target symlink path
    link_path="$SKILLS_DEST/superpowers:$skill_name"
    target_path="$SKILLS_SRC/$skill_name"

    # Remove existing symlink if present
    if [ -L "$link_path" ]; then
        rm "$link_path"
        ln -s "$target_path" "$link_path"
        echo "✓ Updated: superpowers:$skill_name"
        ((updated_count++))
    else
        ln -s "$target_path" "$link_path"
        echo "✓ Installed: superpowers:$skill_name"
        ((installed_count++))
    fi
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Installation complete!"
echo ""
echo "📊 Summary:"
echo "   - Installed: $installed_count skills"
if [ $updated_count -gt 0 ]; then
    echo "   - Updated: $updated_count skills"
fi
if [ $skipped_count -gt 0 ]; then
    echo "   - Skipped: $skipped_count directories"
fi
echo ""
echo "🔄 Please restart Claude Code to load the new skills"
echo ""
echo "💡 Verify installation:"
echo "   ls ~/.claude/skills/ | grep superpowers:"
echo ""
