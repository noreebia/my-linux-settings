#!/bin/bash

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}"; )" &> /dev/null && pwd; )"
cd "$SCRIPT_DIR"
./scripts/install_essential_packages.sh
./scripts/zsh/2_configure_essential_plugins.sh
./scripts/zsh/3_configure_zioxide.sh
./scripts/tmux/setup_tmux.sh
./scripts/llm-agents/update_claude_code_settings.sh
./scripts/llm-agents/update_codex_settings.sh
./scripts/llm-agents/update_gemini_settings.sh
./scripts/mise/install_mise.sh

echo "All configuration scripts completed successfully."

