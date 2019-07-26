#!/bin/sh
if ! hash git-lfs 2>/dev/null; then
    echo "Installing Git LFS"
    apt-get update
    curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | sudo bash
    apt-get install git-lfs --yes
    git lfs install
else
    echo "Git LFS is already installed"
fi

git-lfs
sleep 10