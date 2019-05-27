#!/bin/sh
if ! hash atom 2>/dev/null; then
    echo "Installing Atom"
    add-apt-repository ppa:webupd8team/atom --yes
    apt-get update
    apt-get install atom --yes
    apt-get clean
fi

# Run
echo "Starting Atom"
atom