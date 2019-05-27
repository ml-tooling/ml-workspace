#!/bin/sh
if ! hash postman 2>/dev/null; then
    cd /resources
    echo "Installing Postman"
    wget --quiet https://dl.pstmn.io/download/latest/linux64 -O ./postman.tar.gz
    tar -xzf ./postman.tar.gz -C /opt && \
    rm postman.tar.gz && \
    ln -s /opt/Postman/Postman /usr/bin/postman && \
    echo "[Desktop Entry]\nEncoding=UTF-8\nName=Postman\nComment=Postman\nExec=postman\nIcon=/opt/Postman/app/resources/app/assets/icon.png\nTerminal=false\nType=Application\nCategories=Development;" > /usr/share/applications/postman.desktop
fi

# Run
echo "Starting Postman"
postman