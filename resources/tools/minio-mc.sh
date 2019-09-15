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

if ! hash mc 2>/dev/null; then
    echo "Installing Minio Utility (mc). Please wait..."
    wget https://dl.min.io/client/mc/release/linux-amd64/mc -O /usr/sbin/mc
    chmod +x /usr/sbin/mc
else
    echo "Minio Utility is already installed"
fi

# Run
if [ $INSTALL_ONLY = 0 ] ; then
    echo "Use minio mc via command line:"
    mc --help
    sleep 20
fi