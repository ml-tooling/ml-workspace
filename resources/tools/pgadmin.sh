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

if ! hash pgadmin4 2>/dev/null; then
    echo "Installing pgAdmin4"
    pipx install pgadmin4
fi

# Run
if [ $INSTALL_ONLY = 0 ] ; then
  if [ -z "$PORT" ]; then
        read -p "Please provide a port for starting pgAdmin4: " PORT
    fi

    echo "Starting pgAdmin4 on port "$PORT
    # TODO: Currently does not use port, can only be used from within VNC
    pgadmin4
fi
