# Changes in this fork

Everything changed in this fork compared with upstream
[ml-tooling/ml-workspace](https://github.com/ml-tooling/ml-workspace), oldest first. Each entry
names its commit; `git show <commit>` has the details, and the commit messages explain the why.
Changes to the image need a rebuild of both images - see [BUILD.md](BUILD.md).

## Image tags at a glance

Images are tagged with the commit they were built from. The repository history was rewritten on
2026-10-22 (a configuration folder was removed from all commits), which changed the IDs of commits
from 2026-10-17 onward - so the three newest images keep their original tag names, and the
**Commit** column gives the commit each one corresponds to now.

| Image tag | Commit | Date | What it adds | Use it? |
|---|---|---|---|---|
| `b36e5d8` | `4c02f58` | 2026-10-22 | Thread count follows the CPU limit | **Current** - everything below included |
| `f8f92b6` | `a7ef1e8` | 2026-10-21 | Jupyter port, VNC/VS Code login check, launcher links, nested Docker flag fix | Works; lacks the thread fix |
| `e2dce20` | `485960f` | 2026-10-17 | Passwordless VNC, jupyterhub 5.x client | No - nested Docker broken |
| `5f3da27` | `5f3da27` | 2026-09-08 | Nested Docker works | No |
| older | | 2026-08/09 | Modernization and fixes | No |

---

## 2026-08-20 - Modernization (`af002a7`, `4e0a670`)

Ubuntu 20.04 → 24.04, Python 3.8 → 3.12 (Miniforge), JupyterLab 3 → 4, Notebook 6 → 7,
CUDA 11.2 → 12.6, and current versions of the whole ML stack and every bundled tool.
[UPDATE.md](UPDATE.md) has the full version table and the build bugs found along the way.

## 2026-08-21 - Make the modernized image actually work

- **Jupyter tooling extension ported to Notebook 7 / jupyter_server APIs** (`cf4ab70`). Restores
  `/tooling/ping`, which nginx calls to check the login before serving any `/tools/*` page.
- **VS Code behind the `/tools/vscode/` proxy** (`f9de387`, `2a4c35b`, `9786593`): route
  code-server's `/stable-<hash>` assets, and keep the port in the `Host` header - both caused
  WebSocket 403s that broke the editor and file saving.
- **Launcher tiles for the workspace tools** via `jupyter_app_launcher` (`fd6df67`) - VS Code, VNC,
  Ungit, Filebrowser, Netdata, Glances - replacing the old Notebook 6 "Open Tools" widget.
- **Run as a real Linux user** named after `WORKSPACE_AUTH_USER` (`5349ac8`), with sudo; Jupyter and
  VS Code run as that user instead of root.
- Shell fixes: oh-my-zsh actually installed, clean prompt (`3fd5e67`); pyenv working under
  `sudo su` (`8c06944`).
- **GPU flavor builds again** (`b69eb3b`): `cudnn9-cuda-12`, `libopenblas` package changes.

## 2026-08-22 → 09-03 - Docker-in-Docker, desktop

- **Nested Docker** (`7c71e7c`): full Docker Engine inside the workspace, `dockerd` under
  supervisor. See [DOCKER_IN_DOCKER.md](DOCKER_IN_DOCKER.md).
- **noVNC fixes** (`e86b1a4`, `e17c265`): page-load crash on noVNC 1.7, and a build step that
  silently shipped broken noVNC/websockify downloads.
- **VNC desktop as the landing page** (`1ff2703`): `/` opens the desktop; Google Chrome and desktop
  shortcuts added.

## 2026-09-07 - Auditing

- `login.log` and `history_audit.log` (`2d06e19`): who logged in when, and every shell command.
- nginx no longer refuses to start when `/workspace` has bad permissions (`b1dd1cc`).

## 2026-09-08 → 09-10 - Nested Docker on real hosts, Kubernetes manifest

- **`docker run` inside the workspace works** (`5f3da27`): nested `dockerd` uses `fuse-overlayfs`
  (overlay2 can't mount on top of overlay2).
- **GPU flavor uses `vfs`** for nested Docker (`6b823dd`, `8aa45eb`): fuse-overlayfs breaks
  `docker run --gpus` inside the workspace.
- **Nested Docker's bridge moved to `192.168.200.0/24`** (pool `192.168.208.0/20`) (`5d9961b`): the
  default `172.17.0.1` collided with the host's own `docker0`, so host-to-pod traffic (kubelet
  probes, NodePorts) was swallowed.
- A per-developer Kubernetes manifest (`98ff35c`), first with HAMi GPU slicing. Deployment
  manifests have since been taken out of the repo.

## 2026-10-15 → 10-19 - Kubernetes hardening, VNC

- **Pods no longer `privileged: true`** (`0fcdb2f` / `c042cad`): a privileged pod
  sees every GPU on the node regardless of its allocation. Instead: `SYS_ADMIN`, `NET_ADMIN`,
  `SYS_RESOURCE`, unconfined seccomp/AppArmor, and a `postStart` hook that remounts
  `/sys/fs/cgroup` and `/proc/sys` read-write and sets up cgroup v2 for nested Docker.
- **HAMi removed**; the GPU is chosen with `NVIDIA_VISIBLE_DEVICES`. Home and `/workspace` share
  one volume (`/workspace` = `~/workspace`).
- **VNC** (`485960f`): `VNC_PW=""` now means no VNC password (it used to fall back to
  `vncpassword`); the password file is overwritten instead of appended to (with home on a PVC, the
  first password ever set stuck forever); VNC and noVNC listen on localhost only.
- **`jupyterhub` client pinned to 5.x** in the image (`485960f`).

## 2026-10-21 - Running behind a JupyterHub, nested Docker flag (`a7ef1e8`)

These make the image work when a JupyterHub starts it (it then runs `jupyterhub-singleuser` under a
`/user/<name>/` prefix); they change nothing when it runs on its own.

- **Jupyter's port** (`start-singleuser.sh`): `jupyterhub-singleuser` listened on 8080 - which
  belongs to sslh inside the image (8080 sslh → 8092 nginx → 8090 Jupyter) - so it crashed. It now
  listens on 8090.
- **Nested Docker flag** (`docker.conf`), affects every deployment: `--default-address-pools` →
  `--default-address-pool`. The plural is only valid in `daemon.json`; dockerd refused to start, so
  nested Docker was broken in every image since `5d9961b`.
- **VNC / VS Code login check** (`nginx.conf`): JupyterHub ≥ 4.1 ignores the login cookie on
  requests not marked as a navigation; nginx's own `/tooling/ping` check now passes
  `Sec-Fetch-Mode: navigate` for same-site requests. A failed check redirects to `/lab` (which logs
  you in) instead of `/`, which looped back to `/tools/vnc/` forever.
- **Launcher links** (`run_workspace.py`): the Workspace Tools tiles linked to `/tools/...` at the
  site root; they're now rewritten with the base URL prefix on every start.

## 2026-10-22 - Thread count follows the CPU limit (`4c02f58`)

`OMP_NUM_THREADS` (and so `nproc`) was always 32: the entrypoint only read the cgroup v1 CPU quota,
which doesn't exist on cgroup v2 nodes. It now reads `cpu.max`, so a 16-CPU workspace gets 15
threads, a 4-CPU one 4. `nproc` / `lscpu` / `free` otherwise still show the whole node - the real
limits are in `/sys/fs/cgroup/cpu.max` and `/sys/fs/cgroup/memory.max`.
