#!/bin/sh
echo "Installing and starting ungit on port "$1

if ! hash ungit 2>/dev/null; then
    npm update
    npm install -g ungit
fi

# Run
nohup ungit --port=$1 --launchBrowser=0 --bugtracking=false --rootPath="workspace/tools/ungit" &>/dev/null &
sleep 5
