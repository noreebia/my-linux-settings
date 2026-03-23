
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
alias gh-switch-push-return="gh auth switch && git push && gh auth switch"

cdc() {
  cd ~/code 2>/dev/null || cd ~/Code 2>/dev/null || echo "Neither directory exists!"
}

git_sync_all() {
    # iterate over all items in the current directory
    for dir in */; do
        # Clean up the directory name for display
        local dir_name="${dir%/}"

        # Check if the directory contains a .git folder
        if [[ -d "${dir}.git" ]]; then
            echo "--- Syncing: $dir_name ---"
            (
                # Move into directory; if it fails, skip to next
                cd "$dir" || { echo "Error: Could not enter $dir_name"; return 1 }
                
                # Execute your git (hub) sync alias
                # The '||' catch ensures the loop continues on error
                git sync || echo "Error: 'git sync' failed in $dir_name"
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