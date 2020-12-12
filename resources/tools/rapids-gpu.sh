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
    RAPIDS_VERSION=0.17
    conda create -n rapids-$RAPIDS_VERSION -c rapidsai -c nvidia -c conda-forge -c defaults rapids-blazing=$RAPIDS_VERSION ipykernel python=3.8 cudatoolkit=10.1
    conda run -n rapids-$RAPIDS_VERSION python -m ipykernel install --user --name=rapids-$RAPIDS_VERSION --display-name="rapids-$RAPIDS_VERSION"
else
    echo "NVCC / CUDA is not installed. Rapids.ai requires CUDA support, so it cannot be installed within this container."
fi

# Run
if [ $INSTALL_ONLY = 0 ] ; then
    echo "Use rapids.ai as described on the official docs: https://docs.rapids.ai/"
    sleep 15
fi
