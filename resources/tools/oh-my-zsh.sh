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
    # --unattended (the officially documented non-interactive flag) is used instead of piping
    # "yes" to the installer's prompts - the older "yes |" trick left /root/.oh-my-zsh existing
    # but empty (just a dir, no git clone) whenever a prompt didn't behave as expected, which then
    # made the installer's own "$ZSH folder already exists" guard silently no-op on every future
    # run, since it bails out before doing any cloning at all if the directory is already there.
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
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

    # Fix red arrow problem with avit theme (best-effort: oh-my-zsh is cloned from master each
    # build, and this theme file's path/name has moved around upstream over the years)
    sed -i 's/fg\[red\]}.${fg\[white\]})%}▶/fg\[white\]}.${fg\[white\]})%}▶/g' ~/.oh-my-zsh/themes/avit.zsh-theme 2>/dev/null || true

    # NOTE: $HOME below is deliberately escaped (\$HOME) so it's written literally into .zshrc and
    # re-expands at shell-login time for whoever is actually logged in, instead of being expanded
    # once here (at build time, when $HOME is always /root) and baked in as a hardcoded /root path -
    # which silently breaks this file for any other user it later gets copied to.
    printf "export source ZSH=\"\$HOME/.oh-my-zsh\"\nZSH_THEME=\"avit\"\nDISABLE_AUTO_UPDATE=\"true\"\nZSH_AUTOSUGGEST_HIGHLIGHT_STYLE=\"fg=245\"\nplugins=(git k extract cp pip yarn npm sudo zsh-256color supervisor rsync command-not-found autojump colored-man-pages git-flow git-extras httpie python zsh-autosuggestions history-substring-search zsh-completions zsh-syntax-highlighting)\nsource \$ZSH/oh-my-zsh.sh\n# Standard user@host:path prompt (kept after the theme's own PROMPT so it takes precedence)\nPROMPT='%%n@%%m:%%~$ '\nLS_COLORS=\"\"\nexport LS_COLORS\nalias pcat=\"pygmentize -g\"\n# pyenv, unlike conda below, resolves itself purely via \$PATH rather than an absolute path -\n# explicitly re-add it here so it still works after 'sudo su', which resets PATH to a bare system\n# default regardless of what PATH the calling shell had.\nexport PATH=\"/resources/.pyenv/shims:/resources/.pyenv/bin:\$PATH\"\neval \"\$(pyenv init -)\"\neval \"\$(pyenv virtualenv-init -)\"" > ~/.zshrc

    # Command audit log - every interactive command, timestamped, into the workspace itself so it
    # survives container recreation (rather than /var/log, which doesn't). Uses a quoted heredoc
    # (not the printf above) so none of this gets expanded at build time - it's written completely
    # literally into .zshrc and interpreted fresh by whichever user's shell sources it later.
    cat >> ~/.zshrc <<'ZSHRC_AUDIT_LOG_EOF'

# Command audit log
mkdir -p "${WORKSPACE_HOME:-/workspace}/.workspace" 2>/dev/null
preexec() {
    print -r -- "$(date '+%Y-%m-%d %H:%M:%S') $1" >> "${WORKSPACE_HOME:-/workspace}/.workspace/history_audit.log" 2>/dev/null
}
ZSHRC_AUDIT_LOG_EOF

    # Also add fzf to plugins
    git clone --depth 1 https://github.com/junegunn/fzf.git $RESOURCES_PATH/.fzf
    # 'y' is not a real command (was silently failing every build with "y: command not found") -
    # fzf's own installer already supports a non-interactive full-install flag.
    $RESOURCES_PATH/.fzf/install --all --no-update-rc

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
