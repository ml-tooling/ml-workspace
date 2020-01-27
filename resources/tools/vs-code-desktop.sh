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

if [ ! -f "/usr/share/code/code" ]; then
    echo "Installing VS Code. Please wait..."
    cd $RESOURCES_PATH
    wget -q https://go.microsoft.com/fwlink/?LinkID=760868 -O ./vscode.deb
    apt-get update
    apt-get install -y ./vscode.deb
    rm ./vscode.deb
    rm /etc/apt/sources.list.d/vscode.list
else
    echo "VS Code is already installed"
fi

# Run
if [ $INSTALL_ONLY = 0 ] ; then
    echo "Starting VS Code"
    /usr/share/code/code --unity-launch $WORKSPACE_HOME
    sleep 10
fi
