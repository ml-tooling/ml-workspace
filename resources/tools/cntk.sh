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

# https://docs.microsoft.com/en-us/cognitive-toolkit/

# pip uninstall cntk  - TODO run uninstall?

if hash nvidia-smi 2>/dev/null; then
    echo "Installing CNTK (GPU). Please wait..."
    pip install -U --no-cache-dir cntk-gpu
else
    echo "Installing CNTK (CPU). Please wait..."
    pip install -U --no-cache-dir cntk
fi

# Run
if [ $INSTALL_ONLY = 0 ] ; then
    echo "Use cntk as described on the cntk docs: https://docs.microsoft.com/en-us/cognitive-toolkit/"
    sleep 15
fi