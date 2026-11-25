#!/bin/bash
set -e

if ! command -v gemini >/dev/null 2>&1; then
    echo "Gemini CLI not found; skipping settings update."
    exit 0
fi

command -v rsync >/dev/null 2>&1 || sudo apt install rsync -y
source ./scripts/llm-agents/copy_shared_skills.sh

TARGET_DIR="$HOME/.gemini"
copy_shared_skills ./llm-agents/skills "$TARGET_DIR/skills"
cp ./llm-agents/AGENTS_GLOBAL.md "$TARGET_DIR/GEMINI.md"

echo "Gemini settings updated successfully."
