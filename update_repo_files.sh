#!/bin/bash

set -e

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Updating my-linux-settings repo..."

# # claude-code: copy each file from ~/.claude/ that exists in the repo
# echo "Updating claude-code files..."
# for file in "$REPO_DIR"/claude-code/*; do
#     filename="$(basename "$file")"
#     src="$HOME/.claude/$filename"
#     if [ -f "$src" ]; then
#         cp "$src" "$file"
#         echo "  Copied $src -> claude-code/$filename"
#     else
#         echo "  WARNING: $src not found, skipping"
#     fi
# done

# zsh/.zshrc: copy from ~/.zshrc
echo "Updating zsh/.zshrc..."
if [ -f "$HOME/.zshrc" ]; then
    cp "$HOME/.zshrc" "$REPO_DIR/zsh/.zshrc"
    echo "  Copied ~/.zshrc -> zsh/.zshrc"
else
    echo "  WARNING: ~/.zshrc not found, skipping"
fi

echo "Done!"
