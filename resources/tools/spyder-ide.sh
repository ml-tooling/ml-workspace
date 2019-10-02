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

if ! hash spyder 2>/dev/null; then
    echo "Installing Spyder. Please wait..."
    conda install -y spyder
else
    echo "Spyder is already installed"
fi

# Run
if [ $INSTALL_ONLY = 0 ] ; then
    echo "Starting Spyder..."
    echo "Spyder is a GUI application. Make sure to run this script only within the VNC Desktop."
    spyder
    sleep 10
fi