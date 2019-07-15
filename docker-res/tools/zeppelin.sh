#!/bin/sh
if [ ! -f /resources/zeppelin/zeppelin-0.8.1-bin-all/bin/zeppelin-daemon.sh  ]; then
    echo "Installing zeppelin"
    mkdir /resources/zeppelin
    cd /resources/zeppelin
    wget https://www.apache.org/dist/zeppelin/zeppelin-0.8.1/zeppelin-0.8.1-bin-all.tgz -O ./zeppelin-0.8.1-bin-all.tgz
    tar -zxvf zeppelin-0.8.1-bin-all.tgz
    rm zeppelin-0.8.1-bin-all.tgz
fi

# Run
if [ -z "$1" ]; then
    echo "A port needs to be provided as argument to start zeppelin."
    echo "Exiting in 10 seconds."
    sleep 10
    exit 1
fi

echo "Starting zeppelin on port "$1
mkdir $WORKSPACE_HOME/zeppelin
export ZEPPELIN_NOTEBOOK_DIR=$WORKSPACE_HOME/zeppelin
export ZEPPELIN_PORT=$1
/resources/zeppelin/zeppelin-0.8.1-bin-all/bin/zeppelin-daemon.sh start