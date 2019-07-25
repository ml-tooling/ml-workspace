#!/bin/sh
if [ ! -f "/opt/Rodeo/rodeo" ]; then
    cd /resources
    echo "Installing Rodeo"
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 33D40BC6
    add-apt-repository -u "deb http://rodeo-deb.yhat.com/ rodeo main"
    apt-get update
    apt-get -y --allow-unauthenticated install rodeo
fi

# Run
echo "Starting Rodeo"
/opt/Rodeo/rodeo
sleep 15