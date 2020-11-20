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
   - git-lens: [latest release](https://github.com/eamodio/vscode-gitlens/releases/latest)
   - code-runner: [latest release](https://github.com/formulahendry/vscode-code-runner/releases/latest)
   - eslint: [latest release](https://marketplace.visualstudio.com/items?itemName=dbaeumer.vscode-eslint)
   - markdownlint: [latest release](https://marketplace.visualstudio.com/items?itemName=DavidAnson.vscode-markdownlint)
   - remote-ssh: [latest release](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-ssh)

6. Update tool installer scripts:

   - intellij.sh: [latest release](https://www.jetbrains.com/idea/download/other.html)
   - pycharm.sh: [latest release](https://www.jetbrains.com/pycharm/download/other.html)
   - nteract.sh: [latest release](https://github.com/nteract/nteract/releases/latest)
   - pillow-simd.sh: [latest release](https://pypi.org/project/Pillow-SIMD/#history)
   - rstudio-server.sh: [latest release](https://www.rstudio.com/products/rstudio/download-server/)
   - rstudio-desktop.sh: [latest release](https://www.rstudio.com/products/rstudio/download/#download)
   - sqlectron.sh: [latest release](https://github.com/sqlectron/sqlectron-gui/releases/latest)
   - zeppelin.sh: [latest release](http://zeppelin.apache.org/download.html)
   - robo3t.sh: [latest release](https://github.com/Studio3T/robomongo/releases/latest)
   - metabase.sh: [latest release](https://github.com/metabase/metabase/releases/latest)
   - fasttext.sh: [latest release](https://github.com/facebookresearch/fastText/releases/latest)
   - kubernetes-utils.sh: [kube-prompt release](https://github.com/c-bata/kube-prompt/releases/latest)

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

9. Build and test `light` flavor:

   - Build light workspace flavor via `python build.py --flavor=light`
   - Run workspace container and check startup logs
   - Check/Compare layer sizes of new image with previous version (via Portainer)
   - Check folder sizes via `Disk Usage Analyzer` within the Desktop VNC
   - Run `evaluate-python-libraries.ipynb` notebook to update `requirements-full.txt`

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
    - Check all gui-tools in VNC Desktop (just open and see of running)
    - Run from inside workspace: `python /resources/tests/test-installers.py`
    - Run from inside workspace: `/bin/bash /resources/tests/scan-python-vulnerabilities.sh`
    - Run from inside workspace: `/bin/bash /resources/tests/scan-clamav-virus.sh`
    - Run from inside workspace: `/bin/bash /resources/tests/scan-system-vulnerabilities.sh`
    - Run from inside workspace: `python /resources/tests/test-code-execution.py`
    - Update reports and licenses in git repo
    - Check if tutorials are still working in `/workspace/tutorials`

11. Build and test `gpu` flavor via `python build.py --flavor=gpu`
12. Build and test `R` flavor via `python build.py --flavor=R`
13. Build and test `spark` flavor via `python build.py --flavor=spark`
14. Build and push all flavors via `python build.py --deploy --version=<VERSION> --flavor=all`
