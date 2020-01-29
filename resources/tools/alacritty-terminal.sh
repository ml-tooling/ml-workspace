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

if ! hash alacritty 2>/dev/null; then
    echo "Installing Alacritty Terminal. Please wait..."
    add-apt-repository ppa:mmstick76/alacritty
    apt-get update
    apt-get install -y alacritty
else
    echo "Alacritty Terminal is already installed"
fi

# Run
if [ $INSTALL_ONLY = 0 ] ; then
    echo "Starting Alacritty Terminal..."
    echo "Alacritty Terminal is a GUI application. Make sure to run this script only within the VNC Desktop."
    alacritty
    sleep 10
fi