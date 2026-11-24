#!/bin/bash
set -euo pipefail

if ! command -v zsh >/dev/null 2>&1; then
    echo "Zsh not found; skipping zoxide configuration."
    exit 0
fi

BIN_DIR="$HOME/.local/bin"
export PATH="$BIN_DIR:$PATH"

missing_packages=()
for package in curl git tar; do
    command -v "$package" >/dev/null 2>&1 || missing_packages+=("$package")
done
if [ "${#missing_packages[@]}" -gt 0 ]; then
    sudo apt install -y "${missing_packages[@]}"
fi

if ! command -v zoxide >/dev/null 2>&1; then
    curl -fsSL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
fi

if ! command -v fzf >/dev/null 2>&1; then
    FZF_DIR="$HOME/.fzf"
    if [ ! -d "$FZF_DIR" ]; then
        git clone --depth 1 https://github.com/junegunn/fzf.git "$FZF_DIR"
    fi
    # zi only needs the executable; no separate fzf shell integration is required.
    "$FZF_DIR/install" --bin
    mkdir -p "$BIN_DIR"
    ln -s "$FZF_DIR/bin/fzf" "$BIN_DIR/fzf"
fi

# Verify installation before adding commands to the user's shell configuration.
zoxide --version
fzf --version

ZSHRC="${ZDOTDIR:-$HOME}/.zshrc"
PATH_LINE='[[ ":$PATH:" == *":$HOME/.local/bin:"* ]] || export PATH="$HOME/.local/bin:$PATH"'
INIT_LINE='eval "$(zoxide init zsh)"'

mkdir -p "$(dirname "$ZSHRC")"
if ! grep -qxF "$PATH_LINE" "$ZSHRC" 2>/dev/null; then
    printf '\n%s\n' "$PATH_LINE" >> "$ZSHRC"
fi
if ! grep -qxF "$INIT_LINE" "$ZSHRC" 2>/dev/null; then
    printf '\n%s\n' "$INIT_LINE" >> "$ZSHRC"
fi

echo "Zoxide configured. Open a new terminal to use z and zi."
