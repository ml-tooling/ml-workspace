#!/bin/sh

# Stops script execution if a command has an error
set -e

INSTALL_ONLY=0

# Loop through arguments and process them: https://pretzelhands.com/posts/command-line-flags
for arg in "$@"; do
    case $arg in
        -i|--install) INSTALL_ONLY=1 ; shift ;;
        *) break ;;
    esac
done

if [ ! -f "/usr/sbin/xrdp"  ]; then
    echo "Installing XRDP. Please wait..."
    cd ${RESOURCES_PATH}
    apt-get update
    yes N | apt-get install -y --no-install-recommends xrdp
    # use xfce
    sudo sed -i.bak '/fi/a #xrdp multiple users configuration \n xfce-session \n' /etc/xrdp/startwm.sh
    # generate /etc/xrdp/rsakeys.ini
    cd /etc/xrdp/ && xrdp-keygen xrdp
else
    echo "XRDP is already installed"
fi

# Run
if [ $INSTALL_ONLY = 0 ] ; then
    echo "Starting XRDP server"
    /usr/sbin/xrdp -nodaemon
    sleep 10
fi
