#!/bin/bash
set -eo pipefail

if command -v mise >/dev/null 2>&1; then
    MISE_COMMAND="mise"
elif [ -x "$HOME/.local/bin/mise" ]; then
    MISE_COMMAND="~/.local/bin/mise"
else
    curl -fsSL https://mise.run | sh
    "$HOME/.local/bin/mise" --version
    MISE_COMMAND="~/.local/bin/mise"
    echo "Mise installed successfully."
fi

configure_activation() {
    local shell_name="$1"
    local rc_file="$2"
    local activation_line="eval \"\$($MISE_COMMAND activate $shell_name)\""
    local local_activation_line="eval \"\$(~/.local/bin/mise activate $shell_name)\""
    local path_activation_line="eval \"\$(mise activate $shell_name)\""

    # Recognize either supported form so reruns after activation do not add a duplicate.
    if [ -f "$rc_file" ]; then
        if grep -qxF "$local_activation_line" "$rc_file" || grep -qxF "$path_activation_line" "$rc_file"; then
            return
        fi
    fi

    mkdir -p "$(dirname "$rc_file")"
    printf '\n%s\n' "$activation_line" >> "$rc_file"
}

configure_activation bash "$HOME/.bashrc"

if command -v zsh >/dev/null 2>&1; then
    configure_activation zsh "${ZDOTDIR:-$HOME}/.zshrc"
fi

echo "Mise activation configured. Open a new terminal to apply changes."
