
#!/bin/bash
#
# This scripts should be called at the end of each RUN command
# in the Dockerfiles.
#
# Each RUN command creates a new layer that is stored separately.
# At the end of each command, we should ensure we clean up downloaded
# archives and source files used to produce binary to reduce the size
# of the layer.

# Disable exit on error
set +e
# Show all commands
set -x

echo "Running layer cleanup script..."

# Delete old downloaded archive files
apt-get autoremove -y
# Delete downloaded archive files
apt-get clean
# Delete source files used for building binaries
rm -rf /usr/local/src/*
# Delete cache and temp folders
rm -rf /tmp/* /var/tmp/* $HOME/.cache/* /var/cache/apt/*
# Fix permissions on tmp directory
chmod 1777 /tmp
# Remove apt lists
rm -rf /var/lib/apt/lists/*
# Remove third-party PPA files added via add-apt-repository, but keep the base OS's own sources
# (Ubuntu 24.04+ ships its default archive entries as /etc/apt/sources.list.d/ubuntu.sources -
# wiping the whole directory here breaks every apt-get call after the first RUN that calls this script)
find /etc/apt/sources.list.d/ -maxdepth 1 -type f ! -name 'ubuntu.sources' -delete 2>/dev/null

# Clean conda
if [ -x "$(command -v conda)" ]; then
    # Full Conda Cleanup
    conda clean --all -f -y
    # Remove source cache files
    conda build purge-all
    if [ -d $CONDA_ROOT ]; then
        # Cleanup python bytecode files - not needed: https://jcrist.github.io/conda-docker-tips.html
        find $CONDA_ROOT -type f -name '*.pyc' -delete
        find $CONDA_ROOT -type l -name '*.pyc' -delete
    fi
fi

# Clean npm
if [ -x "$(command -v npm)" ]; then
    npm cache clean --force
    rm -rf $HOME/.npm/* $HOME/.node-gyp/*
fi

# Clean yarn
if [ -x "$(command -v yarn)" ]; then
    yarn cache clean --all
fi

# pip is cleaned by the rm -rf $HOME/.cache/* commmand above

# Always exit without error
exit 0
