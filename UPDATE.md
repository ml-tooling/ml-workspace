# Update: Modernization to Ubuntu 24.04 / Python 3.12 / JupyterLab 4 / CUDA 12.6

This document describes the changes made to bring this workspace from its ~2021 baseline up to
current stable versions. It also lists the
bugs that were only discoverable by actually building and running the image end to end, not just by
bumping version numbers.

This was the first step. Everything changed since - Docker-in-Docker, Kubernetes, VNC and more - is
listed in [CHANGE.md](CHANGE.md); how to build the images is in [BUILD.md](BUILD.md).

## Why

The repo was pinned to 2021-era versions (Ubuntu 20.04, Python 3.8, PyTorch 1.9, JupyterLab 3, CUDA
11.2, Node 14, etc.). This update brings the whole stack current so it builds and runs on current
systems.

## Version bumps

| Component | Before | After |
|---|---|---|
| Base OS | Ubuntu 20.04 | Ubuntu 24.04 LTS |
| Python | 3.8.10 (Miniconda) | 3.12 (Miniforge) |
| Node.js | 14.x | 24.x LTS |
| OpenResty | 1.19.3.2 | 1.29.2.5 |
| TigerVNC | 1.11.0 | 1.16.2 |
| noVNC | v1.2.0 | v1.7.0 |
| websockify | v0.9.0 | v0.13.0 |
| JupyterLab | 3.0 | 4.6 |
| Notebook | 6.4 | 7.6 |
| ipython | 7.24 | 8.x |
| numpy | 1.19 | 2.x |
| scipy | 1.7 | 1.18 |
| scikit-learn | unpinned (~0.24 era) | 1.9 |
| PyTorch (CPU) | 1.9 | 2.13 |
| pandas | 1.2.5 | 2.3.x |
| matplotlib | 3.4.2 | 3.11.x |
| TensorFlow | intel-tensorflow 2.5.0 | tensorflow 2.21.x |
| VS Code Desktop / Server | 1.56.2 / 3.10.2 | latest-stable redirect / 4.133.0 |
| GPU: CUDA | 11.2.2 | 12.6 |
| GPU: cuDNN | 8.1.1 | 9.x (cudnn9-cuda-12-6) |

### Why Miniforge instead of Miniconda

Anaconda's `defaults`/`repo.anaconda.com` channels require a paid license for larger organizations
under Anaconda's 2020 Terms of Service, and are blocked outright on some corporate/cloud networks.
Miniforge bootstraps a conda-forge-only `conda` from a GitHub-hosted installer instead, avoiding both
issues while keeping the same `conda`/`mamba` tooling.

### Dependency pinning strategy (`resources/libraries/requirements-*.txt`)

Only the core platform packages (numpy, pandas, scipy, scikit-learn, matplotlib, Pillow, PyTorch,
TensorFlow, xgboost) are hard-pinned to current stable. The long tail of ~250 other packages is left
unpinned so pip's resolver picks whatever is mutually compatible with the new core stack, rather than
forcing exact 2021-era pins that predate Python 3.12 wheels entirely.

A handful of packages with no maintained release compatible with modern Python/numpy were dropped or
swapped for their current successor instead of being force-pinned to something broken:

