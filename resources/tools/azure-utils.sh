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

echo "Installing Azure Tooling Collection. Please wait..."
pip install --no-cache-dir \
        azure-mgmt-compute \
        azure-mgmt-storage \
        azure-mgmt-resource \
        azure-keyvault-secrets \
        azure-storage-blob \
        msrestazure \
        azure-mgmt-resource \
        azure-mgmt-datalake-store

# Install vscode azure extension
if hash code 2>/dev/null; then
    echo "Installing vs code azure extensions..."
    # https://marketplace.visualstudio.com/items?itemName=ms-vscode.vscode-node-azure-pack
    LD_LIBRARY_PATH="" LD_PRELOAD="" code --user-data-dir=$HOME/.config/Code/ --extensions-dir=$HOME/.vscode/extensions/ --install-extension ms-vscode.vscode-node-azure-pack
    sleep 10
else
    echo "Please install the desktop version of vscode via the vs-code-desktop.sh script to install azure vscode extensions."
    sleep 10
fi
