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

echo "Installing Dev Utils Collection. Please wait..."
# Add bazel repo: https://docs.bazel.build/versions/master/install-ubuntu.html
echo "deb [arch=amd64] https://storage.googleapis.com/bazel-apt stable jdk1.8" | sudo tee /etc/apt/sources.list.d/bazel.list
curl https://bazel.build/bazel-release.pub.gpg | sudo apt-key add -

apt-get update
apt-get install -y --no-install-recommends \
        apache2 \
        mercurial \
        bzr \
        cvs \
        bazel \
        debian-archive-keyring debian-keyring \
        xvfb dbus-x11 x11-xserver-utils x11-utils wmctrl x11-apps \
        lmodern \
        msttcorefonts \
        libhdf5-serial-dev \
        gdb \
        aptitude \
        sshuttle \
        libgnome-keyring*
