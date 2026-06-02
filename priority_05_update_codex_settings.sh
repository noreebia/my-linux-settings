#!/bin/bash
set -euo pipefail

SOURCE_DIR="./llm-agents/codex"
TARGET_DIR="$HOME/.codex"
CONFIG_SOURCE="$SOURCE_DIR/config.toml"
CONFIG_TARGET="$TARGET_DIR/config.toml"
MERGE_CONFIG_SCRIPT="$SOURCE_DIR/scripts/merge_tui_config.py"

command -v python3 >/dev/null 2>&1 || sudo apt install python3 -y

mkdir -p "$TARGET_DIR"

# Copy AGENTS_GLOBAL.md as AGENTS.md to ~/.codex
cp ./llm-agents/AGENTS_GLOBAL.md "$TARGET_DIR/AGENTS.md"

# Reuse Claude skills for Codex.
rsync -a --exclude='CLAUDE.md' ./llm-agents/claude-code/skills/ "$TARGET_DIR/skills/"

python3 "$MERGE_CONFIG_SCRIPT" "$CONFIG_SOURCE" "$CONFIG_TARGET"

echo "Codex settings updated successfully."
