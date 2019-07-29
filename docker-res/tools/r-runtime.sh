#!/bin/sh

INSTALL_ONLY=0
# Loop through arguments and process them: https://pretzelhands.com/posts/command-line-flags
for arg in "$@"; do
    case $arg in
        -i|--install) INSTALL_ONLY=1 ; shift ;;
        *) break ;;
    esac
done

if ! hash Rscript 2>/dev/null; then
    echo "Installing R Runtime"
    # See https://github.com/jupyter/docker-stacks/blob/master/r-notebook/Dockerfile
    apt-get update
    # R pre-requisites
    apt-get install -y --no-install-recommends fonts-dejavu unixodbc unixodbc-dev r-cran-rodbc gfortran
    # R basics and essentials: https://docs.anaconda.com/anaconda/packages/r-language-pkg-docs/
    conda install --yes r-base r-irkernel r-reticulate r-essentials rpy2
else
    echo "Ruby R is already installed"
fi

# Run
if [ $INSTALL_ONLY = 0 ] ; then
    Rscript --help
    sleep 20
fi

