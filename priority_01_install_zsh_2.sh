#!/bin/bash
set -e

ZSH_PLUGIN_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins"

if [ ! -d "$ZSH_PLUGIN_DIR/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_PLUGIN_DIR/zsh-autosuggestions"
fi

if [ ! -d "$ZSH_PLUGIN_DIR/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_PLUGIN_DIR/zsh-syntax-highlighting"
fi

if [ ! -d "$ZSH_PLUGIN_DIR/you-should-use" ]; then
    git clone https://github.com/MichaelAquilina/zsh-you-should-use.git "$ZSH_PLUGIN_DIR/you-should-use"
fi

for plugin in zsh-autosuggestions zsh-syntax-highlighting you-should-use; do
    if ! grep -q "^plugins=.*$plugin" ~/.zshrc; then
        sed -i "s/^plugins=(\(.*\))/plugins=(\1 $plugin)/" ~/.zshrc
    fi
done

cp -r ./zsh/.oh-my-zsh/* ~/.oh-my-zsh/

echo ".zshrc configuration has been completed. Run 'source ~/.zshrc' or start a new terminal to apply changes."
