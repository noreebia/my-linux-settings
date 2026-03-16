#!/bin/bash
set -e

sudo apt update && sudo apt upgrade -y

if ! command -v zsh &> /dev/null; then
    sudo apt install zsh -y
fi

if ! dpkg -s fonts-powerline &> /dev/null; then
    sudo apt-get install fonts-powerline -y
fi

if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

echo "Zsh and Oh My Zsh setup completed successfully."
