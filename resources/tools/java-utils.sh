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

echo "Installing Java Utils Collection. Please wait..."
apt-get update
apt-get install -y --no-install-recommends \
        scala \
        gradle

# Install Java - Python Integrations
pip install --no-cache-dir jep py4j

if [[ ! $(jupyter kernelspec list) =~ "java" ]]; then
    echo "Installing Java Kernel for Jupyter. Please wait..."
    cd $RESOURCES_PATH
    wget https://github.com/SpencerPark/IJava/releases/download/v1.3.0/ijava-1.3.0.zip -O ./ijava.zip
    mkdir ./ijava
    unzip ./ijava.zip -d ./ijava
    python ./ijava/install.py --sys-prefix
    rm ./ijava.zip
    rm -r ./ijava
else
    echo "Java Kernel for Jupyter is already installed."
fi

# Install vscode java extension pack
if hash code 2>/dev/null; then
    # https://marketplace.visualstudio.com/items?itemName=vscjava.vscode-java-pack
    LD_LIBRARY_PATH="" LD_PRELOAD="" code --user-data-dir=$HOME/.config/Code/ --extensions-dir=$HOME/.vscode/extensions/ --install-extension vscjava.vscode-java-pack
else
    echo "Please install the desktop version of vscode via the vs-code-desktop.sh script to install java vscode extensions."
fi

# TODO install java kernel? https://github.com/SpencerPark/IJava