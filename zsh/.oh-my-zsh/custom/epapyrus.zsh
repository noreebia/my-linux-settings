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
alias rmsdh2="/bin/rm -rf /ePapyrus/sd/resources/h2/*"


# Chrome-style recursive copy: file.txt -> file (1).txt
ccp() {
    local src="${1%/}"
    local dst="${2%/}"

    if [[ ! -d "$src" ]]; then
        echo "Error: Source '$src' is not a directory."
        return 1
    fi

    # Loop through every file in the source directory
    find "$src" -type f | while read -r src_file; do
        # Calculate destination path
        local rel_path="${src_file#$src/}"
        local dest_file="$dst/$rel_path"
        local dest_dir=$(dirname "$dest_file")

        mkdir -p "$dest_dir"

        # If conflict, find the next available (n) suffix
        if [[ -e "$dest_file" ]]; then
            local base="${dest_file%.*}"
            local ext="${dest_file##*.}"
            # Handle files without extensions
            [[ "$dest_file" == "$base" ]] && ext="" || ext=".$ext"
            
            local i=1
            while [[ -e "$base ($i)$ext" ]]; do
                ((i++))
            done
            dest_file="$base ($i)$ext"
        fi

        cp "$src_file" "$dest_file"
    done
    echo "Successfully copied '$src' to '$dst' with Chrome-style naming."
}

alias ccp-agents="ccp ./agents ~/code_linux/agents"