# Docker-in-Docker

This workspace runs a nested Docker daemon inside the container (see
`resources/supervisor/programs/docker.conf`), so developers can `docker run`, `docker build` and
`docker compose` their own containers from inside their workspace.

How the nested daemon is set up, in every deployment:

| | CPU image | GPU image |
|---|---|---|
| Storage driver | `fuse-overlayfs` - overlay2 can't mount on top of the container's own overlay2 rootfs | `vfs` - fuse-overlayfs breaks the NVIDIA hooks behind `docker run --gpus` (`gpu-flavor/Dockerfile` swaps it). Slower and uses more disk: no layer sharing |
| Bridge / address pool | `192.168.200.1/24` / `192.168.208.0/20` - off Docker's default `172.17.0.0/16`, which collides with the host's own `docker0` and swallows host-to-pod traffic (kubelet probes, NodePorts) | same |

The address pool flag is `--default-address-pool` (singular). Images older than tag `f8f92b6`
(commit `a7ef1e8` - see [CHANGE.md](CHANGE.md)) used the
plural, which `dockerd` rejects on the command line - nested Docker never started in them.

There are two ways to run it, depending on where the workspace runs.

## On Kubernetes

No sysbox and no `privileged: true` - a privileged pod gets the node's whole `/dev`, so every GPU,
bypassing the GPU assignment. Instead the pod needs:

