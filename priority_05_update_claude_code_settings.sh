#!/bin/bash
set -e

# copy the claude-code settings from llm-agents to ~/.claude
command -v jq >/dev/null 2>&1 || sudo apt install jq -y
cp -r ./llm-agents/claude-code/* ~/.claude/

# Copy AGENTS.md as CLAUDE.md
cp ./llm-agents/AGENTS_GLOBAL.md ~/.claude/CLAUDE.md

echo "Claude Code settings updated successfully."