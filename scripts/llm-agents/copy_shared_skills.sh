# Sourced by the agent settings updaters.
copy_shared_skills() {
    local source_dir="$1" target_dir="$2"
    local category_index entry skill_dir skill_name
    local -a category_dirs=("$source_dir")
    local -a skill_dirs=()
    local -A skill_sources=()

    if [[ ! -d "$source_dir" ]]; then
        printf 'Shared skills directory not found: %s\n' "$source_dir" >&2
        return 1
    fi

    # A directory with SKILL.md is a complete skill, including its subdirectories.
    for ((category_index = 0; category_index < ${#category_dirs[@]}; category_index++)); do
        for entry in "${category_dirs[category_index]}"/*; do
            [[ -d "$entry" ]] || continue
            if [[ -f "$entry/SKILL.md" ]]; then
                skill_dirs+=("$entry")
            elif [[ ! -L "$entry" ]]; then
                # Traverse real category directories to avoid symlink cycles.
                category_dirs+=("$entry")
            fi
        done
    done

    # Validate before copying so a name collision cannot overwrite a skill.
    for skill_dir in "${skill_dirs[@]}"; do
        skill_name="${skill_dir##*/}"
        if [[ -n "${skill_sources[$skill_name]+present}" ]]; then
            printf 'Duplicate shared skill folder "%s": %s and %s\n' \
                "$skill_name" "${skill_sources[$skill_name]}" "$skill_dir" >&2
            return 1
        fi
        skill_sources["$skill_name"]="$skill_dir"
    done

    mkdir -p -- "$target_dir" || return
    if (( ${#skill_dirs[@]} )); then
        rsync -a -- "${skill_dirs[@]}" "$target_dir/"
    fi
}
