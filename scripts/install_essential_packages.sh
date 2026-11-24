#!/bin/bash
set -e

sudo apt update && sudo apt upgrade -y
sudo apt install jq git gh -y

echo "Essential packages installed successfully."
