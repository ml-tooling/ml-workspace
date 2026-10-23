#!/usr/bin/python

"""
Main Workspace Run Script
"""

# Enable logging
import logging
import math
import os
import sys
from subprocess import call
from urllib.parse import quote

logging.basicConfig(
    format="%(asctime)s [%(levelname)s] %(message)s",
    level=logging.INFO,
    stream=sys.stdout,
)

log = logging.getLogger(__name__)

log.info("Starting...")


def set_env_variable(env_variable: str, value: str, ignore_if_set: bool = False):
    if ignore_if_set and os.getenv(env_variable, None):
        # if it is already set, do not set it to the new value
        return
    # TODO is export needed as well?
    call("export " + env_variable + '="' + value + '"', shell=True)
    os.environ[env_variable] = value


# Manage base path dynamically

ENV_JUPYTERHUB_SERVICE_PREFIX = os.getenv("JUPYTERHUB_SERVICE_PREFIX", None)

ENV_NAME_WORKSPACE_BASE_URL = "WORKSPACE_BASE_URL"
base_url = os.getenv(ENV_NAME_WORKSPACE_BASE_URL, "")

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
base_url = base_url.rstrip("/").strip()
# always quote base url
base_url = quote(base_url, safe="/%")

set_env_variable(ENV_NAME_WORKSPACE_BASE_URL, base_url)

# Dynamically set MAX_NUM_THREADS
ENV_MAX_NUM_THREADS = os.getenv("MAX_NUM_THREADS", None)
if ENV_MAX_NUM_THREADS:
    # Determine the number of availabel CPU resources, but limit to a max number
    if ENV_MAX_NUM_THREADS.lower() == "auto":
        ENV_MAX_NUM_THREADS = str(math.ceil(os.cpu_count()))
        # This container's own CPU limit (docker --cpus / Kubernetes limits.cpu), read at every start,
        # so each pod gets a thread count matching what it was given. cgroup v2 first - the v1 file
        # alone doesn't exist on cgroup v2 hosts, which made every container fall back to the
        # host's full CPU count (capped to 32 below) regardless of its limit.
        cpu_limit = None
        try:
            # cgroup v2: "<quota> <period>", or "max <period>" when unlimited
            with open("/sys/fs/cgroup/cpu.max") as f:
                quota, period = f.read().split()
            if quota != "max":
                cpu_limit = int(quota) / int(period)
        except (OSError, ValueError):
            try:
                # cgroup v1: quota is -1 when unlimited
                with open("/sys/fs/cgroup/cpu/cpu.cfs_quota_us") as f:
                    quota = int(f.read())
                with open("/sys/fs/cgroup/cpu/cpu.cfs_period_us") as f:
                    period = int(f.read())
                if quota > 0:
                    cpu_limit = quota / period
            except (OSError, ValueError):
                pass
        if cpu_limit:
            cpu_count = math.ceil(cpu_limit)
            if cpu_count > 0 and cpu_count < os.cpu_count():
                ENV_MAX_NUM_THREADS = str(cpu_count)
        if (
            not ENV_MAX_NUM_THREADS
            or not ENV_MAX_NUM_THREADS.isnumeric()
            or ENV_MAX_NUM_THREADS == "0"
        ):
            ENV_MAX_NUM_THREADS = "4"

        if int(ENV_MAX_NUM_THREADS) > 8:
            # there should be atleast one thread less compared to cores
            ENV_MAX_NUM_THREADS = str(int(ENV_MAX_NUM_THREADS) - 1)

        # set a maximum of 32, in most cases too many threads are adding too much overhead
        if int(ENV_MAX_NUM_THREADS) > 32:
            ENV_MAX_NUM_THREADS = "32"

    # only set if it is not None or empty
    # OMP_NUM_THREADS: Suggested value: vCPUs / 2 in which vCPUs is the number of virtual CPUs.
    set_env_variable(
        "OMP_NUM_THREADS", ENV_MAX_NUM_THREADS, ignore_if_set=True
    )  # OpenMP
    set_env_variable(
        "OPENBLAS_NUM_THREADS", ENV_MAX_NUM_THREADS, ignore_if_set=True
    )  # OpenBLAS
    set_env_variable("MKL_NUM_THREADS", ENV_MAX_NUM_THREADS, ignore_if_set=True)  # MKL
    set_env_variable(
        "VECLIB_MAXIMUM_THREADS", ENV_MAX_NUM_THREADS, ignore_if_set=True
    )  # Accelerate
    set_env_variable(
        "NUMEXPR_NUM_THREADS", ENV_MAX_NUM_THREADS, ignore_if_set=True
    )  # Numexpr
    set_env_variable(
        "NUMEXPR_MAX_THREADS", ENV_MAX_NUM_THREADS, ignore_if_set=True
    )  # Numexpr - maximum
    set_env_variable(
        "NUMBA_NUM_THREADS", ENV_MAX_NUM_THREADS, ignore_if_set=True
    )  # Numba
    set_env_variable(
        "SPARK_WORKER_CORES", ENV_MAX_NUM_THREADS, ignore_if_set=True
    )  # Spark Worker
    set_env_variable(
        "BLIS_NUM_THREADS", ENV_MAX_NUM_THREADS, ignore_if_set=True
    )  # Blis
    set_env_variable("TBB_NUM_THREADS", ENV_MAX_NUM_THREADS, ignore_if_set=True)  # TBB
    # GOTO_NUM_THREADS

ENV_RESOURCES_PATH = os.getenv("RESOURCES_PATH", "/resources")
ENV_WORKSPACE_HOME = os.getenv("WORKSPACE_HOME", "/workspace")

# pass all script arguments to next script
script_arguments = " " + " ".join(sys.argv[1:])

EXECUTE_CODE = os.getenv("EXECUTE_CODE", None)
if EXECUTE_CODE:
    # use workspace as working directory
    sys.exit(
        call(
            "cd "
            + ENV_WORKSPACE_HOME
            + " && python "
            + ENV_RESOURCES_PATH
            + "/scripts/execute_code.py"
            + script_arguments,
            shell=True,
        )
    )

sys.exit(
    call(
        "python " + ENV_RESOURCES_PATH + "/scripts/run_workspace.py" + script_arguments,
        shell=True,
    )
)
