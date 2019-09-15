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

if ! hash git-lfs 2>/dev/null; then
    echo "Installing Git LFS. Please wait..."
    apt-get update
    curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | sudo bash
    apt-get install git-lfs --yes
    git lfs install
else
    echo "Git LFS is already installed"
fi

# Run
if [ $INSTALL_ONLY = 0 ] ; then
    echo "Use Git LFS via command-line:"
    git-lfs
    sleep 10
fi

