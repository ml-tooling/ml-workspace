<h1 align="center">
    <a href="https://github.com/ml-tooling/ml-workspace" title="ML Workspace Home">
    <img width=50% alt="" src="./docs/images/ml-workspace-logo.png"> </a>
    <br>
</h1>

<p align="center">
    <strong>All-in-one web-based development environment for machine learning</strong>
</p>

<p align="center">
    <a href="https://hub.docker.com/r/mltooling/ml-workspace" title="Docker Image Version"><img src="https://images.microbadger.com/badges/version/mltooling/ml-workspace.svg"></a>
    <a href="https://hub.docker.com/r/mltooling/ml-workspace" title="Docker Pulls"><img src="https://img.shields.io/docker/pulls/mltooling/ml-workspace.svg"></a>
    <a href="https://hub.docker.com/r/mltooling/ml-workspace" title="Docker Image Metadata"><img src="https://images.microbadger.com/badges/image/mltooling/ml-workspace.svg"></a>
    <a href="https://github.com/ml-tooling/ml-workspace/blob/master/LICENSE" title="ML Workspace License"><img src="https://img.shields.io/badge/License-Apache%202.0-green.svg"></a>
    <a href="https://gitter.im/ml-tooling/ml-workspace" title="Chat on Gitter"><img src="https://badges.gitter.im/ml-tooling/ml-workspace.svg"></a>
    <a href="https://twitter.com/mltooling" title="ML Tooling on Twitter"><img src="https://img.shields.io/twitter/follow/mltooling.svg?style=social"></a>
</p>

<p align="center">
  <a href="#getting-started">Getting Started</a> •
  <a href="#highlights">Highlights</a> •
  <a href="#features">Features & Screenshots</a> •
  <a href="#support">Support</a> •
  <a href="https://github.com/ml-tooling/ml-workspace/issues/new?labels=bug&template=01_bug-report.md">Report a Bug</a> •
  <a href="#contribution">Contribution</a>
</p>

The ML workspace is an all-in-one web-based IDE specialized for machine learning and data science. It is simple to deploy and gets you started within minutes to productively built ML solutions on your own machines. This workspace is the ultimate tool for developers preloaded with a variety of popular data science libraries (e.g., Tensorflow, PyTorch, Keras, Sklearn) and dev tools (e.g., Jupyter, VS Code, Tensorboard) perfectly configured, optimized, and integrated.

## Highlights

- 💫 Jupyter, JupyterLab, and Visual Studio Code web-based IDEs.
- 🗃 Pre-installed with many popular data science libraries & tools.
- 🖥 Full Linux desktop GUI accessible via web browser.
- 🔀 Seamless Git integration optimized for notebooks.
- 📈 Integrated hardware & training monitoring via Tensorboard & Netdata.
- 🚪 Access from anywhere via Web, SSH, or VNC under a single port.
- 🎛 Usable as remote kernel (Jupyter) or remote machine (VS Code) via SSH.
- 🐳 Easy to deploy on Mac, Linux, and Windows via Docker.

## Getting Started

### Prerequisites

