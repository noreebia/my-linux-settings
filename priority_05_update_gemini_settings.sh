#!/bin/bash
set -e

# Copy AGENTS_GLOBAL.md as GEMINI.md to ~/.gemini
mkdir -p ~/.gemini
cp ./llm-agents/AGENTS_GLOBAL.md ~/.gemini/GEMINI.md

echo "Gemini settings updated successfully."
