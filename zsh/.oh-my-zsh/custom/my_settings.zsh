
alias upd="sudo apt update && sudo apt upgrade -y"
alias cleanup="sudo apt autoremove -y && sudo apt autoclean && sudo apt clean"
alias cue="cleanup && upd && exit"
alias uc="upd && cleanup"
alias uce="upd && cleanup && exit"
alias ll="ls -al"

alias git-prune-local="git fetch -p && git branch -vv | awk '/: gone] / {print \$1}' | xargs -r git branch -D"
alias git-prune-local-dry="git branch -vv | awk '/: gone] / {print \$1}'"
alias gpl="git-prune-local"
alias gpld="git-prune-local-dry"
alias gpfl="git push --force-with-lease"

alias szsh="source ~/.zshrc"
alias vizsh="vi ~/.zshrc"
alias t="tmux"

alias chmodsh="chmod +x *.sh"
alias chmodx="chmod +x"

alias gh-switch-push="gh auth switch && git push"
alias gh-switch-push-switch="gh auth switch && git push && gh auth switch"

cdc() {
  cd ~/code 2>/dev/null || cd ~/Code 2>/dev/null || echo "Neither directory exists!"
}

git_sync_all() {
    for dir in */; do
        local dir_name="${dir%/}"

        if [[ -d "${dir}.git" ]]; then
            echo "--- Syncing: $dir_name ---"
            (
                cd "$dir" || { echo "Error: Could not enter $dir_name"; return 1 }

                git fetch --all --prune || { echo "Error: fetch failed in $dir_name"; return 1 }

                if git rev-parse --abbrev-ref --symbolic-full-name @{u} >/dev/null 2>&1; then
                    git merge --ff-only @{u} || echo "Warning: cannot fast-forward $dir_name (diverged or has local commits)"
                else
                    echo "Skipping pull: no upstream for current branch in $dir_name"
                fi
            )
        else
            echo "Skipping: $dir_name (Not a git repo)"
        fi
    done
    echo "--- Finished processing all directories ---"
}

alias git-sync-all='git_sync_all'

# Initialize, commit, and publish a repo to GitHub
# Usage: gh-publish [public|private]
gh-publish() {
  # Guard: Check if a .git directory already exists to avoid nesting
  if [ -d ".git" ]; then
    echo "⚠️ Error: This directory is already a Git repository."
    return 1
  fi

  # Default to private if no argument is provided
  local visibility=${1:-private}
  
  git init && \
  git add . && \
  git commit -m "Initial commit" && \
  git branch -M main && \
  gh repo create --source=. --"$visibility" --push
}

setopt NULL_GLOB