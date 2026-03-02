sudo apt update && sudo apt upgrade -y
sudo apt install zsh -y
chsh -s /usr/bin/zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
sudo apt-get install fonts-powerline
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# modify .zshrc - change the plugins line to the following plugins=(git zsh-autosuggestions zsh-syntax-highlighting)

# modify .zshrc - add the following
# alias upd="sudo apt update && apt upgrade -y"
# alias cleanup="sudo apt autoremove -y && sudo apt autoclean && sudo apt clean"
# alias cue="cleanup && upd && exit"
# alias uc="upd && cleanup"
# alias uce="upd && cleanup && exit"
# alias git=hub
# alias cleanup-branches='git fetch -p && for branch in $(git for-each-ref --format "%(refname) %(upstream:track)" refs/heads | awk '\''$2 == "[gone]" {sub("refs/heads/", "", $1); print $1}'\''); do git branch -D $branch; done'
# alias ll="ls -al"
