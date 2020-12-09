# Workspace Update Process

We plan to do a full workspace image update (all libraries and tools) about every three month. The full update involves quiet a bit of manual work as documented below:

1. Refactor incubation zone:

   - Move ubuntu packages to basics or gui-tools section.
   - Move python libraries to requirement files in `resources/libraries`.
   - Refactor other installs.

2. Update core (process) tools and interpreters:

   - Tini: [latest release](https://github.com/krallin/tini/releases/latest)
   - OpenResty: [latest release](https://openresty.org/en/download.html)
   - Miniconda: [latest release](https://repo.continuum.io/miniconda/), [python version](https://anaconda.org/conda-forge/python)
   - Node.js: [latest release](https://nodejs.org/en/download/current/)

3. Update core (gui) tools:

   - TigetVNC: [latest release](https://dl.bintray.com/tigervnc/stable/)
   - noVNC: [latest release](https://github.com/novnc/noVNC/releases/latest)
   - Websockify: [latest release](https://github.com/novnc/websockify/releases/latest)
   - VS Code Server: [latest release](https://github.com/cdr/code-server/releases/latest)
   - Ungit: [latest release](https://www.npmjs.com/package/ungit)
   - FileBrowser: [latest release](https://github.com/filebrowser/filebrowser/releases/latest)

4. Update conda packages:

   - Jupyter Notebook: [latest release](https://anaconda.org/search?q=notebook&sort=ndownloads&sort_order=1&reverse=true)
   - JupyterLab: [latest release](https://anaconda.org/search?q=jupyterlab&sort=ndownloads&sort_order=1&reverse=true)
   - IPython: [latest release](https://anaconda.org/search?q=ipython&sort=ndownloads&sort_order=1&reverse=true)
   - Tensorflow: [latest release](https://anaconda.org/search?q=tensorflow&sort=ndownloads&sort_order=1&reverse=true)
   - PyTorch: [latest release](https://anaconda.org/search?q=pytorch&sort=ndownloads&sort_order=1&reverse=true)

5. Update VS-code extensions:

   - python: [latest release](https://github.com/microsoft/vscode-python/releases/latest)
   - java: [latest release](https://github.com/redhat-developer/vscode-java/releases)
   - prettier: [latest release](https://github.com/prettier/prettier-vscode/releases/latest)
   - jupyter: [latest release](https://marketplace.visualstudio.com/items?itemName=ms-toolsai.jupyter)
   - code-runner: [latest release](https://github.com/formulahendry/vscode-code-runner/releases/latest)
   - eslint: [latest release](https://marketplace.visualstudio.com/items?itemName=dbaeumer.vscode-eslint)

6. Update tool installer scripts:

   - intellij.sh: [latest release](https://www.jetbrains.com/idea/download/other.html)
   - pycharm.sh: [latest release](https://www.jetbrains.com/pycharm/download/other.html)
   - nteract.sh: [latest release](https://github.com/nteract/nteract/releases/latest)
   - r-runtime.sh: [latest release](https://www.rstudio.com/products/rstudio/download-server/)
   - rstudio-server.sh: [latest release](https://www.rstudio.com/products/rstudio/download-server/)
   - rstudio-desktop.sh: [latest release](https://www.rstudio.com/products/rstudio/download/#download)
   - sqlectron.sh: [latest release](https://github.com/sqlectron/sqlectron-gui/releases/latest)
   - zeppelin.sh: [latest release](http://zeppelin.apache.org/download.html)
   - robo3t.sh: [latest release](https://github.com/Studio3T/robomongo/releases/latest)
   - metabase.sh: [latest release](https://github.com/metabase/metabase/releases/latest)
   - fasttext.sh: [latest release](https://github.com/facebookresearch/fastText/releases/latest)
   - kubernetes-utils.sh: [kube-prompt release](https://github.com/c-bata/kube-prompt/releases/latest), [conftest release](ttps://github.com/open-policy-agent/conftest), [yq release](https://github.com/mikefarah/yq/releases)
   - portainer.sh: [latests release](https://github.com/portainer/portainer/releases/latest)
   - rapids-gpu.sh: [latests release](https://rapids.ai/)

7. Update `minimmal` and `light` flavor python libraries:

   - Update requirement files using [piprot](https://github.com/sesh/piprot), [pur](https://github.com/alanhamlett/pip-update-requirements), or [pip-upgrader](https://github.com/simion/pip-upgrader):
     - `piprot ./resources/libraries/requirements-minimal.txt`
     - `piprot ./resources/libraries/requirements-light.txt`
     - [pur](https://github.com/alanhamlett/pip-update-requirements) example: `pur -i -r ./resources/libraries/requirements-minimal.txt`

8. Build and test `minimal` flavor:

   - Build minimal workspace flavor via `python build.py --flavor=minimal`
   - Run workspace container and check startup logs
   - Check/Compare layer sizes of new image with previous version (via Portainer)
   - Check Image Labels (via Portainer)
   - Check folder sizes via `Disk Usage Analyzer` within the Desktop VNC
   - Check all webtools/features (just open and see of running):
     - Jupyter, VNC, JupyterLab, VS-Code, Ungit, Netdata, Glances, Filebrowser, Access Port, SSH Access, Git Integration, Tensorboard
     - Check if novnc settings are applied in settings menu: reconnect = True, scaling = remote, and correct websockify path
     - Check if vs-code settings are applied: the settings file in vs-code should be filled with some settings

9. Build and test `light` flavor:

   - Build light workspace flavor via `python build.py --flavor=light`
   - Run workspace container and check startup logs
   - Check/Compare layer sizes of new image with previous version (via Portainer)
   - Check folder sizes via `Disk Usage Analyzer` within the Desktop VNC
   - Run `/resources/tests/evaluate-python-libraries.ipynb` notebook to update `requirements-full.txt`
   - Run `/resources/tests/test-tool-installers.ipynb` notebook to test installer scripts.

10. Build and test `full` flavor:

    - Build main workspace flavor via `python build.py --flavor=full`
    - Deploy new workspace image and check startup logs
    - Check/Compare layer sizes of new image with previous version (via Portainer)
    - Check Image Labels (via Portainer)
    - Check folder sizes via `Disk Usage Analyzer` within the Desktop VNC
    - Check all webtools/features (just open and see of running):
      - Jupyter (+ Extensions), JupyterLab (+ Extensions), VNC, VS-Code (+ Extensions), Ungit, Netdata, Glances, Filebrowser, Access Port, SSH Access, Git Integration, Tensorboard
    - Run from inside workspace: `/bin/bash /resources/tests/log-environment-info.sh`
    - Run from inside workspace: `tutorials/workspace-test-utilities.ipynb`
    - Check all gui-tools in VNC Desktop (just open and see of running): VS Code, glogg, Chrome, Firefox, DB Browser, Task Manager
    - Run from inside workspace: `/bin/bash /resources/tests/scan-python-vulnerabilities.sh`
    - Run from inside workspace (virus scan via [trivy](https://github.com/aquasecurity/trivy)): `/bin/bash /resources/tests/scan-trivy-vulnerabilities.sh`
    - Run from inside workspace (virus scan via [clamav](https://www.clamav.net/)): `/bin/bash /resources/tests/scan-clamav-virus.sh`
    - Run from inside workspace: `python /resources/tests/test-code-execution.py`
    - Update reports and licenses in Git repo
    - Check if tutorials are still working in `/workspace/tutorials`
    - Scan workspace image with [docker scan](https://docs.docker.com/engine/scan/): `docker scan --accept license --dependency-tree --file Dockerfile ml-workspace`. Fix or prevent high- or critical-severity vulnerabilities. Update report in `resources/reports/docker-snyk-scan.txt`.

11. Update, build and test `gpu` flavor:

   - Update CUDA Tooling based on [cuda container images](https://gitlab.com/nvidia/container-images/cuda/)
   - Decide for CUDA version update based on tensorflow & pytorch support
   - Update GPU libraries and tooling inside Dockerfile
   - Build via `python build.py --flavor=gpu`
   - Test `nvidia-smi` in terminal to check for GPU access
   - Test image on GPU machine und run `/workspace/tutorials/workspace-test-utilities.ipynb`
   - Test GPU interface in Netdata and Glances

12. Update, build and test `R` flavor:

   - Build via `python build.py --flavor=R`
   - Run `/workspace/tutorials/test-r-runtime.Rmd` via R kernel.
   - Test `R Studio Server` tool and run the `/workspace/tutorials/test-r-runtime.Rmd`.

13. Build and test `spark` flavor via `python build.py --flavor=spark`

   - Build via `python build.py --flavor=spark`
   - Run `/workspace/tutorials/test-spark.ipynb` via Python kernel.
   - Run `/workspace/tutorials/toree-scala-kernel-tutorial.ipynb` via Toree kernel.
   - Test `Zeppelin` tool.

14. Build and push all flavors via `python build.py --deploy --version=<VERSION> --flavor=all`
