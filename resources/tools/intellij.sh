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

if ! hash intellij-community 2>/dev/null; then
    echo "Installing IntelliJ Community. Please wait..."
    cd $RESOURCES_PATH
    wget https://download.jetbrains.com/idea/ideaIC-2019.3.2.tar.gz -O ./ideaIC.tar.gz
    tar xfz ideaIC.tar.gz
    mv idea-* /opt/idea
    rm ./ideaIC.tar.gz
    ln -s /opt/idea/bin/idea.sh /usr/bin/intellij-community
    printf "[Desktop Entry]\nEncoding=UTF-8\nName=IntelliJ IDEA\nComment=IntelliJ IDEA\nExec=intellij-community\nIcon=/opt/idea/bin/idea.png\nTerminal=false\nStartupNotify=true\nType=Application\nCategories=Development;IDE;" > /usr/share/applications/IDEA.desktop
else
    echo "IntelliJ is already installed"
fi

# Run
if [ $INSTALL_ONLY = 0 ] ; then
    echo "Starting IntelliJ Community..."
    echo "IntelliJ is a GUI application. Make sure to run this script only within the VNC Desktop."
    intellij-community
    sleep 10
fi

