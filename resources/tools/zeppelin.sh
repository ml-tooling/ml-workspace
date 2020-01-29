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

if [ ! -f "$RESOURCES_PATH/zeppelin/zeppelin-0.8.2-bin-all/bin/zeppelin-daemon.sh"  ]; then
    echo "Installing Zeppelin. Please wait..."
    cd $RESOURCES_PATH
    mkdir ./zeppelin
    cd ./zeppelin
    echo "Downloading. Please wait..."
    wget -q https://www.apache.org/dist/zeppelin/zeppelin-0.8.2/zeppelin-0.8.2-bin-all.tgz -O ./zeppelin-0.8.2-bin-all.tgz
    tar xfz zeppelin-0.8.2-bin-all.tgz
    rm zeppelin-0.8.2-bin-all.tgz
    # https://github.com/mirkoprescha/spark-zeppelin-docker/blob/master/Dockerfile#L40
    echo '{ "allow_root": true }' > $HOME/.bowerrc
else
    echo "Zeppelin is already installed"
fi

# Run
if [ $INSTALL_ONLY = 0 ] ; then
    if [ -z "$PORT" ]; then
        read -p "Please provide a port for starting Zeppelin: " PORT
    fi

    echo "Starting Zeppelin on port "$PORT
    # Create tool entry for tooling plugin
    echo '{"id": "zeppelin-link", "name": "Zeppelin", "url_path": "/tools/'$PORT'/", "description": "Notebook for interactive data analytics"}' > $HOME/.workspace/tools/zeppelin.json
    export ZEPPELIN_HOME=$RESOURCES_PATH/zeppelin/zeppelin-0.8.2-bin-all
    mkdir -p $WORKSPACE_HOME/zeppelin
    mkdir -p $ZEPPELIN_HOME/logs
    mkdir -p $ZEPPELIN_HOME/run
    export ZEPPELIN_NOTEBOOK_DIR=$WORKSPACE_HOME/zeppelin
    export ZEPPELIN_PORT=$PORT
    # ZEPPELIN_CONF_DIR=$ZEPPELIN_HOME/conf
    $ZEPPELIN_HOME/bin/zeppelin.sh start
    sleep 15
fi
