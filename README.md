<h1 align="center">
    <a href="https://github.com/ml-tooling/ml-workspace" title="ML Workspace Home">
    <img width=50% alt="" src="https://github.com/ml-tooling/ml-workspace/raw/main/docs/images/ml-workspace-logo.png"> </a>
    <br>
</h1>

<p align="center">
    <strong>All-in-one web-based development environment for machine learning</strong>
</p>

<p align="center">
    <a href="https://hub.docker.com/r/mltooling/ml-workspace" title="Docker Image Version"><img src="https://img.shields.io/docker/v/mltooling/ml-workspace?color=blue&sort=semver"></a>
    <a href="https://hub.docker.com/r/mltooling/ml-workspace" title="Docker Pulls"><img src="https://img.shields.io/docker/pulls/mltooling/ml-workspace.svg?color=blue"></a>
    <a href="https://hub.docker.com/r/mltooling/ml-workspace" title="Docker Image Size"><img src="https://img.shields.io/docker/image-size/mltooling/ml-workspace?color=blue&sort=semver"></a>
    <a href="https://gitter.im/ml-tooling/ml-workspace" title="Chat on Gitter"><img src="https://badges.gitter.im/ml-tooling/ml-workspace.svg"></a>
    <a href="https://mltooling.substack.com/subscribe" title="Subscribe to newsletter"><img src="http://bit.ly/2Md9rxM"></a>
    <a href="https://twitter.com/mltooling" title="Follow on Twitter"><img src="https://img.shields.io/twitter/follow/mltooling.svg?style=social&label=Follow"></a>
</p>

<p align="center">
  <a href="#getting-started">Getting Started</a> •
  <a href="#features">Features & Screenshots</a> •
  <a href="#support">Support</a> •
  <a href="https://github.com/ml-tooling/ml-workspace/issues/new?labels=bug&template=01_bug-report.md">Report a Bug</a> •
  <a href="#faq">FAQ</a> •
  <a href="#known-issues">Known Issues</a> •
  <a href="#contribution">Contribution</a>
</p>

The ML workspace is an all-in-one web-based IDE specialized for machine learning and data science. It is simple to deploy and gets you started within minutes to productively built ML solutions on your own machines. This workspace is the ultimate tool for developers preloaded with a variety of popular data science libraries (e.g., Tensorflow, PyTorch, Keras, Sklearn) and dev tools (e.g., Jupyter, VS Code, Tensorboard) perfectly configured, optimized, and integrated.

## Highlights

- 💫&nbsp; Jupyter, JupyterLab, and Visual Studio Code web-based IDEs.
- 🗃&nbsp; Pre-installed with many popular data science libraries & tools.
- 🖥&nbsp; Full Linux desktop GUI accessible via web browser.
- 🔀&nbsp; Seamless Git integration optimized for notebooks.
- 📈&nbsp; Integrated hardware & training monitoring via Tensorboard & Netdata.
- 🚪&nbsp; Access from anywhere via Web, SSH, or VNC under a single port.
- 🎛&nbsp; Usable as remote kernel (Jupyter) or remote machine (VS Code) via SSH.
- 🐳&nbsp; Easy to deploy on Mac, Linux, and Windows via Docker.

<br>

## Getting Started

<p>
<a href="https://labs.play-with-docker.com/?stack=https://raw.githubusercontent.com/ml-tooling/ml-workspace/main/deployment/play-with-docker/docker-compose.yml" title="Docker Image Metadata" target="_blank"><img src="https://cdn.rawgit.com/play-with-docker/stacks/cff22438/assets/images/button.png" alt="Try in PWD" width="100px"></a>
</p>

### Prerequisites

