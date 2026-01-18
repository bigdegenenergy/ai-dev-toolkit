#!/bin/bash
# init-repo.sh
# Universal Claude Code Setup Initializer (v3.0)
#
# This script initializes a repository with Claude Code's virtual team setup.
# It can copy from a template directory or generate fresh configs.
#
# Features: 18 agents, 11 skills, 22 commands, 8 hooks
#
# Usage:
#   ./init-repo.sh                    # Initialize current directory
#   ./init-repo.sh /path/to/repo      # Initialize specific repo
#   ./init-repo.sh --from-global      # Copy from ~/.claude/ template
#
# For global installation (run once):
#   ./setup-claude-team.sh --global   # Sets up ~/.claude/ as template

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Determine target directory
TARGET_DIR="${1:-.}"
if [[ "$1" == "--from-global" ]]; then
    TARGET_DIR="."
    USE_GLOBAL=true
else
    USE_GLOBAL=false
fi

# Resolve to absolute path
TARGET_DIR=$(cd "$TARGET_DIR" && pwd)

echo -e "${BLUE}═══════════════════════════════════════════${NC}"
echo -e "${BLUE}  Claude Code Virtual Team Initializer v3.0${NC}"
echo -e "${BLUE}═══════════════════════════════════════════${NC}"
echo ""
echo -e "Target: ${GREEN}$TARGET_DIR${NC}"

# Check if .claude already exists
if [ -d "$TARGET_DIR/.claude" ]; then
    echo -e "${YELLOW}⚠️  .claude directory already exists${NC}"
    read -p "Overwrite existing configuration? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 0
    fi
fi

# Create directory structure
echo ""
echo "Creating directory structure..."
mkdir -p "$TARGET_DIR/.claude/commands"
mkdir -p "$TARGET_DIR/.claude/agents"
mkdir -p "$TARGET_DIR/.claude/skills"
mkdir -p "$TARGET_DIR/.claude/hooks"
mkdir -p "$TARGET_DIR/.claude/templates"
mkdir -p "$TARGET_DIR/.claude/artifacts"
mkdir -p "$TARGET_DIR/.claude/metrics"

# Check for global template
GLOBAL_CLAUDE="$HOME/.claude"
if [ "$USE_GLOBAL" = true ] && [ -d "$GLOBAL_CLAUDE" ]; then
    echo -e "${GREEN}Copying from global template (~/.claude/)...${NC}"

    # Copy commands
    if [ -d "$GLOBAL_CLAUDE/commands" ]; then
        cp -r "$GLOBAL_CLAUDE/commands/"* "$TARGET_DIR/.claude/commands/" 2>/dev/null || true
        echo "  ✅ Copied commands"
    fi

    # Copy agents
    if [ -d "$GLOBAL_CLAUDE/agents" ]; then
        cp -r "$GLOBAL_CLAUDE/agents/"* "$TARGET_DIR/.claude/agents/" 2>/dev/null || true
        echo "  ✅ Copied agents"
    fi

    # Copy skills
    if [ -d "$GLOBAL_CLAUDE/skills" ]; then
        cp -r "$GLOBAL_CLAUDE/skills/"* "$TARGET_DIR/.claude/skills/" 2>/dev/null || true
        echo "  ✅ Copied skills"
    fi

    # Copy hooks
    if [ -d "$GLOBAL_CLAUDE/hooks" ]; then
        cp -r "$GLOBAL_CLAUDE/hooks/"* "$TARGET_DIR/.claude/hooks/" 2>/dev/null || true
        echo "  ✅ Copied hooks"
    fi

    # Copy templates
    if [ -d "$GLOBAL_CLAUDE/templates" ]; then
        cp -r "$GLOBAL_CLAUDE/templates/"* "$TARGET_DIR/.claude/templates/" 2>/dev/null || true
        echo "  ✅ Copied templates"
    fi

    # Copy settings (as template)
    if [ -f "$GLOBAL_CLAUDE/settings.json" ]; then
        cp "$GLOBAL_CLAUDE/settings.json" "$TARGET_DIR/.claude/settings.json"
        echo "  ✅ Copied settings.json"
    fi

    # Copy docs template
    if [ -f "$GLOBAL_CLAUDE/docs.md" ]; then
        cp "$GLOBAL_CLAUDE/docs.md" "$TARGET_DIR/.claude/docs.md"
        echo "  ✅ Copied docs.md"
    fi

    # Copy notifications template if exists
    if [ -f "$GLOBAL_CLAUDE/notifications.json.template" ]; then
        cp "$GLOBAL_CLAUDE/notifications.json.template" "$TARGET_DIR/.claude/notifications.json.template"
        echo "  ✅ Copied notifications.json.template"
    fi
