#!/bin/bash
set -e

PLUGIN_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins"

if [ ! -d "$PLUGIN_DIR/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions "$PLUGIN_DIR/zsh-autosuggestions"
fi

if [ ! -d "$PLUGIN_DIR/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$PLUGIN_DIR/zsh-syntax-highlighting"
fi

for plugin in zsh-autosuggestions zsh-syntax-highlighting; do
    if ! grep -q "^plugins=.*$plugin" ~/.zshrc; then
        sed -i "s/^plugins=(\(.*\))/plugins=(\1 $plugin)/" ~/.zshrc
    fi
done

grep -q 'alias upd=' ~/.zshrc || echo 'alias upd="sudo apt update && sudo apt upgrade -y"' >> ~/.zshrc
grep -q 'alias cleanup=' ~/.zshrc || echo 'alias cleanup="sudo apt autoremove -y && sudo apt autoclean && sudo apt clean"' >> ~/.zshrc
grep -q 'alias cue=' ~/.zshrc || echo 'alias cue="cleanup && upd && exit"' >> ~/.zshrc
grep -q 'alias uc=' ~/.zshrc || echo 'alias uc="upd && cleanup"' >> ~/.zshrc
grep -q 'alias uce=' ~/.zshrc || echo 'alias uce="upd && cleanup && exit"' >> ~/.zshrc
grep -q 'alias git-prune-local=' ~/.zshrc || cat >> ~/.zshrc << 'ALIASES'
alias git-prune-local="git fetch -p && git branch -vv | awk '/: gone] / {print \$1}' | xargs -r git branch -D"
alias git-prune-local-dry="git branch -vv | awk '/: gone] / {print \$1}'"
alias gpl=git-prune-local
alias gpld=git-prune-local-dry
ALIASES
grep -q 'alias ll=' ~/.zshrc || echo 'alias ll="ls -al"' >> ~/.zshrc

grep -q 'cdc()' ~/.zshrc || cat >> ~/.zshrc << 'EOF'
cdc() {
  cd ~/code 2>/dev/null || cd ~/Code 2>/dev/null || echo "Neither directory exists!"
}
EOF

echo "Done! Run 'source ~/.zshrc' or start a new terminal to apply changes."
