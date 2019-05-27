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

ENV_RESOURCES_PATH = os.getenv("RESOURCES_PATH", "/resources")

log.info("Configure and run nginx service")
call("python " + ENV_RESOURCES_PATH + "/scripts/run_nginx.py", shell=True)

log.info("Configure and run ssh service")
call("python " + ENV_RESOURCES_PATH + "/scripts/run_ssh.py", shell=True)

log.info("Configure and run tools")
call("python " + ENV_RESOURCES_PATH + "/scripts/run_tools.py", shell=True)

log.info("Configure and run cron scripts")
call("python " + ENV_RESOURCES_PATH + "/scripts/run_cron_scripts.py", shell=True)

log.info("Configure and run custom scripts")
call("python " + ENV_RESOURCES_PATH + "/scripts/run_custom_scripts.py", shell=True)

log.info("Configure and run jupyter")
call("python " + ENV_RESOURCES_PATH + "/scripts/run_jupyter.py", shell=True)