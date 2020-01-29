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

if ! hash pycharm-community 2>/dev/null; then
    echo "Installing PyCharm Community. Please wait..."
    cd /resources
    wget https://download.jetbrains.com/python/pycharm-community-2019.3.2.tar.gz -O ./pycharm.tar.gz 
    tar xfz ./pycharm.tar.gz
    mv pycharm-* /opt/pycharm
    rm ./pycharm.tar.gz
    ln -s /opt/pycharm/bin/pycharm.sh /usr/bin/pycharm-community 
    printf "[Desktop Entry]\nEncoding=UTF-8\nName=PyCharm Community\nComment=Python IDE\nExec=pycharm-community\nIcon=/opt/pycharm/bin/pycharm.png\nTerminal=false\nStartupNotify=true\nType=Application\nCategories=Development;IDE;" > /usr/share/applications/pycharm.desktop
else
    echo "PyCharm is already installed"
fi

# Run
if [ $INSTALL_ONLY = 0 ] ; then
    echo "Starting PyCharm Community..."
    echo "PyCharm is a GUI application. Make sure to run this script only within the VNC Desktop."
    pycharm-community
    sleep 10
fi