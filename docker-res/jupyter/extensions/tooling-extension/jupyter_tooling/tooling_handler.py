import json
import os
import subprocess

try:
    from urllib.parse import unquote
except ImportError:
    from urllib import unquote

import warnings
from datetime import datetime

import git
import tornado
from notebook.base.handlers import IPythonHandler
from notebook.utils import url_path_join
from tornado import web


# -------------- HANDLER -------------------------
class HelloWorldHandler(IPythonHandler):

    def data_received(self, chunk):
        pass

    def get(self):
        result = self.request.protocol + "://" + self.request.host
        if 'base_url' in self.application.settings:
            result = result + "   " + self.application.settings['base_url']
        self.finish(result)


def handle_error(handler, status_code: int, error_msg: str = None, exception=None):
    handler.set_status(status_code)

    if not error_msg:
        error_msg = ""

    if exception:
        if error_msg:
            error_msg += "\nException: "

        error_msg += str(exception)

    error = {
        "error": error_msg
    }
    handler.finish(json.dumps(error))

    log.info("An error occurred (" + str(status_code) + "): " + error_msg)


def send_data(handler, data):
    handler.finish(json.dumps(data, sort_keys=True, indent=4))

class PingHandler(IPythonHandler):

    @web.authenticated
    def get(self):
        # Used by Jupyterhub to test if user cookies are valid
        self.finish("Successful")

class GitCommitHandler(IPythonHandler):

    @web.authenticated
    def post(self):
        data = self.get_json_body()

        if data is None:
            handle_error(self, 400, "Please provide a valid file path and commit msg in body.")
            return

        if "filePath" not in data or not data["filePath"]:
            handle_error(self, 400, "Please provide a valid filePath in body.")
            return

        file_path = _resolve_path(unquote(data["filePath"]))

        commit_msg = None
        if "commitMsg" in data:
            commit_msg = unquote(data["commitMsg"])

        try:
            commit_file(file_path, commit_msg)
        except Exception as ex:
            handle_error(self, 500, exception=ex)
            return


class GitInfoHandler(IPythonHandler):

    @web.authenticated
    def get(self):
        try:
            path = _resolve_path(self.get_argument('path', None))
            send_data(self, get_git_info(path))
        except Exception as ex:
            handle_error(self, 500, exception=ex)
            return

    @web.authenticated
    def post(self):

        path = _resolve_path(self.get_argument('path', None))
        data = self.get_json_body()

        if data is None:
            handle_error(self, 400, "Please provide a valid name and email in body.")
            return

        if "email" not in data or not data["email"]:
            handle_error(self, 400, "Please provide a valid email.")
            return

        email = data["email"]

        if "name" not in data or not data["name"]:
            handle_error(self, 400, "Please provide a valid name.")
            return

        name = data["name"]

        try:
            repo = get_repo(path)
            set_user_email(email, repo)
            set_user_name(name, repo)
        except Exception as ex:
            handle_error(self, 500, exception=ex)
            return

