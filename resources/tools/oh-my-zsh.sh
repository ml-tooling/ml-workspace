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
    apt-get install -y --no-install-recommends autojump git-flow git-extras ncdu htop
    pip install Pygments ranger-fm thefuck bpytop
    # Install fkill-cli: (too big - 30MB) npm install --global fkill-cli && \
    yes | sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
    # Install powerlevel10k for instant prompt
    # git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
    # https://www.reddit.com/r/zsh/comments/dht4zt/make_zsh_start_instantly_with_this_one_weird_trick/
    # Install plugins
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    git clone https://github.com/zsh-users/zsh-history-substring-search ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-history-substring-search
    git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:=~/.oh-my-zsh/custom}/plugins/zsh-completions
    git clone https://github.com/supercrabtree/k ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/k
    git clone https://github.com/chrissicool/zsh-256color ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-256color
    curl -fsSL -o $RESOURCES_PATH/instant-zsh.zsh https://gist.github.com/romkatv/8b318a610dc302bdbe1487bb1847ad99/raw

    # Use avit theme instead of typewritten: Install typewritten theme
    # git clone https://github.com/reobin/typewritten.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/typewritten
    # ln -s "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/typewritten/typewritten.zsh-theme" "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/typewritten.zsh-theme"
    # ln -s "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/typewritten/async.zsh" "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/async"
    # \nexport TYPEWRITTEN_PROMPT_LAYOUT=\"pure\"\nexport TYPEWRITTEN_COLOR_MAPPINGS=\"primary:cyan\"
    # Other good themes: avit, clean

    # Fix red arrow problem with avit theme
    sed -i 's/fg\[red\]}.${fg\[white\]})%}▶/fg\[white\]}.${fg\[white\]})%}▶/g' ~/.oh-my-zsh/themes/avit.zsh-theme

    printf "export source ZSH=\"$HOME/.oh-my-zsh\"\nZSH_THEME=\"avit\"\nDISABLE_AUTO_UPDATE=\"true\"\nZSH_AUTOSUGGEST_HIGHLIGHT_STYLE=\"fg=245\"\nplugins=(git k extract cp pip yarn npm sudo zsh-256color supervisor rsync command-not-found autojump colored-man-pages git-flow git-extras httpie python zsh-autosuggestions history-substring-search zsh-completions zsh-syntax-highlighting)\nsource \$ZSH/oh-my-zsh.sh\nLS_COLORS=\"\"\nexport LS_COLORS\nalias pcat=\"pygmentize -g\"\neval \"\$(pyenv init -)\"\neval \"\$(pyenv virtualenv-init -)\"" > ~/.zshrc

    # Also add fzf to plugins
    git clone --depth 1 https://github.com/junegunn/fzf.git $RESOURCES_PATH/.fzf
    y | $RESOURCES_PATH/.fzf/install

    # TODO install zsh completions?
    # sudo sh -c "echo 'deb http://download.opensuse.org/repositories/shells:/zsh-users:/zsh-completions/xUbuntu_16.04/ /' > /etc/apt/sources.list.d/shells:zsh-users:zsh-completions.list"
    # wget -nv https://download.opensuse.org/repositories/shells:zsh-users:zsh-completions/xUbuntu_16.04/Release.key -O Release.key
    # sudo apt-key add - < Release.key
    # sudo apt-get update
    # sudo apt-get install zsh-completions

else
    echo "ZSH is already installed"
fi


# docker, kubectl
# Run
if [ $INSTALL_ONLY = 0 ] ; then
    echo "Sourcing ZSH"
    zsh
fi
