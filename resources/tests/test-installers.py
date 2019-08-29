#!/usr/bin/python

"""
Configure and run custom scripts
"""
import subprocess
import os
import sys
import logging

logging.basicConfig(stream=sys.stdout, format='%(asctime)s : %(levelname)s : %(message)s', level=logging.INFO)
log = logging.getLogger(__name__)

# Wrapper to print out command
def call(command):
    print("Executing: "+command)
    return subprocess.call(command, shell=True)

ENV_RESOURCES_PATH = os.getenv("RESOURCES_PATH", "/resources")
TOOLS_DIR = os.path.join(ENV_RESOURCES_PATH, "tools")

test_results = {}

for filename in os.listdir(TOOLS_DIR):
    if filename.endswith(".sh"):
        script_path = os.path.join(TOOLS_DIR, filename)
        print("Testing " + filename)
        exit_code = call(script_path + " --install")
        if exit_code == 0:
            test_results[filename] = "Installed successfully."
        else:
            test_results[filename] = "Failed to install."
        print(filename + ": " + test_results[filename])

print("###### TEST RESULTS ######")
for tool in test_results:
    print(tool + ": " + test_results[tool])