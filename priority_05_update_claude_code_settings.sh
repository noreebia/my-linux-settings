# copy the files in claude-code of this current repo to ~/.claude
command -v jq >/dev/null 2>&1 || sudo apt install jq -y
cp -r ./claude-code/* ~/.claude/

# if ~/.claude/CLAUDE_ACTUAL.md exists, change it to ~/.claude/CLAUDE.md
if [ -f ~/.claude/CLAUDE_ACTUAL.md ]; then
    mv ~/.claude/CLAUDE_ACTUAL.md ~/.claude/CLAUDE.md
fi