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

echo "Installing Azure Tooling Collection"
pip install --no-cache-dir \
        azure \
        msrestazure \
        azure-mgmt-resource \
        azure-mgmt-datalake-store