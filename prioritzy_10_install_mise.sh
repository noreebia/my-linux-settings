#!/bin/bash
set -e

curl https://mise.run | sh
echo 'eval "$(~/.local/bin/mise activate zsh)"' >> ~/.zshrc
# or if you don't use zsh
# echo 'eval "$(~/.local/bin/mise activate bash)"' >> ~/.bashrc