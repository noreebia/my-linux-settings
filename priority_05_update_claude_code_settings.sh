#!/bin/bash
set -e

command -v jq >/dev/null 2>&1 || sudo apt install jq -y

SOURCE_DIR="./llm-agents/claude-code"
TARGET_DIR="$HOME/.claude"
SETTINGS_SOURCE="$SOURCE_DIR/settings.json"
SETTINGS_TARGET="$TARGET_DIR/settings.json"

# Copy non-settings files (skills, statuslines, etc.)
find "$SOURCE_DIR" -mindepth 1 -not -name "settings.json" -not -path "$SOURCE_DIR" | while read -r src; do
  rel="${src#$SOURCE_DIR/}"
  dest="$TARGET_DIR/$rel"
  if [ -d "$src" ]; then
    mkdir -p "$dest"
  else
    mkdir -p "$(dirname "$dest")"
    cp "$src" "$dest"
  fi
done

# Deep-merge settings.json: source keys overwrite existing, but existing-only keys are preserved
if [ -f "$SETTINGS_TARGET" ]; then
  jq -s '.[0] * .[1]' "$SETTINGS_TARGET" "$SETTINGS_SOURCE" > "$SETTINGS_TARGET.tmp"
  mv "$SETTINGS_TARGET.tmp" "$SETTINGS_TARGET"
else
  cp "$SETTINGS_SOURCE" "$SETTINGS_TARGET"
fi

# Copy AGENTS.md as CLAUDE.md
cp ./llm-agents/AGENTS_GLOBAL.md "$TARGET_DIR/CLAUDE.md"

echo "Claude Code settings updated successfully."