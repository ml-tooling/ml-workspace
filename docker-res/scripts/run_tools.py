# !/usr/bin/python

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


# start vnc server
if not ENV_WORKSPACE_BASE_URL.startswith("/"):
    ENV_WORKSPACE_BASE_URL = "/" + ENV_WORKSPACE_BASE_URL

DESKTOP_PATH = os.getenv("HOME", "/root") + "/Desktop"

# Create Jupyter Shortcut
shortcut_metadata = '[Desktop Entry]\nVersion=1.0\nType=Link\nName=Jupyter Notebook\nComment=\nCategories=Development;\nIcon=' + ENV_RESOURCES_PATH + '/icons/jupyter-icon.png\nURL=http://localhost:8091' + ENV_WORKSPACE_BASE_URL

call('printf "' + shortcut_metadata + '" > ' + DESKTOP_PATH + '/jupyter.desktop', shell=True) # create a link on the Desktop to your Jupyter notebook server
call('chmod +x ' + DESKTOP_PATH + '/jupyter.desktop', shell=True) # Make executable
call('printf "' + shortcut_metadata + '" > /usr/share/applications/jupyter.desktop', shell=True) # create a link in categories menu to your Jupyter notebook server
call('chmod +x /usr/share/applications/jupyter.desktop', shell=True) # Make executable

# Create Jupyter Lab Shortcut
shortcut_metadata = '[Desktop Entry]\nVersion=1.0\nType=Link\nName=Jupyter Lab\nComment=\nCategories=Development;\nIcon=' + ENV_RESOURCES_PATH + '/icons/jupyterlab-icon.png\nURL=http://localhost:8091' + ENV_WORKSPACE_BASE_URL + "lab"

call('printf "' + shortcut_metadata + '" > /usr/share/applications/jupyterlab.desktop', shell=True) # create a link in categories menu to your Jupyter Lab server
call('chmod +x /usr/share/applications/jupyterlab.desktop', shell=True) # Make executable

# Start VNC
call("/dockerstartup/vnc_startup.sh &", shell=True)

# start the tools we want to offer in Jupyter
SCRIPTS_DIR = ENV_RESOURCES_PATH + "/scripts"

call(SCRIPTS_DIR + "/start_ungit.sh " + str(8051) + " &", shell=True)
call(SCRIPTS_DIR + "/start_glances.sh " + str(8053) + " &", shell=True)
call(SCRIPTS_DIR + "/start_vscode.sh " + str(8054) + " &", shell=True)


# The tool execution must be in this order, however, 
# because otherwise netdata raises an 'Insufficient Permissions' error. 
# I guess, some other tool messes with the permissions.
if ENV_WORKSPACE_TYPE == 'gpu':
    # The 'find' command is only relevant for the GPU container. 
    call("find / -name *nvidia* -exec sudo chmod -R a+rwx {} +", shell=True)

# Start netdata with provided netdata config on port 8050
call("/usr/sbin/netdata", shell=True)

