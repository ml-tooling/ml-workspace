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

if ! hash dbeaver 2>/dev/null; then
    echo "Installing DBeaver. Please wait..."
    add-apt-repository ppa:serge-rider/dbeaver-ce --yes
    apt-get update
    apt-get install dbeaver-ce --yes
else
    echo "DBeaver is already installed"
fi

# Run
if [ $INSTALL_ONLY = 0 ] ; then
    echo "Starting DBeaver..."
    echo "DBeaver is a GUI application. Make sure to run this script only within the VNC Desktop."
    dbeaver
    sleep 10
fi