else
    echo -e "${YELLOW}No global template found. Run setup-claude-team.sh --global first.${NC}"
    echo "Creating minimal configuration..."

    # Create minimal settings.json
    cat > "$TARGET_DIR/.claude/settings.json" << 'EOF'
{
  "permissions": {
    "allow": [
      "Bash(git*)",
      "Bash(npm*)",
      "Bash(ls*)",
      "Read(*)",
      "Glob(*)",
      "Grep(*)"
    ],
    "deny": []
  },
  "hooks": {},
  "defaults": {
    "model": "claude-opus-4-5-20251101",
    "thinking_enabled": true
  }
}
EOF
    echo "  ✅ Created minimal settings.json"

    # Create docs.md template
    cat > "$TARGET_DIR/.claude/docs.md" << 'EOF'
# Project Documentation

## Quick Reference

### Commands Available
Run `claude /help` to see available commands.

### Project Conventions
- [Add your conventions here]

### Things Claude Should Know
- [Add project-specific context here]

## Update Log
- [Date]: Initial setup
EOF
    echo "  ✅ Created docs.md template"
fi

# Make hooks executable
chmod +x "$TARGET_DIR/.claude/hooks/"* 2>/dev/null || true

# Create CLAUDE.md if it doesn't exist
if [ ! -f "$TARGET_DIR/CLAUDE.md" ]; then
    echo ""
    echo "Creating CLAUDE.md project memory file..."
    cat > "$TARGET_DIR/CLAUDE.md" << 'EOF'
# CLAUDE.md - Project Memory

This file provides context for Claude Code when working on this project.

## Project Overview

**Purpose:** [Describe what this project does]

**Tech Stack:** [List key technologies]

## Quick Reference

- See `.claude/docs.md` for team documentation
- See `.claude/commands/` for available slash commands
- See `.claude/agents/` for specialized agents

## Project-Specific Rules

### Do
- [Add project-specific best practices]

### Don't
- [Add things to avoid]

## Getting Started

```bash
# Install dependencies
npm install  # or pip install, cargo build, etc.

# Run tests
npm test

# Start development
npm run dev
```

## Update Log

- [Date]: Project initialized with Claude Code setup
EOF
    echo "  ✅ Created CLAUDE.md"
fi

# Add to .gitignore if needed
GITIGNORE="$TARGET_DIR/.gitignore"
if [ -f "$GITIGNORE" ]; then
    # Check if .claude/metrics is already ignored
    if ! grep -q ".claude/metrics" "$GITIGNORE"; then
        echo "" >> "$GITIGNORE"
        echo "# Claude Code" >> "$GITIGNORE"
        echo ".claude/metrics/" >> "$GITIGNORE"
        echo ".claude/artifacts/" >> "$GITIGNORE"
        echo ".claude/settings.local.json" >> "$GITIGNORE"
        echo ".claude/notifications.json" >> "$GITIGNORE"
        echo "  ✅ Updated .gitignore"
    fi
else
    # Create .gitignore with Claude Code entries
    cat > "$GITIGNORE" << 'EOF'
# Claude Code
.claude/metrics/
.claude/artifacts/
.claude/settings.local.json
.claude/notifications.json
EOF
    echo "  ✅ Created .gitignore"
fi

# Summary
echo ""
echo -e "${GREEN}═══════════════════════════════════════════${NC}"
echo -e "${GREEN}  Setup Complete! (v3.0)${NC}"
echo -e "${GREEN}═══════════════════════════════════════════${NC}"
echo ""
echo "Directory structure:"
echo "  $TARGET_DIR/"
echo "  ├── .claude/"
echo "  │   ├── commands/    (22 slash commands)"
echo "  │   ├── agents/      (18 specialized agents)"
echo "  │   ├── skills/      (11 auto-discovered skills)"
echo "  │   ├── hooks/       (8 automated hooks)"
echo "  │   ├── templates/   (project templates)"
echo "  │   ├── artifacts/   (gitignored, PR context)"
echo "  │   ├── metrics/     (gitignored, tracking)"
echo "  │   ├── settings.json"
echo "  │   └── docs.md"
echo "  └── CLAUDE.md        (project memory)"
echo ""
echo "Next steps:"
echo "  1. cd $TARGET_DIR"
echo "  2. git add .claude/ CLAUDE.md"
echo "  3. git commit -m 'chore: add Claude Code v3.0 configuration'"
echo "  4. (Optional) Copy notifications.json.template to notifications.json"
echo "  5. Start Claude: claude"
echo "  6. Try: /plan, /qa, /ship, /ralph"
echo ""
echo "Key commands:"
echo "  /plan            - Think before coding"
echo "  /qa              - Run tests until green"
echo "  /ship            - Commit, push, and PR"
echo "  /ralph           - Autonomous dev loop"
echo "  /feature-workflow - Multi-agent orchestration"
echo ""
echo -e "${BLUE}Happy coding with your virtual team!${NC}"
