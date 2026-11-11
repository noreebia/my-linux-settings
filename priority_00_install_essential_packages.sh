#!/bin/bash
set -e

sudo apt update && sudo apt upgrade -y
sudo apt install jq git gh tmux -y

echo "Essential packages installed successfully."