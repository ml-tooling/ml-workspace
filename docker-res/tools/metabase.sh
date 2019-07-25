#!/bin/sh
if [ ! -f "/resources/metabase.jar" ]; then
    cd /resources
    echo "Installing metabase"
    wget http://downloads.metabase.com/v0.32.9/metabase.jar
fi

# Run
port=$1
if [ -z "$port" ]; then
    echo "A port needs to be provided as argument to start metabase."
    read -p "Please provide a port for starting metabase: " port
fi

echo "Starting metabase on port "$port
export MB_JETTY_PORT=$port
cd /resources/
java -jar metabase.jar
sleep 15