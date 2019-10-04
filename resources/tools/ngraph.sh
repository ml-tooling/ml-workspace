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

# https://www.ngraph.ai/
echo "Installing NGraph and PlaidML. Please wait..."
pip install -U --no-cache-dir ngraph-core ngraph-onnx plaidml
# ngraph-tensorflow-bridge NGRAPH_TF_BACKEND="INTELGPU"

# Run
if [ $INSTALL_ONLY = 0 ] ; then
    echo "Use ngraph as described on the ngraph docs: https://www.ngraph.ai/"
    sleep 15
fi