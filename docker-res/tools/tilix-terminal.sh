#!/bin/sh
if ! hash tilix 2>/dev/null; then
    echo "Installing Tilix Terminal"
    add-apt-repository ppa:webupd8team/terminix --yes
    apt-get update
    apt-get install tilix --yes
fi

# Run
echo "Starting Tilix Terminal"
nohup tilix &>/dev/null &