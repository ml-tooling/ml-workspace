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

if [ ! -f "/opt/Rodeo/rodeo" ]; then
    echo "Installing Rodeo. Please wait..."
    cd $RESOURCES_PATH
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 33D40BC6
    add-apt-repository -u "deb http://rodeo-deb.yhat.com/ rodeo main"
    apt-get update
    apt-get -y install libgconf2-4
    apt-get -y --allow-unauthenticated install rodeo
else
    echo "Rodeo is already installed"
fi

# Run
if [ $INSTALL_ONLY = 0 ] ; then
    echo "Starting Rodeo..."
    echo "Rodeo is a GUI application. Make sure to run this script only within the VNC Desktop."
    /opt/Rodeo/rodeo
    sleep 10
fi