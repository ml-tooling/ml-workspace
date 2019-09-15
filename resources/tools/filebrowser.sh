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

if [ ! -f "/usr/local/bin/filebrowser"  ]; then
    echo "Installing Filebrowser. Please wait..."
    cd $RESOURCES_PATH
    curl -fsSL https://raw.githubusercontent.com/filebrowser/get/master/get.sh | bash
else
    echo "Filebrowser is already installed"
fi

# Run
if [ $INSTALL_ONLY = 0 ] ; then
    if [ -z "$PORT" ]; then
        read -p "Please provide a port for starting Filebrowser: " PORT
    fi

    echo "Starting Filebrowser on port "$PORT
    # Create tool entry for tooling plugin
    echo '{"id": "filebrowser-link", "name": "Filebrowser", "url_path": "/tools/'$PORT'/", "description": "Browse and manage workspace files"}' > $HOME/.workspace/tools/filebrowser.json
    /usr/local/bin/filebrowser --port=$PORT
    sleep 15
fi
