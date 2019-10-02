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

if ! hash tilix 2>/dev/null; then
    echo "Installing Tilix Terminal. Please wait..."
    add-apt-repository ppa:webupd8team/terminix --yes
    apt-get update
    apt-get install tilix --yes
else
    echo "Tilix Terminal is already installed"
fi

# Run
if [ $INSTALL_ONLY = 0 ] ; then
    echo "Starting Tilix Terminal..."
    echo "Tilix Terminal is a GUI application. Make sure to run this script only within the VNC Desktop."
    tilix
    sleep 10
fi