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
  <a href="#-where-to-ask-questions">Support</a> •
  <a href="https://github.com/ml-tooling/ml-workspace/issues/new?labels=bug&template=01_bug-report.md">Report a Bug</a> •
  <a href="#contribution">Contribution</a>
</p>

The ML workspace is an all-in-one web-based IDE specialized for machine learning and data science. It is simple to deploy and gets you started within minutes to productively built ML solutions on your own machines. This workspace is the ultimate tool for developers preloaded with a variety of popular data science libraries (e.g., Tensorflow, PyTorch, Keras, Sklearn) and dev tools (e.g., Jupyter, VS Code, Tensorboard) perfectly configured, optimized, and integrated.

## Highlights

- 💫 Jupyter, JupyterLab, and Visual Studio Code web-based IDEs.
- 🗃 Pre-installed with many popular data science libraries & tools.
- 🖥 Full Linux desktop GUI accessible via web browser.
- 🔀 Seamless Git integration optimized for notebooks.
- 🚪 Access from anywhere via Web, SSH, or VNC under a single port.
- 🎛 Modular: Workspaces can be added to others as remote runtimes.
- 🐳 Easy to deploy on Mac, Linux, and Windows via Docker.

## Getting Started

### Prerequisites

The workspace requires **Docker** to be installed on your machine ([Installation Guide](https://docs.docker.com/install/#supported-platforms)).

> 📖 _If you are new to Docker, we recommend taking a look at [this awesome beginner guide](https://docker-curriculum.com/)._

### Start single instance

Deploying a single workspace instance is as simple as:

```bash
docker run -d -p 8091:8091 --restart always mltooling/ml-workspace:latest
```

Voilà, that was easy! Now, Docker will pull the latest workspace image to your machine. This may take a few minutes, depending on your internet speed. Once the workspace is started, you can access it via: http://localhost:8091. 

> ℹ️ _If started on a remote machine or with a different port, make sure to use the machines IP/DNS and/or the exposed port._

### Persist Data

To persist the data, you need to mount a volume into `/workspace`.

### Configuration

The container can be configured with following environment variables (`--env`):

<table>
    <tr>
        <th>Variable</th>
        <th>Description</th>
        <th>Default</th>
    </tr>
    <tr>
        <td>WORKSPACE_BASE_URL</td>
        <td>The base URL under which the notebook server is reachable. E.g. setting it to /my-workspace, the workspace would be reachable under /my-workspace/tree.</td>
        <td>/</td>
    </tr>
    <tr>
        <td>WORKSPACE_CONFIG_BACKUP</td>
        <td>Automatically backup and restore user configuration to the persisted /workspace folder, such as the .ssh, .jupyter, or .gitconfig from the users home directory.</td>
        <td>true</td>
    </tr>
    <tr>
        <td>WORKSPACE_AUTH_USER</td>
        <td>Basic auth user name. To enable basic auth, both the user and password needs to be set.</td>
        <td></td>
    </tr>
    <tr>
        <td>WORKSPACE_AUTH_PASSWORD</td>
        <td>Basic auth user password. To enable basic auth, both the user and password needs to be set.</td>
        <td></td>
    </tr>
    <tr>
        <td>WORKSPACE_SSL_ENABLED</td>
        <td>Enable or disable SSL. When set to true, either certificates (cert.crt) must be mounted to /resources/ssl or, if not, the container generates self-signed certificates.</td>
        <td>false</td>
    </tr>
    <tr>
        <td colspan="3"><b>Jupyter Configuration:</b></td>
    </tr>
    <tr>
        <td>NOTEBOOK_ARGS</td>
        <td>Add and overwrite Jupyter configuration options via command line args. Refer to <a href="https://jupyter-notebook.readthedocs.io/en/stable/config.html">this overview</a> for all options.</td>
        <td></td>
    </tr>
    <tr>
        <td colspan="3"><b>Hardware Optimization:</b></td>
    </tr>
    <tr>
        <td>OMP_NUM_THREADS</td>
        <td>Number of threads used for MKL computations.</td>
        <td>8</td>
    </tr>
    <tr>
        <td colspan="3"><b>VNC Configuration:</b></td>
    </tr>
    <tr>
        <td>VNC_PW</td>
        <td>Password of VNC Connection.</td>
        <td>vncpassword</td>
    </tr>
    <tr>
        <td>VNC_RESOLUTION</td>
        <td>Desktop Resolution of VNC Connection.</td>
        <td>1600x900</td>
    </tr>
    <tr>
        <td>VNC_COL_DEPTH</td>
        <td>Color Depth of VNC Connection.</td>
        <td>24</td>
    </tr>
</table>

_WIP_ Add Examples

### Run multiple instances

_WIP_

## 💬 Where to ask questions

The ML Workspace project is maintained by [@LukasMasuch](https://twitter.com/LukasMasuch)
and [@raethlein](https://twitter.com/raethlein). Please understand that we won't be able
to provide individual support via email. We also believe that help is much more
valuable if it's shared publicly, so that more people can benefit from it.

| Type                     | Channel                                              |
| ------------------------ | ------------------------------------------------------ |
| 🚨 **Bug Reports**       | <a href="https://github.com/ml-tooling/ml-workspace/issues?utf8=%E2%9C%93&q=is%3Aopen+is%3Aissue+label%3Abug+sort%3Areactions-%2B1-desc+" title="Open Bug Report"><img src="https://img.shields.io/github/issues/ml-tooling/ml-workspace/bug.svg"></a>                                 |
| 🎁 **Feature Requests**  | <a href="https://github.com/ml-tooling/ml-workspace/issues?q=is%3Aopen+is%3Aissue+label%3Afeature-request+sort%3Areactions-%2B1-desc" title="Open Feature Request"><img src="https://img.shields.io/github/issues/ml-tooling/ml-workspace/feature-request.svg?label=feature%20requests"></a>                                 |
| 👩‍💻 **Usage Questions**   |  <a href="https://stackoverflow.com/questions/tagged/ml-tooling" title="Open Question on Stackoverflow"><img src="https://img.shields.io/badge/stackoverflow-ml--tooling-orange.svg"></a> <a href="https://gitter.im/ml-tooling/ml-workspace" title="Chat on Gitter"><img src="https://badges.gitter.im/ml-tooling/ml-workspace.svg"></a> |
| 🗯 **General Discussion** | <a href="https://gitter.im/ml-tooling/ml-workspace" title="Chat on Gitter"><img src="https://badges.gitter.im/ml-tooling/ml-workspace.svg"></a>  <a href="https://twitter.com/mltooling" title="ML Tooling on Twitter"><img src="https://img.shields.io/twitter/follow/mltooling.svg?style=social"></a>                  |

## Features

### Desktop GUI

### Git Integration

### Visual Studio Code

### JupyterLab

[JupyterLab](https://github.com/jupyterlab/jupyterlab) (`Open Tool -> JupyterLab`) is the next-generation user interface for Project Jupyter. It offers all the familiar building blocks of the classic Jupyter Notebook (notebook, terminal, text editor, file browser, rich outputs, etc.) in a flexible and powerful user interface. This JupyterLab instance comes pre-installed with a few helpful extensions such as a the [jupyterlab-toc](https://github.com/jupyterlab/jupyterlab-toc), [jupyterlab-git](https://github.com/jupyterlab/jupyterlab-git), and [juptyterlab-tensorboard](https://github.com/chaoleili/jupyterlab_tensorboard).

<img src="./docs/images/feature-jupyterlab.png" />

### Hardware Monitoring

The workspace provides two preinstalled web-based tools to help developers during model training and other experimentation tasks to get insights into everything happening on the system and figure out performance bottlenecks.

[Netdata](https://github.com/netdata/netdata) (`Open Tool -> Netdata`) is a real-time hardware and performance monitoring dashboard that visualise the processes and services on your Linux systems. It monitors metrics about CPU, GPU, memory, disks, networks, processes, and more. 

<img src="./docs/images/feature-netdata.png" />

[Glances](https://github.com/nicolargo/glances) (`Open Tool -> Glances`) is a web-based hardware monitoring dashboard as well and can be used as an alternative to Netdata.

> ℹ️ _Netdata and Glances will show you the hardware statistics for the entire machine on which the workspace container is running._

### Tensorboard

### SSH Access

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