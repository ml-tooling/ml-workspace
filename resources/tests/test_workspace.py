import os
import re
import sys
import time
from subprocess import PIPE, run
from typing import Union

import pytest
import requests

workspace_host = os.getenv("WORKSPACE_IP", "localhost")
workspace_port = os.getenv("WORKSPACE_ACCESS_PORT", "8080")


def setup_module():
    _wait_until_workspace_is_healthy(workspace_host, workspace_port)


@pytest.fixture(scope="session")
def ssh_connection() -> str:
    ssh_connection_name = os.getenv("WORKSPACE_NAME", "workspace-test")

    result = requests.get(
        f"http://{workspace_host}:{workspace_port}/tooling/ssh/setup-command?origin=http://{workspace_host}:{workspace_port}"
    )
    assert result.status_code == 200
    assert "/bin/bash" in result.text

    ssh_script_runner_regex = rf'^\/bin\/bash <\(curl -s --insecure "(http:\/\/{workspace_host}:{workspace_port}\/shared\/ssh\/setup\?token=[a-z0-9]+&host={workspace_host}&port={workspace_port})"\)$'
    pattern = re.compile(ssh_script_runner_regex)
    match = pattern.match(result.text)
    assert match is not None

    # Execute the ssh setup script and automatically pass an ssh connection name to the script
    script_url = match.groups()[0]
    r = requests.get(script_url)
    setup_ssh_file = "./setup-ssh.sh"
    with open(setup_ssh_file, "w") as f:
        f.write(r.text)
    # make the file executable for the user
    os.chmod(setup_ssh_file, 0o744)

    # Todo: Remove usage of pexpect when ssh setup script callable non-interactively
    import pexpect

    child = pexpect.spawn(f"/bin/bash {setup_ssh_file}", encoding="UTF-8")
    child.expect("Provide a name .*")
    child.sendline(ssh_connection_name)
    child.expect("remote_ikernel was detected .*")
    child.sendline("no")
    child.expect("Do you want to add this connection as mountable SFTP storage .*")
    child.sendline("no")
    child.close()

    os.remove(setup_ssh_file)

    return ssh_connection_name


class TestTooling:
    def test_healthy(self):
        result = requests.get(f"http://{workspace_host}:{workspace_port}/healthy")
        print(result.status_code)
        assert result.status_code == 200

    def test_tool_vnc(self):
        # Test whether tools are accessible
        result = requests.get(
            f"http://{workspace_host}:{workspace_port}/tools/vnc/?password=vncpassword"
        )
        assert result.status_code == 200
        assert "<title>noVNC</title>" in result.text

    def test_tool_vscode(self):
        result = requests.get(f"http://{workspace_host}:{workspace_port}/tools/vscode/")
        assert result.status_code == 200
        assert "Microsoft Corporation" in result.text

    def test_ssh(self, ssh_connection: str):

        completed_process = run(
            f"ssh {ssh_connection} 'echo {ssh_connection}'",
            shell=True,
            stdout=PIPE,
            stderr=PIPE,
        )
        assert completed_process.stderr == b""
        stdout = completed_process.stdout.decode("UTF-8").replace("\n", "")
        assert stdout == ssh_connection


class TestLibInstallations:
    def test_pytorch(self):
        import numpy as np

        size = 10
        x = np.random.randint(2, size=size)
        assert len(x) == size


def _wait_until_workspace_is_healthy(
    ip_address: str, workspace_port: Union[str, int]
) -> None:
    MAX_ITERATIONS = 30
    index = 0
    health_url = f"http://{ip_address}:{str(workspace_port)}/healthy"
    response = None
    while response is None or (response.status_code != 200 and index < MAX_ITERATIONS):
        index += 1
        time.sleep(1)
        try:
            response = requests.get(health_url, allow_redirects=False, timeout=2)
        except requests.ConnectionError:
            # Catch error that is raised when the workspace container
            # is not reachable yet and waited sufficiently long
            if index == MAX_ITERATIONS:
                print("The workspace did not start")
                raise

    if index == MAX_ITERATIONS:
        print("The workspace did not start")
        sys.exit(-1)
    # Wait a little more to get all processes time to start
    time.sleep(15)
