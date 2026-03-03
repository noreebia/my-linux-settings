# copy the files in claude-code of this current repo to ~/.claude
command -v jq >/dev/null 2>&1 || sudo apt install jq -y
cp -r ./claude-code/* ~/.claude/