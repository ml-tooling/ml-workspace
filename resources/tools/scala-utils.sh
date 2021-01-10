#!/bin/bash

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

cd $RESOURCES_PATH

if [[ ! $(scala -version 2>&1) =~ "version 2.12" ]]; then
    # Update to Scala 2.12 is required for spark
    SCALA_VERSION=2.12.12
    echo "Updating to Scala $SCALA_VERSION. Please wait..."
    apt-get remove scala-library scala
    apt-get autoremove
    wget -q https://downloads.lightbend.com/scala/$SCALA_VERSION/scala-$SCALA_VERSION.deb -O ./scala.deb
    dpkg -i scala.deb
    rm scala.deb
    apt-get update
    apt-get install scala
else
    echo "Scala 2.12 already installed."
fi

if ! hash sbt 2>/dev/null; then
    echo "Installing SBT for Scala. Please wait..."
    echo "deb https://dl.bintray.com/sbt/debian /" | sudo tee -a /etc/apt/sources.list.d/sbt.list
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2EE0EA64E40A89B84B2DF73499E82A75642AC823
    apt-get update
    apt-get install sbt
else
    echo "SBT already installed."
fi


# TODO: Install Coursier https://get-coursier.io/docs/cli-installation

if [ ! -d "$HOME/.local/share/jupyter/kernels/scala" ]; then
    echo "Installing Almond Scala Kernel for Jupyter. Please wait..."
    curl -Lo coursier https://git.io/coursier-cli
    chmod +x coursier
    ./coursier launch --fork almond -- --install
    rm -f coursier
else
    echo "Almond Scala Kernel for Jupyter is already installed."
fi

# Install vscode scala extensions
if hash code 2>/dev/null; then
    # https://marketplace.visualstudio.com/items?itemName=scala-lang.scala
    LD_LIBRARY_PATH="" LD_PRELOAD="" code --user-data-dir=$HOME/.config/Code/ --extensions-dir=$HOME/.vscode/extensions/ --install-extension scala-lang.scala
    # https://marketplace.visualstudio.com/items?itemName=scalameta.metals
    LD_LIBRARY_PATH="" LD_PRELOAD="" code --user-data-dir=$HOME/.config/Code/ --extensions-dir=$HOME/.vscode/extensions/ --install-extension scalameta.metals
else
    echo "Please install the desktop version of vscode via the vs-code-desktop.sh script to install scala vscode extensions."
fi
