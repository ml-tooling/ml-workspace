#!/usr/bin/python

"""
Configure and run tools
"""

from subprocess import call
import os
import sys

# Enable logging
import logging
logging.basicConfig(
    format='%(asctime)s [%(levelname)s] %(message)s', 
    level=logging.INFO, 
    stream=sys.stdout)

log = logging.getLogger(__name__)

ENV_RESOURCES_PATH = os.getenv("RESOURCES_PATH", "/resources")
ENV_WORKSPACE_HOME = os.getenv("WORKSPACE_HOME", "/workspace")
ENV_WORKSPACE_BASE_URL = os.getenv("WORKSPACE_BASE_URL", "/")
HOME = os.getenv("HOME", "/root")

if not ENV_WORKSPACE_BASE_URL.startswith("/"):
    ENV_WORKSPACE_BASE_URL = "/" + ENV_WORKSPACE_BASE_URL

if not ENV_WORKSPACE_BASE_URL.endswith("/"):
    ENV_WORKSPACE_BASE_URL = ENV_WORKSPACE_BASE_URL + "/"

DESKTOP_PATH = HOME + "/Desktop"

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

# Configure filebrowser - only if database file does not exist yet (e.g. isn't restored)
if not os.path.exists(HOME + '/filebrowser.db'):
    log.info("Initialize filebrowser database.")
    # Init filebrowser configuration - Surpress all output
    call('filebrowser config init --database=' + HOME + '/filebrowser.db > /dev/null', shell=True)

    # Add admin user
    import random, string
    filebrowser_pwd = ''.join(random.sample(string.ascii_lowercase, 20))
    log.info("Create filebrowser admin with generated password: " + filebrowser_pwd)
    call('filebrowser users add admin ' + filebrowser_pwd + ' --perm.admin=true --database=' + HOME + '/filebrowser.db > /dev/null', shell=True)

    # Configure filebrowser
    configure_filebrowser = 'filebrowser config set --root="/" --auth.method=proxy --auth.header=X-Token-Header ' \
                    + ' --branding.files=$RESOURCES_PATH"/filebrowser/" --branding.name="Filebrowser" ' \
                    + ' --branding.disableExternal --signup=false --perm.admin=false --perm.create=false ' \
                    + ' --perm.delete=false --perm.download=true --perm.execute=false ' \
                    + ' --perm.admin=false --perm.create=false --perm.delete=false ' \
                    + ' --perm.modify=false --perm.rename=false --perm.share=false ' \
                    + '  --database=' + HOME + '/filebrowser.db'
    # Port and base url is configured at startup - Surpress all output
    call(configure_filebrowser + " > /dev/null", shell=True)

# Tools are started via supervisor, see supervisor.conf