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
WORKSPACE_HOME = os.getenv("WORKSPACE_HOME", "/workspace")

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
test_results_str = ""
for tool in test_results:
    print(tool + ": " + test_results[tool])
    test_results_str += tool + ": " + test_results[tool] + "/n"

os.makedirs(os.path.join(WORKSPACE_HOME, "reports"), exist_ok=True)
with open(os.path.join(WORKSPACE_HOME, "reports", "tool-installers-test.txt"),"w+") as f:
    f.write(test_results_str)
