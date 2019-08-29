#!/usr/bin/python

# System libraries
from __future__ import absolute_import, division, print_function

import argparse
import logging
import os
import random
import subprocess
import sys
import time

# Enable logging
logging.basicConfig(
    format='%(asctime)s [%(levelname)s] %(message)s', 
    level=logging.INFO, 
    stream=sys.stdout)

log = logging.getLogger(__name__)

parser = argparse.ArgumentParser()
parser.add_argument('mode', type=str, default="backup", help='Either backup or restore the workspace configuration.',
                    choices=["backup", "restore", "schedule"])

args, unknown = parser.parse_known_args()
if unknown:
    log.info("Unknown arguments " + str(unknown))

WORKSPACE_HOME = os.getenv('WORKSPACE_HOME')
USER_HOME = os.getenv('HOME')
RESOURCE_FOLDER = os.getenv('RESOURCES_PATH')
CONFIG_BACKUP_ENABLED = os.getenv('CONFIG_BACKUP_ENABLED')
CONFIG_BACKUP_FOLDER = WORKSPACE_HOME + "/.workspace/backup/"

if args.mode == "restore":
    if CONFIG_BACKUP_ENABLED is None or CONFIG_BACKUP_ENABLED.lower() == "false" or CONFIG_BACKUP_ENABLED.lower() == "off":
        log.info("Configuration Backup is not activated. Restore process will not be started.")
        sys.exit()

    log.info("Running config backup restore.")

    if not os.path.exists(CONFIG_BACKUP_FOLDER) or len(os.listdir(CONFIG_BACKUP_FOLDER)) == 0:
        log.info("Nothing to restore. Config backup folder is empty.")
        sys.exit()
    
    # set verbose? -v
    rsync_restore =  "rsync -a -r -t -z -E -X -A " + CONFIG_BACKUP_FOLDER + " " + USER_HOME
    log.debug("Run rsync restore: " + rsync_restore)
    subprocess.call(rsync_restore, shell=True)
elif args.mode == "backup":
    if not os.path.exists(CONFIG_BACKUP_FOLDER):
        os.makedirs(CONFIG_BACKUP_FOLDER)
    
    log.info("Starting configuration backup.")
    backup_selection = "--include='/.config' \
                        --include='/.config/xfce4/' --include='/.config/xfce4/xfconf/***' \
                        --include='/.config/Code/' --include='/.config/Code/User/' --include='/.config/Code/User/settings.json' \
                        --include='/.config/gtk-3.0/' --include='/.config/gtk-3.0/bookmarks' \
                        --include='/.gitconfig' \
                        --include='/filebrowser.db' \
                        --include='/.local/' --include='/.local/share/' --include='/.local/share/jupyter/' --include='/.local/share/jupyter/kernels/***' \
                        --include='/.jupyter/***'"
    # Do not backup vscode extensions? --include='/.vscode/***' \
    
    # TODO configure selection via environemnt flag? 
    # set verbose? -v
    rsync_backup =  "rsync -a -r -t -z -E -X -A --delete-excluded --max-size=100m \
                        " + backup_selection + " \
                        --exclude='/.ssh/environment' --include='/.ssh/***' \
                        --exclude='*' " + USER_HOME + "/ " + CONFIG_BACKUP_FOLDER
    log.debug("Run rsync backup: " + rsync_backup)
    subprocess.call(rsync_backup, shell=True)

elif args.mode == "schedule":
    DEFAULT_CRON = "0 * * * *"  # every hour

    if CONFIG_BACKUP_ENABLED is None or CONFIG_BACKUP_ENABLED.lower() == "false" or CONFIG_BACKUP_ENABLED.lower() == "off":
        log.info("Configuration Backup is not activated.")
        sys.exit()

    if not os.path.exists(CONFIG_BACKUP_FOLDER):
        os.makedirs(CONFIG_BACKUP_FOLDER)
    
    from crontab import CronTab, CronSlices

    cron_schedule = DEFAULT_CRON
    # env variable can also be a cron scheadule
    if CronSlices.is_valid(CONFIG_BACKUP_ENABLED):
        cron_schedule = CONFIG_BACKUP_ENABLED
    
    # Cron does not provide enviornment variables, source them manually
    environment_file = os.path.join(RESOURCE_FOLDER, "environment.sh")
    with open(environment_file, 'w') as fp:
        for env in os.environ:
            if env != "LS_COLORS":
                fp.write("export " + env + "=\"" + os.environ[env] + "\"\n")

    os.chmod(environment_file, 0o777)

    script_file_path = os.path.realpath(__file__)
    command = ". " + environment_file + "; " + sys.executable + " '" + script_file_path + "' backup> /proc/1/fd/1 2>/proc/1/fd/2"
    cron = CronTab(user=True)

    # remove all other backup tasks
    cron.remove_all(command=command)

    job = cron.new(command=command)
    if CronSlices.is_valid(cron_schedule):
        log.info("Scheduling cron config backup task with with cron: " + cron_schedule)
        job.setall(cron_schedule)
        job.enable()
        cron.write()
    else:
        log.info("Failed to schedule config backup. Cron is not valid.")

    log.info("Running cron jobs:")
    for job in cron:
        log.info(job)
