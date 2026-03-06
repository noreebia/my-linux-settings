#!/bin/bash
set -e

# copy the files in claude-code of this current repo to ~/.claude
command -v jq >/dev/null 2>&1 || sudo apt install jq -y
cp -r ./claude-code/* ~/.claude/
rm -rf ~/.claude/statusline*.sh

# Rename a CLAUDE_*.md file to CLAUDE.md, then clean up any remaining ones
first_detected_file=""
for claude_md_variant in ~/.claude/CLAUDE_*.md; do
    [ -f "$claude_md_variant" ] || continue
    if [ -z "$first_detected_file" ]; then
        first_detected_file="$claude_md_variant"
        mv -- "$claude_md_variant" ~/.claude/CLAUDE.md
    else
        rm -f -- "$claude_md_variant"
    fi
done