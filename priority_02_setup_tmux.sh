#!/bin/bash
set -e

if ! command -v tmux &> /dev/null; then
    sudo apt install tmux -y
fi

sudo cp ./tmux/tmux.conf /etc/tmux.conf

echo "Successfully moved tmux.conf to /etc/tmux.conf. You can keep it there or copy it to ~/.tmux.conf for user-specific settings."