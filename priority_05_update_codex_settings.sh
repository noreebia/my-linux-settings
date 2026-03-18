#!/bin/bash
set -e

# Copy AGENTS_GLOBAL.md as AGENTS.md to ~/.codex
mkdir -p ~/.codex
cp ./llm-agents/AGENTS_GLOBAL.md ~/.codex/AGENTS.md

echo "Codex settings updated successfully."
