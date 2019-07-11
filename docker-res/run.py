#!/usr/bin/python

"""
Main Workspace Run Script
"""

from subprocess import call
import os
import logging, sys

print("Starting Workspace")

logging.basicConfig(stream=sys.stdout, format='%(asctime)s : %(levelname)s : %(message)s', level=logging.INFO)
log = logging.getLogger(__name__)

# Manage base path dynamically
ENV_JUPYTERHUB_BASE_URL = os.getenv("JUPYTERHUB_BASE_URL")
ENV_JUPYTERHUB_SERVICE_PREFIX = os.getenv("JUPYTERHUB_SERVICE_PREFIX")

ENV_NAME_WORKSPACE_BASE_URL = "WORKSPACE_BASE_URL"
base_url = os.environ[ENV_NAME_WORKSPACE_BASE_URL]

if not base_url:
    base_url = ""

if ENV_JUPYTERHUB_BASE_URL and ENV_JUPYTERHUB_SERVICE_PREFIX:
    # Installation with Jupyterhub -> use combination as base path
    base_url = ENV_JUPYTERHUB_BASE_URL.rstrip('/') + ENV_JUPYTERHUB_SERVICE_PREFIX

# Add leading slash
if not base_url.startswith("/"):
    base_url = "/" + base_url

# Remove trailing slash
base_url = base_url.rstrip('/').strip()

# Dynamically set noVNC websockify path during runtime
websockify_path = base_url.strip('/') + "/tools/vnc/websockify"
call("sed -i \"s@UI.updateSetting('path', 'workspace/tools/vnc/websockify')@UI.updateSetting('path', '" + websockify_path + "')@g\" /headless/noVNC/app/ui.js", shell=True)

# TODO is export needed as well?
call("export " + ENV_NAME_WORKSPACE_BASE_URL + "=" + base_url, shell=True)
os.environ[ENV_NAME_WORKSPACE_BASE_URL] = base_url

ENV_RESOURCES_PATH = os.getenv("RESOURCES_PATH", "/resources")

log.info("Configure ssh service")
call("python " + ENV_RESOURCES_PATH + "/scripts/configure_ssh.py", shell=True)

log.info("Configure nginx service")
call("python " + ENV_RESOURCES_PATH + "/scripts/configure_nginx.py", shell=True)

log.info("Configure tools")
call("python " + ENV_RESOURCES_PATH + "/scripts/configure_tools.py", shell=True)

log.info("Configure cron scripts")
call("python " + ENV_RESOURCES_PATH + "/scripts/configure_cron_scripts.py", shell=True)

log.info("Configure and run custom scripts")
call("python " + ENV_RESOURCES_PATH + "/scripts/run_custom_scripts.py", shell=True)

# Start VNC
call("/dockerstartup/vnc_startup.sh &", shell=True)

call('supervisord -n -c /etc/supervisor/supervisord.conf', shell=True)