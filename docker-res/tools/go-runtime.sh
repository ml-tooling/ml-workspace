#!/bin/sh
if ! hash go 2>/dev/null; then
    echo "Installing Go Runtime"
    apt-get update
    apt-get install -y golang-go
else
    echo "Go Runtime is already installed"
fi

go --help
sleep 10
