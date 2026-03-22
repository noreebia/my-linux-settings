#!/bin/bash
set -e

# Copy AGENTS_GLOBAL.md as AGENTS.md to ~/.codex
mkdir -p ~/.codex
cp ./llm-agents/AGENTS_GLOBAL.md ~/.codex/AGENTS.md

mkdir -p ~/.agents
cp -r ./llm-agents/claude-code/skills ~/.codex/skills

echo "Codex settings updated successfully."
