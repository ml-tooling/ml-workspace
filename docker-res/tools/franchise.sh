#!/bin/sh
if [ -z "$1" ]; then
    echo "A port needs to be provided as argument to start franchise."
    echo "Exiting in 10 seconds."
    sleep 10
    exit 1
fi

if [ ! -d "/resources/franchise" ]; then
    cd /resources
    echo "Installing franchise on port "$1
    npm update
    git clone --depth 1 https://github.com/HVF/franchise.git
    cd franchise
    sed -i 's/"start": "nwb serve-react-app"/"start": "nwb serve-react-app --port='"$1"'"/g' package.json
    npm install
fi

# Run
echo "Starting franchise on port "$1
# TODO change port again via sed and regex
cd /resources/franchise
npm start