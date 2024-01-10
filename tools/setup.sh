#!/bin/bash

## Install dependencies for environments

# Node via nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

# Build-essential
sudo apt -y install build-essential

## Tmux TPM & config copy
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
cd ~ && ln -s ~/repos/misc/dotfiles/.tmux.conf .tmux.conf

echo "💡 Press Ctrl + I to install and reload tmux conf"

## Install zsh, omz and plugins
sudo apt -y install zsh
chsh -s $(which zsh)

# Oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# omz plugins
git clone https://github.com/svenXY/timewarrior ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/timewarrior
git clone https://github.com/chrisands/zsh-yarn-completions ~/.oh-my-zsh/custom/plugins/zsh-yarn-completions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

# Copy zshrc template
cp ~/repos/misc/dotfiles/zshrc.template ~/.zshrc

## Timewarrior
cd ~ && git clone git@github.com:bogdan-calapod/timew.git .timewarrior
sudo apt -y install timewarrior

## Clone configurations

# Neovim
cd ~/.config/
git clone git@github.com:bogdan-calapod/nvim-dotfiles.git nvim

# Lazygit
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar xf lazygit.tar.gz lazygit
sudo install lazygit /usr/local/bin
mkdir ~/.config/lazygit ; cd ~/.config/lazygit ; ln -s ~/repos/misc/dotfiles/config/lazygit/config.yml config.yml

## Misc other stuff
sudo apt -y install bat

