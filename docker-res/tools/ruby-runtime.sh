#!/bin/sh
if ! hash ruby 2>/dev/null; then
    echo "Installing Ruby Runtime"
    apt-get update
    apt-get install -y ruby-full
else
    echo "Ruby Runtime is already installed"
fi

ruby --help
sleep 20