#!/bin/bash
set -e

PLUGIN_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins"

if [ ! -d "$PLUGIN_DIR/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions "$PLUGIN_DIR/zsh-autosuggestions"
fi

if [ ! -d "$PLUGIN_DIR/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$PLUGIN_DIR/zsh-syntax-highlighting"
fi

sed -i 's/^plugins=(.*)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' ~/.zshrc

grep -q 'alias upd=' ~/.zshrc || echo 'alias upd="sudo apt update && sudo apt upgrade -y"' >> ~/.zshrc
grep -q 'alias cleanup=' ~/.zshrc || echo 'alias cleanup="sudo apt autoremove -y && sudo apt autoclean && sudo apt clean"' >> ~/.zshrc
grep -q 'alias cue=' ~/.zshrc || echo 'alias cue="cleanup && upd && exit"' >> ~/.zshrc
grep -q 'alias uc=' ~/.zshrc || echo 'alias uc="upd && cleanup"' >> ~/.zshrc
grep -q 'alias uce=' ~/.zshrc || echo 'alias uce="upd && cleanup && exit"' >> ~/.zshrc
grep -q 'alias cleanup-branches=' ~/.zshrc || echo 'alias cleanup-branches='"'"'git fetch -p && for branch in $(git for-each-ref --format "%(refname) %(upstream:track)" refs/heads | awk '"'"'"'"'"'"'"'"'$2 == "[gone]" {sub("refs/heads/", "", $1); print $1}'"'"'"'"'"'"'"'"'); do git branch -D $branch; done'"'"'' >> ~/.zshrc
grep -q 'alias ll=' ~/.zshrc || echo 'alias ll="ls -al"' >> ~/.zshrc