class SSHHandler(IPythonHandler):
    private_ssh_key_path = "/root/.ssh/id_ed25519"

    @web.authenticated
    def get(self):
        try:
            with open(self.private_ssh_key_path, "r") as f:
                runtime_private_key = f.read()
            
            ssh_templates_path = os.path.dirname(os.path.abspath(__file__)) + "/setup_templates"

            with open(ssh_templates_path + '/client_command.txt', 'r') as file:
                client_command = file.read()

            HOSTNAME = self.get_argument('hostname', None)
            PORT = self.get_argument('port', None)
            
            SSH_JUMPHOST_TARGET = os.environ.get("SSH_JUMPHOST_TARGET", "")
            is_runtime_manager_existing = False if SSH_JUMPHOST_TARGET == "" else True
 
            RUNTIME_CONFIG_NAME = "workspace-"
            if is_runtime_manager_existing:
                HOSTNAME_RUNTIME = SSH_JUMPHOST_TARGET
                HOSTNAME_MANAGER = HOSTNAME
                PORT_MANAGER = PORT
                PORT_RUNTIME = 8091

                RUNTIME_CONFIG_NAME = RUNTIME_CONFIG_NAME + "{}-{}-{}".format(HOSTNAME_RUNTIME, HOSTNAME_MANAGER, PORT_MANAGER)
                    
                client_command = client_command \
                    .replace("{HOSTNAME_MANAGER}", HOSTNAME_MANAGER) \
                    .replace("{PORT_MANAGER}", str(PORT_MANAGER)) \
                    .replace("#ProxyCommand", "ProxyCommand")
                
                local_keyscan_replacement = "{}".format(HOSTNAME_RUNTIME)

            else:
                HOSTNAME_RUNTIME = HOSTNAME
                PORT_RUNTIME = PORT
                RUNTIME_CONFIG_NAME = RUNTIME_CONFIG_NAME + "{}-{}".format(HOSTNAME_RUNTIME, PORT_RUNTIME)
                
                local_keyscan_replacement = "[{}]:{}".format(HOSTNAME_RUNTIME, PORT_RUNTIME)            

            # perform keyscan with localhost to get the runtime's keyscan result.
            # Replace then the "localhost" part in the returning string with the actual RUNTIME_HOST_NAME
            local_keyscan_entry = get_ssh_keyscan_results("localhost")
            if local_keyscan_entry is not None:
                local_keyscan_entry = local_keyscan_entry.replace(
                    "localhost", local_keyscan_replacement)

            output = client_command \
                .replace("{PRIVATE_KEY_RUNTIME}", runtime_private_key) \
                .replace("{HOSTNAME_RUNTIME}", HOSTNAME_RUNTIME) \
                .replace("{RUNTIME_KNOWN_HOST_ENTRY}", local_keyscan_entry) \
                .replace("{PORT_RUNTIME}", str(PORT_RUNTIME)) \
                .replace("{RUNTIME_CONFIG_NAME}", RUNTIME_CONFIG_NAME) \
                .replace("{RUNTIME_KEYSCAN_NAME}", local_keyscan_replacement.replace("[", "\[").replace("]", "\]"))

            # Use hostname, otherwise it cannot be reconstructed in tooling plugin
            file_name = 'setup_ssh_{}-{}.sh'.format(HOSTNAME.lower().replace(".", "-"), PORT)

            FORMAT = self.get_argument('format', None)
            if FORMAT == 'text':
                self.finish(output)
            else:
                self.set_header('Content-Type', 'application/octet-stream')
                self.set_header('Content-Disposition', 'attachment; filename=' + file_name) # Hostname runtime
                self.write(output)
                self.finish()
            
        except Exception as ex:
            handle_error(self, 500, exception=ex)
            return


# ------------- GIT FUNCTIONS ------------------------

def execute_command(cmd: str):
    return subprocess.check_output(cmd.split()).decode('utf-8').replace("\n", "")


def get_repo(directory: str):
    if not directory:
        return None

    try:
        return git.Repo(directory, search_parent_directories=True)
    except:
        return None


def set_user_email(email: str, repo=None):
    if repo:
        repo.config_writer().set_value("user", "email", email).release()
    else:
        exit_code = subprocess.call('git config --global user.email "' + email + '"', shell=True)
        if exit_code > 0:
            warnings.warn("Global email configuration failed.")


def set_user_name(name: str, repo=None):
    if repo:
        repo.config_writer().set_value("user", "name", name).release()
    else:
        exit_code = subprocess.call('git config --global user.name "' + name + '"', shell=True)
        if exit_code > 0:
            warnings.warn("Global name configuration failed.")


def commit_file(file_path: str, commit_msg: str = None, push: bool = True):
    if not os.path.isfile(file_path):
        raise Exception("File does not exist: " + file_path)

    repo = get_repo(os.path.dirname(file_path))
    if not repo:
        raise Exception("No git repo was found for file: " + file_path)

    # Always add file
    repo.index.add([file_path])

    if not get_user_name(repo):
        raise Exception('Cannot push to remote. Please specify a name with: git config --global user.name "YOUR NAME"')

    if not get_user_email(repo):
        raise Exception(
            'Cannot push to remote. Please specify an email with: git config --global user.emails "YOUR EMAIL"')

    if not commit_msg:
        commit_msg = "Updated " + os.path.relpath(file_path, repo.working_dir)

    try:
        # fetch and merge newest state - fast-forward-only
        repo.git.pull('--ff-only')
    except:
        raise Exception("The repo is not up-to-date or cannot be updated.")

    try:
        # Commit single file with commit message
        repo.git.commit(file_path, m=commit_msg)
    except git.GitCommandError as error:
        if error.stdout and (
                "branch is up-to-date with" in error.stdout or "branch is up to date with" in error.stdout):
            # TODO better way to check if file has changed, e.g. has_file_changed
            raise Exception("File has not been changed: " + file_path)
        else:
            raise error

    if push:
        # Push file to remote
        try:
            repo.git.push("origin", 'HEAD')
        except git.GitCommandError as error:
            if error.stderr and ( "No such device or address" in error.stderr and "could not read Username" in error.stderr):
                raise Exception("User is not authenticated. Please use Ungit to login via HTTPS or use SSH authentication.")
            else:
                raise error

