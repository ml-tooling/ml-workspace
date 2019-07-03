#!/bin/sh

if ! hash ungit 2>/dev/null; then
    echo "Installing ungit."
    npm update
    npm install -g ungit
fi

# Run
echo "Starting ungit on port "$1
nohup ungit --port=$1 --launchBrowser=0 --bugtracking=false --rootPath=$WORKSPACE_BASE_URL/tools/ungit &>/dev/null &
sleep 5
