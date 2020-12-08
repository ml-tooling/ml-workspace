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


if hash nvcc 2>/dev/null; then
    # https://rapids.ai/start.html#conda-install
    echo "Installing Rapids.ai. Please wait..."
    conda create -n rapids-0.16 -c rapidsai -c nvidia -c conda-forge -c defaults rapids=0.16 python=3.8 ipykernel cudatoolkit=10.1
    conda run -n rapids-0.16 python -m ipykernel install --user --name=rapids-0.16 --display-name="rapids-0.16"
    # TODO: Install blazingsql
else
    echo "NVCC / CUDA is not installed. Rapids.ai requires CUDA support, so it cannot be installed within this container."
fi

# Run
if [ $INSTALL_ONLY = 0 ] ; then
    echo "Use rapids.ai as described on the official docs: https://docs.rapids.ai/"
    sleep 15
fi
