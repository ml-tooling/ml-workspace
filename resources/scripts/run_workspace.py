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

log.info("Start Workspace")

ENV_RESOURCES_PATH = os.getenv("RESOURCES_PATH", "/resources")

# Include tutorials 
WORKSPACE_HOME = os.getenv('WORKSPACE_HOME', "/workspace")
INCLUDE_TUTORIALS = os.getenv('INCLUDE_TUTORIALS', "true")

# Only copy all content of tutorial folder to workspace folder if it is initialy empty
if INCLUDE_TUTORIALS.lower() == "true" and os.path.exists(WORKSPACE_HOME) and len(os.listdir(WORKSPACE_HOME)) == 0:
    log.info("Copy tutorials to /workspace folder")
    from distutils.dir_util import copy_tree
    # Copy all files within tutorials folder in resources to workspace home
    copy_tree(os.path.join(ENV_RESOURCES_PATH, "tutorials"), WORKSPACE_HOME)

# restore config on startup - if CONFIG_BACKUP_ENABLED - it needs to run before other configuration 
call("python " + ENV_RESOURCES_PATH + "/scripts/backup_restore_config.py restore", shell=True)

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

startup_custom_script = os.path.join(WORKSPACE_HOME, "on_startup.sh")
if os.path.exists(startup_custom_script):
    log.info("Run on_startup.sh user script from workspace folder")
    # run startup script from workspace folder - can be used to run installation routines on workspace updates
    call("/bin/bash " + startup_custom_script, shell=True)

# Run supervisor process - main container process
call('supervisord -n -c /etc/supervisor/supervisord.conf', shell=True)