#!/bin/bash
set -e

git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

sed -i 's/^plugins=(.*)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' ~/.zshrc

cat >> ~/.zshrc << 'EOF'

alias upd="sudo apt update && sudo apt upgrade -y"
alias cleanup="sudo apt autoremove -y && sudo apt autoclean && sudo apt clean"
alias cue="cleanup && upd && exit"
alias uc="upd && cleanup"
alias uce="upd && cleanup && exit"
alias cleanup-branches='git fetch -p && for branch in $(git for-each-ref --format "%(refname) %(upstream:track)" refs/heads | awk '\''$2 == "[gone]" {sub("refs/heads/", "", $1); print $1}'\''); do git branch -D $branch; done'
alias ll="ls -al"
EOF
