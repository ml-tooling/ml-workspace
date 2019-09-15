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

#https://github.com/epfml/sent2vec
echo "Installing Sent2vec. Please wait..."
pip install -U --no-cache-dir git+https://github.com/epfml/sent2vec

# Run
if [ $INSTALL_ONLY = 0 ] ; then
    echo "Use sent2vec via python as described here: https://github.com/epfml/sent2vec#directly-from-python"
    sleep 15
fi
