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

if ! hash postman 2>/dev/null; then
    echo "Installing Postman. Please wait..."
    cd $RESOURCES_PATH
    wget https://dl.pstmn.io/download/latest/linux64 -O ./postman.tar.gz
    tar -xzf ./postman.tar.gz -C /opt
    rm postman.tar.gz
    ln -s /opt/Postman/Postman /usr/bin/postman
    printf "[Desktop Entry]\nEncoding=UTF-8\nName=Postman\nComment=Postman\nExec=postman\nIcon=/opt/Postman/app/resources/app/assets/icon.png\nTerminal=false\nType=Application\nCategories=Development;" > /usr/share/applications/postman.desktop
else
    echo "Postman is already installed"
fi

# Run
if [ $INSTALL_ONLY = 0 ] ; then
    echo "Starting Postman..."
    echo "Postman is a GUI application. Make sure to run this script only within the VNC Desktop."
    postman
    sleep 10
fi