#!/bin/sh
if ! hash dbeaver 2>/dev/null; then
    echo "Installing DBeaver"
    add-apt-repository ppa:serge-rider/dbeaver-ce --yes
    apt-get update
    apt-get install dbeaver-ce --yes
fi

# Run
echo "Starting DBeaver"
dbeaver