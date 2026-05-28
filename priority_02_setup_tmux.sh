#!/bin/bash
set -e

if ! command -v tmux &> /dev/null; then
    sudo apt install tmux -y
fi

cp ./tmux/tmux.conf ~/.tmux.conf

echo "Tmux installed successfully by configuring ~/.tmux.conf. You can keep it there or modify it as needed."