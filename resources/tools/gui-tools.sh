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

echo "Installing GUI Tool Collection. Please wait..."
apt-get update
LD_LIBRARY_PATH="" LD_PRELOAD="" apt-get install -y --no-install-recommends \
        gnome-tweak-tool \
        file-roller \
        gitg \
        mupdf \
        synapse \
        meld \
        ark \
        neovim \
        muon
