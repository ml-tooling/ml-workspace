#!/usr/bin/python

# System libraries
from __future__ import absolute_import, division, print_function

import argparse
import logging
import os
import random
import sys
import time
import psutil
import subprocess

# Enable logging
logging.basicConfig(
    format='%(asctime)s [%(levelname)s] %(message)s', 
    level=logging.INFO, 
    stream=sys.stdout)

def get_process_id(name):
    """Return process ids found by (partial) name.

    >>> get_process_id('kthreadd')
    [2]
    >>> get_process_id('watchdog')
    [10, 11, 16, 21, 26, 31, 36, 41, 46, 51, 56, 61]  # ymmv
    >>> get_process_id('non-existent process')
    []
    """
    return list(map(int,subprocess.check_output(["pidof",name]).split()))

log = logging.getLogger(__name__)

# Studio Libraries
parser = argparse.ArgumentParser()
parser.add_argument('mode', type=str, default="check", help='Either check or schedule the xfdesktop leak check.',
                    choices=["check", "schedule"])

args, unknown = parser.parse_known_args()
if unknown:
    log.info("Unknown arguments " + str(unknown))

if args.mode == "check":
    log.debug("Starting xfdesktop leak check.")
    
    CHECKS = 10 # number of checks
    CHECK_INTERVAL = 15 # seconds
    MEMORY_THRESHOLD = 120000000 # == 120 MB
    CPU_THRESHOLD = 1 # 1 % average - low value because probably relativ to cpus
    MAX_MEMORY_THRESHOLD = 250000000 # == 250MB if it reaches this memory, kill anyways (regardless of CPU)
    
    # TODO generify for any process

    # Get processes
    try:
        xfdesktop_pids = get_process_id("xfdesktop")
        if len(xfdesktop_pids) > 1:
            log.info("Multiple processes found for xfdesktop: " + str(xfdesktop_pids))
        xfdesktop_process = psutil.Process(int(xfdesktop_pids[0]))

        xfsettingsd_pids = get_process_id("xfsettingsd")
        if len(xfsettingsd_pids) > 1:
            log.info("Multiple processes found for xfsettingsd: " + str(xfsettingsd_pids))
        xfsettingsd_process = psutil.Process(int(xfsettingsd_pids[0]))

        xfce4panel_pids = get_process_id("xfce4-panel")
        if len(xfce4panel_pids) > 1:
            log.info("Multiple processes found for xfce4-panel: " + str(xfce4panel_pids))
        xfce4panel_process = psutil.Process(int(xfce4panel_pids[0]))
    except:
        # could not find processes
        log.info("Failed to find xfdesktop, xfsettingsd, or xfce4-panel.")
        sys.exit()

    # Initial stats (on the first call those stats give wrong data):
    xfdesktop_process.memory_info().rss
    xfdesktop_process.cpu_percent()
    xfsettingsd_process.memory_info().rss
    xfsettingsd_process.cpu_percent()
    xfce4panel_process.memory_info().rss
    xfce4panel_process.cpu_percent()

    xfdesktop_memory_sum = 0
    xfdesktop_cpu_sum = 0
    xfsettingsd_memory_sum = 0
    xfsettingsd_cpu_sum = 0
    xfce4panel_memory_sum = 0
    xfce4panel_cpu_sum = 0

    for i in range(CHECKS):
        time.sleep(CHECK_INTERVAL) 
        # xfdesktop
        xfdesktop_memory_sum += xfdesktop_process.memory_info().rss
        # always call cpu percentage twice... otherwise it might be 0.0
        xfdesktop_process.cpu_percent()
        time.sleep(1) 
        xfdesktop_cpu_sum += xfdesktop_process.cpu_percent()
        
        # xfsettingsd
        xfsettingsd_memory_sum += xfsettingsd_process.memory_info().rss
        # always call cpu percentage twice... otherwise it might be 0.0
        xfsettingsd_process.cpu_percent()
        time.sleep(1)
        xfsettingsd_cpu_sum += xfsettingsd_process.cpu_percent()

        # xfce4panel
        xfce4panel_memory_sum += xfce4panel_process.memory_info().rss
        # always call cpu percentage twice... otherwise it might be 0.0
        xfce4panel_process.cpu_percent()
        time.sleep(1)
        xfce4panel_cpu_sum += xfce4panel_process.cpu_percent()
    
    xfdesktop_memory_avg = xfdesktop_memory_sum/CHECKS
    xfdesktop_cpu_avg = xfdesktop_cpu_sum/CHECKS
    xfsettingsd_memory_avg = xfsettingsd_memory_sum/CHECKS
    xfsettingsd_cpu_avg = xfsettingsd_cpu_sum/CHECKS
    xfce4panel_memory_avg = xfce4panel_memory_sum/CHECKS
    xfce4panel_cpu_avg = xfce4panel_cpu_sum/CHECKS

    log.info("Leak check: xfdesktop (mem=" + str(xfdesktop_memory_avg) + " cpu=" + str(xfdesktop_cpu_avg) + "); xfsettingsd (mem=" + str(xfsettingsd_memory_avg) + " cpu=" + str(xfsettingsd_cpu_avg) + "); xfce4-panel (mem=" + str(xfce4panel_memory_avg) + " cpu=" + str(xfce4panel_cpu_avg) + ")")

    if (xfdesktop_memory_avg > MEMORY_THRESHOLD and xfdesktop_cpu_avg > CPU_THRESHOLD) or xfdesktop_memory_avg > MAX_MEMORY_THRESHOLD:
        log.info("xfdesktop process is leaking. Kill xfdesktop processes!")
        xfdesktop_process.kill()
    
    if (xfsettingsd_memory_avg > MEMORY_THRESHOLD and xfsettingsd_cpu_avg > CPU_THRESHOLD) or xfsettingsd_memory_avg > MAX_MEMORY_THRESHOLD:
        log.info("xfsettingsd process is leaking. Kill xfsettingsd processes!")
        xfsettingsd_process.kill()

    if (xfce4panel_memory_avg > MEMORY_THRESHOLD and xfce4panel_cpu_avg > CPU_THRESHOLD) or xfce4panel_memory_avg > MAX_MEMORY_THRESHOLD:
        log.info("xfce4-panel process is leaking. Kill xfce4-panel processes!")
        xfce4panel_process.kill()
        time.sleep(5)
        log.info("Start xfce4-panel again.")
        log.info("xfce4-panel started with exit code: " + str(subprocess.call("xfce4-panel", shell=True)))

elif args.mode == "schedule":
    DEFAULT_CRON = "0 * * * *"  # every hour
    
    from crontab import CronTab, CronSlices

    cron_schedule = DEFAULT_CRON

    script_file_path = os.path.realpath(__file__)
    command = sys.executable + " '" + script_file_path + "' check> /proc/1/fd/1 2>/proc/1/fd/2"

    cron = CronTab(user=True)

    # remove all other tasks
    cron.remove_all(command=command)

    job = cron.new(command=command)
    if CronSlices.is_valid(cron_schedule):
        log.info("Scheduling cron check xfdesktop task with with cron: " + cron_schedule)
        job.setall(cron_schedule)
        job.enable()
        cron.write()
    else:
        log.info("Failed to schedule check xfdesktop. Cron is not valid.")

    log.info("Running cron jobs:")
    for job in cron:
        log.info(job)