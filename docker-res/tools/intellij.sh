#!/bin/sh
if ! hash intellij-community 2>/dev/null; then
    echo "Installing IntelliJ Community"
    cd /resources
    wget https://download.jetbrains.com/idea/ideaIC-2019.1.2.tar.gz -O ./ideaIC.tar.gz
    tar xfz ideaIC.tar.gz
    mv idea-* /opt/idea
    rm ./ideaIC.tar.gz
    ln -s /opt/idea/bin/idea.sh /usr/bin/intellij-community
    echo -e "[Desktop Entry]\nEncoding=UTF-8\nName=IntelliJ IDEA\nComment=IntelliJ IDEA\nExec=intellij-community\nIcon=/opt/idea/bin/idea.png\nTerminal=false\nStartupNotify=true\nType=Application\nCategories=Development;IDE;" > /usr/share/applications/IDEA.desktop
fi

# Run
echo "Starting IntelliJ Community"
intellij-community