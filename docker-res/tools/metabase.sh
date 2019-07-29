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

if [ ! -f "/resources/metabase.jar" ]; then
    cd $RESOURCES_PATH
    echo "Installing metabase"
    wget http://downloads.metabase.com/v0.32.9/metabase.jar
else
    echo "Metabase is already installed"
fi

# Run
if [ $INSTALL_ONLY = 0 ] ; then
    if [ -z "$PORT" ]; then
        read -p "Please provide a port for starting metabase: " PORT
    fi

    echo "Starting metabase on port "$PORT
    export MB_JETTY_PORT=$PORT
    cd $RESOURCES_PATH
    java -jar metabase.jar
    sleep 15
fi
