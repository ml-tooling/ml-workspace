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

if ! hash label-studio 2>/dev/null; then
    echo "Installing Label Studio. Please wait..."
    pipx install label-studio
else
    echo "Label Studio is already installed"
fi

# Run
if [ $INSTALL_ONLY = 0 ] ; then
    if [ -z "$PORT" ]; then
        read -p "Please provide a port for starting Label Studio: " PORT
    fi

    echo "Starting Label Studio on port "$PORT
    cd $WORKSPACE_HOME
    # Create tool entry for tooling plugin
    echo '{"id": "label-studio-link", "name": "Label Studio", "url_path": "/tools/'$PORT'/import", "description": "Multi-type data labeling & annotation tool"}' > $HOME/.workspace/tools/label-studio.json
    label-studio start labeling_project --allow-serving-local-files --init -p $PORT --no-browser
    sleep 15
fi
