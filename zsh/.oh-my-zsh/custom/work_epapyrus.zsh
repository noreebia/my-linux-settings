sdhomeset() {
    local parent_dir="/ePapyrus"
    local link_path="/ePapyrus/sd"
    local real_folder="$1"

    # 1. Validation: Does the input folder actually exist?
    if [ ! -d "$real_folder" ]; then
        echo "Error: Source directory '$real_folder' does not exist."
        return 1
    fi

    # 2. Ensure the parent /ePapyrus exists and is a directory
    if [ ! -d "$parent_dir" ]; then
        echo "Creating parent directory $parent_dir..."
        sudo mkdir -p "$parent_dir"
    fi

    # 3. Cleanup: If /ePapyrus/sd exists (as a file, folder, or link), remove it
    if [ -e "$link_path" ] || [ -L "$link_path" ]; then
        echo "Updating existing link at $link_path..."
        sudo rm -rf "$link_path"
    fi

    # 4. Execution: Create the symlink pointing to your input
    # Use realpath to handle relative paths correctly
    sudo ln -sv "$(realpath "$real_folder")" "$link_path"

    echo "Success: $link_path now points to $(realpath "$real_folder")"
}

alias sdhomecd="cd /ePapyrus/sd"
alias sdhomels="ls -al /ePapyrus/sd"
alias sdhomermh2="/bin/rm -rf /ePapyrus/sd/resources/h2/*"

sdhomejdk8set() {
    local parent_dir="/ePapyrus-jdk8"
    local link_path="/ePapyrus-jdk8/sd"
    local real_folder="$1"

    # 1. Validation: Does the input folder actually exist?
    if [ ! -d "$real_folder" ]; then
        echo "Error: Source directory '$real_folder' does not exist."
        return 1
    fi

    # 2. Ensure the parent /ePapyrus-jdk8 exists and is a directory
    if [ ! -d "$parent_dir" ]; then
        echo "Creating parent directory $parent_dir..."
        sudo mkdir -p "$parent_dir"
    fi

    # 3. Cleanup: If /ePapyrus-jdk8/sd exists (as a file, folder, or link), remove it
    if [ -e "$link_path" ] || [ -L "$link_path" ]; then
        echo "Updating existing link at $link_path..."
        sudo rm -rf "$link_path"
    fi

    # 4. Execution: Create the symlink pointing to your input
    # Use realpath to handle relative paths correctly
    sudo ln -sv "$(realpath "$real_folder")" "$link_path"

    echo "Success: $link_path now points to $(realpath "$real_folder")"
}

alias sdhomejdk8cd="cd /ePapyrus-jdk8/sd"
alias sdhomejdk8ls="ls -al /ePapyrus-jdk8/sd"
alias sdhomejdk8rmh2="/bin/rm -rf /ePapyrus-jdk8/sd/resources/h2/*"

webrenderset() {
    local target="/ePapyrus/sd/bin/webRender"
    local link_path="./webRender"

    # Only apply the safety guard when we'd actually be deleting something.
    if [ -e "$link_path" ] || [ -L "$link_path" ]; then
        if [[ "$PWD" == /ePapyrus/* ]]; then
            echo "Error: $link_path already exists and \$PWD ($PWD) is under /ePapyrus/."
            echo "Refusing to auto-delete inside the ePapyrus tree. Remove it manually if intended."
            return 1
        fi
        echo "Removing existing $link_path..."
        /bin/rm -rf "$link_path"
    fi

    ln -sv "$target" "$link_path"
}

alias ccp-agents="cp -r ./agents/* ~/code_linux/agents/"

# Release a new version from develop to master
release-streamdocs-packager() {
  if [ -z "$1" ]; then
    echo "Usage: release-streamdocs-packager <tag_name>"
    return 1
  fi

  git switch master && \
  git merge develop && \
  git tag "$1" && \
  git push origin "$1" && \
  git push origin master
}

# Usage: git-clone-branch <url> <branch> [directory]
git-clone-branch() {
  if [[ -z "$1" || -z "$2" ]]; then
    echo "Usage: git-clone-branch <repo_url> <branch_name> [target_directory]"
    return 1
  fi

  local url=$1
  local branch=$2
  local dir=$3

  if [[ -n "$dir" ]]; then
    # If a directory is provided, use it
    echo "Cloning branch '$branch' into folder '$dir'..."
    git clone --branch "$branch" --single-branch "$url" "$dir"
  else
    # Fallback to default Git behavior (uses repo name)
    echo "Cloning branch '$branch' into default folder..."
    git clone --branch "$branch" --single-branch "$url"
  fi
}

# 2. Add a specific branch to an existing single-branch clone
# Usage: git-add-branch <branch>
git-add-branch() {
  if [[ -z "$1" ]]; then
    echo "Usage: git-add-branch <branch_name>"
    return 1
  fi

  if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    echo "Error: You are not inside a git repository."
    return 1
  fi

  echo "Expanding local config to include: $1"
  git remote set-branches --add origin "$1"
  git fetch origin "$1"
  git checkout "$1"
}