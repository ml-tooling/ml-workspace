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

if ! hash emacs 2>/dev/null; then
    echo "Installing Emacs. Please wait..."
    apt-get update
    LD_LIBRARY_PATH="" LD_PRELOAD="" apt-get install --yes emacs
else
    echo "Emacs is already installed"
fi

# Run
if [ $INSTALL_ONLY = 0 ] ; then
    echo "Starting Emacs"
    LD_LIBRARY_PATH="" LD_PRELOAD="" emacs
    sleep 10
fi
