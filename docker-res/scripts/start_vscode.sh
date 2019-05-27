#!/bin/sh
echo "Starting vscode on port "$1

# Run

# set path to default vscode path - share with VNC version
nohup code-server --port=$1 --allow-http --disable-telemetry --user-data-dir=/root/.config/Code/ --extensions-dir=/root/.vscode/extensions/ --no-auth /workspace/ &>/dev/null &
sleep 5