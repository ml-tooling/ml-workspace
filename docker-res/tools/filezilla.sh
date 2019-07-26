#!/bin/sh
if ! hash filezilla 2>/dev/null; then
    echo "Installing Filezilla"
    apt-get update
    apt-get install --yes filezilla
fi

# Run
echo "Starting Filezilla"
filezilla