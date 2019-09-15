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

if [ ! -f "/usr/sbin/netdata"  ]; then
    echo "Installing Netdata. Please wait..."
    cd $RESOURCES_PATH
    apt-get update
    wget https://my-netdata.io/kickstart.sh -O $RESOURCES_PATH/netdata-install.sh
    # Surpress output - if there is a problem remove to see logs > /dev/null
    /bin/bash $RESOURCES_PATH/netdata-install.sh --dont-wait --dont-start-it --stable-channel --disable-telemetry > /dev/null
    rm $RESOURCES_PATH/netdata-install.sh
else
    echo "Netdata is already installed"
fi

# Run
if [ $INSTALL_ONLY = 0 ] ; then
    if [ -z "$PORT" ]; then
        read -p "Please provide a port for starting Netdata: " PORT
    fi

    echo "Starting Netdata on port "$PORT
    # Create tool entry for tooling plugin
    echo '{"id": "netdata-link", "name": "Netdata", "url_path": "/tools/'$PORT'/", "description": "Monitor Hardware Resources"}' > $HOME/.workspace/tools/netdata.json
    /usr/sbin/netdata -D -p $PORT
    sleep 15
fi