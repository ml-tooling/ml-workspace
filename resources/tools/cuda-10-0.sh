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

if [ ! -d "/usr/local/cuda" ]; then
    echo "Installing CUDA 10.0 runtime. Please wait..."
    mkdir $RESOURCES_PATH"/cuda-10-0"
    cd $RESOURCES_PATH"/cuda-10-0"
    # Instructions from: https://gitlab.com/nvidia/container-images/cuda/-/tree/ubuntu18.04/10.0
    curl -fsSL https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/7fa2af80.pub | apt-key add -
    echo "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64 /" > /etc/apt/sources.list.d/cuda.list
    echo "deb https://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1804/x86_64 /" > /etc/apt/sources.list.d/nvidia-ml.list
    apt-get update && apt-get install -y --no-install-recommends cuda-cudart-10-0=10.0.130-1 cuda-compat-10-0
    ln -s cuda-10.0 /usr/local/cuda
    apt-get update && apt-get install -y --no-install-recommends cuda-libraries-10-0=10.0.130-1 cuda-nvtx-10-0=10.0.130-1
    /bin/rm -rf /var/lib/apt/lists/*
    # libnccl2=2.4.2-1+cuda10.0 
    # cd back otherwise clean layer will fail since it is deleted
    cd $RESOURCES_PATH
    rm -r $RESOURCES_PATH"/cuda-10-0"
else
    echo "CUDA 10.0 is already installed"
fi

# Run
if [ $INSTALL_ONLY = 0 ] ; then
    echo "Use CUDA 10.0 via supporting libraries and frameworks."
    sleep 15
fi