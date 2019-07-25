#!/bin/sh
if ! hash mc 2>/dev/null; then
    echo "Installing Minio Utility (mc)"
    wget --quiet https://dl.min.io/client/mc/release/linux-amd64/mc -O /usr/sbin/mc
    chmod +x /usr/sbin/mc
else
    echo "Minio Utility is already installed"
fi

# Run
echo "Use minio mc via command line:"
mc --help
sleep 20