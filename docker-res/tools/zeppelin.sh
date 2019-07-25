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
port=$1
if [ -z "$port" ]; then
    echo "A port needs to be provided as argument to start zeppelin."
    read -p "Please provide a port for starting zeppelin: " port
fi

echo "Starting zeppelin on port "$port
mkdir -p $WORKSPACE_HOME/zeppelin
export ZEPPELIN_NOTEBOOK_DIR=$WORKSPACE_HOME/zeppelin
export ZEPPELIN_PORT=$port
/resources/zeppelin/zeppelin-0.8.1-bin-all/bin/zeppelin-daemon.sh start
sleep 15