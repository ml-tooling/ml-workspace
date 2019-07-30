#!/usr/bin/python

"""
Configure and run custom scripts
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

# Do nothing here, this file can be overwritten by containers that extend the workspace