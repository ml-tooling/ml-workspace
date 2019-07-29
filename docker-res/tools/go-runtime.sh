#!/bin/sh

# Stops script execution if a command has an error
set -e

INSTALL_ONLY=0
# Loop through arguments and process them: https://pretzelhands.com/posts/command-line-flags
for arg in "$@"; do
    case $arg in
        -i|--install) INSTALL_ONLY=1 ; shift ;;
        *) break ;;
    esac
done

if ! hash go 2>/dev/null; then
    echo "Installing Go Runtime"
    apt-get update
    apt-get install -y golang-go
else
    echo "Go Runtime is already installed"
fi

# Run
if [ $INSTALL_ONLY = 0 ] ; then
    echo "Use go via command-line"
    go --help
    sleep 20
fi

