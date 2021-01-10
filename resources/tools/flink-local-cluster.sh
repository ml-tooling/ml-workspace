#!/bin/bash

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

# Script inspired by: https://ci.apache.org/projects/flink/flink-docs-stable/try-flink/local_installation.html

export FLINK_HOME=/opt/flink
export PATH=$PATH:$FLINK_HOME/bin

if [ ! -d "$FLINK_HOME" ]; then
    echo "Installing Flink. Please wait..."
    cd $RESOURCES_PATH
    FLINK_VERSION=1.12.0
    SCALA_VERSION=2.12
    echo "Downloading. Please wait..."
    wget -q https://ftp.fau.de/apache/flink/flink-$FLINK_VERSION/flink-$FLINK_VERSION-bin-scala_$SCALA_VERSION.tgz -O ./flink.tar.gz
    tar xzf flink.tar.gz
    mv flink-$FLINK_VERSION $FLINK_HOME
    rm flink.tar.gz
    # Install python library for flink
    # TODO: many dependencies changed: pip install --no-cache-dir apache-flink
else
    echo "Flink is already installed"
fi


# Run
if [ $INSTALL_ONLY = 0 ] ; then
    # TODO: support setting ports: http://www.alternatestack.com/development/apache-flink-change-port-for-web-front-end/
    echo "Start local Flink cluster..."
    $FLINK_HOME/bin/stop-cluster.sh
    $FLINK_HOME/bin/start-cluster.sh
    echo "Flink cluster is started. To access the dashboard, use the WebBrowser within VNC: http://localhost:8081 or use the link from the open-tool menu."
    echo '{"id": "flink-link", "name": "Flink", "url_path": "/tools/8081/", "description": "Apache Flink Dashboard"}' > $HOME/.workspace/tools/flink.json
    sleep 20
fi

