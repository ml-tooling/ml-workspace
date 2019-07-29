#!/bin/sh

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

if [ ! -f "/resources/zeppelin/zeppelin-0.8.1-bin-all/bin/zeppelin-daemon.sh"  ]; then
    echo "Installing zeppelin"
    cd $RESOURCES_PATH
    mkdir ./zeppelin
    cd ./zeppelin
    wget https://www.apache.org/dist/zeppelin/zeppelin-0.8.1/zeppelin-0.8.1-bin-all.tgz -O ./zeppelin-0.8.1-bin-all.tgz
    tar -zxvf zeppelin-0.8.1-bin-all.tgz
    rm zeppelin-0.8.1-bin-all.tgz
else
    echo "Zeppelin is already installed"
fi

# Run
if [ $INSTALL_ONLY = 0 ] ; then
    if [ -z "$PORT" ]; then
        read -p "Please provide a port for starting Zeppelin: " PORT
    fi

    echo "Starting Zeppelin on port "$port
    mkdir -p $WORKSPACE_HOME/zeppelin
    export ZEPPELIN_NOTEBOOK_DIR=$WORKSPACE_HOME/zeppelin
    export ZEPPELIN_PORT=$PORT
    $RESOURCES_PATH/zeppelin/zeppelin-0.8.1-bin-all/bin/zeppelin-daemon.sh start
    sleep 15
fi
