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

if ! hash atom 2>/dev/null; then
    echo "Installing Atom. Please wait..."
    add-apt-repository ppa:webupd8team/atom --yes
    apt-get update
    apt-get install atom --yes
    apt-get clean
else
    echo "Atom is already installed"
fi

# Run
if [ $INSTALL_ONLY = 0 ] ; then
    echo "Starting Atom..."
    echo "Atom is a GUI application. Make sure to run this script only within the VNC Desktop."
    atom
    sleep 10
fi
