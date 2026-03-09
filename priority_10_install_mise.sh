#!/bin/bash
set -e

if ! command -v mise &> /dev/null; then
    curl https://mise.run | sh
fi
grep -qF 'eval "$(~/.local/bin/mise activate zsh)"' ~/.zshrc || echo 'eval "$(~/.local/bin/mise activate zsh)"' >> ~/.zshrc
# or if I use bash instead of zsh, I can run this line instead:
# echo 'eval "$(~/.local/bin/mise activate bash)"' >> ~/.bashrc
echo "Mise has been activated! Run 'source ~/.zshrc' or start a new terminal to apply changes."