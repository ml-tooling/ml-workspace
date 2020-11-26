import os
import subprocess
import sys
import time

import docker
import requests


client = docker.from_env()
workspace_name = "test-ml-workspace"
container = client.containers.run(
    "mltooling/ml-workspace-minimal:0.9.1",
    name=workspace_name,
    environment={"WORKSPACE_NAME": workspace_name},
    ports={'8080/tcp': None},
    detach=True,
)

container.reload()
ip_address = os.getenv("_HOST_IP", "localhost")  # container.attrs["NetworkSettings"]["Networks"]["bridge"]["IPAddress"]
os.environ["WORKSPACE_NAME"] = workspace_name
os.environ["WORKSPACE_IP"] = ip_address
workspace_port = container.attrs["NetworkSettings"]["Ports"]["8080/tcp"][0]["HostPort"]
os.environ["WORKSPACE_ACCESS_PORT"] = workspace_port

index = 0
health_url = f"http://{ip_address}:{workspace_port}/healthy"
r = None
while r is None or (r.status_code != 200 and index < 15):
    index += 1
    time.sleep(1)
    try:
        r = requests.get(health_url, allow_redirects=False, timeout=2)
    except requests.ConnectionError:
        # Catch error that is raised when the workspace container is not reachable yet
        pass

    if index == 15:
        print("The workspace did not start")
        sys.exit(-1)

exit_code = 0
# Sleep a moment to give all processes time to start within the Workspace container
time.sleep(15)
print("Workspace started! Execute tests:", flush=True)

# Test workspace APIs and SSH
print("Execute API and SSH Tests", flush=True)
exit_code_api_test = subprocess.call(["pytest", "-s", "tests"])

# Test libraries within workspace
print("Execute library tests within workspace", flush=True)
# Copy and executing unit test file in workspace
test_file_archive = "./tests/workspace_tests.py.tar"
subprocess.call(
    [
        "tar",
        "-cvf",
        test_file_archive,
        "-C",
        "./tests",
        "workspace_tests.py",
    ],
    stdout=subprocess.PIPE,
)

with open(test_file_archive, "r") as file:
    container.put_archive(path="/tmp", data=file.read())
exit_code_lib_test, output = container.exec_run("python /tmp/workspace_tests.py")
print(output.decode("UTF-8"), flush=True)

print("Executed tests.", flush=True)

# Cleanup
print("Clean up landscape", flush=True)
container.remove(force=True)
os.remove(test_file_archive)

if (exit_code_api_test and exit_code_lib_test) != 0:
    exit_code = 1
elif exit_code_api_test != 0:
    exit_code = 2
elif exit_code_lib_test != 0:
    exit_code = 3

sys.exit(exit_code)
