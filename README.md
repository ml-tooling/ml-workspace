<h1 align="center">
    <img width=50% alt="" src="./docs/images/ml-workspace-logo.png">
    <br>
</h1>

<p align="center">
    <strong>All-in-one web-based development environment for machine learning</strong>
</p>

<p align="center">
    <a href="https://hub.docker.com/r/mltooling/ml-workspace" title="Docker Image Version"><img src="https://images.microbadger.com/badges/version/mltooling/ml-workspace.svg"></a>
    <a href="https://hub.docker.com/r/mltooling/ml-workspace" title="Docker Pulls"><img src="https://img.shields.io/docker/pulls/mltooling/ml-workspace.svg"></a>
    <a href="https://hub.docker.com/r/mltooling/ml-workspace" title="Docker Image Metadata"><img src="https://images.microbadger.com/badges/image/mltooling/ml-workspace.svg"></a>
    <a href="https://github.com/ml-tooling/ml-workspace/issues" title="Open Issues"><img src="https://img.shields.io/github/issues-raw/ml-tooling/ml-workspace.svg"></a>
    <a href="https://github.com/ml-tooling/ml-workspace/blob/master/LICENSE" title="ML Workspace License"><img src="https://img.shields.io/badge/License-Apache%202.0-green.svg"></a>
    <a href="https://twitter.com/mltooling" title="ML Tooling on Twitter"><img src="https://img.shields.io/twitter/follow/mltooling.svg?style=social"></a>
</p>

<p align="center">
  <a href="#getting-started">Getting Started</a> •
  <a href="#highlights">Highlights</a> •
  <a href="#features">Features</a> •
  <a href="#screenshots">Screenshots</a> •
  <a href="#usage">Usage</a> •
  <a href="#contribution">Contribution</a> •
  <a href="#faq">FAQ</a>
</p>

The ML workspace is an all-in-one web-based IDE specialized for machine learning and data science. It is simple to deploy and gets you started within minutes to productively built and train ML solutions on your own machines. This workspace is the ultimate tool for developers preloaded with a variety of popular data science libraries (e.g., Tensorflow, PyTorch, Keras, Sklearn) and dev tools (e.g., Jupyter, VS Code, Tensorboard) perfectly configured, optimized, and integrated.

## Highlights

- 💫 Jupyter, JupyterLab, and Visual Studio Code web-based IDEs.
- 🗃 Pre-installed with many popular data science libraries & tools.
- 🖥 Full Linux desktop GUI accesible via web browser.
- 🔀 Seamless Git integration optimized for notebooks.
- 🚪 Access from anywhere via Web, SSH, or VNC under a single port.
- 🐳 Easy to deploy on Mac, Linux, and Windows via Docker.

## Getting Started

### Prerequisites

The Workspace requires **Docker** 🐳 to be installed on your machine ([Installation Guide](https://docs.docker.com/install/#supported-platforms)).

> 📖 _If you are new to Docker, we recommend to take a look at [this wonderful beginner guide](https://docker-curriculum.com/)._

### Start single instance

Deploying a single Workspace instance is as simple as:

```bash
docker run -d --name ml-workspace -p 8091:8091 --restart always mltooling/ml-workspace:latest
```

Voilà, that was easy 😌 Now, Docker will pull the latest workspace image to your machine. This may take a few minutes depending on your internet speed. Grab a coffee ☕ and dream about all the exciting things you can built with Machine Learning 🦄. Once the workspace is started, you can access it via: http://localhost:8091. 

> ☝️ _If started on a remote machine or with a different port, make sure to use the machines IP/DNS and/or the exposed port._

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
        <td>The base URL under which the notebook server is reachable. E.g. setting it to /workspace, the workspace would be reachable under /workspace/tree</td>
        <td>/</td>
    </tr>
    <tr>
        <td colspan="3">Jupyter Configuration:</td>
    </tr>
    <tr>
        <td colspan="3">VNC Configuration:</td>
    </tr>
    <tr>
        <td>VNC_PW</td>
        <td>Password of VNC Connection</td>
        <td>vncpassword</td>
    </tr>
    <tr>
        <td>VNC_RESOLUTION</td>
        <td>Desktop Resolution of VNC Connection</td>
        <td>1600x900</td>
    </tr>
    <tr>
        <td>VNC_COL_DEPTH</td>
        <td>Color Depth of VNC Connection</td>
        <td>24</td>
    </tr>
</table>

### Run multiple instances

## Features

### Screenshots

## Contribution
 
## Develop

<details>

<summary>Development information for contributors (click to expand...)</summary>



### Build

Execute this command in the project root folder to build the docker container:

```bash
python build.py --version={MAJOR.MINOR.PATCH-TAG}
```

The version has to be provided. The version format should follow the [Semantic Versioning](https://semver.org/) standard (MAJOR.MINOR.PATCH). For additional script options:

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