The workspace requires **Docker** to be installed on your machine ([Installation Guide](https://docs.docker.com/install/#supported-platforms)).

> 📖 _If you are new to Docker, we recommend taking a look at [this beginner guide](https://docker-curriculum.com/)._

### Start single instance

Deploying a single workspace instance is as simple as:

```bash
docker run -p 8091:8091 mltooling/ml-workspace:latest
```

Voilà, that was easy! Now, Docker will pull the latest workspace image to your machine. This may take a few minutes, depending on your internet speed. Once the workspace is started, you can access it via: http://localhost:8091.

> ℹ️ _If started on a remote machine or with a different port, make sure to use the machine's IP/DNS and/or the exposed port._

To deploy a single instance for productive usage, we recommend to apply at least the following options:

```bash
docker run -d -p 8091:8091 -v "${PWD}:/workspace" --env AUTHENTICATE_VIA_JUPYTER="mytoken" --restart always mltooling/ml-workspace:latest
```

This command runs the container in background (`-d`), mounts your current working directory into the `/workspace` folder (`-v`), secures the workspace via a provided token (`--env AUTHENTICATE_VIA_JUPYTER`), and keeps the container running even on system restarts (`--restart always`). You can find additional options for docker run [here](https://docs.docker.com/engine/reference/commandline/run/) and workspace configuration options in [the section below](#Configuration).

### Persist Data

To persist the data, you need to mount a volume into `/workspace` (via docker run option: `-v`).

The default work directory within the container is `/workspace`, which is also the root directory of the Jupyter instance. The `/workspace` directory is intended to be used for all the important work artifacts. Data within other directories of the server (e.g. `/root`) might get lost at container restarts.

### Configuration Options

The container can be configured with the following environment variables (via docker run option: `--env`):

<table>
    <tr>
        <th>Variable</th>
        <th>Description</th>
        <th>Default</th>
    </tr>
    <tr>
        <td>WORKSPACE_BASE_URL</td>
        <td>The base URL under which Jupyter and all other tools will be reachable from.</td>
        <td>/</td>
    </tr>
    <tr>
        <td>WORKSPACE_SSL_ENABLED</td>
        <td>Enable or disable SSL. When set to true, either certificates (cert.crt) must be mounted to <code>/resources/ssl</code> or, if not, the container generates self-signed certificates.</td>
        <td>false</td>
    </tr>
    <tr>
        <td>WORKSPACE_AUTH_USER</td>
        <td>Basic auth user name. To enable basic auth, both the user and password need to be set. We recommend to use the <code>AUTHENTICATE_VIA_JUPYTER</code> for securing the workspace.</td>
        <td></td>
    </tr>
    <tr>
        <td>WORKSPACE_AUTH_PASSWORD</td>
        <td>Basic auth user password. To enable basic auth, both the user and password need to be set. We recommend to use the <code>AUTHENTICATE_VIA_JUPYTER</code> for securing the workspace.</td>
        <td></td>
    </tr>
    <tr>
        <td>CONFIG_BACKUP_ENABLED</td>
        <td>Automatically backup and restore user configuration to the persisted <code>/workspace</code> folder, such as the .ssh, .jupyter, or .gitconfig from the users home directory.</td>
        <td>true</td>
    </tr>
    <tr>
        <td>SHARED_LINKS_ENABLED</td>
        <td>Enable or disable the capability to share resources via external links. This is used to enable file sharing, access to workspace-internal ports, and easy command-based SSH setup. All shared links are protected via a token. However, there are certain risks since the token cannot be easily invalidated after sharing and does not expire.</td>
        <td>true</td>
    </tr>
    <tr>
        <td>INCLUDE_TUTORIALS</td>
        <td>If <code>true</code>, a selection of tutorial and introduction notebooks are added to the <code>/workspace</code> folder at container startup, but only in if the folder is empty.</td>
        <td>true</td>
    </tr>
    <tr>
        <td>MAX_NUM_THREADS</td>
        <td>The number of threads used for computations when using various common libraries (MKL, OPENBLAS, OMP, NUMBA, ...). You can also use <code>auto</code> to let the workspace dynamically determine the number of threads based on available CPU resources. This configuration can be overwritten by the user from within the workspace. Generally, it is good to set it at or below the number of CPUs available to the workspace.</td>
        <td>auto</td>
    </tr>
    <tr>
        <td colspan="3"><b>Jupyter Configuration:</b></td>
    </tr>
    <tr>
        <td>SHUTDOWN_INACTIVE_KERNELS</td>
        <td>Automatically shutdown inactive kernels after a given timeout (to cleanup memory or gpu resources). Value can be either a timeout in seconds or set to <code>true</code> with a default value of 48h.</td>
        <td>false</td>
    </tr>
    <tr>
        <td>AUTHENTICATE_VIA_JUPYTER</td>
        <td>If <code>true</code>, all HTTP requests will be authenticated against the Jupyter server, meaning that the authentication method configured with Jupyter will be used for all other tools as well. This can be deactivated with <code>false</code>. Any other value will activate this authentication and are applied as token via NotebookApp.token configuration of Jupyter.</td>
        <td>false</td>
    </tr>
    <tr>
        <td>NOTEBOOK_ARGS</td>
        <td>Add and overwrite Jupyter configuration options via command line args. Refer to <a href="https://jupyter-notebook.readthedocs.io/en/stable/config.html">this overview</a> for all options.</td>
        <td></td>
    </tr>
    <tr>
        <td colspan="3"><b>VNC Configuration:</b></td>
    </tr>
    <tr>
        <td>VNC_PW</td>
        <td>Password of VNC connection. This password only needs to be secure if the VNC server is directly exposed. If it is used via noVNC, it is already protected based on the configured authentication mechanism.</td>
        <td>vncpassword</td>
    </tr>
    <tr>
        <td>VNC_RESOLUTION</td>
        <td>Default desktop resolution of VNC connection. When using noVNC, the resolution will be dynamically adapted to the window size.</td>
        <td>1600x900</td>
    </tr>
    <tr>
        <td>VNC_COL_DEPTH</td>
        <td>Default color depth of VNC connection.</td>
        <td>24</td>
    </tr>
</table>

### Enable Authentication

We strongly recommend enabling authentication via one of the following two options. For both options, the user will be required to authenticate for accessing any of the preinstalled tools.

#### Token-based Authentication via Jupyter (recommended)

Activate the token-based authentication based on the authentication implementation of Jupyter via the `AUTHENTICATE_VIA_JUPYTER` variable:

```bash
docker run -p 8091:8091 --env AUTHENTICATE_VIA_JUPYTER="mytoken" mltooling/ml-workspace:latest
```

You can also use `<generated>` to let Jupyter generate a random token that is printed out on the container logs. A value of `true` will not set any token but activate that every request to any tool in the workspace will be checked with the Jupyter instance if the user is authenticated. This is used for tools like JupyterHub, which configures its own way of authentication.

#### Basic Authentication via Nginx

Activate the basic authentication via the `WORKSPACE_AUTH_USER` and `WORKSPACE_AUTH_PASSWORD` variable:

```bash
docker run -p 8091:8091 --env WORKSPACE_AUTH_USER="user" --env WORKSPACE_AUTH_PASSWORD="pwd" mltooling/ml-workspace:latest
```

The basic authentication is configured via the nginx proxy and might be more performant compared to the other option since with `AUTHENTICATE_VIA_JUPYTER` every request to any tool in the workspace will check via the Jupyter instance if the user (based on the request cookies) is authenticated.

### Enable SSL/HTTPS

We recommend enabling SSL so that the workspace is accessible via HTTPS (encrypted communication). SSL encryption can be activated via the `WORKSPACE_SSL_ENABLED` variable. When set to `true`, either the `cert.crt` and `cert.key` file must be mounted to `/resources/ssl` or, if the certificate files do not exist, the container generates self-signed certificates. For example, if the `/path/with/certificate/files` on the local system contains a valid certificate for the host domain (`cert.crt` and `cert.key` file), it can be used from the workspace as shown below:

```bash
docker run -p 8091:8091 --env WORKSPACE_SSL_ENABLED="true" -v /path/with/certificate/files:/resources/ssl:ro mltooling/ml-workspace:latest
```

### Proxy

If a proxy is required, you can pass the proxy configuration via the `http_proxy` and `no_proxy` environment variables.

### Workspace Flavors

In addition to the main workspace image (`mltooling/ml-workspace`), we provide other image flavors that extend the features or minimize the image size to support a variety of use cases.

#### Minimal Flavor

<a href="https://hub.docker.com/r/mltooling/ml-workspace-minimal" title="Docker Image Version"><img src="https://images.microbadger.com/badges/version/mltooling/ml-workspace-minimal.svg"></a>
<a href="https://hub.docker.com/r/mltooling/ml-workspace-minimal" title="Docker Image Metadata"><img src="https://images.microbadger.com/badges/image/mltooling/ml-workspace-minimal.svg"></a>
<a href="https://hub.docker.com/r/mltooling/ml-workspace-minimal" title="Docker Pulls"><img src="https://img.shields.io/docker/pulls/mltooling/ml-workspace-minimal.svg"></a>
<a href="https://hub.docker.com/r/mltooling/ml-workspace-minimal" title="Docker Stars"><img src="https://img.shields.io/docker/stars/mltooling/ml-workspace-minimal"></a>

The minimal flavor (`mltooling/ml-workspace-minimal`) is our smallest image that contains most of the tools and features described in the [features section](#features) without most of the python libraries that are preinstalled in our main image. Any Python library or excluded tool can be installed manually during runtime by the user.

```bash
docker run -p 8091:8091 mltooling/ml-workspace-minimal:latest
```

#### Light Flavor

<a href="https://hub.docker.com/r/mltooling/ml-workspace-light" title="Docker Image Version"><img src="https://images.microbadger.com/badges/version/mltooling/ml-workspace-light.svg"></a>
<a href="https://hub.docker.com/r/mltooling/ml-workspace-light" title="Docker Image Metadata"><img src="https://images.microbadger.com/badges/image/mltooling/ml-workspace-light.svg"></a>
<a href="https://hub.docker.com/r/mltooling/ml-workspace-light" title="Docker Pulls"><img src="https://img.shields.io/docker/pulls/mltooling/ml-workspace-light.svg"></a>
<a href="https://hub.docker.com/r/mltooling/ml-workspace-light" title="Docker Stars"><img src="https://img.shields.io/docker/stars/mltooling/ml-workspace-light"></a>

The light flavor (`mltooling/ml-workspace-light`) has all of the tools and features described in the [features section](#features), but only a small collection of popular python machine learning libraries preinstalled. Any Python library can be installed manually during runtime.

```bash
docker run -p 8091:8091 mltooling/ml-workspace-light:latest
```

#### GPU Flavor

<a href="https://hub.docker.com/r/mltooling/ml-workspace-gpu" title="Docker Image Version"><img src="https://images.microbadger.com/badges/version/mltooling/ml-workspace-gpu.svg"></a>
<a href="https://hub.docker.com/r/mltooling/ml-workspace-gpu" title="Docker Image Metadata"><img src="https://images.microbadger.com/badges/image/mltooling/ml-workspace-gpu.svg"></a>
<a href="https://hub.docker.com/r/mltooling/ml-workspace-gpu" title="Docker Pulls"><img src="https://img.shields.io/docker/pulls/mltooling/ml-workspace-gpu.svg"></a>
<a href="https://hub.docker.com/r/mltooling/ml-workspace-gpu" title="Docker Stars"><img src="https://img.shields.io/docker/stars/mltooling/ml-workspace-gpu"></a>

The GPU flavor (`mltooling/ml-workspace-gpu`) is based on our main workspace image and extends it with CUDA 10 and GPU-ready versions of various machine learning libraries (e.g. tensorflow, pytorch, cntk, jax). This GPU image has the following additional requirements for the system:

- Nvidia Drivers for the GPUs. Drivers need to be CUDA 10 compatible, version `>= 410.48` ([📖 Instructions](https://github.com/NVIDIA/nvidia-docker/wiki/Frequently-Asked-Questions#how-do-i-install-the-nvidia-driver)).
- (Docker >= 19.03) Nvidia Container Toolkit ([📖 Instructions](https://github.com/NVIDIA/nvidia-docker/wiki/Installation-(Native-GPU-Support))).

```bash
docker run -p 8091:8091 --gpus all mltooling/ml-workspace-gpu:latest
```

- (Docker < 19.03) Nvidia Docker 2.0 ([📖 Instructions](https://github.com/NVIDIA/nvidia-docker/wiki/Installation-(version-2.0))).

```bash
docker run -p 8091:8091 --runtime nvidia --env NVIDIA_VISIBLE_DEVICES="all" mltooling/ml-workspace-gpu:latest
```

The GPU flavor also comes with a few additional configuration options as explained below:

<table>
    <tr>
        <th>Variable</th>
        <th>Description</th>
        <th>Default</th>
    </tr>
    <tr>
        <td>NVIDIA_VISIBLE_DEVICES</td>
        <td>Controls which GPUs will be accessible inside the workspace. By default, all GPUs from the host are accessible within the workspace. You can either use <code>all</code>, <code>none</code>, or specify a comma-separated list of device IDs (e.g. <code>0,1</code>). You can find out the list of available device IDs by running <code>nvidia-smi</code> on the host machine.</td>
        <td>all</td>
    </tr>
    <tr>
        <td>CUDA_VISIBLE_DEVICES</td>
        <td>Controls which GPUs CUDA applications running inside the workspace will see. By default, all GPUs that the workspace has access to will be visible. To restrict applications, provide a comma-separated list of internal device IDs (e.g. <code>0,2</code>) based on the available devices within the workspace (run <code>nvidia-smi</code>). In comparison to <code>NVIDIA_VISIBLE_DEVICES</code>, the workspace user will still able to access other GPUs by overwriting this configuration from within the workspace.</td>
        <td></td>
    </tr>
    <tr>
        <td>TF_FORCE_GPU_ALLOW_GROWTH</td>
        <td>By default, the majority of GPU memory will be allocated by the first execution of a TensorFlow graph. While this behavior can be desirable for production pipelines, it is less desirable for interactive use. Use <code>true</code> to enable dynamic GPU Memory allocation or <code>false</code> to instruct TensorFlow to allocate all memory at execution.</td>
        <td>true</td>
    </tr>
</table>

### Multi-user setup

The workspace is designed as a single user development environment. For a multi-user setup, we recommend to deploy [🧰 ML Hub](https://github.com/ml-tooling/ml-hub). ML Hub is based on JupyterHub and spawns, manages, and proxies multiple workspace instances. It is easy to set up on a single server (via Docker) or a cluster (via Kubernetes) and supports a variety of usage scenarios & authentication providers. You can try out ML Hub  via:

```bash
docker run -p 8091:8091 -v /var/run/docker.sock:/var/run/docker.sock mltooling/ml-hub:latest
```

For more information and documentation about ML Hub, please take a look at the [Github Site](https://github.com/ml-tooling/ml-hub).

### Run as a job

> ℹ️ _A job is defined as any computational task that runs for a certain time to completion, such as a model training or a data pipeline._

The workspace image can also be used as a job to execute arbitrary Python code without starting any of the preinstalled tools. This provides a seamless way to productize your ML projects since the code that has been developed interactively within the workspace will have the same environment and configuration when run as a job via the same workspace image. To run Python code as a job, you need to provide a path or URL to a code directory (or script) via `EXECUTE_CODE`. The code can be either already mounted into the workspace container or downloaded from a version control system (e.g., git or svn) as described in the following sections. The selected code path needs to be python executable. In case the selected code is a directory (e.g., whenever you download the code from a VCS) you need to put a `__main__.py` file at the root of this directory. The `__main__.py` needs to contain the code that starts your job.

#### Run code from version control system

You can execute code directly from Git, Mercurial, Subversion, or Bazaar by using the pip-vcs format as described in [this guide](https://pip.pypa.io/en/stable/reference/pip_install/#vcs-support). For example, to execute code from a [subdirectory](https://github.com/ml-tooling/ml-workspace/tree/develop/docker-res/tests/ml-job) of a git repository, just run:

```bash
docker run --env EXECUTE_CODE="git+https://github.com/ml-tooling/ml-workspace.git#subdirectory=docker-res/tests/ml-job" mltooling/ml-workspace:latest
```

> ℹ️ _You can find information on how to specify branches, commits, or tags please refer to [this guide](https://pip.pypa.io/en/stable/reference/pip_install/#vcs-support)._

#### Run code mounted into workspace

In the following example, we mount and execute the current working directory (expected to contain our code) into the `/workspace/ml-job/` directory of the workspace:

```bash
docker run -v "${PWD}:/workspace/ml-job/" --env EXECUTE_CODE="/workspace/ml-job/" mltooling/ml-workspace:latest
```

#### Install Dependencies

In the case that the preinstalled workspace libraries are not compatible with your code, you can install or change dependencies by just adding one or multiple of the following files to your code directory:

- `requirements.txt`: [pip requirements format](https://pip.pypa.io/en/stable/user_guide/#requirements-files) for pip-installable dependencies.
- `environment.yml`: [conda environment file](https://docs.conda.io/projects/conda/en/latest/user-guide/tasks/manage-environments.html?highlight=environment.yml#creating-an-environment-file-manually) to create a separate Python environment.
- `setup.sh`: A shell script executed via `/bin/bash`.

The execution order is 1. `environment.yml` -> 2. `setup.sh` -> 3. `requirements.txt`

#### Test job in interactive mode

You can test your job code within the workspace (started normally with interactive tools) by executing the following python script:

```bash
python /resources/scripts/execute_code.py /path/to/your/job
```

#### Build a custom job image

It is also possible to embed your code directly into a custom job image, as shown below:

```dockerfile
FROM mltooling/ml-workspace:latest

COPY /mljob /workspace/mljob
ENV EXECUTE_CODE=/workspace/mljob
```

## Support

The ML Workspace project is maintained by [@LukasMasuch](https://twitter.com/LukasMasuch)
and [@raethlein](https://twitter.com/raethlein). Please understand that we won't be able
to provide individual support via email. We also believe that help is much more
valuable if it's shared publicly so that more people can benefit from it.

| Type                     | Channel                                              |
| ------------------------ | ------------------------------------------------------ |
| 🚨 **Bug Reports**       | <a href="https://github.com/ml-tooling/ml-workspace/issues?utf8=%E2%9C%93&q=is%3Aopen+is%3Aissue+label%3Abug+sort%3Areactions-%2B1-desc+" title="Open Bug Report"><img src="https://img.shields.io/github/issues/ml-tooling/ml-workspace/bug.svg"></a>                                 |
| 🎁 **Feature Requests**  | <a href="https://github.com/ml-tooling/ml-workspace/issues?q=is%3Aopen+is%3Aissue+label%3Afeature-request+sort%3Areactions-%2B1-desc" title="Open Feature Request"><img src="https://img.shields.io/github/issues/ml-tooling/ml-workspace/feature-request.svg?label=feature%20requests"></a>                                 |
| 👩‍💻 **Usage Questions**   |  <a href="https://stackoverflow.com/questions/tagged/ml-tooling" title="Open Question on Stackoverflow"><img src="https://img.shields.io/badge/stackoverflow-ml--tooling-orange.svg"></a> <a href="https://gitter.im/ml-tooling/ml-workspace" title="Chat on Gitter"><img src="https://badges.gitter.im/ml-tooling/ml-workspace.svg"></a> |
| 🗯 **General Discussion** | <a href="https://gitter.im/ml-tooling/ml-workspace" title="Chat on Gitter"><img src="https://badges.gitter.im/ml-tooling/ml-workspace.svg"></a>  <a href="https://twitter.com/mltooling" title="ML Tooling on Twitter"><img src="https://img.shields.io/twitter/follow/mltooling.svg?style=social"></a>                  |

## Features

<p align="center">
  <a href="#jupyter">Jupyter</a> •
  <a href="#desktop-gui">Desktop GUI</a> •
  <a href="#visual-studio-code">VS Code</a> •
  <a href="#git-integration">Git Integration</a> •
  <a href="#jupyterlab">JupyterLab</a> •
  <a href="#hardware-monitoring">Hardware Monitoring</a> •
  <a href="#tensorboard">Tensorboard</a> •
  <a href="#ssh-access">SSH Access</a>
</p>

The workspace is equipped with a selection of best-in-class open-source development tools to help with the machine learning workflow. Many of these tools can be started from the `Open Tool` menu from Jupyter (the main application of the workspace):

<img style="width: 100%" src="./docs/images/feature-open-tools.png"/>

> ℹ️ _Within your workspace you have **full root & sudo access** to install any library or tool you need via terminal (e.g., `pip` or `apt-get`)_

### Jupyter

[Jupyter Notebook](https://jupyter.org/) is a web-based interactive environment for writing and running code. The main building blocks of Jupyter are the file-browser, the notebook editor, and kernels. The file-browser provides an interactive file manager for all notebooks, files, and folders in the `/workspace` directory.

<img style="width: 100%" src="./docs/images/feature-jupyter-tree.png"/>

A new notebook can be created by clicking on the `New` drop-down button at the top of the list and selecting the desired language kernel.

> 💡 _You can spawn interactive **terminal** instances as well by selecting `New -> Terminal` in the file-browser._

<img style="width: 100%" src="./docs/images/feature-jupyter-notebook.png"/>

The notebook editor enables users to author documents that include live code, markdown text, shell commands, LaTeX equations, interactive widgets, plots, and images. These notebook documents provide a complete and self-contained record of a computation that can be converted to various formats and shared with others.

> ℹ️ _This workspace has a variety of **third-party Jupyter extensions** activated. You can configure these extensions in the nbextensions configurator: `nbextensions` tab on the file browser_

The Notebook allows code to be run in a range of different programming languages. For each notebook document that a user opens, the web application starts a **kernel** that runs the code for that notebook and returns output. This workspace has a Python 3 and Python 2 kernel pre-installed. Additional Kernels can be installed to get access to other languages (e.g., R, Scala, Go) or additional computing resources (e.g., GPUs, CPUs, Memory).

> ℹ️ _**Python 2** support is deprecated and not fully supported. Please only use Python 2 if necessary!_

### Desktop GUI

This workspace provides an HTTP-based VNC access to the workspace via [noVNC](https://github.com/novnc/noVNC). Thereby, you can access and work within the workspace with a fully featured desktop GUI. To access this desktop GUI, go to `Open Tool`, select `VNC`, and click the `Connect` button. In the case you are asked for a password, use `vncpassword`.

<img style="width: 100%" src="./docs/images/feature-desktop-vnc.png"/>

Once you are connected, you will see a desktop GUI that allows you to install and use full-fledged web-browsers or any other tool that is available for Ubuntu. Within the `Tools` folder on the desktop, you will find a collection of install scripts that makes it straightforward to install some of the most commonly used development tools, such as Atom, PyCharm, R-Runtime, R-Studio, or Postman (just double-click on the script).

**Clipboard:** If you want to share the clipboard between your machine and the workspace, you can use the copy-paste functionality as described below:

<img style="width: 100%" src="./docs/images/feature-desktop-vnc-clipboard.png"/>

> 💡 _**Long-running tasks:** Use the desktop GUI for long-running Jupyter executions. By running notebooks from the browser of your workspace desktop GUI, all output will be synchronized to the notebook even if you have disconnected your browser from the notebook._

### Visual Studio Code

[Visual Studio Code](https://github.com/microsoft/vscode) (`Open Tool -> VS Code`) is an open-source lightweight but powerful code editor with built-in support for a variety of languages and a rich ecosystem of extensions. It combines the simplicity of a source code editor with powerful developer tooling, like IntelliSense code completion and debugging. The workspace integrates VS Code as a web-based application accessible through the browser based on the awesome [code-server](https://github.com/cdr/code-server) project. It allows you to customize every feature to your liking and install any number of third-party extensions.

<p align="center"><img src="./docs/images/feature-vs-code.png"/></p>

### Git Integration

Version control is a crucial aspect for productive collaboration. To make this process as smooth as possible, we have integrated a custom-made Jupyter extension specialized on pushing single notebooks, a full-fledged web-based Git client ([ungit](https://github.com/FredrikNoren/ungit)), a tool to open and edit plain text documents (e.g., `.py`, `.md`) as notebooks ([jupytext](https://github.com/mwouts/jupytext)), as well as a notebook merging tool ([nbdime](https://github.com/jupyter/nbdime)). Additionally, JupyterLab and VS Code also provide GUI-based Git clients.

#### Clone Repository

For cloning repositories via `https`, we recommend to navigate to the desired root folder and to click on the `git` button as shown below:

<img style="width: 100%" src="./docs/images/feature-git-open.png"/>

This might ask for some required settings and, subsequently, opens [ungit](https://github.com/FredrikNoren/ungit), a web-based Git client with a clean and intuitive UI that makes it convenient to sync your code artifacts. Within ungit, you can clone any repository. If authentication is required, you will get asked for your credentials.

<img style="width: 100%" src="./docs/images/feature-clone-repo.png"/>

#### Push, Pull, Merge, and Other Git Actions

To commit and push a single notebook to a remote Git repository, we recommend to use the Git plugin integrated into Jupyter as shown below:

<img style="width: 100%" src="./docs/images/feature-git-extension.png"/>

For more advanced Git operations we recommend to use [ungit](https://github.com/FredrikNoren/ungit). With ungit, you can do most of the common git actions such as push, pull, merge, branch, tag, checkout, and many more.

#### Sharing, Diffing, and Merging Notebooks

Jupyter notebooks are great, but they often are huge files, with a very specific JSON file format. To enable seamless sharing, diffing, and merging via Git this workspace is pre-installed with [nbdime](https://github.com/jupyter/nbdime). Nbdime understands the structure of notebook documents and, therefore, automatically makes intelligent decisions when diffing and merging notebooks. In the case you have merge conflicts, nbdime will make sure that the notebook is still readable by Jupyter, as shown below:

<img style="width: 100%" src="./docs/images/feature-git-merging.png"/>

Furthermore, the workspace comes pre-installed with [jupytext](https://github.com/mwouts/jupytext), a Jupyter plugin that reads and writes notebooks as plain text files. This allows you to open, edit, and run scripts or markdown files (e.g., `.py`, `.md`) as notebooks within Jupyter. In the following screenshot, we have opened this `README.md` file via Jupyter:

<img style="width: 100%" src="./docs/images/feature-git-jupytext.png"/>

In combination with Git, jupytext enables a clear diff history and easy merging of version conflicts. With both of those tools, collaborating on Jupyter notebooks with Git becomes straightforward.

### JupyterLab

[JupyterLab](https://github.com/jupyterlab/jupyterlab) (`Open Tool -> JupyterLab`) is the next-generation user interface for Project Jupyter. It offers all the familiar building blocks of the classic Jupyter Notebook (notebook, terminal, text editor, file browser, rich outputs, etc.) in a flexible and powerful user interface. This JupyterLab instance comes pre-installed with a few helpful extensions such as a the [jupyterlab-toc](https://github.com/jupyterlab/jupyterlab-toc), [jupyterlab-git](https://github.com/jupyterlab/jupyterlab-git), and [juptyterlab-tensorboard](https://github.com/chaoleili/jupyterlab_tensorboard).

<img style="width: 100%" src="./docs/images/feature-jupyterlab.png"/>

### Hardware Monitoring

The workspace provides two preinstalled web-based tools to help developers during model training and other experimentation tasks to get insights into everything happening on the system and figure out performance bottlenecks.

[Netdata](https://github.com/netdata/netdata) (`Open Tool -> Netdata`) is a real-time hardware and performance monitoring dashboard that visualize the processes and services on your Linux systems. It monitors metrics about CPU, GPU, memory, disks, networks, processes, and more.

<img style="width: 100%" src="./docs/images/feature-netdata.png" />

[Glances](https://github.com/nicolargo/glances) (`Open Tool -> Glances`) is a web-based hardware monitoring dashboard as well and can be used as an alternative to Netdata.

<img style="width: 100%" src="./docs/images/feature-glances.png"/>

> ℹ️ _Netdata and Glances will show you the hardware statistics for the entire machine on which the workspace container is running._

### Tensorboard

[Tensorboard](https://www.tensorflow.org/tensorboard) provides a suite of visualization tools to make it easier to understand, debug, and optimize your experiment runs. It includes logging features for scalar, histogram, model structure, embeddings, and text & image visualization. The workspace comes preinstalled with [jupyter_tensorboard extension](https://github.com/lspvic/jupyter_tensorboard) that integrates Tensorboard into the Jupyter interface with functionalities to start, manage, and stop instances. You can open a new instance for a valid logs directory as shown below:

<img style="width: 100%" src="./docs/images/feature-tensorboard-open.png" />

If you have opened a Tensorboard instance in a valid log directory, you will see the visualizations of your logged data:

<img style="width: 100%" src="./docs/images/feature-tensorboard-overview.png" />

> ℹ️ _Tensorboard can be used in combination with many other ML frameworks besides Tensorflow. By using the [tensorboardX](https://github.com/lanpa/tensorboardX) library you can log basically from any python based library. Also, PyTorch has a direct Tensorboard integration as described [here](https://pytorch.org/docs/stable/tensorboard.html)._

If you prefer to see the tensorboard directly within your notebook, you can make use of following **Jupyter magic**:

```
%load_ext tensorboard.notebook
%tensorboard --logdir /workspace/path/to/logs
```

### SSH Access

SSH provides a powerful set of features that enables you to be more productive with your development tasks. You can easily setup a secure and passwordless SSH connection to a workspace by selecting `Open Tool -> SSH`. This will download a customized setup script and shows some additional instructions:

> ℹ️ _The setup script only runs on Mac and Linux, Windows is currently not supported._

Just run the setup script on the machine from where you want to setup a connection to the workspace and input a name for the connection (e.g. `my-workspace`). You might also get asked for some additional input during the process. Once the connection is successfully setup and tested, you can securely connect to the workspace by simply executing `ssh my-workspace`. 

Besides the ability to execute commands on a remote machine, SSH also provides a variety of other features that can improve your development workflow as described in the following sections.

#### Tunnel Ports

An SSH connection can be used for tunneling application ports from the remote machine to the local machine, or vice versa. For example, you can expose the workspace internal port `5901` (VNC Server) to the local machine on port `5000` by executing:

```
ssh -nNT -L 5000:localhost:5901 my-workspace
```

> ℹ️ _You can also expose an application port from your local machine to a workspace via the `-R` option (instead of `-L`)._

After the tunnel is established, you can use your favorite VNC viewer on your local machine and connect to `vnc://localhost:5000` (default password: `vncpassword`). To make the tunnel connection more resistant and reliable, we recommend to use [autossh](https://www.harding.motd.ca/autossh/) to automatically restart SSH tunnels in the case that the connection dies:

```
autossh -M 0 -f -nNT -L 5000:localhost:5901 my-workspace
```

Port tunneling is quite useful when you have started any server-based tool within the workspace that you like to make accessible for another machine. In its default setting, the workspace has a variety of tools already running on different ports, such as:

- `8091`: Main workspace port with access to all integrated tools.
- `8090`: Jupyter server.
- `8054`: VS Code server.
- `5901`: VNC server.
- `3389`: RDP server.
- `22`: SSH server.

> 📖 _For more information about port tunneling/forwarding, we recommend [this guide](https://www.everythingcli.org/ssh-tunnelling-for-fun-and-profit-local-vs-remote/)._

#### Copy Data via SCP

SCP allows files and directories to be securely copied to, from, or between different machines via SSH connections. For example, to copy a local file (`./local-file.txt`) into the `/workspace` folder inside the workspace, execute:

```
scp ./local-file.txt my-workspace:/workspace
```

To copy the `/workspace` directory from `my-workspace` to the working directory of the local machine, execute:

```
scp -r local-workspace:/workspace .
```

> 📖 _For more information about scp, we recommend [this guide](https://www.garron.me/en/articles/scp.html)._

#### Sync Data via Rsync

```
rsync -avzP source/ destination
```

https://github.com/dooblem/bsync
https://github.com/bcpierce00/unison
https://axkibe.github.io/lsyncd/
https://github.com/deajan/osync

#### Mount Folders via SSHFS

Besides copying and syncing data, an SSH connection can also be used to mount directories from a remote machine into the local filesystem via [SSHFS](https://github.com/libfuse/sshfs). 
For example, to mount the `/workspace` directory of `my-workspace` into a local path (e.g. `/local/folder/path`), execute:

```
sshfs -o reconnect my-workspace:/workspace /local/folder/path
```

Once the remote directory is mounted, you can interact with the remote file system the same way as with any local directory and file.

> 📖 _For more information about sshfs, we recommend [this guide](https://www.digitalocean.com/community/tutorials/how-to-use-sshfs-to-mount-remote-file-systems-over-ssh)._

### Remote Development

The workspace can be integrated and used as remote runtime for a variety of common development tools and IDE's.


. All of those integrations require a passwordless SSH connection from the local machine to the workspace. You can easily setup a

_WIP: Remote Kernels, VS Code remote development, and usage as Colab local runtime._

#### Jupyter - Remote Kernel

The workspace can be added to a Jupyter instance as a remote kernel. 

To a running 

#### VS Code - Remote Machine


#### PyCharm - Remote Interpreter


#### Colab - Local Runtime


### Preinstalled Libraries and Runtimes

The workspace is pre-installed with many popular runtimes, data science libraries, and ubuntu packages:

- **Runtimes:** Miniconda 3 (Python 3.6), Java 8, NodeJS 11, Go, Ruby
- **Python libraries:** Tensorflow, Keras, Pytorch, Sklearn, CNTK, XGBoost, Theano, Fastai, and [many more](https://github.com/ml-tooling/ml-workspace/blob/master/docker-res/requirements.txt)

The full list of installed tools can be found within the [Dockerfile](https://github.com/ml-tooling/ml-workspace/blob/master/Dockerfile).

> ℹ️ _**An R-Runtime** installation script is provided in the `Tools` folder on the desktop of the VNC GUI._

### GPU Support

_WIP_

## Contribution

- Pull requests are encouraged and always welcome. Read [`CONTRIBUTING.md`](https://github.com/ml-tooling/ml-workspace/tree/master/CONTRIBUTING.md) and check out [help-wanted](https://github.com/ml-tooling/ml-workspace/issues?utf8=%E2%9C%93&q=is%3Aopen+is%3Aissue+label%3A"help+wanted"+sort%3Areactions-%2B1-desc+) issues.
- Submit github issues for any [feature enhancements](https://github.com/ml-tooling/ml-workspace/issues/new?assignees=&labels=feature-request&template=02_feature-request.md&title=), [bugs](https://github.com/ml-tooling/ml-workspace/issues/new?assignees=&labels=bug&template=01_bug-report.md&title=), or [documentation](https://github.com/ml-tooling/ml-workspace/issues/new?assignees=&labels=enhancement%2C+docs&template=03_documentation.md&title=) problems. 
- By participating in this project you agree to abide by its [Code of Conduct](https://github.com/ml-tooling/ml-workspace/tree/master/CODE_OF_CONDUCT.md).

<details>

<summary>Development instructions for contributors (click to expand...)</summary>

### Build

Execute this command in the project root folder to build the docker container:

```bash
python build.py --version={MAJOR.MINOR.PATCH-TAG}
```

The version is optional and should follow the [Semantic Versioning](https://semver.org/) standard (MAJOR.MINOR.PATCH). For additional script options:

```bash
python build.py --help
```

### Deploy

Execute this command in the project root folder to push the container to the configured docker registry:

```bash
python build.py --deploy --version={MAJOR.MINOR.PATCH-TAG}
```

The version has to be provided. The version format should follow the [Semantic Versioning](https://semver.org/) standard (MAJOR.MINOR.PATCH). For additional script options:

```bash
python build.py --help
```

</details>

---

Licensed **Apache 2.0**. Created and maintained with ❤️ by developers from SAP in Berlin. 
