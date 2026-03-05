#!/bin/bash
set -e

# copy the files in claude-code of this current repo to ~/.claude
command -v jq >/dev/null 2>&1 || sudo apt install jq -y
cp -r ./claude-code/* ~/.claude/

# Rename a CLAUDE_*.md file to CLAUDE.md, then clean up any remaining ones
first_variant=""
for f in ~/.claude/CLAUDE_*.md; do
    [ -f "$f" ] || continue
    if [ -z "$first_variant" ]; then
        first_variant="$f"
        mv -- "$f" ~/.claude/CLAUDE.md
    else
        rm -f -- "$f"
    fi
done