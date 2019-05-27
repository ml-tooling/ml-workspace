# Machine Learning Workspace

The ML workspace is an all-in-one web IDE specialized for machine learning and data science. It comes with Jupyter Notebook, VNC access, Git integration, hardware monitoring, GPU access, and many common ML libraries. The workspace is preinstalled with various common data science tools, libraries, and features, such as:

- Runtimes: Anaconda 3, Java 8, NodeJS
- Tools: Jupyter, Visual Studio Code, ungit, netdata, noVNC
- ML libs: Tensorflow, Keras, Pytorch, Sklearn, CNTK, XGBoost, ...

## Usage

### Deploy Workspace

To start the workspace locally, execute:

```bash
docker run -d --name ml-workspace -p 8091:8091 --restart always mltooling/ml-workspace
```

Visit http://localhost:8091
 
#### Persist Data

To persist the data, you need to mount a volume into `/workspace`.

#### Configuration

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

## Develop

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