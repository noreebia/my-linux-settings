#!/bin/bash
set -euo pipefail

SOURCE_DIR="./llm-agents/codex"
TARGET_DIR="$HOME/.codex"
CONFIG_SOURCE="$SOURCE_DIR/config.toml"
CONFIG_TARGET="$TARGET_DIR/config.toml"
MERGE_CONFIG_SCRIPT="$SOURCE_DIR/scripts/merge_codex_config.py"
SHARED_SKILLS_SOURCE="./llm-agents/skills"
CODEX_SKILLS_SOURCE="$SOURCE_DIR/skills"

command -v python3 >/dev/null 2>&1 || sudo apt install python3 -y

mkdir -p "$TARGET_DIR"

# Copy AGENTS_GLOBAL.md as AGENTS.md to ~/.codex
cp ./llm-agents/AGENTS_GLOBAL.md "$TARGET_DIR/AGENTS.md"

# Reuse shared skills while removing Claude-only frontmatter that Codex rejects.
CODEX_SKILLS_STAGE="$(mktemp -d)"
trap 'rm -rf -- "$CODEX_SKILLS_STAGE"' EXIT

rsync -a --exclude='CLAUDE.md' --exclude='/AGENTS.md' "$SHARED_SKILLS_SOURCE/" "$CODEX_SKILLS_STAGE/"
find "$CODEX_SKILLS_STAGE" -type f -name 'SKILL.md' -exec sed -i '/^argument-hint:/d' {} +

mkdir -p "$TARGET_DIR/skills"
rsync -a "$CODEX_SKILLS_STAGE/" "$TARGET_DIR/skills/"

# Overlay Codex-only skills after shared skills so deliberate Codex variants take precedence.
if [ -d "$CODEX_SKILLS_SOURCE" ]; then
  for codex_skill_dir in "$CODEX_SKILLS_SOURCE"/*/; do
    [ -d "$codex_skill_dir" ] || continue
    codex_skill_name="$(basename "$codex_skill_dir")"
    rsync -a --delete "$codex_skill_dir" "$TARGET_DIR/skills/$codex_skill_name/"
  done
fi

python3 "$MERGE_CONFIG_SCRIPT" "$CONFIG_SOURCE" "$CONFIG_TARGET"

echo "Codex settings updated successfully."
