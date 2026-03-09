#!/bin/bash

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}"; )" &> /dev/null && pwd; )"
cd "$SCRIPT_DIR"
./priority_01_install_zsh_2.sh
./priority_02_setup_tmux.sh
./priority_05_update_claude_code_settings.sh
./priority_10_install_mise.sh

