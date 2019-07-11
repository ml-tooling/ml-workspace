#!/usr/bin/python

"""
Configure and run cron scripts
"""

from subprocess import call
import os
import sys

ENV_RESOURCES_PATH = os.getenv("RESOURCES_PATH", "/resources")

# start check xfdesktop leak process
call("python " + ENV_RESOURCES_PATH + "/scripts/check_xfdesktop_leak.py schedule", shell=True)

# Conifg Backup 

# restore config on startup
call("python " + ENV_RESOURCES_PATH + "/scripts/backup_restore_config.py restore", shell=True)

# backup config directly on startup (e.g. ssh key)
call("python " + ENV_RESOURCES_PATH + "/scripts/backup_restore_config.py backup", shell=True)

# start backup restore config process
call("python " + ENV_RESOURCES_PATH + "/scripts/backup_restore_config.py schedule", shell=True)