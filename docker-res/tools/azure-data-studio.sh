#!/bin/sh
if ! hash azuredatastudio 2>/dev/null; then
    echo "Installing Azure Data Studio"
    cd /resources
    wget https://go.microsoft.com/fwlink/?linkid=2092022 -O ./azure-data-studio.deb
    dpkg -i ./azure-data-studio.deb
    rm ./azure-data-studio.deb
fi

# Run
echo "Start Azure Data Studio from Applications -> Development"