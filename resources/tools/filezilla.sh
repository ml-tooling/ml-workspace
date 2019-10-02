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

if ! hash filezilla 2>/dev/null; then
    echo "Installing Filezilla. Please wait..."
    apt-get update
    apt-get install --yes filezilla
else
    echo "Filezilla is already installed"
fi

# Run
if [ $INSTALL_ONLY = 0 ] ; then
    echo "Starting Filezilla..."
    echo "Filezilla is a GUI application. Make sure to run this script only within the VNC Desktop."
    filezilla
    sleep 10
fi
