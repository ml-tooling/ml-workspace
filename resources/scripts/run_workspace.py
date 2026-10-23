#!/usr/bin/python

"""
Configure and run tools
"""

from subprocess import call, DEVNULL
import os
import re
import shutil
import sys

# Enable logging
import logging
logging.basicConfig(
    format='%(asctime)s [%(levelname)s] %(message)s',
    level=logging.INFO,
    stream=sys.stdout)

log = logging.getLogger(__name__)

log.info("Start Workspace")


def configure_runtime_user():
    """
    If WORKSPACE_AUTH_USER is set to something other than "root", create a real Linux user with
    that name (idempotent - safe to call on every container start) so Jupyter and VS Code run as
    that user instead of root: terminals show the right whoami, and files created in /workspace
    are owned by that user rather than root.

    Sets WORKSPACE_RUNTIME_USER / WORKSPACE_RUNTIME_HOME in os.environ for supervisord (started
    later in this same process) to pick up via %(ENV_...)s interpolation in the program configs.
    """
    auth_user = os.getenv("WORKSPACE_AUTH_USER", "").strip()
    workspace_home = os.getenv("WORKSPACE_HOME", "/workspace")

    # Linux usernames: lowercase, start with a letter, only letters/digits/underscore/hyphen
    username = re.sub(r"[^a-z0-9_-]", "", auth_user.lower())
    if username and not re.match(r"^[a-z_]", username):
        username = ""
    username = username[:32]

    if not username or username == "root":
        os.environ["WORKSPACE_RUNTIME_USER"] = "root"
        os.environ["WORKSPACE_RUNTIME_HOME"] = "/root"
        return

    runtime_home = "/home/" + username
    user_exists = call(["id", username], stdout=DEVNULL, stderr=DEVNULL) == 0

    if not user_exists:
        log.info("Creating Linux user '%s' for WORKSPACE_AUTH_USER", username)
        if call(["useradd", "-m", "-s", "/bin/zsh", "-d", runtime_home, username]) != 0:
            log.error("Failed to create user '%s' - falling back to root", username)
            os.environ["WORKSPACE_RUNTIME_USER"] = "root"
            os.environ["WORKSPACE_RUNTIME_HOME"] = "/root"
            return

        # Best-effort: only present on images that have Docker installed (see the DOCKER section
        # of the Dockerfile) - lets this user run `docker` directly instead of needing `sudo`.
        call(["usermod", "-aG", "docker", username], stderr=DEVNULL)

        # Passwordless sudo - this is a personal dev workspace, not a shared multi-tenant system.
        # sudo's default "secure_path" strips the image's custom PATH (pyenv shims/conda) and
        # replaces it with a bare system default, which breaks tools like `pyenv` as soon as this
        # user runs `sudo`/`sudo su` - so explicitly extend secure_path to keep them working.
        resources_path = os.getenv("RESOURCES_PATH", "/resources")
        secure_path = (
            resources_path + "/.pyenv/shims:" + resources_path + "/.pyenv/bin:"
            "/opt/conda/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
        )
        with open("/etc/sudoers.d/" + username, "w") as f:
            f.write('Defaults:' + username + ' secure_path="' + secure_path + '"\n')
            f.write(username + " ALL=(ALL) NOPASSWD:ALL\n")
        os.chmod("/etc/sudoers.d/" + username, 0o440)

        # Copy root's shell/tooling setup (oh-my-zsh, conda init, VS Code extensions already
        # installed at build time, etc.) so the new user's environment isn't a bare, broken shell.
        # .config/xfce4 (panel/taskbar layout) and Desktop (app shortcuts) do the same for the VNC
        # desktop session, which now also runs as this user instead of root - .vnc itself is
        # deliberately not copied here since start-vnc-server.sh creates it fresh per user anyway.
        for entry in [".zshrc", ".bashrc", ".oh-my-zsh", ".config/Code", ".vscode", ".condarc",
                      ".jupyter", ".local", ".config/xfce4", "Desktop"]:
            src = os.path.join("/root", entry)
            dst = os.path.join(runtime_home, entry)
            if os.path.exists(src) and not os.path.exists(dst):
                try:
                    if os.path.isdir(src):
                        shutil.copytree(src, dst, symlinks=True)
                    else:
                        shutil.copy2(src, dst)
                except Exception as ex:
                    log.warning("Could not copy %s to new user home: %s", src, ex)

        # Defensive safety net: rewrite any lingering literal "/root" path left over in the small,
        # directly-copied text config files (e.g. an older-built image's .zshrc that predates the
        # fix making that file's own $HOME reference re-expand correctly per-user). Deliberately
        # scoped to just the top-level dotfiles, not recursed into .oh-my-zsh/.local/.vscode/etc,
        # since those are large trees of code/binaries where a blind text substitution is a much
        # bigger footgun than the narrow problem it's meant to catch.
        for entry in [".zshrc", ".bashrc", ".condarc"]:
            path = os.path.join(runtime_home, entry)
            if os.path.isfile(path):
                try:
                    with open(path, "r") as f:
                        content = f.read()
                    fixed = content.replace("/root/", runtime_home + "/")
                    if fixed != content:
                        with open(path, "w") as f:
                            f.write(fixed)
                except Exception as ex:
                    log.warning("Could not rewrite /root paths in %s: %s", path, ex)

        call(["chown", "-R", username + ":" + username, runtime_home])

    # Always re-assert /workspace ownership (idempotent, cheap, and handles the case where the
    # container was previously started with a different or no WORKSPACE_AUTH_USER)
    if os.path.exists(workspace_home):
        call(["chown", "-R", username + ":" + username, workspace_home])

    # Symlink nginx's login.log into the workspace for developer convenience. Best-effort and
    # never fatal - unlike nginx's own startup, which used to write directly into /workspace and
    # would refuse to start at all if that path had a permission problem (e.g. a stale UID
    # mismatch left over from an earlier container instance under sysbox's user-namespace
    # remapping), taking the whole server down on every restart.
    try:
        workspace_meta_dir = os.path.join(workspace_home, ".workspace")
        os.makedirs(workspace_meta_dir, exist_ok=True)
        login_log_link = os.path.join(workspace_meta_dir, "login.log")
        if not os.path.lexists(login_log_link):
            os.symlink("/var/log/nginx/login.log", login_log_link)
    except Exception as ex:
        log.warning("Could not symlink login.log into workspace: %s", ex)

    os.environ["WORKSPACE_RUNTIME_USER"] = username
    os.environ["WORKSPACE_RUNTIME_HOME"] = runtime_home


