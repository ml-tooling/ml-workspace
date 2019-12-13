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

if ! hash ungit 2>/dev/null; then
    echo "Installing Ungit. Please wait..."
    npm update
    npm install -g ungit@1.5.1
else
    echo "Ungit is already installed"
fi

# Run
if [ $INSTALL_ONLY = 0 ] ; then
    if [ -z "$PORT" ]; then
        read -p "Please provide a port for starting Ungit: " PORT
    fi

    echo "Starting Ungit on port "$PORT
    # Create tool entry for tooling plugin
    echo '{"id": "ungit-link", "name": "Ungit", "url_path": "/tools/'$PORT'/#/repository?path=%2Fworkspace", "description": "Interactive Git interface"}' > $HOME/.workspace/tools/ungit.json
    /usr/bin/node /usr/lib/node_modules/ungit/source/server.js --port=$PORT --launchBrowser=0 --bugtracking=false --rootPath=$WORKSPACE_BASE_URL/tools/ungit
    sleep 15
fi
