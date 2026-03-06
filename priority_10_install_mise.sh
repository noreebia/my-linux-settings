#!/bin/bash
set -e

curl https://mise.run | sh
echo 'eval "$(~/.local/bin/mise activate zsh)"' >> ~/.zshrc
# or if I use bash instead of zsh, I can run this line instead:
# echo 'eval "$(~/.local/bin/mise activate bash)"' >> ~/.bashrc
echo "Mise has been activated! Run 'source ~/.zshrc' or start a new terminal to apply changes."