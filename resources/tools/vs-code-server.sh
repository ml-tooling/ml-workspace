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

if [ ! -f "/usr/local/bin/code-server"  ]; then
    echo "Installing VS Code Server. Please wait..."
    cd ${RESOURCES_PATH}
    VS_CODE_VERSION=3.8.0
    # Use yarn install since it is smaller
    yarn --production --frozen-lockfile global add code-server@"$VS_CODE_VERSION"
    yarn cache clean
    ln -s /usr/local/bin/code-server /usr/bin/code-server
    #wget -q https://github.com/cdr/code-server/releases/download/v$VS_CODE_VERSION/code-server_${VS_CODE_VERSION}_amd64.deb -O ./code-server.deb
    #apt-get update
    #apt-get install -y ./code-server.deb
    #rm ./code-server.deb
    #ln -s /usr/bin/code-server /usr/local/bin/code-server
else
    echo "VS Code Server is already installed"
fi

# Run
if [ $INSTALL_ONLY = 0 ] ; then
    if [ -z "$PORT" ]; then
        read -p "Please provide a port for starting VS Code Server: " PORT
    fi

    echo "Starting VS Code Server on port "$PORT
    # Create tool entry for tooling plugin
    echo '{"id": "vscode-link", "name": "VS Code", "url_path": "/tools/'$PORT'/", "description": "Visual Studio Code webapp"}' > $HOME/.workspace/tools/vscode.json
    /usr/local/bin/code-server --port=$PORT --disable-telemetry --user-data-dir=$HOME/.config/Code/ --extensions-dir=$HOME/.vscode/extensions/ --disable-update-check --auth=none $WORKSPACE_HOME/
    sleep 15
fi
