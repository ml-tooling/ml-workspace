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


if hash nvidia-smi 2>/dev/null; then
    echo "Installing Rapids.ai. Please wait..."
    conda install --yes -c rapidsai -c nvidia -c conda-forge -c defaults rapids=0.11 python=3.7 cudatoolkit=10.1
else
    echo "Nvidia-smi is not installed. Rapids.ai requires CUDA support, so it cannot be installed within this container."
fi

# Run
if [ $INSTALL_ONLY = 0 ] ; then
    echo "Use rapids.ai as described on the official docs: https://docs.rapids.ai/"
    sleep 15
fi