def get_config_value(key: str, repo=None):
    try:
        if repo:
            return repo.git.config(key)
        # no repo, look up global config
        return execute_command('git config ' + key)
    except:
        return None


def get_user_name(repo=None):
    return get_config_value("user.name", repo)


def get_user_email(repo=None):
    return get_config_value("user.email", repo)


def get_active_branch(repo) -> str or None:
    try:
        return repo.active_branch.name
    except:
        return None


def get_last_commit(repo) -> str or None:
    try:
        return datetime.fromtimestamp(repo.head.commit.committed_date).strftime("%d.%B %Y %I:%M:%S")
    except:
        return None


def has_file_changed(repo, file_path: str):
    # not working in all situations
    changed_files = [item.a_path for item in repo.index.diff(None)]
    return os.path.relpath(os.path.realpath(file_path), repo.working_dir) in (path for path in changed_files)


def get_git_info(directory: str):
    repo = get_repo(directory)
    git_info = {
        "userName": get_user_name(repo),
        "userEmail": get_user_email(repo),
        "repoRoot": repo.working_dir if repo else None,
        "activeBranch": get_active_branch(repo) if repo else None,
        "lastCommit": get_last_commit(repo) if repo else None,
        "requestPath": directory
    }
    return git_info


def _get_server_root() -> str:
    return os.path.expanduser(web_app.settings['server_root_dir'])


def _resolve_path(path: str) -> str or None:
    if path:
        # add jupyter server root directory
        if path.startswith("/"):
            path = path[1:]

        return os.path.join(_get_server_root(), path)
    else:
        return None


# ------------- SSH Functions ------------------------

def get_ssh_keyscan_results(host_name, host_port=22, key_format="ecdsa"):
    """
    Perform the keyscan command to get the certicicate fingerprint (of specified format [e.g. rsa256, ecdsa, ...]) of the container.

    # Arguments
      - host_name (string): hostname which to scan for a key
      - host_port (int): port which to scan for a key
      - key_format (string): type of the key to return. the `ssh-keyscan` command usually lists the fingerprint in different formats (e.g. ecdsa-sha2-nistp256, ssh-rsa, ssh-ed25519, ...). The ssh-keyscan result is grepped for the key_format, so already a part could match. In that case, the last match is used.

    # Returns
      The keyscan entry which can be added to the known_hosts file. If `key_format` matches multiple results of `ssh-keyscan`, the last match is returned. If no match exists, it returns empty
    """

    keyscan_result = subprocess.run(
        ['ssh-keyscan', '-p', str(host_port), host_name], stdout=subprocess.PIPE)
    keys = keyscan_result.stdout.decode("utf-8").split("\n")
    keyscan_entry = ""
    for key in keys:
        if key_format in key:
            keyscan_entry = key
    return keyscan_entry


# ------------- PLUGIN LOADER ------------------------


def load_jupyter_server_extension(nb_server_app) -> None:
    # registers all handlers as a REST interface
    global web_app
    global log

    web_app = nb_server_app.web_app
    log = nb_server_app.log

    host_pattern = '.*$'

    route_pattern = url_path_join(web_app.settings['base_url'], '/tooling/ping')
    web_app.add_handlers(host_pattern, [(route_pattern, PingHandler)])

    route_pattern = url_path_join(web_app.settings['base_url'], '/git/info')
    web_app.add_handlers(host_pattern, [(route_pattern, GitInfoHandler)])

    route_pattern = url_path_join(web_app.settings['base_url'], '/git/commit')
    web_app.add_handlers(host_pattern, [(route_pattern, GitCommitHandler)])

    route_pattern = url_path_join(web_app.settings['base_url'], '/ssh/setup')
    web_app.add_handlers(host_pattern, [(route_pattern, SSHHandler)])

    nb_server_app.log.info('Extension jupyter-tooling-widget loaded successfully.')


# Test routine. Can be invoked manually
if __name__ == "__main__":
    application = tornado.web.Application([
        (r'/test', HelloWorldHandler),
        (r'/git/info', GitInfoHandler),
        (r'/git/commit', GitCommitHandler),
        (r'/ssh/setup', SSHHandler)
    ])

    application.listen(555)
    tornado.ioloop.IOLoop.current().start()
