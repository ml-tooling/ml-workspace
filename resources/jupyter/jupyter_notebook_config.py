from jupyter_core.paths import jupyter_data_dir
import subprocess
import os
import psutil
import errno
import stat

c = get_config()
# https://jupyter-notebook.readthedocs.io/en/stable/config.html
c.NotebookApp.ip = '*'
c.NotebookApp.port = 8090
c.NotebookApp.notebook_dir="./"
c.NotebookApp.open_browser = False
c.NotebookApp.allow_root=True
# https://forums.fast.ai/t/jupyter-notebook-enhancements-tips-and-tricks/17064/22
c.NotebookApp.iopub_msg_rate_limit = 100000000
c.NotebookApp.iopub_data_rate_limit=2147483647
c.NotebookApp.port_retries=0
c.NotebookApp.quit_button=False
c.NotebookApp.allow_remote_access=True
c.NotebookApp.disable_check_xsrf=True
c.NotebookApp.allow_origin='*'
c.NotebookApp.trust_xheaders=True
# c.NotebookApp.log_level="WARN"

c.JupyterApp.answer_yes = True

# set base url if available
base_url = os.getenv("WORKSPACE_BASE_URL", "/")
if base_url is not None and base_url is not "/":
    c.NotebookApp.base_url=base_url

# Do not delete files to trash: https://github.com/jupyter/notebook/issues/3130
c.FileContentsManager.delete_to_trash=False

# Always use inline for matplotlib
c.IPKernelApp.matplotlib = 'inline'

shutdown_inactive_kernels = os.getenv("SHUTDOWN_INACTIVE_KERNELS", "false")
if shutdown_inactive_kernels and shutdown_inactive_kernels.lower().strip() != "false":
    cull_timeout = 172800 # default is 48 hours
    try: 
        # see if env variable is set as timout integer
        cull_timeout = int(shutdown_inactive_kernels)
    except ValueError:
        pass
    
    if cull_timeout > 0:
        print("Activating automatic kernel shutdown after " + str(cull_timeout) + "s of inactivity.")
        # Timeout (in seconds) after which a kernel is considered idle and ready to be shutdown.
        c.MappingKernelManager.cull_idle_timeout = cull_timeout
        # Do not shutdown if kernel is busy (e.g on long-running kernel cells)
        c.MappingKernelManager.cull_busy = False
        # Do not shutdown kernels that are connected via browser, activate?
        c.MappingKernelManager.cull_connected = False

authenticate_via_jupyter = os.getenv("AUTHENTICATE_VIA_JUPYTER", "false")
if authenticate_via_jupyter and authenticate_via_jupyter.lower().strip() != "false":
    # authentication via jupyter is activated

    # Do not allow password change since it currently needs a server restart to accept the new password
    c.NotebookApp.allow_password_change = False

    if authenticate_via_jupyter.lower().strip() == "<generated>":
        # dont do anything to let jupyter generate a token in print out on console
        pass
    # if true, do not set any token, authentication will be activate on another way (e.g. via JupyterHub)
    elif authenticate_via_jupyter.lower().strip() != "true":
        # if not true or false, set value as token
        c.NotebookApp.token = authenticate_via_jupyter
else:
    # Deactivate token -> no authentication
    c.NotebookApp.token=""

# https://github.com/timkpaine/jupyterlab_iframe
try:
    if not base_url.startswith("/"):
        base_url = "/" + base_url
    # iframe plugin currently needs absolut URLS
    c.JupyterLabIFrame.iframes = [base_url + 'tools/ungit', base_url + 'tools/netdata', base_url + 'tools/vnc', base_url + 'tools/glances', base_url + 'tools/vscode']
except:
    pass

# https://github.com/timkpaine/jupyterlab_templates
WORKSPACE_HOME = os.getenv("WORKSPACE_HOME", "/workspace")
try:
    if os.path.exists(WORKSPACE_HOME + '/templates'):
        c.JupyterLabTemplates.template_dirs = [WORKSPACE_HOME + '/templates']
    c.JupyterLabTemplates.include_default = False
except:
    pass

# Set memory limits for resource use display: https://github.com/yuvipanda/nbresuse
try:
    mem_limit = None
    if os.path.isfile("/sys/fs/cgroup/memory/memory.limit_in_bytes"):
        with open('/sys/fs/cgroup/memory/memory.limit_in_bytes', 'r') as file:
            mem_limit = file.read().replace('\n', '').strip()
    
    total_memory = psutil.virtual_memory().total

    if not mem_limit:
        mem_limit = total_memory
    elif int(mem_limit) > int(total_memory):
        # if mem limit from cgroup bigger than total memory -> use total memory
        mem_limit = total_memory
    
    # Workaround -> round memory limit, otherwise the number is quite long
    # TODO fix in nbresuse
    mem_limit = round(int(mem_limit) / (1024 * 1024)) * (1024 * 1024)
    c.ResourceUseDisplay.mem_limit = int(mem_limit)
    c.ResourceUseDisplay.mem_warning_threshold=0.1
except:
    pass

# Change default umask for all subprocesses of the notebook server if set in
# the environment
if 'NB_UMASK' in os.environ:
    os.umask(int(os.environ['NB_UMASK'], 8))
