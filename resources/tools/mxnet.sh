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

# https://mxnet.apache.org/versions/master/

# pip uninstall mxnet  - TODO run uninstall?

if hash nvidia-smi 2>/dev/null; then
    echo "Installing MXNet (GPU). Please wait..."
    pip install -U --no-cache-dir mxnet-cu100mkl
else
    echo "Installing MXNet (CPU-MKL). Please wait..."
    pip install -U --no-cache-dir mxnet-mkl
fi

# Run
if [ $INSTALL_ONLY = 0 ] ; then
    echo "Use mxnet as described on the mxnet docs: https://mxnet.apache.org/versions/master/"
    sleep 15
fi