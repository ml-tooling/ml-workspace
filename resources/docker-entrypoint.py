#!/usr/bin/python

"""
Main Workspace Run Script
"""

from subprocess import call
import os
import math
import sys
from urllib.parse import quote

# Enable logging
import logging
logging.basicConfig(
    format='%(asctime)s [%(levelname)s] %(message)s', 
    level=logging.INFO, 
    stream=sys.stdout)

log = logging.getLogger(__name__)

log.info("Starting...")

def set_env_variable(env_variable: str, value: str, ignore_if_set: bool = False):
    if ignore_if_set and os.getenv(env_variable, None):
        # if it is already set, do not set it to the new value
        return
    # TODO is export needed as well?
    call('export ' + env_variable + '="' + value + '"', shell=True)
    os.environ[env_variable] = value

# Manage base path dynamically

ENV_JUPYTERHUB_SERVICE_PREFIX = os.getenv("JUPYTERHUB_SERVICE_PREFIX")

ENV_NAME_WORKSPACE_BASE_URL = "WORKSPACE_BASE_URL"
base_url = os.environ[ENV_NAME_WORKSPACE_BASE_URL]

if not base_url:
    base_url = ""

if ENV_JUPYTERHUB_SERVICE_PREFIX:
    # Installation with Jupyterhub
    
    # Base Url is not needed, Service prefix contains full path
    # ENV_JUPYTERHUB_BASE_URL = os.getenv("JUPYTERHUB_BASE_URL")
    # ENV_JUPYTERHUB_BASE_URL.rstrip('/') + 
    base_url = ENV_JUPYTERHUB_SERVICE_PREFIX

# Add leading slash
if not base_url.startswith("/"):
    base_url = "/" + base_url

# Remove trailing slash
base_url = base_url.rstrip('/').strip()
# always quote base url
base_url = quote(base_url, safe="/%")

set_env_variable(ENV_NAME_WORKSPACE_BASE_URL, base_url)

# Dynamically set MAX_NUM_THREADS
ENV_MAX_NUM_THREADS = os.getenv("MAX_NUM_THREADS", None)
if ENV_MAX_NUM_THREADS:
    # Determine the number of availabel CPU resources, but limit to a max number
    if ENV_MAX_NUM_THREADS.lower() == "auto":
        ENV_MAX_NUM_THREADS = str(math.ceil(os.cpu_count()))
        try:
            # read out docker information - if docker limits cpu quota
            cpu_count = math.ceil(int(os.popen('cat /sys/fs/cgroup/cpu/cpu.cfs_quota_us').read().replace('\n', '')) / 100000)
            if cpu_count > 0 and cpu_count < os.cpu_count():
                ENV_MAX_NUM_THREADS = str(cpu_count)
        except:
            pass
        if not ENV_MAX_NUM_THREADS or not ENV_MAX_NUM_THREADS.isnumeric() or ENV_MAX_NUM_THREADS == "0":
            ENV_MAX_NUM_THREADS = "4"
        
        if int(ENV_MAX_NUM_THREADS) > 8:
            # there should be atleast one thread less compared to cores
            ENV_MAX_NUM_THREADS = str(int(ENV_MAX_NUM_THREADS)-1)
        
        # set a maximum of 32, in most cases too many threads are adding too much overhead
        if int(ENV_MAX_NUM_THREADS) > 32:
            ENV_MAX_NUM_THREADS = "32"
    
    # only set if it is not None or empty
    # OMP_NUM_THREADS: Suggested value: vCPUs / 2 in which vCPUs is the number of virtual CPUs. 
    set_env_variable("OMP_NUM_THREADS", ENV_MAX_NUM_THREADS, ignore_if_set=True) # OpenMP
    set_env_variable("OPENBLAS_NUM_THREADS", ENV_MAX_NUM_THREADS, ignore_if_set=True) # OpenBLAS
    set_env_variable("MKL_NUM_THREADS", ENV_MAX_NUM_THREADS, ignore_if_set=True) # MKL
    set_env_variable("VECLIB_MAXIMUM_THREADS", ENV_MAX_NUM_THREADS, ignore_if_set=True) # Accelerate
    set_env_variable("NUMEXPR_NUM_THREADS", ENV_MAX_NUM_THREADS, ignore_if_set=True) # Numexpr
    set_env_variable("NUMEXPR_MAX_THREADS", ENV_MAX_NUM_THREADS, ignore_if_set=True) # Numexpr - maximum
    set_env_variable("NUMBA_NUM_THREADS", ENV_MAX_NUM_THREADS, ignore_if_set=True) # Numba
    set_env_variable("SPARK_WORKER_CORES", ENV_MAX_NUM_THREADS, ignore_if_set=True) # Spark Worker
    # TBB_NUM_THREADS
    # GOTO_NUM_THREADS

ENV_RESOURCES_PATH = os.getenv("RESOURCES_PATH", "/resources")
ENV_WORKSPACE_HOME = os.getenv('WORKSPACE_HOME', "/workspace")

# pass all script arguments to next script
script_arguments = " " + ' '.join(sys.argv[1:])

EXECUTE_CODE = os.getenv('EXECUTE_CODE', None)
if EXECUTE_CODE:
    # use workspace as working directory
    sys.exit(call("cd " + ENV_WORKSPACE_HOME + " && python " + ENV_RESOURCES_PATH + "/scripts/execute_code.py" + script_arguments, shell=True))

sys.exit(call("python " + ENV_RESOURCES_PATH + "/scripts/run_workspace.py" + script_arguments, shell=True))