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

if [ ! -d "$CONDA_DIR/envs/python2" ]; then
    echo "Installing Python 2.7 Interpreter and Kernel. Please wait..."
    conda create --yes -p $CONDA_DIR/envs/python2 python=2.7
    ln -s $CONDA_DIR/envs/python2/bin/pip $CONDA_DIR/bin/pip2
    ln -s $CONDA_DIR/envs/python2/bin/ipython2 $CONDA_DIR/bin/ipython2
    $CONDA_DIR/bin/pip2 install --upgrade pip
    # Install compatibility libraries
    $CONDA_DIR/bin/pip2 install future enum34 six typing
    # Add as Python 2 kernel
    # Install Python 2 kernel spec globally to avoid permission problems when NB_UID
    # switching at runtime and to allow the notebook server running out of the root
    # environment to find it. Also, activate the python2 environment upon kernel launch.
    pip install --no-cache-dir kernda
    $CONDA_DIR/envs/python2/bin/python -m pip install ipykernel
    $CONDA_DIR/envs/python2/bin/python -m ipykernel install
    kernda -o -y /usr/local/share/jupyter/kernels/python2/kernel.json
    # link conda python 2 to python 2 bin instances (in /usr/bin)
    ln -s -f $CONDA_DIR/envs/python2/bin/python /usr/bin/python2
    rm /usr/bin/python2.7
    ln -s -f $CONDA_DIR/envs/python2/bin/python /usr/bin/python2.7
else
    echo "Python 2.7 Interpreter is already installed"
fi

# Run
if [ $INSTALL_ONLY = 0 ] ; then
    echo "Use python 2.7 via command-line."
    python2.7 --version
    sleep 15
fi

