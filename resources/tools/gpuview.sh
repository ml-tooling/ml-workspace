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

if ! hash gpuview 2>/dev/null; then
    echo "Installing GPUview. Please wait..."
    # https://github.com/fgaim/gpuview
    pipx install gpuview
else
    echo "GPUview is already installed"
fi

# Run
if [ $INSTALL_ONLY = 0 ] ; then
    if [ -z "$PORT" ]; then
        read -p "Please provide a port for starting GPUview: " PORT
    fi

    echo "Starting GPUview on port "$PORT
    # Create tool entry for tooling plugin
    echo '{"id": "gpuview-link", "name": "GPUview", "url_path": "/tools/'$PORT'/", "description": "Web dashboard for monitoring GPU usage."}' > $HOME/.workspace/tools/gpuview.json
    gpuview run --safe-zone --safe-zone --port $PORT
    sleep 15
fi
