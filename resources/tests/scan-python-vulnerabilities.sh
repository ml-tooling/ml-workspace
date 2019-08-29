#!/bin/sh

# Stops script execution if a command has an error
set -e

INSTALL_ONLY=0
# Loop through arguments and process them: https://pretzelhands.com/posts/command-line-flags
for arg in "$@"; do
    case $arg in
        -i|--install) INSTALL_ONLY=1 ; shift ;;
        *) break ;;
    esac
done

if ! hash safety 2>/dev/null; then
    # https://github.com/future-architect/vuls
    echo "Installing Safety - pip vulnerability scanner"
    pip install safety
else
    echo "Safety is already installed" 
fi

# Run
if [ $INSTALL_ONLY = 0 ] ; then
    echo "Starting local safety scan"
    mkdir -p $WORKSPACE_HOME/reports/
    safety check | tee $WORKSPACE_HOME/reports/python-safety-scan.txt
    sleep 50
fi