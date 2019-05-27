
"""
Build workspace gpu image
"""

import os, sys
import subprocess
import argparse

parser = argparse.ArgumentParser()
parser.add_argument('--name', help='name of docker container', default="ml-workspace-gpu")
parser.add_argument('--version', help='version tag of docker container', default="latest")
parser.add_argument('--deploy', help='deploy docker container to remote', action='store_true')

REMOTE_IMAGE_PREFIX = "mltooling/"

args, unknown = parser.parse_known_args()
if unknown:
    print("Unknown arguments "+str(unknown))

# Wrapper to print out command
def call(command):
    print("Executing: "+command)
    return subprocess.call(command, shell=True)

# calls build scripts in every module with same flags
def build(module):
    build_command = "python build.py"

    if args.version:
        build_command += " --version=" + str(args.version)

    if args.deploy:
        build_command += " --deploy"

    working_dir = os.path.dirname(os.path.realpath(__file__))
    full_command = "cd " + module + " && " + build_command + " && cd " + working_dir
    print("Building " + module + " with: " + full_command)
    failed = call(full_command)
    if failed:
        print("Failed to build module " + module)
        sys.exit()

service_name = os.path.basename(os.path.dirname(os.path.realpath(__file__)))
if args.name:
    service_name = args.name

# docker build
version_build_arg = " --build-arg workspace_version=" + str(args.version)
versioned_image = service_name+":"+str(args.version)
latest_image = service_name+":latest"
failed = call("docker build -t " + versioned_image + " -t " + latest_image + " " + version_build_arg + " ./")

if failed:
    print("Failed to build container")
    sys.exit()

remote_versioned_image = REMOTE_IMAGE_PREFIX + versioned_image
call("docker tag " + versioned_image + " " + remote_versioned_image)

remote_latest_image = REMOTE_IMAGE_PREFIX + latest_image
call("docker tag " + latest_image + " " + remote_latest_image)

if args.deploy:
    call("docker push " + remote_versioned_image)

    if "SNAPSHOT" not in args.version:
    # do not push SNAPSHOT builds as latest version

        call("docker push " + remote_latest_image)
