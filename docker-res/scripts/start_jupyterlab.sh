#!/bin/sh
echo "Installing and starting JupyterLab on port "$1

pip install jupyterlab

# Run
nohup jupyter lab --port $1 --NotebookApp.token='' --allow-root &>/dev/null &
sleep 5