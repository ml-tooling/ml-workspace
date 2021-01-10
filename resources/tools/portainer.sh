#!/bin/sh

# Stops script execution if a command has an error
set -e

INSTALL_ONLY=0
PORT=""
# Loop through arguments and process them: https://pretzelhands.com/posts/command-line-flags
for arg in "$@"; do
    case $arg in
        -i|--install) INSTALL_ONLY=1 ; shift ;;
        -p=*|--port=*) PORT="${arg#*=}" ; shift ;; # TODO Does not allow --port 1234
        *) break ;;
    esac
done

if [ ! -f "$RESOURCES_PATH/portainer/portainer"  ]; then
    echo "Installing Portainer. Please wait..."
    cd $RESOURCES_PATH
    PORTAINER_VERSION=2.0.1
    wget https://github.com/portainer/portainer/releases/download/$PORTAINER_VERSION/portainer-$PORTAINER_VERSION-linux-amd64.tar.gz
    tar xvpfz portainer-$PORTAINER_VERSION-linux-amd64.tar.gz
    rm ./portainer-$PORTAINER_VERSION-linux-amd64.tar.gz
    mkdir $RESOURCES_PATH/portainer/portainer-data
else
    echo "Portainer is already installed"
fi

# Run
if [ $INSTALL_ONLY = 0 ] ; then
    if [ -z "$PORT" ]; then
        read -p "Please provide a port for starting Portainer: " PORT
    fi

    echo "Starting Portainer on port "$PORT
    # Create tool entry for tooling plugin
    echo '{"id": "portainer-link", "name": "Portainer", "url_path": "/tools/'$PORT'/", "description": "Lightweight management UI for Docker"}' > $HOME/.workspace/tools/embedding-projector.json
    cd $RESOURCES_PATH/portainer
    ./portainer -p :$PORT --data $RESOURCES_PATH/portainer/portainer-data
    sleep 10
fi
