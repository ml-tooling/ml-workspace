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

if ! hash omnidb-server 2>/dev/null; then
    echo "Installing OmniDB"
    cd $RESOURCES_PATH
    wget https://github.com/OmniDB/OmniDB/releases/download/3.0.2b/omnidb-server_3.0.2b_linux_x86_64.deb -O ./omnidb-server.deb
    apt-get update
    apt-get install -y ./omnidb-server.deb
    rm ./omnidb-server.deb
fi

# Run
if [ $INSTALL_ONLY = 0 ] ; then
  if [ -z "$PORT" ]; then
        read -p "Please provide a port for starting OmniDB: " PORT
    fi

    echo "Starting OmniDB on port "$PORT
    # TODO: the normal tooling proxy does not work here since the traffic is not redirected the the configured base path
    # https://omnidb.readthedocs.io/en/latest/en/05_deploying_omnidb-server.html
    # use --path /tools/8000 to configure a base path
    omnidb-server --port=$PORT
fi
