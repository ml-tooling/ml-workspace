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

if ! hash Rscript 2>/dev/null; then
    echo "Installing R runtime"
    # See https://github.com/jupyter/docker-stacks/blob/master/r-notebook/Dockerfile
    apt-get update
    # R pre-requisites
    apt-get install -y --no-install-recommends fonts-dejavu unixodbc unixodbc-dev r-cran-rodbc gfortran
    # R basics and essentials: https://docs.anaconda.com/anaconda/packages/r-language-pkg-docs/
    conda install --yes r-base r-irkernel r-reticulate r-essentials rpy2 r-rodbc unixodbc
else
    echo "R runtime is already installed"
fi

# Install vscode R extension 
if hash code 2>/dev/null; then
    # https://marketplace.visualstudio.com/items?itemName=Ikuyadeu.r
    LD_LIBRARY_PATH="" LD_PRELOAD="" code --user-data-dir=$HOME/.config/Code/ --extensions-dir=$HOME/.vscode/extensions/ --install-extension Ikuyadeu.r
else
    echo "Please install the desktop version of vscode via the vs-code-desktop.sh script to install R vscode extensions."
fi

# Run
if [ $INSTALL_ONLY = 0 ] ; then
    Rscript --help
    sleep 20
fi

