#!/bin/sh
if ! hash pycharm-community 2>/dev/null; then
    echo "Installing PyCharm Community"
    cd /resources
    wget https://download.jetbrains.com/python/pycharm-community-2018.3.tar.gz -O ./pycharm.tar.gz 
    tar xfz ./pycharm.tar.gz
    mv pycharm-* /opt/pycharm
    rm ./pycharm.tar.gz
    ln -s /opt/pycharm/bin/pycharm.sh /usr/bin/pycharm-community 
    echo "[Desktop Entry]\nEncoding=UTF-8\nName=PyCharm Community\nComment=Python IDE\nExec=pycharm-community\nIcon=/opt/pycharm/bin/pycharm.png\nTerminal=false\nStartupNotify=true\nType=Application\nCategories=Development;IDE;" > /usr/share/applications/pycharm.desktop
fi

# Run
echo "Starting PyCharm Community"
pycharm-community