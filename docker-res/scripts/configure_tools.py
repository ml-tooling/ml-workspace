#!/usr/bin/python

"""
Configure and run tools
"""

from subprocess import call
import os
import sys

ENV_RESOURCES_PATH = os.getenv("RESOURCES_PATH", "/resources")
ENV_WORKSPACE_TYPE = os.getenv("WORKSPACE_TYPE", "cpu")
ENV_WORKSPACE_HOME = os.getenv("WORKSPACE_HOME", "/workspace")
ENV_WORKSPACE_BASE_URL = os.getenv("WORKSPACE_BASE_URL", "/")

if not ENV_WORKSPACE_BASE_URL.startswith("/"):
    ENV_WORKSPACE_BASE_URL = "/" + ENV_WORKSPACE_BASE_URL

if not ENV_WORKSPACE_BASE_URL.endswith("/"):
    ENV_WORKSPACE_BASE_URL = ENV_WORKSPACE_BASE_URL + "/"

DESKTOP_PATH = os.getenv("HOME", "/root") + "/Desktop"

# Get jupyter token 
ENV_AUTHENTICATE_VIA_JUPYTER = os.getenv("AUTHENTICATE_VIA_JUPYTER", "false")

token_parameter = ""
if ENV_AUTHENTICATE_VIA_JUPYTER.lower() == "true":
    # Check if started via Jupyterhub -> JPY_API_TOKEN is set
    ENV_JPY_API_TOKEN = os.getenv("JPY_API_TOKEN", None)
    if ENV_JPY_API_TOKEN:
        token_parameter = "?token=" + ENV_JPY_API_TOKEN
elif ENV_AUTHENTICATE_VIA_JUPYTER and ENV_AUTHENTICATE_VIA_JUPYTER.lower() != "false":
    token_parameter = "?token=" + ENV_AUTHENTICATE_VIA_JUPYTER

# Create Jupyter Shortcut
url = 'http://localhost:8091' + ENV_WORKSPACE_BASE_URL + token_parameter
shortcut_metadata = '[Desktop Entry]\nVersion=1.0\nType=Link\nName=Jupyter Notebook\nComment=\nCategories=Development;\nIcon=' + ENV_RESOURCES_PATH + '/icons/jupyter-icon.png\nURL=' + url

call('printf "' + shortcut_metadata + '" > ' + DESKTOP_PATH + '/jupyter.desktop', shell=True) # create a link on the Desktop to your Jupyter notebook server
call('chmod +x ' + DESKTOP_PATH + '/jupyter.desktop', shell=True) # Make executable
call('printf "' + shortcut_metadata + '" > /usr/share/applications/jupyter.desktop', shell=True) # create a link in categories menu to your Jupyter notebook server
call('chmod +x /usr/share/applications/jupyter.desktop', shell=True) # Make executable

# Create Jupyter Lab Shortcut
url = 'http://localhost:8091' + ENV_WORKSPACE_BASE_URL + "lab" + token_parameter
shortcut_metadata = '[Desktop Entry]\nVersion=1.0\nType=Link\nName=Jupyter Lab\nComment=\nCategories=Development;\nIcon=' + ENV_RESOURCES_PATH + '/icons/jupyterlab-icon.png\nURL=' + url

call('printf "' + shortcut_metadata + '" > /usr/share/applications/jupyterlab.desktop', shell=True) # create a link in categories menu to your Jupyter Lab server
call('chmod +x /usr/share/applications/jupyterlab.desktop', shell=True) # Make executable

# Set vnc password
call('mkdir -p $HOME/.vnc && touch $HOME/.vnc/passwd && echo "$VNC_PW" | vncpasswd -f >> $HOME/.vnc/passwd && chmod 600 $HOME/.vnc/passwd', shell=True)

# Tools are started via supervisor, see supervisor.conf