
alias upd="sudo apt update && sudo apt upgrade -y"
alias cleanup="sudo apt autoremove -y && sudo apt autoclean && sudo apt clean"
alias cue="cleanup && upd && exit"
alias uc="upd && cleanup"
alias uce="upd && cleanup && exit"
alias ll="ls -al"

alias git-prune-local="git fetch -p && git branch -vv | awk '/: gone] / {print \$1}' | xargs -r git branch -D"
alias git-prune-local-dry="git branch -vv | awk '/: gone] / {print \$1}'"
alias gpl="git-prune-local"
alias gpld="git-prune-local-dry"\
alias gpfl="git push --force-with-lease"

alias szsh="source ~/.zshrc"
alias vizsh="vi ~/.zshrc"
alias t="tmux"

cdc() {
  cd ~/code 2>/dev/null || cd ~/Code 2>/dev/null || echo "Neither directory exists!"
}

