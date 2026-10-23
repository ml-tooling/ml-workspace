# Building and pushing the workspace images

Two images are built from this repo, always as a pair from the same commit:

| Image | Built from | Tag | Size |
|---|---|---|---|
| CPU (base) | [`Dockerfile`](Dockerfile) | `ml-workspace:<commit>` | ~30 GB |
| GPU | [`gpu-flavor/Dockerfile`](gpu-flavor/Dockerfile), on top of the CPU image | `ml-workspace:<commit>-gpu` | ~58 GB |

Registry: `registry.example.com/ml-workspace` is a placeholder - use your own registry. The tag is
the short git commit ID of the code the image was built from, so every image can be traced back to
its source.

The GPU image is built **on top of** the CPU image (`ARG_WORKSPACE_BASE_IMAGE`). Almost everything
the workspace does - nginx, Jupyter, VNC, VS Code, nested Docker, startup scripts - lives in the
CPU image. So **any change under `resources/` or in the root `Dockerfile` needs both images
rebuilt**, CPU first.

## Requirements

- An **x86_64** Linux build machine (the GPU nodes are amd64) with Docker (BuildKit is the default).
- About **120 GB free** under `/var/lib/docker` for a full build of both images: ~30 GB CPU image,
  ~58 GB GPU image, plus build cache. See [Running out of disk](#running-out-of-disk).
- Network access to Ubuntu, conda-forge, PyPI, NVIDIA's CUDA repo, GitHub and SourceForge.
- Push access to your registry (`docker login registry.example.com`).
- A checkout of this repo (not upstream `ml-tooling/ml-workspace`, which doesn't have these changes).

## 1. Get the code

```bash
cd ~/ml-workspace                                 # your checkout on the build machine
git config --global --add safe.directory "$PWD"   # only needed when building as root in another user's checkout
git pull
git status -s                                     # must print nothing - build only committed code
git log --oneline -1                              # the commit you're about to build
```

Never build from uncommitted changes: the tag would name a commit that doesn't contain them.

## 2. Build

Run the builds inside `tmux` or `screen` - they take a long time, and a dropped SSH connection
otherwise kills them.

```bash
REG=registry.example.com/ml-workspace
TAG=$(git rev-parse --short HEAD)

# CPU (base) image
docker build -t $REG:$TAG . 2>&1 | tee build-base.log

# GPU image, on top of the CPU image just built
docker build -t $REG:$TAG-gpu \
  --build-arg ARG_WORKSPACE_BASE_IMAGE=$REG:$TAG \
  --build-arg ARG_WORKSPACE_FLAVOR=gpu \
  --build-arg ARG_VCS_REF=$TAG \
  gpu-flavor/ 2>&1 | tee build-gpu.log
```

Docker only tags an image when its build finishes, so if `docker images` lists `$REG:$TAG`, that
build completed. If a build fails, `tail -40 build-base.log` (or `build-gpu.log`) shows why.

`python build.py --make` (upstream's [universal-build](https://github.com/ml-tooling/universal-build)
wrapper) also works, but it tags images its own way; the commands above produce the
`<commit>` / `<commit>-gpu` tags used everywhere else.

## 3. Check the images before pushing

```bash
# The jupyterhub client package (pinned to 5.x), only relevant if the image is run under a JupyterHub
docker run --rm --entrypoint pip $REG:$TAG-gpu show jupyterhub | grep Version

# Fixes the workspace depends on (see CHANGE.md)
docker run --rm --entrypoint grep $REG:$TAG -c "127.0.0.1:8090" /usr/local/bin/start-singleuser.sh   # 1
docker run --rm --entrypoint grep $REG:$TAG -c "Sec-Fetch-Mode" /etc/nginx/nginx.conf               # 4 or more
docker run --rm --entrypoint grep $REG:$TAG -c "default-address-pool " /etc/supervisor/conf.d/docker.conf  # 1

# Nested Docker storage driver: fuse-overlayfs on CPU, vfs on GPU (see DOCKER_IN_DOCKER.md)
docker run --rm --entrypoint grep $REG:$TAG     -o -- "--storage-driver=[a-z-]*" /etc/supervisor/conf.d/docker.conf
docker run --rm --entrypoint grep $REG:$TAG-gpu -o -- "--storage-driver=[a-z-]*" /etc/supervisor/conf.d/docker.conf
```

## 4. Push

```bash
docker login registry.example.com
docker push $REG:$TAG
docker push $REG:$TAG-gpu
```

Pushing the CPU image right after it's built (before building the GPU image) is safe and frees you
to clear the build cache if disk gets tight.

## 5. Roll it out

Point the deployment at the new tag and recreate the workspace:

- **Kubernetes:** change the `image:` tag in the workspace's Deployment, `kubectl apply` it, and
  wait for `kubectl rollout status` - the Deployment recreates the pod with the new image.
- **docker compose:** change the `image:` tag in the compose file, then
  `docker compose up -d --force-recreate`.

The first start on a node pulls the image (~58 GB for GPU), which takes several minutes.

**Rollback:** set the tag back to the previous one and apply again - keep the previous pair in the
registry until the new one is proven.

## Running out of disk

```bash
docker system df                         # what's using space - build cache is usually the biggest
docker builder prune -af                 # build cache (often 50-100+ GB)
docker image prune -f                    # dangling layers, e.g. from a failed build
docker rmi $REG:<old-tag> $REG:<old-tag>-gpu   # old pairs you no longer need (keep the last good one)
df -h /var/lib/docker
```

If only the GPU build failed, you don't need to rebuild the CPU image: push it, clean up, and run
just the GPU `docker build` command again.

## Where the images run

As a single workspace per developer: on Kubernetes, or with docker compose on one host. See
[`DOCKER_IN_DOCKER.md`](DOCKER_IN_DOCKER.md) for what each needs for nested Docker, in
both.
