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

if ! hash mongod 2>/dev/null; then
    echo "Installing MongoDB. Please wait..."
    cd $RESOURCES_PATH
    wget -qO - https://www.mongodb.org/static/pgp/server-4.2.asc | sudo apt-key add -
    echo "deb [ arch=amd64 ] https://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/4.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.2.list
    apt-get update
    apt-get install -y mongodb-org
    # set mongodb runner to set default environment variables
    # alias mongod='LD_LIBRARY_PATH="" LD_PRELOAD="" /usr/bin/mongod'
    mv /usr/bin/mongod /usr/bin/mongod-original
    printf '#!/bin/bash\nbash -c "LD_LIBRARY_PATH= LD_PRELOAD= /usr/bin/mongod-original $*"' > /usr/bin/mongod
    chmod a+rwx /usr/bin/mongod
else
    echo "MongoDB is already installed"
fi

# Run
if [ $INSTALL_ONLY = 0 ] ; then
    echo "Use mongod via command line:"
    mongod --help
    sleep 20
fi