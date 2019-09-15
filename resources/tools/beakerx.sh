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

if ! hash beakerx 2>/dev/null; then
    echo "Installing BeakerX. Please wait..."
    pip install --no-cache-dir py4j beakerx 
    beakerx install
    jupyter labextension install beakerx-jupyterlab
else
    echo "BeakerX is already installed"
fi

# Run
if [ $INSTALL_ONLY = 0 ] ; then
    echo "Use BeakerX from Jupyter"
    beakerx --help
    sleep 20
fi

