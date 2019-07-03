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
c.NotebookApp.iopub_data_rate_limit=2147483647
c.NotebookApp.port_retries=0
c.NotebookApp.quit_button=False
c.NotebookApp.allow_remote_access=True
c.NotebookApp.token=""
c.NotebookApp.disable_check_xsrf=True
c.NotebookApp.allow_origin='*'
c.NotebookApp.trust_xheaders=True

# set base url if available
base_url = os.getenv("WORKSPACE_BASE_URL", "/")
if base_url is not None and base_url is not "/":
    c.NotebookApp.base_url=base_url

# Do not delete files to trash: https://github.com/jupyter/notebook/issues/3130
c.FileContentsManager.delete_to_trash=False

# Always use inline for matplotlib
c.IPKernelApp.matplotlib = 'inline'

shutdown_inactive_kernels = os.getenv("SHUTDOWN_INACTIVE_KERNELS", "false")
if shutdown_inactive_kernels and shutdown_inactive_kernels.lower() != "false".lower():
    cull_timeout = 172800 # default is 48 hours
     try: 
        # see if env variable is set as timout integer
        cull_timeout = int(shutdown_inactive_kernels)
    except ValueError:
        pass
    
    if cull_timeout > 0:
        # Timeout (in seconds) after which a kernel is considered idle and ready to be shutdown.
        c.MappingKernelManager.cull_idle_timeout = cull_timeout
        # Do not shutdown if kernel is busy (e.g on long-running kernel cells)
        c.MappingKernelManager.cull_busy = False
        # Do not shutdown kernels that are connected via browser
        c.MappingKernelManager.cull_connected = False

# https://github.com/timkpaine/jupyterlab_iframe
try:
    if not base_url.startswith("/"):
        base_url = "/" + base_url
    c.JupyterLabIFrame.iframes = [base_url + 'tools/ungit', base_url + 'tools/netdata', base_url + 'tools/vnc', base_url + 'tools/glances', base_url + 'tools/custom']
except:
    pass

# https://github.com/timkpaine/jupyterlab_templates
try:
    if os.path.exists('/workspace/templates'):
        c.JupyterLabTemplates.template_dirs = ['/workspace/templates']
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

# Generate a self-signed certificate
if 'GEN_CERT' in os.environ:
    dir_name = jupyter_data_dir()
    pem_file = os.path.join(dir_name, 'notebook.pem')
    try:
        os.makedirs(dir_name)
    except OSError as exc:  # Python >2.5
        if exc.errno == errno.EEXIST and os.path.isdir(dir_name):
            pass
        else:
            raise
    # Generate a certificate if one doesn't exist on disk
    subprocess.check_call(['openssl', 'req', '-new',
                           '-newkey', 'rsa:2048',
                           '-days', '365',
                           '-nodes', '-x509',
                           '-subj', '/C=XX/ST=XX/L=XX/O=generated/CN=generated',
                           '-keyout', pem_file,
                           '-out', pem_file])
    # Restrict access to the file
    os.chmod(pem_file, stat.S_IRUSR | stat.S_IWUSR)
    c.NotebookApp.certfile = pem_file

# Change default umask for all subprocesses of the notebook server if set in
# the environment
if 'NB_UMASK' in os.environ:
    os.umask(int(os.environ['NB_UMASK'], 8))
