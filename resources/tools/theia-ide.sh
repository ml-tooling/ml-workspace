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

if [ ! -f "$RESOURCES_PATH/theia/package.json" ]; then
    echo "Installing Theia IDE. Please wait..."
    cd $RESOURCES_PATH
    mkdir -p ./theia
    cd ./theia
    # Python-only features?: https://raw.githubusercontent.com/theia-ide/theia-apps/master/theia-python-docker/latest.package.json
    wget https://raw.githubusercontent.com/theia-ide/theia-apps/master/theia-full-docker/latest.package.json -O ./package.json
    yarn --cache-folder ./ycache && rm -rf ./ycache
    NODE_OPTIONS="--max_old_space_size=4096" yarn theia build
else
    echo "Theia IDE is already installed"
fi

# Run
if [ $INSTALL_ONLY = 0 ] ; then
    if [ -z "$PORT" ]; then
        read -p "Please provide a port for starting Theia IDE: " PORT
    fi

    echo "Starting Theia IDE on port "$PORT
    # Create tool entry for tooling plugin
    echo '{"id": "theia-link", "name": "Theia", "url_path": "/tools/'$PORT'/", "description": "Multi-language cloud IDE"}' > $HOME/.workspace/tools/theia.json
    cd $RESOURCES_PATH/theia
    yarn theia start /workspace --hostname=0.0.0.0 --port=$PORT
    sleep 15
fi
