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

if ! hash java 2>/dev/null; then
    echo "Installing Java Runtime. Please wait..."
    apt-get update
    apt-get install -y --no-install-recommends openjdk-11-jdk maven scala
else
    echo "Java Runtime is already installed"
fi

# Install vscode go extension
if hash code 2>/dev/null; then
    LD_LIBRARY_PATH="" LD_PRELOAD="" code --user-data-dir=$HOME/.config/Code/ --extensions-dir=$HOME/.vscode/extensions/ --install-extension redhat.java
else
    echo "Please install the desktop version of vscode via the vs-code-desktop.sh script to install go vscode extensions."
fi

# Run
if [ $INSTALL_ONLY = 0 ] ; then
    echo "Use java via command-line:"
    java --help
    sleep 20
fi

