#!/bin/sh
port=$1
if [ -z "$port" ]; then
    echo "A port needs to be provided as argument to start franchise."
    read -p "Please provide a port for starting franchise: " port
fi

if [ ! -d "/resources/franchise" ]; then
    cd /resources
    echo "Installing franchise on port "$port
    npm update
    git clone --depth 1 https://github.com/HVF/franchise.git
    cd franchise
    sed -i 's/"start": "nwb serve-react-app"/"start": "nwb serve-react-app --port='"$port"'"/g' package.json
    npm install
fi

# Run
echo "Starting franchise on port "$port
# TODO change port again via sed and regex
cd /resources/franchise
npm start
sleep 10