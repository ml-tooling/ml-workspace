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

if [ ! -f "$RESOURCES_PATH/embedding-projector-standalone/index.html"  ]; then
    echo "Installing Embedding Projector. Please wait..."
    cd $RESOURCES_PATH
    git clone https://github.com/tensorflow/embedding-projector-standalone
else
    echo "Embedding Projector is already installed"
fi

# Run
if [ $INSTALL_ONLY = 0 ] ; then
    if [ -z "$PORT" ]; then
        read -p "Please provide a port for starting Embedding Projector: " PORT
    fi

    echo "Starting Embedding Projector on port "$PORT
    # Create tool entry for tooling plugin
    echo '{"id": "embedding-projector-link", "name": "Embedding Projector", "url_path": "/tools/'$PORT'/", "description": "Tool for visualizing high dimensional data"}' > $HOME/.workspace/tools/embedding-projector.json
    cd $RESOURCES_PATH/embedding-projector-standalone/
    python -m http.server $PORT
    sleep 10
fi
