#!/usr/bin/python

"""
Configure and run Jupyter Server
"""

from subprocess import call
import os
import sys

# start jupyter notebook. 
# start-notebook.sh handles whether it is a single notebook start 
# or started via JupyterHub
# Default configuration is provided in jupyter_notebook_config and can be changed via $NOTEBOOK_ARGS
call('/usr/local/bin/start-notebook.sh', shell=True, executable='/bin/bash')
