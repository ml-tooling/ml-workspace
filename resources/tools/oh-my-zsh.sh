#!/bin/sh

# Stops script execution if a command has an error
set -e

INSTALL_ONLY=0
# Loop through arguments and process them: https://pretzelhands.com/posts/command-line-flags
for arg in "$@"; do
    case $arg in
        -i|--install) INSTALL_ONLY=1 ; shift ;;
        *) break ;;
    esac
done

if ! hash zsh 2>/dev/null; then
    echo "Installing Oh My ZSH. Please wait..."
    apt-get update
    apt-get install --yes zsh
    # Install powerline font - required for lots of themes
    # Does not work on ubunutu 18.04: apt-get install -y --no-install-recommends fonts-powerline
    # https://github.com/powerline/fonts/issues/281#issuecomment-417473240
    cd $RESOURCES_PATH
    git clone https://github.com/powerline/fonts.git --depth=1
    cd fonts
    ./install.sh
    cd ..
    rm -rf fonts
    # Install plugins
    apt-get install -y --no-install-recommends autojump git-flow
    yes | sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    git clone https://github.com/zsh-users/zsh-history-substring-search ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-history-substring-search
    git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:=~/.oh-my-zsh/custom}/plugins/zsh-completions
    git clone https://github.com/supercrabtree/k ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/k
    git clone https://github.com/chrissicool/zsh-256color ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-256color
    printf "export ZSH=\"$HOME/.oh-my-zsh\"\nZSH_THEME=\"avit\"\nDISABLE_AUTO_UPDATE=\"true\"\nZSH_AUTOSUGGEST_HIGHLIGHT_STYLE=\"fg=245\"\nplugins=(git k extract colorize pip npm zsh-256color supervisor command-not-found autojump colored-man-pages git-flow git-extras httpie python zsh-autosuggestions history-substring-search zsh-completions zsh-syntax-highlighting)\nsource \$ZSH/oh-my-zsh.sh\nLS_COLORS=\"\"\nexport LS_COLORS\n" > ~/.zshrc 
    # TODO add z
    # Other good themes: avit, sorin, clean
else
    echo "ZSH is already installed"
fi

# docker, kubectl

    # TODO install zsh completions?
    # sudo sh -c "echo 'deb http://download.opensuse.org/repositories/shells:/zsh-users:/zsh-completions/xUbuntu_16.04/ /' > /etc/apt/sources.list.d/shells:zsh-users:zsh-completions.list"
    # wget -nv https://download.opensuse.org/repositories/shells:zsh-users:zsh-completions/xUbuntu_16.04/Release.key -O Release.key
    # sudo apt-key add - < Release.key
    # sudo apt-get update
    # sudo apt-get install zsh-completions

# Run
if [ $INSTALL_ONLY = 0 ] ; then
    echo "Sourcing ZSH"
    zsh
fi