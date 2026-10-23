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
    # Microsoft's official "latest stable" redirect - resolves to whatever the current stable
    # release is at build time, instead of a hardcoded commit/version that goes stale.
    wget -q https://update.code.visualstudio.com/latest/linux-deb-x64/stable -O ./vscode.deb
    apt-get update
    apt-get install -y ./vscode.deb
    rm ./vscode.deb
    # The .deb's postinst no longer adds this apt source file itself - remove it if present, but
    # don't fail the build if it isn't there.
    rm -f /etc/apt/sources.list.d/vscode.list
else
    echo "VS Code is already installed"
fi

# Run
if [ $INSTALL_ONLY = 0 ] ; then
    echo "Starting VS Code"
    /usr/share/code/code --no-sandbox --unity-launch $WORKSPACE_HOME
    sleep 10
fi
