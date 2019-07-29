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

if [ -z "$PORT" ]; then
    read -p "Please provide a port for starting franchise: " PORT
fi

if [ ! -d "/resources/franchise" ]; then
    cd $RESOURCES_PATH
    echo "Installing franchise on port "$PORT
    npm update
    git clone --depth 1 https://github.com/HVF/franchise.git
    cd franchise
    sed -i 's/"start": "nwb serve-react-app"/"start": "nwb serve-react-app --port='"$PORT"'"/g' package.json
    npm install
else
    echo "Franchise is already installed"
fi

# Run
if [ $INSTALL_ONLY = 0 ] ; then
    echo "Starting franchise on port "$PORT
    # TODO change port again via sed and regex
    cd $RESOURCES_PATH/franchise
    npm start
    sleep 10
fi

