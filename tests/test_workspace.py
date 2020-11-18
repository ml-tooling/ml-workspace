import os
import re
from subprocess import PIPE, run

import requests

# from config import workspace_name, workspace_port
workspace_host = os.getenv("WORKSPACE_IP", "localhost")
workspace_name = os.getenv("WORKSPACE_NAME", "")
workspace_port = 8080


class TestStringMethods:
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
        assert "<title>Desktop VNC</title>" in result.text

    def test_tool_vscode(self):
        result = requests.get(f"http://{workspace_host}:{workspace_port}/tools/vscode/")
        assert result.status_code == 200
        assert "Microsoft Corporation" in result.text

    def test_ssh(self):
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
        with open("/setup-ssh.sh", "w") as f:
            f.write(r.text)
        # make the file executable for the user
        os.chmod("/setup-ssh.sh", 0o744)
        ssh_connection_name = "test"
        completed_process = run(
            ['/bin/bash -c "/setup-ssh.sh"'],
            input=ssh_connection_name,
            encoding="ascii",
            shell=True,
            stdout=PIPE,
            stderr=PIPE,
        )
        assert completed_process.stderr == ""
        assert "Connection successful!" in completed_process.stdout

        completed_process = run(
            "ssh test 'echo $WORKSPACE_NAME'", shell=True, stdout=PIPE, stderr=PIPE
        )
        assert completed_process.stderr == b""
        stdout = completed_process.stdout.decode("UTF-8").replace("\n", "")
        assert stdout == workspace_name
