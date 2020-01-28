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

if ! hash gitkraken 2>/dev/null; then
    cd $RESOURCES_PATH
    echo "Installing Git Kraken. Please wait..."
    apt-get update
    wget https://release.gitkraken.com/linux/gitkraken-amd64.deb -O ./gitkraken.deb
    apt-get install --yes gvfs-bin gconf2
    apt-get install -y ./gitkraken.deb
    rm ./gitkraken.deb
    apt-get clean
else
    echo "Git Kraken is already installed"
fi

# Run
if [ $INSTALL_ONLY = 0 ] ; then
    echo "Starting Git Kraken..."
    echo "Git Kraken is a GUI application. Make sure to run this script only within the VNC Desktop."
    gitkraken --no-sandbox
    sleep 10
fi