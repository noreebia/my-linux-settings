#!/bin/bash
set -e

sudo apt update && sudo apt upgrade -y
sudo apt install zsh -y
sudo apt-get install fonts-powerline -y
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"