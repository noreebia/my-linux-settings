#!/bin/bash
set -e

sudo apt update && sudo apt upgrade -y
sudo apt install jq gh -y