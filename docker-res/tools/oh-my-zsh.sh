#!/bin/sh
if ! hash zsh 2>/dev/null; then
    echo "Installing Oh My ZSH"
    apt-get update
    apt-get install --yes zsh
    yes | sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    git clone https://github.com/zsh-users/zsh-history-substring-search ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-history-substring-search
    printf "export ZSH=\"/root/.oh-my-zsh\"\nZSH_THEME=\"robbyrussell\"\nplugins=(git colorize extract pip zsh-autosuggestions history-substring-search zsh-syntax-highlighting)\nsource \$ZSH/oh-my-zsh.sh" > ~/.zshrc 
fi

echo "Sourcing ZSH"
zsh