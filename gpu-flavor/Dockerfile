ARG ARG_WORKSPACE_BASE_IMAGE="mltooling/ml-workspace:latest"
# Build from full flavor of workspace with same version
FROM $ARG_WORKSPACE_BASE_IMAGE

ARG ARG_WORKSPACE_FLAVOR="gpu"
ENV WORKSPACE_FLAVOR=$ARG_WORKSPACE_FLAVOR

USER root

### NVIDIA CUDA BASE ###
# Uses the cuda-keyring package (NVIDIA's current recommended method) instead of the deprecated
# apt-key add + hand-written .list file approach - apt-key is removed/non-functional on recent
# Ubuntu releases. Repo path bumped from ubuntu2004 to ubuntu2404 to match the base image.
RUN apt-get update && apt-get install -y --no-install-recommends \
    gnupg2 curl ca-certificates && \
    curl -fsSL https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/cuda-keyring_1.1-1_all.deb -o /tmp/cuda-keyring.deb && \
    dpkg -i /tmp/cuda-keyring.deb && \
    rm /tmp/cuda-keyring.deb && \
    # Cleanup - cannot use cleanup script here, otherwise too much is removed
    apt-get clean && \
    rm -rf $HOME/.cache/* && \
    rm -rf /tmp/* && \
    rm -rf /var/lib/apt/lists/*

ENV CUDA_VERSION=12.6

# Package versions are left unpinned (just the 12-6 series name, no exact patch) rather than hand-pinned
# to one apt revision like the original - NVIDIA ships frequent point releases within a CUDA minor
# version and a hardcoded patch pin goes stale (and fails to resolve) within weeks.
RUN apt-get update && apt-get install -y --no-install-recommends \
    cuda-cudart-12-6 \
    cuda-compat-12-6 \
    && ln -s /usr/local/cuda-12.6 /usr/local/cuda && \
    rm -rf /var/lib/apt/lists/* && \
    # Cleanup - cannot use cleanup script here, otherwise too much is removed
    apt-get clean && \
    rm -rf $HOME/.cache/* && \
    rm -rf /tmp/* && \
    rm -rf /var/lib/apt/lists/*

# Required for nvidia-docker v1
RUN echo "/usr/local/nvidia/lib" >> /etc/ld.so.conf.d/nvidia.conf \
    && echo "/usr/local/nvidia/lib64" >> /etc/ld.so.conf.d/nvidia.conf

ENV PATH=/usr/local/nvidia/bin:/usr/local/cuda/bin:${PATH}
ENV LD_LIBRARY_PATH=/usr/local/nvidia/lib:/usr/local/nvidia/lib64

# nvidia-container-runtime
# https://github.com/NVIDIA/nvidia-container-runtime#environment-variables-oci-spec
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=compute,utility
# CUDA 12.6 requires NVIDIA driver >=560.28.03 on Linux
ENV NVIDIA_REQUIRE_CUDA="cuda>=12.6 driver>=560"

### CUDA RUNTIME ###

RUN apt-get update && apt-get install -y --no-install-recommends \
    cuda-libraries-12-6 \
    libnpp-12-6 \
    cuda-nvtx-12-6 \
    libcublas-12-6 \
    libcusparse-12-6 \
    libnccl2 \
    && rm -rf /var/lib/apt/lists/* \
    # Cleanup - cannot use cleanup script here, otherwise too much is removed
    && apt-get clean \
    && rm -rf $HOME/.cache/* \
    && rm -rf /tmp/* \
    && rm -rf /var/lib/apt/lists/*

RUN apt-mark hold libcublas-12-6 libnccl2

### END CUDA RUNTIME ###

### CUDA DEVEL ###
RUN apt-get update && apt-get install -y --no-install-recommends \
    # libtinfo5/libncursesw5 were only needed for cuda-gdb's ncurses ABI on older Ubuntu releases;
    # Ubuntu 24.04's own base packages already ship the ncurses6 ABI CUDA 12.6's tools link against.
    cuda-cudart-dev-12-6 \
    cuda-command-line-tools-12-6 \
    cuda-minimal-build-12-6 \
    cuda-libraries-dev-12-6 \
    cuda-nvml-dev-12-6 \
    libnpp-dev-12-6 \
    libnccl-dev \
    libcublas-dev-12-6 \
    libcusparse-dev-12-6 && \
    # Cleanup - cannot use cleanup script here, otherwise too much is removed
    apt-get clean && \
    rm -rf $HOME/.cache/* && \
    rm -rf /tmp/* && \
    rm -rf /var/lib/apt/lists/*

# apt from auto upgrading the cublas package. See https://gitlab.com/nvidia/container-images/cuda/-/issues/88
RUN apt-mark hold libcublas-dev-12-6 libnccl-dev
ENV LIBRARY_PATH=/usr/local/cuda/lib64/stubs

### END CUDA DEVEL ###

### CUDNN9 DEVEL ###

# cudnn9-cuda-12-6 (the CUDA-12.6-suffixed meta-package) stopped being updated past 9.6.0.74-1
# and now pulls in a since-removed exact sub-package version, making it uninstallable. The
# unsuffixed cudnn9-cuda-12 meta-package (ABI-compatible across CUDA 12.x minor versions) is the
# one NVIDIA keeps current.
RUN apt-get update && apt-get install -y --no-install-recommends \
    cudnn9-cuda-12 \
    && apt-mark hold cudnn9-cuda-12 && \
    # Cleanup
    apt-get clean && \
    rm -rf /root/.cache/* && \
    rm -rf /tmp/* && \
    rm -rf /var/lib/apt/lists/*

### END CUDNN9 ###

# Link Cupti:
ENV LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/usr/local/cuda/extras/CUPTI/lib64

### GPU DATA SCIENCE LIBRARIES ###

RUN \
    apt-get update && \
    # libopenblas-base was split into per-threading-backend packages (libopenblas0-pthread etc.)
    # behind the libopenblas0 metapackage on modern Ubuntu; the old name is gone.
    apt-get install -y libomp-dev libopenblas0 && \
    # Install pytorch gpu - uninstall cpu only build first
    pip uninstall -y torch torchvision torchaudio && \
    # https://pytorch.org/get-started/locally/
    pip install --no-cache-dir torch==2.13.* torchvision torchaudio --index-url https://download.pytorch.org/whl/cu126 && \
    # Install cupy: https://cupy.dev/ - cupy-cuda12x covers the whole CUDA 12.x line
    pip install --no-cache-dir cupy-cuda12x && \
    # Install pycuda: https://pypi.org/project/pycuda
    pip install --no-cache-dir pycuda && \
    # Install gpu utils libs
    pip install --no-cache-dir gpustat nvidia-ml-py gputil && \
    # Install tensorflow gpu. Modern TensorFlow bundles GPU support into the plain 'tensorflow'
    # package (the old separate 'tensorflow-gpu' package was discontinued after TF 2.1); the
    # [and-cuda] extra pulls in TensorFlow's own pip-packaged CUDA/cuDNN runtime, so it works
    # independently of the exact system CUDA toolkit version installed above.
    pip uninstall -y tensorflow tensorflow-cpu intel-tensorflow && \
    pip install --no-cache-dir 'tensorflow[and-cuda]==2.21.*' && \
    # Install ONNX GPU Runtime
    pip uninstall -y onnxruntime && \
    pip install --no-cache-dir onnxruntime-gpu && \
    # Install jax with CUDA 12 support: https://github.com/jax-ml/jax#installation
    pip install --no-cache-dir -U "jax[cuda12]" && \
    # Install lightgbm with GPU support (the old pip --install-option flags were removed from pip;
    # this is the current scikit-build-core based way to select the GPU backend)
    pip uninstall -y lightgbm && \
    pip install --no-cache-dir lightgbm --config-settings=cmake.define.USE_GPU=ON && \
    # Ipyexperiments - fix memory leaks
    pip install --no-cache-dir ipyexperiments && \
    # Cleanup
    clean-layer.sh

# By default, the majority of GPU memory will be allocated by the first
# execution of a TensorFlow graph. While this behavior can be desirable for
# production pipelines, it is less desirable for interactive use. Set
# TF_FORCE_GPU_ALLOW_GROWTH to change this default behavior as if the user had
ENV TF_FORCE_GPU_ALLOW_GROWTH=true

### END DATA SCIENCE LIBRARIES ###

### GPU TOOLS ###

### END GPU TOOLS ###

# The base image's docker.conf runs dockerd with --storage-driver=fuse-overlayfs to fix nested
# Docker-in-Docker on the CPU flavor (see resources/supervisor/programs/docker.conf) - but
# fuse-overlayfs conflicts with the NVIDIA container runtime's device/library injection hooks,
# breaking `docker run --gpus ...` inside this GPU flavor. Swap it for vfs instead of just
# dropping it: vfs copies each layer to disk rather than union-mounting, so it sidesteps the
# overlay-on-overlay kernel limitation entirely (unlike plain overlay2) without fuse-overlayfs's
# hook conflict - this flavor needs BOTH ordinary nested `docker run`/`compose` AND nested
# `docker run --gpus ...` to work, not just one. Tradeoff: no layer sharing/caching inside the
# nested dockerd, so nested image pulls/builds use more disk and are slower than fuse-overlayfs
# or overlay2. The --bip/--default-address-pool flags (fixing a separate docker0-subnet
# collision with the host) stay, since those aren't storage-driver-related.
RUN sed -i 's/--storage-driver=fuse-overlayfs/--storage-driver=vfs/' /etc/supervisor/conf.d/docker.conf

### CONFIGURATION ###

#TODO: tests are currently empty COPY resources/tests/ /resources/tests

# arguments declared before FROM go out of scope after it - need to be re-declared to use below
ARG ARG_WORKSPACE_VERSION="latest"
ENV WORKSPACE_VERSION=$ARG_WORKSPACE_VERSION
ARG ARG_WORKSPACE_BASE_IMAGE

# Overwrite & add Labels
ARG ARG_BUILD_DATE="unknown"
ARG ARG_VCS_REF="unknown"

LABEL \
    "workspace.version"=$WORKSPACE_VERSION \
    "workspace.flavor"=$WORKSPACE_FLAVOR \
    "workspace.baseimage"=$ARG_WORKSPACE_BASE_IMAGE \
    "org.opencontainers.image.version"=$WORKSPACE_VERSION \
    "org.opencontainers.image.revision"=$ARG_VCS_REF \
    "org.opencontainers.image.created"=$ARG_BUILD_DATE \
    "org.label-schema.version"=$WORKSPACE_VERSION \
    "org.label-schema.vcs-ref"=$ARG_VCS_REF \
    "org.label-schema.build-date"=$ARG_BUILD_DATE
