#!/bin/sh
if ! hash /opt/Rodeo/rodeo 2>/dev/null; then
    cd /resources
    echo "Installing Rodeo"
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 33D40BC6
    add-apt-repository -u "deb http://rodeo-deb.yhat.com/ rodeo main"
    apt-get update
    apt-get -y install rodeo
fi

# Run
echo "Starting Rodeo"
/opt/Rodeo/rodeo