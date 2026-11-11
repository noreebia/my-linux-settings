#!/bin/bash
set -e

if ! command -v gemini >/dev/null 2>&1; then
    echo "Gemini CLI not found; skipping settings update."
    exit 0
fi

# Copy AGENTS_GLOBAL.md as GEMINI.md to ~/.gemini
mkdir -p ~/.gemini
cp ./llm-agents/AGENTS_GLOBAL.md ~/.gemini/GEMINI.md

echo "Gemini settings updated successfully."
