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
alias ccp-agents="cp -r ./agents/* ~/code_linux/agents/"