- capabilities `SYS_ADMIN`, `NET_ADMIN`, `SYS_RESOURCE`, unconfined seccomp and AppArmor;
- a `postStart` hook that remounts `/sys/fs/cgroup` and `/proc/sys` read-write (unprivileged pods
  get them read-only, which breaks `runc` and dockerd's `ip_forward`), and moves the container's
  processes into a child cgroup so cgroup v2 controllers can be delegated - the same setup as
  Docker's official `dind` image;
- the namespace labelled `pod-security.kubernetes.io/enforce=privileged` (the `baseline` level
  forbids those capabilities - the pod itself still isn't privileged);
- `/var/lib/docker` on the user's volume (`~/.docker-data`), so nested images survive restarts.

Check from a workspace terminal: `docker run --rm hello-world`, and on the GPU image
`docker run --rm --gpus all nvidia/cuda:12.8.1-base-ubuntu24.04 nvidia-smi`. The CUDA version inside
must be supported by the node's driver (e.g. driver 570 supports up to CUDA 12.8).

## On a single host with docker compose: sysbox

The rest of this document covers running the workspace with `docker-compose.yml` on one host.
There, nested Docker needs the **sysbox-runc** container runtime installed on the host - it safely
isolates the nested daemon via a Linux user namespace, instead of the much riskier `--privileged`
flag (which effectively grants host root to anyone with sudo inside the workspace - every
developer, by default).

### 1. Install sysbox

Check https://github.com/nestybox/sysbox/releases for the current latest release (v0.7.1+ is
the minimum for Ubuntu 24.04 support - a newer one is fine too).

```bash
wget https://downloads.nestybox.com/sysbox/releases/v0.7.1/sysbox-ce_0.7.1-0.linux_amd64.deb
sudo apt-get install jq
sudo apt-get install ./sysbox-ce_0.7.1-0.linux_amd64.deb
systemctl status sysbox
```

The installer restarts the Docker daemon, so stop running containers first:

```bash
docker stop ml-workspace
```

### 2. Enable it in docker-compose.yml

```yaml
services:
  ml-workspace:
    runtime: sysbox-runc
    # ...
```

Then:

```bash
docker compose up -d --force-recreate
```

### 3. Verify

```bash
docker exec ml-workspace docker ps
docker exec ml-workspace docker run --rm hello-world
```

### Known issue on newer kernels (5.x/6.x kernel is fine, 7.x may hit this)

On a host running an unusually new kernel (observed on `7.0.0-30-generic` - well past what
sysbox v0.7.1 was tested against, since sysbox 0.7.1 shipped mid-2024), `docker compose up` can
fail with:

```
Error response from daemon: failed to create task for container: failed to create shim task:
OCI runtime create failed: ... rootfs_init_linux.go:410: setting up ID-mapped mount on path
l/6I3LJ6YRZK5TGB4QP6FONCBZCC (likely means idmapped mounts are not supported on the filesystem
at this path ()) caused: Failed to eval symlink on : lstat l: no such file or directory
```

This is `sysbox-runc` failing to resolve Docker's overlay2 `l/<shortname>` symlinks (the
shortcuts overlay2 uses to keep mount arguments under the kernel's length limit) while applying
an ID-mapped mount to the container's rootfs layers. `sysbox-mgr` itself reports ID-mapped
mounts as kernel-supported, so this looks like a real compatibility bug against a kernel this
new, not a config mistake.

#### What we've tried, and the result

| Attempt | Config | Result |
|---|---|---|
| Default | (no override) | Fails during `sysbox-mgr`'s own rootfs-cloning step, at `/var/lib/sysbox/rootfs/<id>/overlay2/merged` - "no such file or directory" |
| `--disable-idmapped-mount` only | with shiftfs absent | Same class of failure - no ID-mapping mechanism available at all (shiftfs isn't installed and isn't needed on a kernel this new, so this alone isn't the right fix) |
| `--disable-rootfs-cloning` only | idmapped-mount left enabled | **Same exact symlink error as the default case** - confirms this specific failure happens in `sysbox-runc`'s own container-init step (`rootfs_init_linux.go`), not `sysbox-mgr`'s rootfs-cloning optimization, so disabling cloning alone doesn't touch it |
| Both flags combined | `--disable-idmapped-mount --disable-rootfs-cloning` | Being tested - see below |

#### How to apply a flag combination

```bash
cat <<'EOF' | sudo tee /etc/systemd/system/sysbox-mgr.service.d/override.conf
[Service]
ExecStart=
ExecStart=/usr/bin/sysbox-mgr --disable-idmapped-mount --disable-rootfs-cloning
EOF
sudo systemctl daemon-reload
sudo systemctl restart sysbox-mgr sysbox-fs sysbox
docker compose up -d
```

#### If the combined flags still fail

Treat this as a genuine, currently-unresolved sysbox compatibility gap against this specific
kernel version, not something fixable by more flag combinations. Next steps, in order of
preference:

1. **Check for a newer sysbox release** at https://github.com/nestybox/sysbox/releases - if
   one post-dates this kernel version, it may include a fix.
2. **File or search for an existing sysbox GitHub issue** describing this exact
   `rootfs_init_linux.go:410` / `l/<shortname>` symlink failure, mentioning the kernel version.
3. **Last resort - `privileged: true`**: works immediately, but disables almost all of Docker's
   isolation (seccomp, AppArmor, device cgroup restrictions). Combined with the passwordless
   `sudo` every developer already has inside their own workspace, this effectively grants every
   developer root on the shared host itself - not just their own container. Only reasonable if
   every developer with access is fully trusted. See `docker-compose.yml` - swap `runtime:
   sysbox-runc` for `privileged: true` if you accept this trade-off.
4. **Skip Docker-in-Docker** - remove the `runtime:`/`privileged:` line entirely. Everything
   else in the workspace works fine without it; `dockerd` will just sit crash-looping quietly in
   supervisor's logs until re-enabled.

### Testing with a sample UI once Docker-in-Docker is working

`docker-compose.yml` reserves ports `10000-10010` for developers to publish their own nested
containers on. Once `docker exec ml-workspace docker run --rm hello-world` succeeds, confirm a
real UI is reachable end-to-end:

```bash
# From inside the workspace (a Jupyter/VS Code terminal, or docker exec):
docker run -d --name test-ui -p 10000:80 nginxdemos/hello
```

Then from your laptop's browser: `http://<server-ip>:10000` (the server's real IP, not
`127.0.0.1` - that only ever resolves to your own laptop) - you should see nginx's demo page
showing the container's hostname, IP, and request headers. This confirms the full chain works:
nested container -> published on the workspace's own port 10000 -> published through to the
host via the `10000-10010` compose range -> reachable externally.

**Stick to ports inside `10000-10010`.** Firefox and Chrome both refuse to connect to a
hardcoded list of ports associated with other protocols (e.g. `10080`, flagged historically for
the "Amanda" backup service) - the browser cancels the request outright with a "This address is
restricted" page, which looks like a networking failure but isn't one. Picking a port outside
`10000-10010` also means `docker-compose.yml` never published it to the host in the first place,
so it wouldn't be reachable even from a non-blocked browser port.

**Note:** this bypasses the workspace's own nginx/basic-auth layer entirely - anything published
on `10000-10010` is open to anyone who can reach the host on that port, unauthenticated. Don't
leave a real service running there without its own auth.

Clean up when done:

```bash
docker exec ml-workspace docker rm -f test-ui
```
