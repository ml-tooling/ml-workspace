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

if ! hash clamscan 2>/dev/null; then
    # https://help.ubuntu.com/community/Antivirus
    # https://help.ubuntu.com/community/ClamAV
    echo "Installing ClamAV - Virus Scan"
    apt-get update
    apt-get install -y clamav clamtk
else
    echo "ClamAV is already installed" 
fi

# Run
if [ $INSTALL_ONLY = 0 ] ; then
    echo "Running clamav scan"
    sudo freshclam
    mkdir -p  $WORKSPACE_HOME/reports
    sudo clamscan --max-filesize=3999M --max-scansize=3999M --exclude-dir=/sys/* -i -r / | tee $WORKSPACE_HOME/reports/clamav-scan.txt
    sleep 100
fi