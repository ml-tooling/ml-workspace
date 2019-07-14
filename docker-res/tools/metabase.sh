#!/bin/sh
if [ -z "$1" ]; then
    echo "A port needs to be provided as argument"
    exit 1
fi

if [ ! -f "/resources/metabase.jar" ]; then
    cd /resources
    echo "Installing metabase"
    wget http://downloads.metabase.com/v0.32.9/metabase.jar
fi

# Run
echo "Starting metabase on port "$1
export MB_JETTY_PORT=$1
cd /resources/
java -jar metabase.jar