#!/bin/sh
if [ ! -f "/opt/Hyper/hyper" ]; then
    cd /resources
    echo "Installing Hyper Terminal"
    apt-get update
    apt-get -f install
    wget https://releases.hyper.is/download/deb -O ./hyper.deb
    dpkg -i ./hyper.deb
    rm ./hyper.deb
fi

# Run
/opt/Hyper/hyper