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

echo "Installing Dev Utils Collection"
apt-get update
apt-get install -y --no-install-recommends \
        apache2 \
        redis-server \
        mercurial \
        bzr \
        postgresql \
        mysql-server \
        debian-archive-keyring debian-keyring \
        xvfb dbus-x11 x11-xserver-utils x11-utils wmctrl x11-apps \
        lmodern \
        msttcorefonts \
        libhdf5-serial-dev \
        gdb \
        aptitude \
        sshuttle \
        libgnome-keyring*

