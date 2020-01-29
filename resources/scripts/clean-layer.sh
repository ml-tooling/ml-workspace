
#!/bin/bash
#
# This scripts should be called at the end of each RUN command
# in the Dockerfiles.
#
# Each RUN command creates a new layer that is stored separately.
# At the end of each command, we should ensure we clean up downloaded
# archives and source files used to produce binary to reduce the size
# of the layer.
set -e
set -x

# Delete old downloaded archive files 
apt-get autoremove -y
# Delete downloaded archive files
apt-get clean
# Delete source files used for building binaries
rm -rf /usr/local/src/*
# Delete cache and temp folders
rm -rf /tmp/* /var/tmp/* $HOME/.cache/* /var/cache/apt/*
# Remove apt lists
rm -rf /var/lib/apt/lists/* /etc/apt/sources.list.d/*

# Clean conda
if [ -x "$(command -v conda)" ]; then
    # Full Conda Cleanup
    conda clean --all -f -y
    # Remove source cache files
    conda build purge-all
    if [ -d $CONDA_DIR ]; then
        # Cleanup python bytecode files - not needed: https://jcrist.github.io/conda-docker-tips.html
        find $CONDA_DIR -type f -name '*.pyc' -delete
        find $CONDA_DIR -type l -name '*.pyc' -delete
    fi
fi

# Clean npm
if [ -x "$(command -v npm)" ]; then
    npm cache clean --force
    rm -rf $HOME/.npm/* $HOME/.node-gyp/*
fi