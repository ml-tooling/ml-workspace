#!/bin/sh
echo "Installing and starting Glances on port "$1

if ! hash glances 2>/dev/null; then
    pip install glances
fi

# Run
nohup glances -w -p $1 &>/dev/null &
sleep 5