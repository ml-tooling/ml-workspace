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

if ! hash ruby 2>/dev/null; then
    echo "Installing Ruby Interpreter. Please wait..."
    apt-get update
    apt-get install -y ruby-full
else
    echo "Ruby Interpreter is already installed"
fi

# Run
if [ $INSTALL_ONLY = 0 ] ; then
    ruby --help
    sleep 20
fi

