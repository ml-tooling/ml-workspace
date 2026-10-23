# GPU flavor

The GPU image: CUDA 12, cuDNN 9 and GPU builds of the ML libraries, built **on top of** the CPU image
from the repo root (`ARG_WORKSPACE_BASE_IMAGE`), and tagged `ml-workspace:<commit>-gpu`.

- Build and push: [BUILD.md](../BUILD.md) - always build the CPU image from the same commit first.
- Nested Docker uses the `vfs` storage driver in this flavor (the `sed` at the end of the
  [Dockerfile](Dockerfile)), because fuse-overlayfs breaks `docker run --gpus` - see
  [DOCKER_IN_DOCKER.md](../DOCKER_IN_DOCKER.md).
- The CUDA version used inside must be supported by the host's driver (e.g. driver 570 supports up
  to CUDA 12.8).
- `NVIDIA_VISIBLE_DEVICES=all` is baked into the image. Deployments must override it with the
  GPUs the workspace should get (e.g. `0,1`), or `void` for none - otherwise the NVIDIA runtime
  hands the container every GPU on the host.

Upstream's GPU flavor: [ml-tooling/ml-workspace](https://github.com/ml-tooling/ml-workspace#gpu-flavor).