- `intel-tensorflow` → `tensorflow` (Intel's optimizations are built into stock TensorFlow now)
- `cx-Oracle` → `oracledb`
- `python-language-server` → `python-lsp-server`
- `pandas-profiling` → `ydata-profiling`
- `mxnet-mkl` / Apache MXNet — retired to the Apache Attic in 2023, dropped
- `empyrical`, `geoplotlib`, `lightfm`, `fairseq`, `theano`, `chainer`, `edward`, `blaze`, `mmdnn`,
  `gluoncv`, `gluonnlp`, `xlearn`, `tensorflow-addons`, `torchtext`, `qgrid` — all unmaintained for
  years with no working build on current Python; dropped rather than pinned to something broken

## JupyterLab 3 → 4 / Notebook 6 → 7 is a breaking change, not just a version bump

Notebook 7 is now built on JupyterLab, and the classic "nbextension" system this repo used throughout
(`jupyter contrib nbextension install`, `jupyter labextension install`, `jupyter lab build`) no longer
exists. Extensions are now plain pip packages that ship a prebuilt ("federated") JupyterLab extension —
no separate install/enable/build step required. Several old extensions (`toc2`, `execute_time`,
`collapsible_headings`, `codefolding`) are simply gone from the Dockerfile because JupyterLab 4 has
them built in natively.

A few extensions had no compatible release for the new stack and were dropped: `witwidget`, `qgrid`,
the old Tensorboard nbextension integrations, and `jupyter-black` (superseded by
`jupyterlab_code_formatter`, which was already present).

**Resolved since:** the workspace's own custom tooling Jupyter extension
(`resources/jupyter/extensions/tooling-extension`) was at first disabled here, because its `setup.py`
and handlers used Notebook 6 APIs that don't exist in Notebook 7. It has since been ported to the
`jupyter_server` APIs (commit `cf4ab70`), which restored `/tooling/ping` - the endpoint nginx checks
before serving VS Code, VNC and the other `/tools/*` pages. The old "Open Tools" dropdown widget
itself wasn't ported; its job is done by launcher tiles under **Workspace Tools** in JupyterLab, via
`jupyter_app_launcher` (`fd6df67`). See [CHANGE.md](CHANGE.md).

## Bugs found only by actually building and running the image

These would not have been caught by researching version numbers alone — each was found by running
`docker build` and, in one case, actually starting the container:

- **`clean-layer.sh` was wiping Ubuntu 24.04's own apt sources.** Ubuntu 24.04 moved its default
  archive entries into `/etc/apt/sources.list.d/ubuntu.sources` (deb822 format); the existing cleanup
  script did `rm -rf /etc/apt/sources.list.d/*` after every build layer, which broke every `apt-get`
  call after the first one. Fixed to preserve `ubuntu.sources` while still clearing third-party PPA
  files.
- **`dpkg-sig`, `zlibc`, `gconf2`, `gvfs-bin`** — all removed from the Ubuntu archives after 20.04
  (unmaintained upstream, or superseded by `gio`/`xfconf`). Removed from the package list.
- **`pyenv-doctor` was cloned via `git://`**, the plaintext git protocol GitHub disabled in 2022.
  Switched to `https://`.
- **VS Code Desktop's install script `rm`'d an apt source file** that the current `.deb`'s postinst no
  longer creates, hard-failing the build. Changed to `rm -f`.
- **Firefox's release archive format changed** from `.tar.bz2` to `.tar.xz` at some point in the last
  few years; the old URL now 404s. Updated the extension and the `tar` extraction flag.
- **`sslh` on Ubuntu 24.04 renamed the `--ssl` flag to `--tls`.** This is the process that owns the
  main workspace port (multiplexing SSH and HTTP on the same port) — with the old flag it crashed
  immediately and supervisor gave up retrying, silently killing all access to the workspace on its
  main port. Only found by actually starting the container and hitting a connection reset. Fixed the
  supervisor program definition.
- **`pip install --use-deprecated=legacy-resolver`** — this flag was removed entirely in pip 23.1 and
  would hard-fail any install. Removed; the modern resolver handles the now largely-unpinned
  requirements files fine.
- **`python -m spacy download en`** — the old shorthand model name was removed years ago; modern spacy
  requires the explicit model package name (`en_core_web_sm`).

## Verification performed

- Full `docker build` of the CPU/`full` flavor succeeds end to end (76/76 steps).
- The built image was started as a container and verified at runtime: all supervisor-managed services
  report `RUNNING` (jupyter, nginx, sslh, vscode, novnc, ungit, filebrowser, netdata, sshd), and the
  web UI is reachable end to end (`/` → redirects to `/tree` → HTTP 200).
- Core package versions confirmed inside the running container: numpy 2.3.5, pandas 2.3.3, scipy
  1.18.0, scikit-learn 1.9.0, torch 2.13.0, matplotlib 3.11.1, JupyterLab 4.6.3.

## Not yet verified

- **GPU flavor** (`gpu-flavor/Dockerfile`): at the time of this update, modernized to CUDA 12.6 but
  not build- or runtime-tested (no GPU on the build machine). **Since then** it has been built and run
  on NVIDIA L40S nodes (driver 570) under Kubernetes, with `nvidia-smi` working inside the
  workspace. Still not confirmed: `docker run --gpus` in the workspace's nested Docker, and
  `torch.cuda.is_available()` on the current image - check both before relying on them.
- **`minimal` and `light` flavors**: only the `full` flavor's build path was exercised end to end.
- A few optional, manually-invoked tool scripts under `resources/tools/` (e.g. `rapids-gpu.sh`,
  `python-27.sh`, `cuda-10-0.sh`) were not audited — they're not part of the automated build and still
  reference old versions if a developer chooses to run them by hand later.