The workspace requires **Docker** to be installed on your machine ([📖 Installation Guide](https://docs.docker.com/install/#supported-platforms)).

### Start single instance

Deploying a single workspace instance is as simple as:

```bash
docker run -p 8080:8080 mltooling/ml-workspace:0.12.1
```

Voilà, that was easy! Now, Docker will pull the latest workspace image to your machine. This may take a few minutes, depending on your internet speed. Once the workspace is started, you can access it via http://localhost:8080.

> _If started on another machine or with a different port, make sure to use the machine's IP/DNS and/or the exposed port._

To deploy a single instance for productive usage, we recommend to apply at least the following options:

```bash
docker run -d \
    -p 8080:8080 \
    --name "ml-workspace" \
    -v "${PWD}:/workspace" \
    --env AUTHENTICATE_VIA_JUPYTER="mytoken" \
    --shm-size 512m \
    --restart always \
    mltooling/ml-workspace:0.12.1
```

This command runs the container in background (`-d`), mounts your current working directory into the `/workspace` folder (`-v`), secures the workspace via a provided token (`--env AUTHENTICATE_VIA_JUPYTER`), provides 512MB of shared memory (`--shm-size`) to prevent unexpected crashes (see [known issues section](#known-issues)), and keeps the container running even on system restarts (`--restart always`). You can find additional options for docker run [here](https://docs.docker.com/engine/reference/commandline/run/) and workspace configuration options in [the section below](#Configuration).

### Configuration Options

The workspace provides a variety of configuration options that can be used by setting environment variables (via docker run option: `--env`).

<details>
<summary>Configuration options (click to expand...)</summary>

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
        <td>Enable or disable SSL. When set to true, either certificate (cert.crt) must be mounted to <code>/resources/ssl</code> or, if not, the container generates self-signed certificate.</td>
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
        <td>WORKSPACE_PORT</td>
        <td>Configures the main container-internal port of the workspace proxy. For most scenarios, this configuration should not be changed, and the port configuration via Docker should be used instead of the workspace should be accessible from a different port.</td>
        <td>8080</td>
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
        <td>If <code>true</code>, a selection of tutorial and introduction notebooks are added to the <code>/workspace</code> folder at container startup, but only if the folder is empty.</td>
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
        <td>Automatically shutdown inactive kernels after a given timeout (to clean up memory or GPU resources). Value can be either a timeout in seconds or set to <code>true</code> with a default value of 48h.</td>
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
</table>

</details>

### Persist Data

To persist the data, you need to mount a volume into `/workspace` (via docker run option: `-v`).

<details>
<summary>Details (click to expand...)</summary>

The default work directory within the container is `/workspace`, which is also the root directory of the Jupyter instance. The `/workspace` directory is intended to be used for all the important work artifacts. Data within other directories of the server (e.g., `/root`) might get lost at container restarts.
</details>

### Enable Authentication

We strongly recommend enabling authentication via one of the following two options. For both options, the user will be required to authenticate for accessing any of the pre-installed tools.

> _The authentication only works for all tools accessed through the main workspace port (default: `8080`). This works for all preinstalled tools and the [Access Ports](#access-ports) feature. If you expose another port of the container, please make sure to secure it with authentication as well!_

<details>
<summary>Details (click to expand...)</summary>

#### Token-based Authentication via Jupyter (recommended)

Activate the token-based authentication based on the authentication implementation of Jupyter via the `AUTHENTICATE_VIA_JUPYTER` variable:

```bash
docker run -p 8080:8080 --env AUTHENTICATE_VIA_JUPYTER="mytoken" mltooling/ml-workspace:0.12.1
```

You can also use `<generated>` to let Jupyter generate a random token that is printed out on the container logs. A value of `true` will not set any token but activate that every request to any tool in the workspace will be checked with the Jupyter instance if the user is authenticated. This is used for tools like JupyterHub, which configures its own way of authentication.

#### Basic Authentication via Nginx

Activate the basic authentication via the `WORKSPACE_AUTH_USER` and `WORKSPACE_AUTH_PASSWORD` variable:

```bash
docker run -p 8080:8080 --env WORKSPACE_AUTH_USER="user" --env WORKSPACE_AUTH_PASSWORD="pwd" mltooling/ml-workspace:0.12.1
```

The basic authentication is configured via the nginx proxy and might be more performant compared to the other option since with `AUTHENTICATE_VIA_JUPYTER` every request to any tool in the workspace will check via the Jupyter instance if the user (based on the request cookies) is authenticated.

</details>

### Enable SSL/HTTPS

We recommend enabling SSL so that the workspace is accessible via HTTPS (encrypted communication). SSL encryption can be activated via the `WORKSPACE_SSL_ENABLED` variable. 

<details>
<summary>Details (click to expand...)</summary>

When set to `true`, either the `cert.crt` and `cert.key` file must be mounted to `/resources/ssl` or, if the certificate files do not exist, the container generates self-signed certificates. For example, if the `/path/with/certificate/files` on the local system contains a valid certificate for the host domain (`cert.crt` and `cert.key` file), it can be used from the workspace as shown below:

```bash
docker run \
    -p 8080:8080 \
    --env WORKSPACE_SSL_ENABLED="true" \
    -v /path/with/certificate/files:/resources/ssl:ro \
    mltooling/ml-workspace:0.12.1
```

If you want to host the workspace on a public domain, we recommend to use [Let's encrypt](https://letsencrypt.org/getting-started/) to get a trusted certificate for your domain.  To use the generated certificate (e.g., via [certbot](https://certbot.eff.org/) tool) for the workspace, the `privkey.pem` corresponds to the `cert.key` file and the `fullchain.pem` to the `cert.crt` file.

> _When you enable SSL support, you must access the workspace over `https://`, not over plain `http://`._

</details>

### Limit Memory & CPU

By default, the workspace container has no resource constraints and can use as much of a given resource as the host’s kernel scheduler allows. Docker provides ways to control how much memory, or CPU a container can use, by setting runtime configuration flags of the docker run command.

> _The workspace requires atleast 2 CPUs and 500MB to run stable and be usable._

<details>
<summary>Details (click to expand...)</summary>

For example, the following command restricts the workspace to only use a maximum of 8 CPUs, 16 GB of memory, and 1 GB of shared memory (see [Known Issues](#known-issues)):

```bash
docker run -p 8080:8080 --cpus=8 --memory=16g --shm-size=1G mltooling/ml-workspace:0.12.1
```

> 📖 _For more options and documentation on resource constraints, please refer to the [official docker guide](https://docs.docker.com/config/containers/resource_constraints/)._

</details>

### Enable Proxy

If a proxy is required, you can pass the proxy configuration via the `HTTP_PROXY`, `HTTPS_PROXY`, and `NO_PROXY` environment variables.

### Workspace Flavors

In addition to the main workspace image (`mltooling/ml-workspace`), we provide other image flavors that extend the features or minimize the image size to support a variety of use cases.

#### Minimal Flavor

<p>
<a href="https://hub.docker.com/r/mltooling/ml-workspace" title="Docker Image Version"><img src="https://img.shields.io/docker/v/mltooling/ml-workspace?color=blue&sort=semver"></a>
<a href="https://hub.docker.com/r/mltooling/ml-workspace-minimal" title="Docker Image Size"><img src="https://img.shields.io/docker/image-size/mltooling/ml-workspace-minimal?color=blue&sort=semver"></a>
<a href="https://hub.docker.com/r/mltooling/ml-workspace-minimal" title="Docker Pulls"><img src="https://img.shields.io/docker/pulls/mltooling/ml-workspace-minimal.svg"></a>
</p>

<details>
<summary>Details (click to expand...)</summary>

The minimal flavor (`mltooling/ml-workspace-minimal`) is our smallest image that contains most of the tools and features described in the [features section](#features) without most of the python libraries that are pre-installed in our main image. Any Python library or excluded tool can be installed manually during runtime by the user.

```bash
docker run -p 8080:8080 mltooling/ml-workspace-minimal:0.12.1
```
</details>

#### R Flavor

<p>
<a href="https://hub.docker.com/r/mltooling/ml-workspace-r" title="Docker Image Version"><img src="https://img.shields.io/docker/v/mltooling/ml-workspace-r?color=blue&sort=semver"></a>
<a href="https://hub.docker.com/r/mltooling/ml-workspace-r" title="Docker Image Size"><img src="https://img.shields.io/docker/image-size/mltooling/ml-workspace-r?color=blue&sort=semver"></a>
<a href="https://hub.docker.com/r/mltooling/ml-workspace-r" title="Docker Pulls"><img src="https://img.shields.io/docker/pulls/mltooling/ml-workspace-r.svg"></a>
</p>

<details>
<summary>Details (click to expand...)</summary>

The R flavor (`mltooling/ml-workspace-r`) is based on our default workspace image and extends it with the R-interpreter, R-Jupyter kernel, RStudio server (access via `Open Tool -> RStudio`), and a variety of popular packages from the R ecosystem.

```bash
docker run -p 8080:8080 mltooling/ml-workspace-r:0.12.1
```
</details>

#### Spark Flavor

<p>
<a href="https://hub.docker.com/r/mltooling/ml-workspace-spark" title="Docker Image Version"><img src="https://img.shields.io/docker/v/mltooling/ml-workspace-spark?color=blue&sort=semver"></a>
<a href="https://hub.docker.com/r/mltooling/ml-workspace-spark" title="Docker Image Size"><img src="https://img.shields.io/docker/image-size/mltooling/ml-workspace-spark?color=blue&sort=semver"></a>
<a href="https://hub.docker.com/r/mltooling/ml-workspace-spark" title="Docker Pulls"><img src="https://img.shields.io/docker/pulls/mltooling/ml-workspace-spark.svg"></a>
</p>

<details>
<summary>Details (click to expand...)</summary>

The Spark flavor (`mltooling/ml-workspace-spark`) is based on our R-flavor workspace image and extends it with the Spark runtime, Spark-Jupyter kernel, Zeppelin Notebook (access via `Open Tool -> Zeppelin`), PySpark, Hadoop, Java Kernel, and a few additional libraries & Jupyter extensions.

```bash
docker run -p 8080:8080 mltooling/ml-workspace-spark:0.12.1
```

</details>

#### GPU Flavor

<p>
<a href="https://hub.docker.com/r/mltooling/ml-workspace-gpu" title="Docker Image Version"><img src="https://img.shields.io/docker/v/mltooling/ml-workspace-gpu?color=blue&sort=semver"></a>
<a href="https://hub.docker.com/r/mltooling/ml-workspace-gpu" ttitle="Docker Image Size"><img src="https://img.shields.io/docker/image-size/mltooling/ml-workspace-gpu?color=blue&sort=semver"></a>
<a href="https://hub.docker.com/r/mltooling/ml-workspace-gpu" title="Docker Pulls"><img src="https://img.shields.io/docker/pulls/mltooling/ml-workspace-gpu.svg"></a>
</p>

<details>
<summary>Details (click to expand...)</summary>

> _Currently, the GPU-flavor only supports CUDA 10.1. Support for other CUDA versions might be added in the future._

The GPU flavor (`mltooling/ml-workspace-gpu`) is based on our default workspace image and extends it with CUDA 10.1 and GPU-ready versions of various machine learning libraries (e.g., tensorflow, pytorch, cntk, jax). This GPU image has the following additional requirements for the system:

- Nvidia Drivers for the GPUs. Drivers need to be CUDA 10.1 compatible, version `>= 418.39` ([📖 Instructions](https://github.com/NVIDIA/nvidia-docker/wiki/Frequently-Asked-Questions#how-do-i-install-the-nvidia-driver)).
- (Docker >= 19.03) Nvidia Container Toolkit ([📖 Instructions](https://github.com/NVIDIA/nvidia-docker/wiki/Installation-(Native-GPU-Support))).

```bash
docker run -p 8080:8080 --gpus all mltooling/ml-workspace-gpu:0.12.1
```

- (Docker < 19.03) Nvidia Docker 2.0 ([📖 Instructions](https://github.com/NVIDIA/nvidia-docker/wiki/Installation-(version-2.0))).

```bash
docker run -p 8080:8080 --runtime nvidia --env NVIDIA_VISIBLE_DEVICES="all" mltooling/ml-workspace-gpu:0.12.1
```

The GPU flavor also comes with a few additional configuration options, as explained below:

<table>
    <tr>
        <th>Variable</th>
        <th>Description</th>
        <th>Default</th>
    </tr>
    <tr>
        <td>NVIDIA_VISIBLE_DEVICES</td>
        <td>Controls which GPUs will be accessible inside the workspace. By default, all GPUs from the host are accessible within the workspace. You can either use <code>all</code>, <code>none</code>, or specify a comma-separated list of device IDs (e.g., <code>0,1</code>). You can find out the list of available device IDs by running <code>nvidia-smi</code> on the host machine.</td>
        <td>all</td>
    </tr>
    <tr>
        <td>CUDA_VISIBLE_DEVICES</td>
        <td>Controls which GPUs CUDA applications running inside the workspace will see. By default, all GPUs that the workspace has access to will be visible. To restrict applications, provide a comma-separated list of internal device IDs (e.g., <code>0,2</code>) based on the available devices within the workspace (run <code>nvidia-smi</code>). In comparison to <code>NVIDIA_VISIBLE_DEVICES</code>, the workspace user will be still able to access other GPUs by overwriting this configuration from within the workspace.</td>
        <td></td>
    </tr>
    <tr>
        <td>TF_FORCE_GPU_ALLOW_GROWTH</td>
        <td>By default, the majority of GPU memory will be allocated by the first execution of a TensorFlow graph. While this behavior can be desirable for production pipelines, it is less desirable for interactive use. Use <code>true</code> to enable dynamic GPU Memory allocation or <code>false</code> to instruct TensorFlow to allocate all memory at execution.</td>
        <td>true</td>
    </tr>
</table>
</details>

### Multi-user setup

The workspace is designed as a single-user development environment. For a multi-user setup, we recommend deploying [🧰 ML Hub](https://github.com/ml-tooling/ml-hub). ML Hub is based on JupyterHub with the task to spawn, manage, and proxy workspace instances for multiple users.

<details>
<summary>Deployment (click to expand...)</summary>

ML Hub makes it easy to set up a multi-user environment on a single server (via Docker) or a cluster (via Kubernetes) and supports a variety of usage scenarios & authentication providers. You can try out ML Hub via:

```bash
docker run -p 8080:8080 -v /var/run/docker.sock:/var/run/docker.sock mltooling/ml-hub:0.12.1
```

For more information and documentation about ML Hub, please take a look at the [Github Site](https://github.com/ml-tooling/ml-hub).

</details>

---

<br>

## Support

This project is maintained by [Benjamin Räthlein](https://twitter.com/raethlein), [Lukas Masuch](https://twitter.com/LukasMasuch), and [Jan Kalkan](https://www.linkedin.com/in/jan-kalkan-b5390284/). Please understand that we won't be able to provide individual support via email. We also believe that help is much more valuable if it's shared publicly so that more people can benefit from it.

| Type                     | Channel                                              |
| ------------------------ | ------------------------------------------------------ |
| 🚨&nbsp; **Bug Reports**       | <a href="https://github.com/ml-tooling/ml-workspace/issues?utf8=%E2%9C%93&q=is%3Aopen+is%3Aissue+label%3Abug+sort%3Areactions-%2B1-desc+" title="Open Bug Report"><img src="https://img.shields.io/github/issues/ml-tooling/ml-workspace/bug.svg"></a>                                  |
| 🎁&nbsp; **Feature Requests**  | <a href="https://github.com/ml-tooling/ml-workspace/issues?q=is%3Aopen+is%3Aissue+label%3Afeature+sort%3Areactions-%2B1-desc" title="Open Feature Request"><img src="https://img.shields.io/github/issues/ml-tooling/ml-workspace/feature.svg?label=feature%20request"></a>                                 |
| 👩‍💻&nbsp; **Usage Questions**   |  <a href="https://github.com/ml-tooling/ml-workspace/issues?q=is%3Aopen+is%3Aissue+label%3Asupport+sort%3Areactions-%2B1-desc" title="Open Support Request"> <img src="https://img.shields.io/github/issues/ml-tooling/ml-workspace/support.svg?label=support%20request"></a> <a href="https://stackoverflow.com/questions/tagged/ml-tooling" title="Open Question on Stackoverflow"> <img src="https://img.shields.io/badge/stackoverflow-ml--tooling-orange.svg"></a> <a href="https://gitter.im/ml-tooling/ml-workspace" title="Chat on Gitter"><img src="https://badges.gitter.im/ml-tooling/ml-workspace.svg"></a> |
| 📢&nbsp; **Announcements** | <a href="https://gitter.im/ml-tooling/ml-workspace" title="Chat on Gitter"><img src="https://badges.gitter.im/ml-tooling/ml-workspace.svg"></a> <a href="https://mltooling.substack.com/subscribe" title="Subscribe for updates"><img src="http://bit.ly/2Md9rxM"></a> <a href="https://twitter.com/mltooling" title="ML Tooling on Twitter"><img src="https://img.shields.io/twitter/follow/mltooling.svg?style=social&label=Follow"> |
| ❓&nbsp; **Other Requests** | <a href="mailto:team@mltooling.org" title="Email ML Tooling Team"><img src="https://img.shields.io/badge/email-ML Tooling-green?logo=mail.ru&logoColor=white"></a> |

---

<br>

## Features

<p align="center">
  <a href="#jupyter">Jupyter</a> •
  <a href="#desktop-gui">Desktop GUI</a> •
  <a href="#visual-studio-code">VS Code</a> •
  <a href="#jupyterlab">JupyterLab</a> •
  <a href="#git-integration">Git Integration</a> •
  <a href="#file-sharing">File Sharing</a> •
  <a href="#access-ports">Access Ports</a> •
  <a href="#tensorboard">Tensorboard</a> •
  <a href="#extensibility">Extensibility</a> •
  <a href="#hardware-monitoring">Hardware Monitoring</a> •
  <a href="#ssh-access">SSH Access</a> •
  <a href="#remote-development">Remote Development</a> •
  <a href="#run-as-a-job">Job Execution</a>
</p>

The workspace is equipped with a selection of best-in-class open-source development tools to help with the machine learning workflow. Many of these tools can be started from the `Open Tool` menu from Jupyter (the main application of the workspace):

<img style="width: 100%" src="https://github.com/ml-tooling/ml-workspace/raw/main/docs/images/features/open-tools.png"/>

> _Within your workspace you have **full root & sudo privileges** to install any library or tool you need via terminal (e.g., `pip`, `apt-get`, `conda`, or `npm`). You can find more ways to extend the workspace within the [Extensibility](#extensibility) section_

### Jupyter

[Jupyter Notebook](https://jupyter.org/) is a web-based interactive environment for writing and running code. The main building blocks of Jupyter are the file-browser, the notebook editor, and kernels. The file-browser provides an interactive file manager for all notebooks, files, and folders in the `/workspace` directory.

<img style="width: 100%" src="https://github.com/ml-tooling/ml-workspace/raw/main/docs/images/features/jupyter-tree.png"/>

A new notebook can be created by clicking on the `New` drop-down button at the top of the list and selecting the desired language kernel.

> _You can spawn interactive **terminal** instances as well by selecting `New -> Terminal` in the file-browser._

<img style="width: 100%" src="https://github.com/ml-tooling/ml-workspace/raw/main/docs/images/features/jupyter-notebook.png"/>

The notebook editor enables users to author documents that include live code, markdown text, shell commands, LaTeX equations, interactive widgets, plots, and images. These notebook documents provide a complete and self-contained record of a computation that can be converted to various formats and shared with others.

> _This workspace has a variety of **third-party Jupyter extensions** activated. You can configure these extensions in the nbextensions configurator: `nbextensions` tab on the file browser_

The Notebook allows code to be run in a range of different programming languages. For each notebook document that a user opens, the web application starts a **kernel** that runs the code for that notebook and returns output. This workspace has a Python 3 kernel pre-installed. Additional Kernels can be installed to get access to other languages (e.g., R, Scala, Go) or additional computing resources (e.g., GPUs, CPUs, Memory).

> _**Python 2** is deprected and we do not recommend to use it. However, you can still install a Python 2.7 kernel via this command: `/bin/bash /resources/tools/python-27.sh`_

### Desktop GUI

This workspace provides an HTTP-based VNC access to the workspace via [noVNC](https://github.com/novnc/noVNC). Thereby, you can access and work within the workspace with a fully-featured desktop GUI. To access this desktop GUI, go to `Open Tool`, select `VNC`, and click the `Connect` button. In the case you are asked for a password, use `vncpassword`.

<img style="width: 100%" src="https://github.com/ml-tooling/ml-workspace/raw/main/docs/images/features/desktop-vnc.png"/>

Once you are connected, you will see a desktop GUI that allows you to install and use full-fledged web-browsers or any other tool that is available for Ubuntu. Within the `Tools` folder on the desktop, you will find a collection of install scripts that makes it straightforward to install some of the most commonly used development tools, such as Atom, PyCharm, R-Runtime, R-Studio, or Postman (just double-click on the script).

**Clipboard:** If you want to share the clipboard between your machine and the workspace, you can use the copy-paste functionality as described below:

<img style="width: 100%" src="https://github.com/ml-tooling/ml-workspace/raw/main/docs/images/features/desktop-vnc-clipboard.png"/>

> 💡 _**Long-running tasks:** Use the desktop GUI for long-running Jupyter executions. By running notebooks from the browser of your workspace desktop GUI, all output will be synchronized to the notebook even if you have disconnected your browser from the notebook._

### Visual Studio Code

[Visual Studio Code](https://github.com/microsoft/vscode) (`Open Tool -> VS Code`) is an open-source lightweight but powerful code editor with built-in support for a variety of languages and a rich ecosystem of extensions. It combines the simplicity of a source code editor with powerful developer tooling, like IntelliSense code completion and debugging. The workspace integrates VS Code as a web-based application accessible through the browser-based on the awesome [code-server](https://github.com/cdr/code-server) project. It allows you to customize every feature to your liking and install any number of third-party extensions.

<p align="center"><img src="https://github.com/ml-tooling/ml-workspace/raw/main/docs/images/features/vs-code.png"/></p>

The workspace also provides a VS Code integration into Jupyter allowing you to open a VS Code instance for any selected folder, as shown below:

<p align="center"><img src="https://github.com/ml-tooling/ml-workspace/raw/main/docs/images/features/vs-code-open.png"/></p>

### JupyterLab

[JupyterLab](https://github.com/jupyterlab/jupyterlab) (`Open Tool -> JupyterLab`) is the next-generation user interface for Project Jupyter. It offers all the familiar building blocks of the classic Jupyter Notebook (notebook, terminal, text editor, file browser, rich outputs, etc.) in a flexible and powerful user interface. This JupyterLab instance comes pre-installed with a few helpful extensions such as a the [jupyterlab-toc](https://github.com/jupyterlab/jupyterlab-toc), [jupyterlab-git](https://github.com/jupyterlab/jupyterlab-git), and [juptyterlab-tensorboard](https://github.com/chaoleili/jupyterlab_tensorboard).

<img style="width: 100%" src="https://github.com/ml-tooling/ml-workspace/raw/main/docs/images/features/jupyterlab.png"/>

### Git Integration

Version control is a crucial aspect of productive collaboration. To make this process as smooth as possible, we have integrated a custom-made Jupyter extension specialized on pushing single notebooks, a full-fledged web-based Git client ([ungit](https://github.com/FredrikNoren/ungit)), a tool to open and edit plain text documents (e.g., `.py`, `.md`) as notebooks ([jupytext](https://github.com/mwouts/jupytext)), as well as a notebook merging tool ([nbdime](https://github.com/jupyter/nbdime)). Additionally, JupyterLab and VS Code also provide GUI-based Git clients.

#### Clone Repository

For cloning repositories via `https`, we recommend to navigate to the desired root folder and to click on the `git` button as shown below:

<img style="width: 100%" src="https://github.com/ml-tooling/ml-workspace/raw/main/docs/images/features/git-open.png"/>

This might ask for some required settings and, subsequently, opens [ungit](https://github.com/FredrikNoren/ungit), a web-based Git client with a clean and intuitive UI that makes it convenient to sync your code artifacts. Within ungit, you can clone any repository. If authentication is required, you will get asked for your credentials.

<img style="width: 100%" src="https://github.com/ml-tooling/ml-workspace/raw/main/docs/images/features/git-ungit-credentials.png"/>

#### Push, Pull, Merge, and Other Git Actions

To commit and push a single notebook to a remote Git repository, we recommend to use the Git plugin integrated into Jupyter, as shown below:

<img style="width: 100%" src="https://github.com/ml-tooling/ml-workspace/raw/main/docs/images/features/git-push-notebook.png"/>

For more advanced Git operations, we recommend to use [ungit](https://github.com/FredrikNoren/ungit). With ungit, you can do most of the common git actions such as push, pull, merge, branch, tag, checkout, and many more.

#### Diffing and Merging Notebooks

Jupyter notebooks are great, but they often are huge files, with a very specific JSON file format. To enable seamless diffing and merging via Git this workspace is pre-installed with [nbdime](https://github.com/jupyter/nbdime). Nbdime understands the structure of notebook documents and, therefore, automatically makes intelligent decisions when diffing and merging notebooks. In the case you have merge conflicts, nbdime will make sure that the notebook is still readable by Jupyter, as shown below:

<img style="width: 100%" src="https://github.com/ml-tooling/ml-workspace/raw/main/docs/images/features/git-nbdime-merging.png"/>

Furthermore, the workspace comes pre-installed with [jupytext](https://github.com/mwouts/jupytext), a Jupyter plugin that reads and writes notebooks as plain text files. This allows you to open, edit, and run scripts or markdown files (e.g., `.py`, `.md`) as notebooks within Jupyter. In the following screenshot, we have opened a markdown file via Jupyter:

<img style="width: 100%" src="https://github.com/ml-tooling/ml-workspace/raw/main/docs/images/features/git-jupytext.png"/>

In combination with Git, jupytext enables a clear diff history and easy merging of version conflicts. With both of those tools, collaborating on Jupyter notebooks with Git becomes straightforward.

### File Sharing

The workspace has a feature to share any file or folder with anyone via a token-protected link. To share data via a link, select any file or folder from the Jupyter directory tree and click on the share button as shown in the following screenshot:

<img style="width: 100%" src="https://github.com/ml-tooling/ml-workspace/raw/main/docs/images/features/file-sharing-open.png"/>

This will generate a unique link protected via a token that gives anyone with the link access to view and download the selected data via the [Filebrowser](https://github.com/filebrowser/filebrowser) UI:

<img style="width: 100%" src="https://github.com/ml-tooling/ml-workspace/raw/main/docs/images/features/file-sharing-filebrowser.png"/>

To deactivate or manage (e.g., provide edit permissions) shared links, open the Filebrowser via `Open Tool -> Filebrowser` and select `Settings->User Management`.

### Access Ports

It is possible to securely access any workspace internal port by selecting `Open Tool -> Access Port`. With this feature, you are able to access a REST API or web application running inside the workspace directly with your browser. The feature enables developers  to build, run, test, and debug REST APIs or web applications directly from the workspace.

<img style="width: 100%" src="https://github.com/ml-tooling/ml-workspace/raw/main/docs/images/features/access-port.png"/>

If you want to use an HTTP client or share access to a given port, you can select the `Get shareable link` option. This generates a token-secured link that anyone with access to the link can use to access the specified port.

> _The HTTP app requires to be resolved from a relative URL path or configure a base path (`/tools/PORT/`). Tools made accessible this way are secured by the workspace's authentication system! If you decide to publish any other port of the container yourself instead of using this feature to make a tool accessible, please make sure to secure it via an authentication mechanism!_

<details>

<summary>Example (click to expand...)</summary>

1. Start an HTTP server on port `1234` by running this command in a terminal within the workspace: `python -m http.server 1234`
2. Select `Open Tool -> Access Port`, input port `1234`, and select the `Get shareable link` option.
3. Click `Access`, and you will see the content provided by Python's `http.server`.
4. The opened link can also be shared to other people or called from external applications (e.g., try with Incognito Mode in Chrome).

</details>

### SSH Access

SSH provides a powerful set of features that enables you to be more productive with your development tasks. You can easily set up a secure and passwordless SSH connection to a workspace by selecting `Open Tool -> SSH`. This will generate a secure setup command that can be run on any Linux or Mac machine to configure a passwordless & secure SSH connection to the workspace. Alternatively, you can also download the setup script and run it (instead of using the command).

<img style="width: 100%" src="https://github.com/ml-tooling/ml-workspace/raw/main/docs/images/features/ssh-access.png"/>

> _The setup script only runs on Mac and Linux. Windows is currently not supported._

Just run the setup command or script on the machine from where you want to setup a connection to the workspace and input a name for the connection (e.g., `my-workspace`). You might also get asked for some additional input during the process, e.g. to install a remote kernel if `remote_ikernel` is installed. Once the passwordless SSH connection is successfully setup and tested, you can securely connect to the workspace by simply executing `ssh my-workspace`.

Besides the ability to execute commands on a remote machine, SSH also provides a variety of other features that can improve your development workflow as described in the following sections.

<details>
<summary><b>Tunnel Ports</b> (click to expand...)</summary>

An SSH connection can be used for tunneling application ports from the remote machine to the local machine, or vice versa. For example, you can expose the workspace internal port `5901` (VNC Server) to the local machine on port `5000` by executing:

```bash
ssh -nNT -L 5000:localhost:5901 my-workspace
```

> _To expose an application port from your local machine to a workspace, use the `-R` option (instead of `-L`)._

After the tunnel is established, you can use your favorite VNC viewer on your local machine and connect to `vnc://localhost:5000` (default password: `vncpassword`). To make the tunnel connection more resistant and reliable, we recommend to use [autossh](https://www.harding.motd.ca/autossh/) to automatically restart SSH tunnels in the case that the connection dies:

```bash
autossh -M 0 -f -nNT -L 5000:localhost:5901 my-workspace
```

Port tunneling is quite useful when you have started any server-based tool within the workspace that you like to make accessible for another machine. In its default setting, the workspace has a variety of tools already running on different ports, such as:

- `8080`: Main workspace port with access to all integrated tools.
- `8090`: Jupyter server.
- `8054`: VS Code server.
- `5901`: VNC server.
- `3389`: RDP server.
- `22`: SSH server.

You can find port information on all the tools in the [supervisor configuration](https://github.com/ml-tooling/ml-workspace/blob/main/resources/supervisor/supervisord.conf).

> 📖 _For more information about port tunneling/forwarding, we recommend [this guide](https://www.everythingcli.org/ssh-tunnelling-for-fun-and-profit-local-vs-remote/)._

</details>

<details>
<summary><b>Copy Data via SCP</b> (click to expand...)</summary>

[SCP](https://linux.die.net/man/1/scp) allows files and directories to be securely copied to, from, or between different machines via SSH connections. For example, to copy a local file (`./local-file.txt`) into the `/workspace` folder inside the workspace, execute:

```bash
scp ./local-file.txt my-workspace:/workspace
```

To copy the `/workspace` directory from `my-workspace` to the working directory of the local machine, execute:

```bash
scp -r my-workspace:/workspace .
```

> 📖 _For more information about scp, we recommend [this guide](https://www.garron.me/en/articles/scp.html)._
</details>

<details>
<summary><b>Sync Data via Rsync</b> (click to expand...)</summary>

[Rsync](https://linux.die.net/man/1/rsync) is a utility for efficiently transferring and synchronizing files between different machines (e.g., via SSH connections) by comparing the modification times and sizes of files. The rsync command will determine which files need to be updated each time it is run, which is far more efficient and convenient than using something like scp or sftp. For example, to sync all content of a local folder (`./local-project-folder/`) into the `/workspace/remote-project-folder/` folder inside the workspace, execute:

```bash
rsync -rlptzvP --delete --exclude=".git" "./local-project-folder/" "my-workspace:/workspace/remote-project-folder/"
```

If you have some changes inside the folder on the workspace, you can sync those changes back to the local folder by changing the source and destination arguments:

```bash
rsync -rlptzvP --delete --exclude=".git" "my-workspace:/workspace/remote-project-folder/" "./local-project-folder/"
```

You can rerun these commands each time you want to synchronize the latest copy of your files. Rsync will make sure that only updates will be transferred.

> 📖 _You can find more information about rsync on [this man page](https://linux.die.net/man/1/rsync)._
</details>

<details>
<summary><b>Mount Folders via SSHFS</b> (click to expand...)</summary>

Besides copying and syncing data, an SSH connection can also be used to mount directories from a remote machine into the local filesystem via [SSHFS](https://github.com/libfuse/sshfs). 
For example, to mount the `/workspace` directory of `my-workspace` into a local path (e.g. `/local/folder/path`), execute:

```bash
sshfs -o reconnect my-workspace:/workspace /local/folder/path
```

Once the remote directory is mounted, you can interact with the remote file system the same way as with any local directory and file.

> 📖 _For more information about sshfs, we recommend [this guide](https://www.digitalocean.com/community/tutorials/how-to-use-sshfs-to-mount-remote-file-systems-over-ssh)._
</details>

### Remote Development

The workspace can be integrated and used as a remote runtime (also known as remote kernel/machine/interpreter) for a variety of popular development tools and IDEs, such as Jupyter, VS Code, PyCharm, Colab, or Atom Hydrogen. Thereby, you can connect your favorite development tool running on your local machine to a remote machine for code execution. This enables a local-quality development experience with remote-hosted compute resources.

These integrations usually require a passwordless SSH connection from the local machine to the workspace. To set up an SSH connection, please follow the steps explained in the [SSH Access](#ssh-access) section.

<details>
<summary><b>Jupyter - Remote Kernel</b> (click to expand...)</summary>

The workspace can be added to a Jupyter instance as a remote kernel by using the [remote_ikernel](https://bitbucket.org/tdaff/remote_ikernel/) tool. If you have installed remote_ikernel (`pip install remote_ikernel`) on your local machine, the SSH setup script of the workspace will automatically offer you the option to setup a remote kernel connection.

> _When running kernels on remote machines, the notebooks themselves will be saved onto the local filesystem, but the kernel will only have access to the filesystem of the remote machine running the kernel. If you need to sync data, you can make use of rsync, scp, or sshfs as explained in the [SSH Access](#ssh-access) section._

In case you want to manually setup and manage remote kernels, use the [remote_ikernel](https://bitbucket.org/tdaff/remote_ikernel/src/default/README.rst) command-line tool, as shown below:

```bash
# Change my-workspace with the name of a workspace SSH connection
remote_ikernel manage --add \
    --interface=ssh \
    --kernel_cmd="ipython kernel -f {connection_file}" \
    --name="ml-server (Python)" \
    --host="my-workspace"
```

You can use the remote_ikernel command line functionality to list (`remote_ikernel manage --show`) or delete (`remote_ikernel manage --delete <REMOTE_KERNEL_NAME>`) remote kernel connections.

<img style="width: 100%" src="https://github.com/ml-tooling/ml-workspace/raw/main/docs/images/features/remote-dev-jupyter-kernel.png"/>

</details>

<details>
<summary><b>VS Code - Remote Machine</b> (click to expand...)</summary>

The Visual Studio Code [Remote - SSH](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-ssh) extension allows you to open a remote folder on any remote machine with SSH access and work with it just as you would if the folder were on your own machine. Once connected to a remote machine, you can interact with files and folders anywhere on the remote filesystem and take full advantage of VS Code's feature set (IntelliSense, debugging, and extension support). The discovers and works out-of-the-box with passwordless SSH connections as configured by the workspace SSH setup script. To enable your local VS Code application to connect to a workspace:

1. Install [Remote - SSH](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-ssh) extension inside your local VS Code.
2. Run the SSH setup script of a selected workspace as explained in the [SSH Access](#ssh-access) section.
3. Open the Remote-SSH panel in your local VS Code. All configured SSH connections should be automatically discovered. Just select any configured workspace connection you like to connect to as shown below:

<img style="width: 100%" src="https://github.com/ml-tooling/ml-workspace/raw/main/docs/images/features/remote-dev-vscode.gif"/>

> 📖 _You can find additional features and information about the Remote SSH extension in [this guide](https://code.visualstudio.com/docs/remote/ssh)._

</details>

### Tensorboard

[Tensorboard](https://www.tensorflow.org/tensorboard) provides a suite of visualization tools to make it easier to understand, debug, and optimize your experiment runs. It includes logging features for scalar, histogram, model structure, embeddings, and text & image visualization. The workspace comes pre-installed with [jupyter_tensorboard extension](https://github.com/lspvic/jupyter_tensorboard) that integrates Tensorboard into the Jupyter interface with functionalities to start, manage, and stop instances. You can open a new instance for a valid logs directory, as shown below:

<img style="width: 100%" src="https://github.com/ml-tooling/ml-workspace/raw/main/docs/images/features/tensorboard-open.png" />

If you have opened a Tensorboard instance in a valid log directory, you will see the visualizations of your logged data:

<img style="width: 100%" src="https://github.com/ml-tooling/ml-workspace/raw/main/docs/images/features/tensorboard-dashboard.png" />

> _Tensorboard can be used in combination with many other ML frameworks besides Tensorflow. By using the [tensorboardX](https://github.com/lanpa/tensorboardX) library you can log basically from any python based library. Also, PyTorch has a direct Tensorboard integration as described [here](https://pytorch.org/docs/stable/tensorboard.html)._

If you prefer to see the tensorboard directly within your notebook, you can make use of following **Jupyter magic**:

```
%load_ext tensorboard
%tensorboard --logdir /workspace/path/to/logs
```

### Hardware Monitoring

The workspace provides two pre-installed web-based tools to help developers during model training and other experimentation tasks to get insights into everything happening on the system and figure out performance bottlenecks.

[Netdata](https://github.com/netdata/netdata) (`Open Tool -> Netdata`) is a real-time hardware and performance monitoring dashboard that visualize the processes and services on your Linux systems. It monitors metrics about CPU, GPU, memory, disks, networks, processes, and more.

<img style="width: 100%" src="https://github.com/ml-tooling/ml-workspace/raw/main/docs/images/features/hardware-monitoring-netdata.png" />

[Glances](https://github.com/nicolargo/glances) (`Open Tool -> Glances`) is a web-based hardware monitoring dashboard as well and can be used as an alternative to Netdata.

<img style="width: 100%" src="https://github.com/ml-tooling/ml-workspace/raw/main/docs/images/features/hardware-monitoring-glances.png"/>

> _Netdata and Glances will show you the hardware statistics for the entire machine on which the workspace container is running._

### Run as a job

> _A job is defined as any computational task that runs for a certain time to completion, such as a model training or a data pipeline._

The workspace image can also be used to execute arbitrary Python code without starting any of the pre-installed tools. This provides a seamless way to productize your ML projects since the code that has been developed interactively within the workspace will have the same environment and configuration when run as a job via the same workspace image.

<details>
<summary><b>Run Python code as a job via the workspace image</b> (click to expand...)</summary>

To run Python code as a job, you need to provide a path or URL to a code directory (or script) via `EXECUTE_CODE`. The code can be either already mounted into the workspace container or downloaded from a version control system (e.g., git or svn) as described in the following sections. The selected code path needs to be python executable. In case the selected code is a directory (e.g., whenever you download the code from a VCS) you need to put a `__main__.py` file at the root of this directory. The `__main__.py` needs to contain the code that starts your job.

#### Run code from version control system

You can execute code directly from Git, Mercurial, Subversion, or Bazaar by using the pip-vcs format as described in [this guide](https://pip.pypa.io/en/stable/reference/pip_install/#vcs-support). For example, to execute code from a [subdirectory](https://github.com/ml-tooling/ml-workspace/tree/main/resources/tests/ml-job) of a git repository, just run:

```bash
docker run --env EXECUTE_CODE="git+https://github.com/ml-tooling/ml-workspace.git#subdirectory=resources/tests/ml-job" mltooling/ml-workspace:0.12.1
```

> 📖 _For additional information on how to specify branches, commits, or tags please refer to [this guide](https://pip.pypa.io/en/stable/reference/pip_install/#vcs-support)._

#### Run code mounted into the workspace

In the following example, we mount and execute the current working directory (expected to contain our code) into the `/workspace/ml-job/` directory of the workspace:

```bash
docker run -v "${PWD}:/workspace/ml-job/" --env EXECUTE_CODE="/workspace/ml-job/" mltooling/ml-workspace:0.12.1
```

#### Install Dependencies

In the case that the pre-installed workspace libraries are not compatible with your code, you can install or change dependencies by just adding one or multiple of the following files to your code directory:

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
FROM mltooling/ml-workspace:0.12.1

# Add job code to image
COPY ml-job /workspace/ml-job
ENV EXECUTE_CODE=/workspace/ml-job

# Install requirements only
RUN python /resources/scripts/execute_code.py --requirements-only

# Execute only the code at container startup
CMD ["python", "/resources/docker-entrypoint.py", "--code-only"]
```

</details>

### Pre-installed Libraries and Interpreters

The workspace is pre-installed with many popular interpreters, data science libraries, and ubuntu packages:

- **Interpreter:** Python 3.8 (Miniconda 3), Java 11 (OpenJDK), NodeJS 14, Scala, Perl 5
- **Python libraries:** Tensorflow, Keras, Pytorch, Sklearn, XGBoost, MXNet, Theano, and [many more](https://github.com/ml-tooling/ml-workspace/tree/main/resources/libraries)
- **Package Manager:** `conda`, `pip`, `apt-get`, `npm`, `yarn`, `sdk`, `poetry`, `gdebi`, `mvn` ...  

The full list of installed tools can be found within the [Dockerfile](https://github.com/ml-tooling/ml-workspace/blob/main/Dockerfile).

> _For every minor version release, we run vulnerability, virus, and security checks within the workspace using [safety](https://pyup.io/safety/), [clamav](https://www.clamav.net/), [trivy](https://github.com/aquasecurity/trivy), and [snyk via docker scan](https://docs.docker.com/engine/scan/) to make sure that the workspace environment is as secure as possible. We are committed to fix and prevent all high- or critical-severity vulnerabilities. You can find some up-to-date reports [here](https://github.com/ml-tooling/ml-workspace/tree/main/resources/reports)._

### Extensibility

The workspace provides a high degree of extensibility. Within the workspace, you have **full root & sudo privileges** to install any library or tool you need via terminal (e.g., `pip`, `apt-get`, `conda`, or `npm`). You can open a terminal by one of the following ways:

- **Jupyter:** `New -> Terminal`
- **Desktop VNC:** `Applications -> Terminal Emulator`
- **JupyterLab:** `File -> New -> Terminal`
- **VS Code:** `Terminal -> New Terminal`

Additionally, pre-installed tools such as Jupyter, JupyterLab, and Visual Studio Code each provide their own rich ecosystem of extensions. The workspace also contains a [collection of installer scripts](https://github.com/ml-tooling/ml-workspace/tree/main/resources/tools) for many commonly used development tools or libraries (e.g., `PyCharm`, `Zeppelin`, `RStudio`, `Starspace`). You can find and execute all tool installers via `Open Tool -> Install Tool`. Those scripts can be also executed from the Desktop VNC (double-click on the script within the `Tools` folder on the Desktop VNC).

<details>
<summary>Example (click to expand...)</summary>

For example, to install the [Apache Zeppelin](https://zeppelin.apache.org/) notebook server, simply execute:

```bash
/resources/tools/zeppelin.sh --port=1234
```

After installation, refresh the Jupyter website and the Zeppelin tool will be available under `Open Tool -> Zeppelin`. Other tools might only be available within the Desktop VNC (e.g., `atom` or `pycharm`) or do not provide any UI (e.g., `starspace`, `docker-client`).
</details>

As an alternative to extending the workspace at runtime, you can also customize the workspace Docker image to create your own flavor as explained in the [FAQ](#faq) section.

---

<br>

## FAQ

<details>
<summary><b>How to customize the workspace image (create your own flavor)?</b> (click to expand...)</summary>

The workspace can be extended in many ways at runtime, as explained [here](#extensibility). However, if you like to customize the workspace image with your own software or configuration, you can do that via a Dockerfile as shown below:

```dockerfile
# Extend from any of the workspace versions/flavors
FROM mltooling/ml-workspace:0.12.1

# Run you customizations, e.g.
RUN \
    # Install r-runtime, r-kernel, and r-studio web server from provided install scripts
    /bin/bash $RESOURCES_PATH/tools/r-runtime.sh --install && \
    /bin/bash $RESOURCES_PATH/tools/r-studio-server.sh --install && \
    # Cleanup Layer - removes unneccessary cache files
    clean-layer.sh
```

Finally, use [docker build](https://docs.docker.com/engine/reference/commandline/build/) to build your customized Docker image.

> 📖 _For a more comprehensive Dockerfile example, take a look at the [Dockerfile of the R-flavor](https://github.com/ml-tooling/ml-workspace/blob/main/r-flavor/Dockerfile)._

</details>

<details>
<summary><b>How to update a running workspace container?</b> (click to expand...)</summary>

To update a running workspace instance to a more recent version, the running Docker container needs to be replaced with a new container based on the updated workspace image.

All data within the workspace that is not persisted to a mounted volume will be lost during this update process. As mentioned in the [persist data](#Persist-Data) section, a volume is expected to be mounted into the `/workspace` folder. All tools within the workspace are configured to make use of the `/workspace` folder as the root directory for all source code and data artifacts. During an update, data within other directories will be removed, including installed/updated libraries or certain machine configurations. We have integrated a backup and restore feature (`CONFIG_BACKUP_ENABLED`) for various selected configuration files/folders, such as the user's Jupyter/VS-Code configuration, `~/.gitconfig`, and `~/.ssh`.

<details>

<summary>Update Example (click to expand...)</summary>

If the workspace is deployed via Docker (Kubernetes will have a different update process), you need to remove the existing container (via `docker rm`) and start a new one (via `docker run`) with the newer workspace image. Make sure to use the same configuration, volume, name, and port. For example, a workspace (image version `0.8.7`) was started with this command:
```
docker run -d \
    -p 8080:8080 \
    --name "ml-workspace" \
    -v "/path/on/host:/workspace" \
    --env AUTHENTICATE_VIA_JUPYTER="mytoken" \
    --restart always \
    mltooling/ml-workspace:0.8.7
```
and needs to be updated to version `0.9.1`, you need to:

1. Stop and remove the running workspace container: `docker stop "ml-workspace" && docker rm "ml-workspace"`
2. Start a new workspace container with the newer image and same configuration: `docker run -d -p 8080:8080 --name "ml-workspace" -v "/path/on/host:/workspace" --env AUTHENTICATE_VIA_JUPYTER="mytoken" --restart always mltooling/ml-workspace:0.9.1`

</details>

</details>

<details>
<summary><b>How to configure the VNC server?</b> (click to expand...)</summary>

If you want to directly connect to the workspace via a VNC client (not using the [noVNC webapp](#desktop-gui)), you might be interested in changing certain VNC server configurations. To configure the VNC server, you can provide/overwrite the following environment variables at container start (via docker run option: `--env`):

<table>
    <tr>
        <th>Variable</th>
        <th>Description</th>
        <th>Default</th>
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

</details>

<details>
<summary><b>How to use a non-root user within the workspace?</b> (click to expand...)</summary>

Unfortunately, we currently do not support using a non-root user within the workspace. We plan to provide this capability and already started with some refactoring to allow this configuration. However, this still requires a lot more work, refactoring, and testing from our side.

Using root-user (or users with sudo permission) within containers is generally not recommended since, in case of system/kernel vulnerabilities, a user might be able to break out of the container and be able to access the host system. Since it is not very common to have such problematic kernel vulnerabilities, the risk of a severe attack is quite minimal. As explained in the [official Docker documentation](https://docs.docker.com/engine/security/security/#linux-kernel-capabilities), containers (even with root users) are generally quite secure in preventing a breakout to the host. And compared to many other container use-cases, we actually want to provide the flexibility to the user to have control and system-level installation permissions within the workspace container.

</details>

<details>
<summary><b>How to create and use a virtual environment?</b> (click to expand...)</summary>

The workspace comes preinstalled with various common tools to create isolated Python environments (virtual environments). The following sections provide a quick-intro on how to use these tools within the workspace. You can find information on when to use which tool [here](https://stackoverflow.com/a/41573588). Please refer to the documentation of the given tool for additional usage information.

**venv** (recommended):

To create a virtual environment via [venv](https://docs.python.org/3/tutorial/venv.html), execute the following commands:

```bash
# Create environment in the working directory
python -m venv my-venv
# Activate environment in shell
source ./my-venv/bin/activate
# Optional: Create Jupyter kernel for this environment
pip install ipykernel
python -m ipykernel install --user --name=my-venv --display-name="my-venv ($(python --version))"
# Optional: Close enviornment session
deactivate
```

**pipenv** (recommended):

To create a virtual environment via [pipenv](https://pipenv.pypa.io/en/latest/), execute the following commands:

```bash
# Create environment in the working directory
pipenv install
# Activate environment session in shell
pipenv shell
# Optional: Create Jupyter kernel for this environment
pipenv install ipykernel
python -m ipykernel install --user --name=my-pipenv --display-name="my-pipenv ($(python --version))"
# Optional: Close environment session
exit
```

**virtualenv**:

To create a virtual environment via [virtualenv](https://virtualenv.pypa.io/en/latest/), execute the following commands:

```bash
# Create environment in the working directory
virtualenv my-virtualenv
# Activate environment session in shell
source ./my-virtualenv/bin/activate
# Optional: Create Jupyter kernel for this environment
pip install ipykernel
python -m ipykernel install --user --name=my-virtualenv --display-name="my-virtualenv ($(python --version))"
# Optional: Close environment session
deactivate
```

**conda**:

To create a virtual environment via [conda](https://docs.conda.io/projects/conda/en/latest/user-guide/tasks/manage-environments.html), execute the following commands:

```bash
# Create environment (globally)
conda create -n my-conda-env
# Activate environment session in shell
conda activate my-conda-env
# Optional: Create Jupyter kernel for this environment
python -m ipykernel install --user --name=my-conda-env --display-name="my-conda-env ($(python --version))"
# Optional: Close environment session
conda deactivate
```

**Tip: Shell Commands in Jupyter Notebooks:**

If you install and use a virtual environment via a dedicated Jupyter Kernel and use shell commands within Jupyter (e.g. `!pip install matplotlib`), the wrong python/pip version will be used. To use the python/pip version of the selected kernel, do the following instead:

```python
import sys
!{sys.executable} -m pip install matplotlib
```

</details>

<details>
<summary><b>How to install a different Python version?</b> (click to expand...)</summary>

The workspace provides three easy options to install different Python versions alongside the main Python instance: [pyenv](https://github.com/pyenv/pyenv), [pipenv](https://pipenv.pypa.io/en/latest/cli/) (recommended), [conda](https://github.com/pyenv/pyenv).

**pipenv** (recommended):

To install a different python version (e.g. `3.7.8`) within the workspace via [pipenv](https://pipenv.pypa.io/en/latest/cli/), execute the following commands:

```bash
# Install python vers
pipenv install --python=3.7.8
# Activate environment session in shell
pipenv shell
# Check python installation
python --version
# Optional: Create Jupyter kernel for this environment
pipenv install ipykernel
python -m ipykernel install --user --name=my-pipenv --display-name="my-pipenv ($(python --version))"
# Optional: Close environment session
exit
```

**pyenv**:

To install a different python version (e.g. `3.7.8`) within the workspace via [pyenv](https://github.com/pyenv/pyenv), execute the following commands:

```bash
# Install python version
pyenv install 3.7.8
# Make globally accessible
pyenv global 3.7.8
# Activate python version in shell
pyenv shell 3.7.8
# Check python installation
python3.7 --version
# Optional: Create Jupyter kernel for this python version
python3.7 -m pip install ipykernel
python3.7 -m ipykernel install --user --name=my-pyenv-3.7.8 --display-name="my-pyenv (Python 3.7.8)"
```

**conda**:

To install a different python version (e.g. `3.7.8`) within the workspace via [conda](https://github.com/pyenv/pyenv), execute the following commands:

```bash
# Create environment with python version
conda create -n my-conda-3.7 python=3.7.8
# Activate environment session in shell
conda activate my-conda-3.7
# Check python installation
python --version
# Optional: Create Jupyter kernel for this python version
pip install ipykernel
python -m ipykernel install --user --name=my-conda-3.7 --display-name="my-conda ($(python --version))"
# Optional: Close environment session
conda deactivate
```

**Tip: Shell Commands in Jupyter Notebooks:**

If you install and use another Python version via a dedicated Jupyter Kernel and use shell commands within Jupyter (e.g. `!pip install matplotlib`), the wrong python/pip version will be used. To use the python/pip version of the selected kernel, do the following instead:

```python
import sys
!{sys.executable} -m pip install matplotlib
```

</details>

<details>
<summary><b>Can I publish any other than the default port to access a tool inside the container?</b> (click to expand...)</summary>
You can do this, but please be aware that this port is <b>not</b> protected by the workspace's authentication mechanism then! For security reasons, we therefore highly recommend to use the <a href="#access-ports">Access Ports</a> functionality of the workspace.
</details>

---

<br>

## Known Issues

<details>

<summary><b>Too small shared memory might crash tools or scripts</b> (click to expand...)</summary>

Certain desktop tools (e.g., recent versions of [Firefox](https://github.com/jlesage/docker-firefox#increasing-shared-memory-size)) or libraries (e.g., Pytorch - see Issues: [1](https://github.com/pytorch/pytorch/issues/2244), [2](https://github.com/pytorch/pytorch/issues/1355)) might crash if the shared memory size (`/dev/shm`) is too small. The default shared memory size of Docker is 64MB, which might not be enough for a few tools. You can provide a higher shared memory size via the `shm-size` docker run option:

```bash
docker run --shm-size=2G mltooling/ml-workspace:0.12.1
```

</details>

<details>

<summary><b>Multiprocessing code is unexpectedly slow </b> (click to expand...)</summary>

In general, the performance of running code within Docker is [nearly identical](https://stackoverflow.com/questions/21889053/what-is-the-runtime-performance-cost-of-a-docker-container) compared to running it directly on the machine. However, in case you have limited the container's CPU quota (as explained in [this section](#limit-memory--cpu)), the container can still see the full count of CPU cores available on the machine and there is no technical way to prevent this. Many libraries and tools will use the full CPU count (e.g., via `os.cpu_count()`) to set the number of threads used for multiprocessing/-threading. This might cause the program to start more threads/processes than it can efficiently handle with the available CPU quota, which can tremendously slow down the overall performance. Therefore, it is important to set the available CPU count or the maximum number of threads explicitly to the configured CPU quota. The workspace provides capabilities to detect the number of available CPUs automatically, which are used to configure a variety of common libraries via environment variables such as `OMP_NUM_THREADS` or `MKL_NUM_THREADS`. It is also possible to explicitly set the number of available CPUs at container startup via the `MAX_NUM_THREADS` environment variable (see [configuration section](https://github.com/ml-tooling/ml-workspace#configuration-options)). The same environment variable can also be used to get the number of available CPUs at runtime.

Even though the automatic configuration capabilities of the workspace will fix a variety of inefficiencies, we still recommend configuring the number of available CPUs with all libraries explicitly. For example:

```python
import os
MAX_NUM_THREADS = int(os.getenv("MAX_NUM_THREADS"))

# Set in pytorch
import torch
torch.set_num_threads(MAX_NUM_THREADS)

# Set in tensorflow
import tensorflow as tf
config = tf.ConfigProto(
    device_count={"CPU": MAX_NUM_THREADS},
    inter_op_parallelism_threads=MAX_NUM_THREADS,
    intra_op_parallelism_threads=MAX_NUM_THREADS,
)
tf_session = tf.Session(config=config)

# Set session for keras
import keras.backend as K
K.set_session(tf_session)

# Set in sklearn estimator
from sklearn.linear_model import LogisticRegression
LogisticRegression(n_jobs=MAX_NUM_THREADS).fit(X, y)

# Set for multiprocessing pool
from multiprocessing import Pool

with Pool(MAX_NUM_THREADS) as pool:
    results = pool.map(lst)
```

</details>

<details>

<summary><b>Nginx terminates with SIGILL core dumped error</b> (click to expand...)</summary>

If you encounter the following error within the container logs when starting the workspace, it will most likely not be possible to run the workspace on your hardware:

```
exited: nginx (terminated by SIGILL (core dumped); not expected)
```

The OpenResty/Nginx binary package used within the workspace requires to run on a CPU with `SSE4.2` support (see [this issue](https://github.com/openresty/openresty/issues/267#issuecomment-309296900)). Unfortunately, some older CPUs do not have support for `SSE4.2` and, therefore, will not be able to run the workspace container. On Linux, you can check if your CPU supports `SSE4.2` when looking into the `cat /proc/cpuinfo` flags section. If you encounter this problem, feel free to notify us by commenting on the following issue: [#30](https://github.com/ml-tooling/ml-workspace/issues/30).

</details>

---

<br>

## Contribution

- Pull requests are encouraged and always welcome. Read our [contribution guidelines](https://github.com/ml-tooling/ml-workspace/tree/main/CONTRIBUTING.md) and check out [help-wanted](https://github.com/ml-tooling/ml-workspace/issues?utf8=%E2%9C%93&q=is%3Aopen+is%3Aissue+label%3A"help+wanted"+sort%3Areactions-%2B1-desc+) issues.
- Submit Github issues for any [feature request and enhancement](https://github.com/ml-tooling/ml-workspace/issues/new?assignees=&labels=feature&template=02_feature-request.md&title=), [bugs](https://github.com/ml-tooling/ml-workspace/issues/new?assignees=&labels=bug&template=01_bug-report.md&title=), or [documentation](https://github.com/ml-tooling/ml-workspace/issues/new?assignees=&labels=documentation&template=03_documentation.md&title=) problems.
- By participating in this project, you agree to abide by its [Code of Conduct](https://github.com/ml-tooling/ml-workspace/blob/main/.github/CODE_OF_CONDUCT.md).
- The [development section](#development) below contains information on how to build and test the project after you have implemented some changes.

## Development

> _**Requirements**: [Docker](https://docs.docker.com/get-docker/) and [Act](https://github.com/nektos/act#installation) are required to be installed on your machine to execute the build process._

To simplify the process of building this project from scratch, we provide build-scripts - based on [universal-build](https://github.com/ml-tooling/universal-build) - that run all necessary steps (build, test, and release) within a containerized environment. To build and test your changes, execute the following command in the project root folder:

```bash
act -b -j build
```

Under the hood it uses the build.py files in this repo based on the [universal-build library](https://github.com/ml-tooling/universal-build). So, if you want to build it locally, you can also execute this command in the project root folder to build the docker container:

```bash
python build.py --make
```

For additional script options:

```bash
python build.py --help
```

Refer to our [contribution guides](https://github.com/ml-tooling/ml-workspace/blob/main/CONTRIBUTING.md#development-instructions) for more detailed information on our build scripts and development process.

---

Licensed **Apache 2.0**. Created and maintained with ❤️&nbsp; by developers from Berlin.
