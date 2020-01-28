ARG ARG_WORKSPACE_VERSION="latest"
# Build from full flavor of workspace with same version
FROM mltooling/ml-workspace:$ARG_WORKSPACE_VERSION

ARG ARG_WORKSPACE_FLAVOR="gpu"
ENV WORKSPACE_FLAVOR=$ARG_WORKSPACE_FLAVOR
# argument needs to be initalized again
ARG ARG_WORKSPACE_VERSION="latest"
ENV WORKSPACE_VERSION=$ARG_WORKSPACE_VERSION

USER root

### NVIDIA CUDA BASE ###
# https://gitlab.com/nvidia/container-images/cuda/blob/ubuntu18.04/10.1/base/Dockerfile
RUN apt-get update && apt-get install -y --no-install-recommends gnupg2 curl ca-certificates && \
    curl -fsSL https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/7fa2af80.pub | apt-key add - && \
    echo "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64 /" > /etc/apt/sources.list.d/cuda.list && \
    echo "deb https://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1804/x86_64 /" > /etc/apt/sources.list.d/nvidia-ml.list && \
    # Cleanup - cannot use cleanup script here, otherwise too much is removed
    apt-get clean && \ 
    rm -rf $HOME/.cache/* && \
    rm -rf /tmp/* && \
    rm -rf /var/lib/apt/lists/*

ENV CUDA_VERSION 10.1.168
ENV CUDA_PKG_VERSION 10-1=$CUDA_VERSION-1

# For libraries in the cuda-compat-* package: https://docs.nvidia.com/cuda/eula/index.html#attachment-a
RUN apt-get update && apt-get install -y --no-install-recommends \
        cuda-cudart-$CUDA_PKG_VERSION \
        cuda-compat-10-1 && \
    ln -s cuda-10.1 /usr/local/cuda && \
    rm -rf /var/lib/apt/lists/* && \
    # Cleanup - cannot use cleanup script here, otherwise too much is removed
    apt-get clean && \ 
    rm -rf $HOME/.cache/* && \
    rm -rf /tmp/* && \
    rm -rf /var/lib/apt/lists/*

# Required for nvidia-docker v1
RUN echo "/usr/local/nvidia/lib" >> /etc/ld.so.conf.d/nvidia.conf && \
    echo "/usr/local/nvidia/lib64" >> /etc/ld.so.conf.d/nvidia.conf

ENV PATH /usr/local/nvidia/bin:/usr/local/cuda/bin:${PATH}
ENV LD_LIBRARY_PATH /usr/local/nvidia/lib:/usr/local/nvidia/lib64:${LD_LIBRARY_PATH}

# nvidia-container-runtime
# https://github.com/NVIDIA/nvidia-container-runtime#environment-variables-oci-spec
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility
ENV NVIDIA_REQUIRE_CUDA "cuda>=10.1 brand=tesla,driver>=384,driver<385 brand=tesla,driver>=396,driver<397 brand=tesla,driver>=410,driver<411"

### CUDA RUNTIME ###
# https://gitlab.com/nvidia/container-images/cuda/blob/ubuntu18.04/10.1/runtime/Dockerfile

ENV NCCL_VERSION 2.4.2

RUN apt-get update && apt-get install -y --no-install-recommends \
        cuda-libraries-$CUDA_PKG_VERSION \
        cuda-nvtx-$CUDA_PKG_VERSION \
        libnccl2=$NCCL_VERSION-1+cuda10.1 && \
    apt-mark hold libnccl2 && \
    rm -rf /var/lib/apt/lists/* && \
    # Cleanup - cannot use cleanup script here, otherwise too much is removed
    apt-get clean && \ 
    rm -rf $HOME/.cache/* && \
    rm -rf /tmp/* && \
    rm -rf /var/lib/apt/lists/*

### END CUDA RUNTIME ###

### CUDA DEVEL ###
# https://gitlab.com/nvidia/container-images/cuda/blob/ubuntu18.04/10.1/devel/Dockerfile
RUN apt-get update && apt-get install -y --no-install-recommends \
        cuda-libraries-dev-$CUDA_PKG_VERSION \
        cuda-nvml-dev-$CUDA_PKG_VERSION \
        cuda-minimal-build-$CUDA_PKG_VERSION \
        cuda-command-line-tools-$CUDA_PKG_VERSION \
        libnccl-dev=$NCCL_VERSION-1+cuda10.1 && \
    rm -rf /var/lib/apt/lists/* && \ 
    # Cleanup - cannot use cleanup script here, otherwise too much is removed
    apt-get clean && \ 
    rm -rf /root/.cache/* && \
    rm -rf /tmp/* && \
    rm -rf /var/lib/apt/lists/*

ENV LIBRARY_PATH /usr/local/cuda/lib64/stubs

### END CUDA DEVEL ###

### CUDANN7 DEVEL ###
# https://gitlab.com/nvidia/container-images/cuda/blob/ubuntu18.04/10.1/devel/cudnn7/Dockerfile

ENV CUDNN_VERSION 7.6.0.64
LABEL com.nvidia.cudnn.version="${CUDNN_VERSION}"

RUN apt-get update && apt-get install -y --no-install-recommends \
            libcudnn7=$CUDNN_VERSION-1+cuda10.1 \
            libcudnn7-dev=$CUDNN_VERSION-1+cuda10.1 && \
    apt-mark hold libcudnn7 && \
    rm -rf /var/lib/apt/lists/* && \ 
    # Cleanup
    apt-get clean && \ 
    rm -rf /root/.cache/* && \
    rm -rf /tmp/* && \
    rm -rf /var/lib/apt/lists/*

### END CUDANN7 ###

# Link Cupti:
ENV LD_LIBRARY_PATH ${LD_LIBRARY_PATH}:/usr/local/cuda/extras/CUPTI/lib64

# Install TensorRT. Requires that libcudnn7 is installed above.
# https://www.tensorflow.org/install/gpu#ubuntu_1804_cuda_101
RUN apt-get update && apt-get install -y --no-install-recommends libnvinfer6=6.0.1-1+cuda10.1 \
    libnvinfer-dev=6.0.1-1+cuda10.1 \
    libnvinfer-plugin6=6.0.1-1+cuda10.1 && \
    # Cleanup
    clean-layer.sh

### GPU DATA SCIENCE LIBRARIES ###

RUN \
    apt-get update && \
    apt-get install -y libomp-dev libopenblas-base && \
    # Not needed? Install cuda-toolkit (e.g. for pytorch: https://pytorch.org/): https://anaconda.org/anaconda/cudatoolkit
    conda install -y cudatoolkit=10.1 -c pytorch && \
    # Install cupy: https://cupy.chainer.org/
    pip install --no-cache-dir cupy-cuda101 && \
    # Install pycuda: https://pypi.org/project/pycuda
    pip install --no-cache-dir pycuda && \
    # Install gpu utils libs
    pip install --no-cache-dir gpustat py3nvml gputil && \
    # Install scikit-cuda: https://scikit-cuda.readthedocs.io/en/latest/install.html
    pip install --no-cache-dir scikit-cuda && \
    # Install tensorflow gpu - conda uninstall removes too much and conda remove corrupts environment
    # only tensorflow 2.1 supports cuda 10.1
    pip uninstall -y tensorflow && \
    pip install --no-cache-dir tensorflow-gpu==2.1.0 && \
    # Install ONNX GPU Runtime
    pip uninstall -y onnxruntime && \
    pip install --no-cache-dir onnxruntime-gpu==1.1.1 && \
    # Install pytorch gpu
    # uninstall cpu only packages via conda
    conda remove --force -y pytorch torchvision cpuonly && \
    # https://pytorch.org/get-started/locally/
    conda install -y pytorch torchvision -c pytorch && \
    # Update mxnet to gpu edition
    pip uninstall -y mxnet-mkl && \
    pip install --no-cache-dir mxnet-cu101mkl==1.5.1.post0 && \
    # install jax: https://github.com/google/jax#pip-installation
    pip install --no-cache-dir --upgrade jax https://storage.googleapis.com/jax-releases/cuda101/jaxlib-0.1.37-cp37-none-linux_x86_64.whl && \
    # Install pygpu - Required for theano: http://deeplearning.net/software/libgpuarray/
    conda install -y pygpu && \
    # nvidia python ml lib
    pip install --upgrade --force-reinstall nvidia-ml-py3 && \ 
    # SpeedTorch: https://github.com/Santosh-Gupta/SpeedTorch
    pip install --no-cache-dir SpeedTorch && \ 
    # TODO: Install blazingsql
    # Install Jupyterlab GPU Plugin: https://github.com/jacobtomlinson/jupyterlab-nvdashboard - TODO deactivate jupyter plugin
    # pip install --no-cache-dir jupyterlab-nvdashboard && \
    # jupyter labextension install jupyterlab-nvdashboard && \
    # Cleanup
    # Cleanup python bytecode files - not needed: https://jcrist.github.io/conda-docker-tips.html
    find ${CONDA_DIR} -type f -name '*.pyc' -delete && \
    find ${CONDA_DIR} -type l -name '*.pyc' -delete && \
    clean-layer.sh

# Install Rapids: https://rapids.ai/start.html#conda-install
# conda install -c rapidsai -c nvidia -c conda-forge -c defaults \
# rapids=0.11 \
# python=3.7 \
# cudatoolkit=10.1 && \
# Install graphvite graph embedding lib: https://github.com/DeepGraphLearning/graphvite
# conda install -c milagraph graphvite cudatoolkit=10.1 && \ 

# Install Nvidia Apex
# RUN cd $RESOURCES_PATH && \
#    git clone https://github.com/NVIDIA/apex && \
#    cd apex && \
#    pip install -v --no-cache-dir --global-option="--cpp_ext" --global-option="--cuda_ext" ./ && \
    # Cleanup
#   clean-layer.sh

# https://www.anaconda.com/getting-started-with-gpu-computing-in-anaconda/

# By default, the majority of GPU memory will be allocated by the first
# execution of a TensorFlow graph. While this behavior can be desirable for
# production pipelines, it is less desirable for interactive use. Set
# TF_FORCE_GPU_ALLOW_GROWTH to change this default behavior as if the user had
ENV TF_FORCE_GPU_ALLOW_GROWTH true

### END DATA SCIENCE LIBRARIES ###

### GPU TOOLS ###

# Install Glances & Netdata GPU Support
RUN \
    apt-get update -y && \
    apt-get install lm-sensors -y && \
    apt-get install netcat -y && \
    apt-get install iproute2 -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    git clone https://github.com/Splo0sh/netdata_nv_plugin --depth 1 /tmp/netdata_nv_plugin && \
    cp /tmp/netdata_nv_plugin/nv.chart.py /usr/libexec/netdata/python.d/ && \
    cp /tmp/netdata_nv_plugin/python_modules/pynvml.py /usr/libexec/netdata/python.d/python_modules/ && \
    cp /tmp/netdata_nv_plugin/nv.conf /etc/netdata/python.d/ && \
    # Cleanup
    clean-layer.sh

### END GPU TOOLS ###

### CONFIGURATION ###

# TODO what does this line do?
RUN \
    echo 'Defaults env_keep += "ftp_proxy http_proxy https_proxy no_proxy"' >> /etc/sudoers

# Overwrite & add Labels
ARG ARG_BUILD_DATE="unknown"
ARG ARG_VCS_REF="unknown"

LABEL \
    "workspace.version"=$WORKSPACE_VERSION \
    "workspace.flavor"=$WORKSPACE_FLAVOR \
    "org.opencontainers.image.version"=$WORKSPACE_VERSION \
    "org.opencontainers.image.revision"=$ARG_VCS_REF \
    "org.opencontainers.image.created"=$ARG_BUILD_DATE \ 
    "org.label-schema.version"=$WORKSPACE_VERSION \
    "org.label-schema.vcs-ref"=$ARG_VCS_REF \
    "org.label-schema.build-date"=$ARG_BUILD_DATE

# TODO use temp as data environment to use temp folder?
# DATA_ENVIRONMENT="temp"

# USER $NB_USER

#RUN \
#    echo "export PATH=$PATH" >> $HOME/.bashrc
