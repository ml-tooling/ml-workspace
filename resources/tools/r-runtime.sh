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
    echo "Installing R runtime. Please wait..."
    # See https://github.com/jupyter/docker-stacks/blob/master/r-notebook/Dockerfile
    apt-get update
    # R pre-requisites
    apt-get install -y --no-install-recommends fonts-dejavu unixodbc unixodbc-dev gfortran libsasl2-dev libssl-dev
    # TODO install: r-cran-rodbc via apt-get -> removed since it install an r-base via apt-get
    # Install newest version, basics, and essentials https://docs.anaconda.com/anaconda/packages/r-language-pkg-docs/
    # use conda-forge https://anaconda.org/conda-forge/r-base
    conda install -y --freeze-installed r-base r-reticulate rpy2 r-rodbc unixodbc cyrus-sasl r-cairo r-irkernel r-essentials r-languageserver
    # link R executable to usr/bin
    ln -s $CONDA_ROOT/bin/R /usr/bin/R
    apt-get clean
else
    echo "R runtime is already installed"
fi

# Install vscode R extension
if hash code 2>/dev/null; then
    # https://marketplace.visualstudio.com/items?itemName=Ikuyadeu.r
    LD_LIBRARY_PATH="" LD_PRELOAD="" code --user-data-dir=$HOME/.config/Code/ --extensions-dir=$HOME/.vscode/extensions/ --install-extension Ikuyadeu.r

    # TODO: cannot find R - https://marketplace.visualstudio.com/items?itemName=mikhail-arkhipov.r
    # Requires .Net runtime
    # wget -q https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb  && \
    # dpkg -i packages-microsoft-prod.deb  && \
    # apt-get update && \
    # apt-get install -y dotnet-runtime-3.1
    # LD_LIBRARY_PATH="" LD_PRELOAD="" code --user-data-dir=$HOME/.config/Code/ --extensions-dir=$HOME/.vscode/extensions/ --install-extension mikhail-arkhipov.r
else
    echo "Please install the desktop version of vscode via the vs-code-desktop.sh script to install R vscode extensions."
    sleep 10
fi

# Run
if [ $INSTALL_ONLY = 0 ] ; then
    Rscript --help
    sleep 20
fi

