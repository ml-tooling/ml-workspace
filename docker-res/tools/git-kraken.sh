#!/bin/sh
if ! hash gitkraken 2>/dev/null; then
    cd /resources
    echo "Installing Git Kraken"
    wget https://release.gitkraken.com/linux/gitkraken-amd64.deb -O ./gitkraken.deb
    apt-get install gvfs-bin --yes
    dpkg -i ./gitkraken.deb
    rm ./gitkraken.deb
    apt-get clean
fi

# Run
echo "Starting Git Kraken"
gitkraken