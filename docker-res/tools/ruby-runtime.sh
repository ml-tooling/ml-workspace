#!/bin/sh

INSTALL_ONLY=0
# Loop through arguments and process them: https://pretzelhands.com/posts/command-line-flags
for arg in "$@"; do
    case $arg in
        -i|--install) INSTALL_ONLY=1 ; shift ;;
        *) break ;;
    esac
done

if ! hash ruby 2>/dev/null; then
    echo "Installing Ruby Runtime"
    apt-get update
    apt-get install -y ruby-full
else
    echo "Ruby Runtime is already installed"
fi

# Run
if [ $INSTALL_ONLY = 0 ] ; then
    ruby --help
    sleep 20
fi

