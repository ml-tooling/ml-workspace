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

if ! hash netron 2>/dev/null; then
    echo "Installing Netron. Please wait..."
    # https://github.com/lutzroeder/netron
    pip install --no-cache-dir  netron
else
    echo "Netron is already installed"
fi

# Run
if [ $INSTALL_ONLY = 0 ] ; then
    if [ -z "$PORT" ]; then
        read -p "Please provide a port for starting Netron: " PORT
    fi

    echo "Starting Netron on port "$PORT
    # Create tool entry for tooling plugin
    echo '{"id": "netron-link", "name": "Netron", "url_path": "/tools/'$PORT'/", "description": "Web-viewer for machine learning models"}' > $HOME/.workspace/tools/netron.json
    netron --port=$PORT --log
    sleep 15
fi