ENV_RESOURCES_PATH = os.getenv("RESOURCES_PATH", "/resources")

# Include tutorials 
WORKSPACE_HOME = os.getenv('WORKSPACE_HOME', "/workspace")
INCLUDE_TUTORIALS = os.getenv('INCLUDE_TUTORIALS', "true")

# Only copy all content of tutorial folder to workspace folder if it is initialy empty
if INCLUDE_TUTORIALS.lower() == "true" and os.path.exists(WORKSPACE_HOME) and len(os.listdir(WORKSPACE_HOME)) == 0:
    log.info("Copy tutorials to /workspace folder")
    from distutils.dir_util import copy_tree
    # Copy all files within tutorials folder in resources to workspace home
    copy_tree(os.path.join(ENV_RESOURCES_PATH, "tutorials"), WORKSPACE_HOME)

# restore config on startup - if CONFIG_BACKUP_ENABLED - it needs to run before other configuration 
call("python " + ENV_RESOURCES_PATH + "/scripts/backup_restore_config.py restore", shell=True)

log.info("Configure ssh service")
call("python " + ENV_RESOURCES_PATH + "/scripts/configure_ssh.py", shell=True)

log.info("Configure nginx service")
call("python " + ENV_RESOURCES_PATH + "/scripts/configure_nginx.py", shell=True)

log.info("Configure tools")
call("python " + ENV_RESOURCES_PATH + "/scripts/configure_tools.py", shell=True)

log.info("Configure cron scripts")
call("python " + ENV_RESOURCES_PATH + "/scripts/configure_cron_scripts.py", shell=True)

log.info("Configure and run custom scripts")
call("python " + ENV_RESOURCES_PATH + "/scripts/run_custom_scripts.py", shell=True)

startup_custom_script = os.path.join(WORKSPACE_HOME, "on_startup.sh")
if os.path.exists(startup_custom_script):
    log.info("Run on_startup.sh user script from workspace folder")
    # run startup script from workspace folder - can be used to run installation routines on workspace updates
    call("/bin/bash " + startup_custom_script, shell=True)

# Runs last, right before supervisord starts the actual services, so it re-asserts /workspace
# ownership after all the root-driven setup above (tutorial copying, config restore, etc.) has
# already written into /workspace.
log.info("Configure runtime user")
configure_runtime_user()


def configure_app_launcher():
    """
    Write the JupyterLab launcher's "Workspace Tools" tiles (jupyter_app_launcher) for the runtime
    user, with every link prefixed by the workspace's base URL. The template's links are absolute
    from the site root (/tools/vnc/...), which only works when the workspace IS the site root - under
    JupyterHub (base URL /user/<name>) they hit the hub instead and 404 as /hub/tools/vnc/.

    Regenerated on every start from the pristine template rather than edited in place: the copy in
    the user's home lives on a persistent volume, so in-place edits would pile up prefixes, and a
    once-only copy (run_workspace's home setup) would never pick up template changes.
    """
    template = os.path.join(os.getenv("RESOURCES_PATH", "/resources"), "jupyter", "jp_app_launcher.yaml")
    if not os.path.isfile(template):
        return
    base_url = os.getenv("WORKSPACE_BASE_URL", "").rstrip("/")
    runtime_home = os.getenv("WORKSPACE_RUNTIME_HOME", "/root")
    runtime_user = os.getenv("WORKSPACE_RUNTIME_USER", "root")

    with open(template, "r") as f:
        content = f.read()
    content = re.sub(r"^(\s*source: )/", lambda m: m.group(1) + base_url + "/", content, flags=re.M)

    target_dir = os.path.join(runtime_home, ".local", "share", "jupyter", "jupyter_app_launcher")
    try:
        os.makedirs(target_dir, exist_ok=True)
        with open(os.path.join(target_dir, "jp_app_launcher.yaml"), "w") as f:
            f.write(content)
        call(["chown", "-R", runtime_user + ":" + runtime_user, target_dir])
    except Exception as ex:
        log.warning("Could not write launcher config to %s: %s", target_dir, ex)


log.info("Configure JupyterLab launcher tool links")
configure_app_launcher()

# Run supervisor process - main container process
call('supervisord -n -c /etc/supervisor/supervisord.conf', shell=True)