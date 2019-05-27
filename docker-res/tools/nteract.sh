#!/bin/sh
if ! hash nteract 2>/dev/null; then
    echo "Installing nteract"
    cd /resources
    wget https://github.com/nteract/nteract/releases/download/v0.14.2/nteract_0.14.2_amd64.deb -O ./nteract.deb
    dpkg -i ./nteract.deb
    rm ./nteract.deb
fi

# Run
echo "Starting nteract"
nteract