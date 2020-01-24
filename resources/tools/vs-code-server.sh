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
    # CODE_SERVER_VERSION=2.1698
    # VS_CODE_VERSION=$CODE_SERVER_VERSION-vsc1.41.1
    # wget -q https://github.com/cdr/code-server/releases/download/$CODE_SERVER_VERSION/code-server$VS_CODE_VERSION-linux-x86_64.tar.gz -O ./vscode-web.tar.gz
    # Use older version, since newer has some problems with python extension
    VS_CODE_VERSION=2.1692-vsc1.39.2
    wget -q https://github.com/cdr/code-server/releases/download/$VS_CODE_VERSION/code-server$VS_CODE_VERSION-linux-x86_64.tar.gz -O ./vscode-web.tar.gz
    tar xfz ./vscode-web.tar.gz
    mv ./code-server$VS_CODE_VERSION-linux-x86_64/code-server /usr/local/bin
    chmod -R a+rwx /usr/local/bin/code-server
    rm ./vscode-web.tar.gz
    rm -rf ./code-server$VS_CODE_VERSION-linux-x86_64
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
    /usr/local/bin/code-server --port=$PORT --disable-telemetry --user-data-dir=$HOME/.config/Code/ --extensions-dir=$HOME/.vscode/extensions/ --auth=none $WORKSPACE_HOME/
    sleep 15
fi
