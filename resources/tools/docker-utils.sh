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

if ! hash docker 2>/dev/null; then
    echo "Installing Docker Client. Please wait..."
    mkdir -p $RESOURCES_PATH"/docker"
    cd $RESOURCES_PATH"/docker"
    wget https://get.docker.com/builds/Linux/x86_64/docker-latest.tgz -O ./docker.tar.gz
    tar xfz ./docker.tar.gz
    rm -rf ./docker.tar.gz
    # TODO? only move the docker client to bin
    mv ./docker/docker /usr/bin
    chmod a+rwx /usr/bin/docker
    cd $RESOURCES_PATH
    rm -rf ./docker
    curl -L "https://raw.githubusercontent.com/MartinsThiago/rdocker/master/rdocker.sh" > /usr/local/bin/rdocker &&\
    chmod a+rwx /usr/local/bin/rdocker &&\
    # Todo install docker compose
    # curl  -L "https://github.com/docker/compose/releases/download/1.7.1/docker-compose-`uname -s`-`uname -m`" > /usr/local/bin/docker-compose &&\
    # chmod +x /usr/local/bin/docker-compose
    pip install -U --no-cache-dir docker
else
    echo "Docker Client is already installed"
fi

# Install vscode docker extension 
if hash code 2>/dev/null; then
    # https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-docker
    LD_LIBRARY_PATH="" LD_PRELOAD="" code --user-data-dir=$HOME/.config/Code/ --extensions-dir=$HOME/.vscode/extensions/ --install-extension ms-azuretools.vscode-docker
else
    echo "Please install the desktop version of vscode via the vs-code-desktop.sh script to install docker vscode extensions."
fi

# Run
if [ $INSTALL_ONLY = 0 ] ; then
    echo "Use Docker Client via command line:"
    docker --help
    sleep 20
fi