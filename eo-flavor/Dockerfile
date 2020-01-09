ARG ARG_WORKSPACE_VERSION="latest"
# Build from full flavor of workspace with same version
FROM imansour/ml-workspace:$ARG_WORKSPACE_VERSION

ARG ARG_WORKSPACE_FLAVOR="eo"
ENV WORKSPACE_FLAVOR=$ARG_WORKSPACE_FLAVOR
# argument needs to be initalized again
ARG ARG_WORKSPACE_VERSION="latest"
ENV WORKSPACE_VERSION=$ARG_WORKSPACE_VERSION

USER root



SHELL ["/bin/bash", "-c"]
WORKDIR /opt/

### Sentinel Application Platform (SNAP) reunites all Sentinel Toolboxes ESA Installation  ###
# https://step.esa.int/main/download/snap-download
ENV SNAP_DIR=/opt/snap \
    SNAP_VERSION="7.0" \
    CONDA_PYTHON_DIR=/opt/conda/lib/python3.7

RUN mkdir -p /tmp/eo/ && cd /tmp/eo/ && \
    wget --quiet https://step.esa.int/downloads/${SNAP_VERSION}/installers/esa-snap_all_unix_${SNAP_VERSION//[.]/_}.sh -O ~/esa-snap.sh && \
    chmod +x ~/esa-snap.sh && \
    printf "# install4j response file for ESA SNAP 7.0 \
    \ndeleteSnapDir=DESKTOP \
    \nexecuteLauncherAction$Boolean=true \
    \nforcePython$Boolean=false \
    \nsys.adminRights$Boolean=true \
    \nsys.component.3109$Boolean=true \
    \nsys.component.RSTB$Boolean=true \
    \nsys.component.S1TBX$Boolean=true \
    \nsys.component.S2TBX$Boolean=true \
    \nsys.component.S3TBX$Boolean=true \
    \nsys.component.SMOS$Boolean=true \
    \nsys.component.SNAP$Boolean=true \
    \nsys.installationDir=${SNAP_DIR} \
    \nsys.languageId=en \
    \nsys.programGroupDisabled$Boolean=false \
    \nsys.symlinkDir=/usr/local/bin" > ~/response.varfile

RUN /bin/sh ~/esa-snap.sh -q -varfile response.varfile && \
    export PATH=$SNAP_DIR/bin:$PATH && \
    rm ~/esa-snap.sh ~/response.varfile
# -varfile ~/response.varfile

# link gpt so it can be used systemwide
RUN ln -s ${SNAP_DIR}/bin/gpt /usr/bin/gpt
### END SNAP Setup ###


### Sen2Cor Download + Installation  ###
ENV SEN2COR_VERSION="2.8.0"
# echo ${SEN2COR_VERSION} | sed 's/\([0-9]\)/0\1/g'
# https://step.esa.int/main/third-party-plugins-2/sen2cor/
# https://gitlab.irstea.fr/loic.lozach/AgriSoilMoisture/blob/master/tools/docker/esa-snap/Dockerfile
RUN wget --quiet https://step.esa.int/thirdparties/sen2cor/${SEN2COR_VERSION}/Sen2Cor-$(echo ${SEN2COR_VERSION} | sed 's/\([0-9]\)/0\1/g')-Linux64.run -O ~/Sen2Cor.run && \
    chmod +x ~/Sen2Cor.run && \
    /bin/bash ~/Sen2Cor.run && \
    export PATH=Sen2Cor-$(echo ${SEN2COR_VERSION} | sed 's/\([0-9]\)/0\1/g')-Linux64/bin:$PATH && \
    rm ~/Sen2Cor.run
#RUN ln -fs /opt/Sen2Cor-*/bin/julia /usr/local/bin/Sen2Cor

### END Sen2Cor Download + Install ###

#      RUN apt-get update && apt-get install -y --no-install-recommends \
#              cuda-libraries-dev-$CUDA_PKG_VERSION \
#              cuda-nvml-dev-$CUDA_PKG_VERSION \
#              cuda-minimal-build-$CUDA_PKG_VERSION \
#              cuda-command-line-tools-$CUDA_PKG_VERSION \
#              libnccl-dev=$NCCL_VERSION-1+cuda10.0 && \
#          rm -rf /var/lib/apt/lists/* && \ 
#          # Cleanup - cannot use cleanup script here, otherwise too much is removed
#          apt-get clean && \ 
#          rm -rf /root/.cache/* && \
#          rm -rf /tmp/* && \
#          rm -rf /var/lib/apt/lists/*
#      
#      ENV LIBRARY_PATH /usr/local/cuda/lib64/stubs
#      
#      ### END CUDA DEVEL ###
#      
#      
#      ### NVIDIA CUDA BASE ###
#      # https://gitlab.com/nvidia/cuda/blob/ubuntu16.04/10.0/base/Dockerfile
#      RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates apt-transport-https gnupg-curl && \
#          rm -rf /var/lib/apt/lists/* && \
#          NVIDIA_GPGKEY_SUM=d1be581509378368edeec8c1eb2958702feedf3bc3d17011adbf24efacce4ab5 && \
#          NVIDIA_GPGKEY_FPR=ae09fe4bbd223a84b2ccfce3f60f4b3d7fa2af80 && \
#          apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1604/x86_64/7fa2af80.pub && \
#          apt-key adv --export --no-emit-version -a $NVIDIA_GPGKEY_FPR | tail -n +5 > cudasign.pub && \
#          echo "$NVIDIA_GPGKEY_SUM  cudasign.pub" | sha256sum -c --strict - && rm cudasign.pub && \
#          echo "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1604/x86_64 /" > /etc/apt/sources.list.d/cuda.list && \
#          echo "deb https://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1604/x86_64 /" > /etc/apt/sources.list.d/nvidia-ml.list && \
#          # Cleanup - cannot use cleanup script here, otherwise too much is removed
#          apt-get clean && \ 
#          rm -rf $HOME/.cache/* && \
#          rm -rf /tmp/* && \
#          rm -rf /var/lib/apt/lists/*
#      
#      ENV CUDA_VERSION 10.0.130
#      ENV CUDA_PKG_VERSION 10-0=$CUDA_VERSION-1
#      
#      # For libraries in the cuda-compat-* package: https://docs.nvidia.com/cuda/eula/index.html#attachment-a
#      RUN apt-get update && apt-get install -y --no-install-recommends \
#              cuda-cudart-$CUDA_PKG_VERSION \
#              cuda-compat-10-0 && \
#          ln -s cuda-10.0 /usr/local/cuda && \
#          rm -rf /var/lib/apt/lists/* && \
#          # Cleanup - cannot use cleanup script here, otherwise too much is removed
#          apt-get clean && \ 
#          rm -rf $HOME/.cache/* && \
#          rm -rf /tmp/* && \
#          rm -rf /var/lib/apt/lists/*
#      
#      
#      RUN echo "/usr/local/nvidia/lib" >> /etc/ld.so.conf.d/nvidia.conf && \
#          echo "/usr/local/nvidia/lib64" >> /etc/ld.so.conf.d/nvidia.conf
#      
#      ENV PATH /usr/local/nvidia/bin:/usr/local/cuda/bin:${PATH}
#      ENV LD_LIBRARY_PATH /usr/local/nvidia/lib:/usr/local/nvidia/lib64:${LD_LIBRARY_PATH}
#      
#      # nvidia-container-runtime
#      # https://github.com/NVIDIA/nvidia-container-runtime#environment-variables-oci-spec
#      ENV NVIDIA_VISIBLE_DEVICES all
#      ENV NVIDIA_DRIVER_CAPABILITIES compute,utility
#      ENV NVIDIA_REQUIRE_CUDA "cuda>=10.0 brand=tesla,driver>=384,driver<385 brand=tesla,driver>=410,driver<411"
#      
#      ### CUDA RUNTIME ###
#      # https://gitlab.com/nvidia/cuda/blob/ubuntu16.04/10.0/runtime/Dockerfile
#      
#      ENV NCCL_VERSION 2.4.2
#      
#      RUN apt-get update && apt-get install -y --no-install-recommends \
#              cuda-libraries-$CUDA_PKG_VERSION \
#              cuda-nvtx-$CUDA_PKG_VERSION \
#              libnccl2=$NCCL_VERSION-1+cuda10.0 && \
#          apt-mark hold libnccl2 && \
#          rm -rf /var/lib/apt/lists/* && \
#          # Cleanup - cannot use cleanup script here, otherwise too much is removed
#          apt-get clean && \ 
#          rm -rf $HOME/.cache/* && \
#          rm -rf /tmp/* && \
#          rm -rf /var/lib/apt/lists/*
#      
#      ### END CUDA RUNTIME ###
#      
#      ### CUDA DEVEL ###
#      # https://gitlab.com/nvidia/cuda/blob/ubuntu16.04/10.0/devel/Dockerfile
#      RUN apt-get update && apt-get install -y --no-install-recommends \
#              cuda-libraries-dev-$CUDA_PKG_VERSION \
#              cuda-nvml-dev-$CUDA_PKG_VERSION \
#              cuda-minimal-build-$CUDA_PKG_VERSION \
#              cuda-command-line-tools-$CUDA_PKG_VERSION \
#              libnccl-dev=$NCCL_VERSION-1+cuda10.0 && \
#          rm -rf /var/lib/apt/lists/* && \ 
#          # Cleanup - cannot use cleanup script here, otherwise too much is removed
#          apt-get clean && \ 
#          rm -rf /root/.cache/* && \
#          rm -rf /tmp/* && \
#          rm -rf /var/lib/apt/lists/*
#      
#      ENV LIBRARY_PATH /usr/local/cuda/lib64/stubs
#      
#      ### END CUDA DEVEL ###
#      
#      ### CUDANN7 DEVEL ###
#      # https://gitlab.com/nvidia/cuda/blob/ubuntu16.04/10.0/devel/cudnn7/Dockerfile
#      
#      ENV CUDNN_VERSION 7.6.0.64
#      LABEL com.nvidia.cudnn.version="${CUDNN_VERSION}"
#      
#      RUN apt-get update && apt-get install -y --no-install-recommends \
#                  libcudnn7=$CUDNN_VERSION-1+cuda10.0 \
#                  libcudnn7-dev=$CUDNN_VERSION-1+cuda10.0 && \
#          apt-mark hold libcudnn7 && \
#          rm -rf /var/lib/apt/lists/* && \ 
#          # Cleanup
#          clean-layer.sh
#      
#      ### END CUDANN7 ###
#      
#      ### GPU DATA SCIENCE LIBRARIES ###
#      
#      RUN \
#          apt-get update && apt-get install -y libomp-dev libopenblas-base && \
#          # Not needed? Install cuda-toolkit (e.g. for pytorch: https://pytorch.org/): https://anaconda.org/anaconda/cudatoolkit
#          conda install -y cudatoolkit=10.0 -c pytorch && \
#          # Install cupy: https://cupy.chainer.org/
#          pip install --no-cache-dir cupy-cuda100 && \
#          # Install pycuda: https://pypi.org/project/pycuda
#          pip install --no-cache-dir pycuda && \
#          # Install gpu utils libs
#          pip install --no-cache-dir gpustat py3nvml gputil && \
#          # Install scikit-cuda: https://scikit-cuda.readthedocs.io/en/latest/install.html
#          pip install --no-cache-dir scikit-cuda && \
#          # Install tensorflow gpu - conda uninstall removes too much and conda remove corrupts environment
#          pip uninstall -y tensorflow && \
#          pip install --no-cache-dir tensorflow-gpu && \
#          # Install ONNX GPU Runtime
#          pip uninstall -y onnxruntime && \
#          pip install --no-cache-dir onnxruntime-gpu==0.5.0 && \
#          # Install pytorch gpu
#          # TODO: deprecated? most likely not installed
#          pip uninstall -y pytorch-cpu torchvision-cpu && \
#          # uninstall cpu only packages via conda
#          conda uninstall -y pytorch torchvision cpuonly -c pytorch && \
#          # https://pytorch.org/get-started/locally/
#          conda install -y pytorch torchvision cudatoolkit=10.0 -c pytorch && \
#          # pip install https://download.pytorch.org/whl/cu100/torch-1.1.0-cp36-cp36m-linux_x86_64.whl && \
#          # pip install https://download.pytorch.org/whl/cu100/torchvision-0.3.0-cp36-cp36m-linux_x86_64.whl && \
#          # install jax: https://github.com/google/jax#pip-installation
#          pip install --no-cache-dir --upgrade https://storage.googleapis.com/jax-wheels/cuda100/jaxlib-0.1.28-cp36-none-linux_x86_64.whl && \
#          pip install --no-cache-dir --upgrade jax  && \
#          # Install Spacy GPU Support:
#          pip install --no-cache-dir thinc-gpu-ops && \
#          # Install Rapids: https://rapids.ai/start.html#conda-install
#          conda install -c rapidsai -c nvidia -c numba -c pytorch -c conda-forge -c defaults \
#                  cudatoolkit=10.0 \
#                  libiconv \
#                  python=3.6 \
#                  pillow=6.1.0 \
#                  cudf=0.9 \
#                  cuml=0.9 \
#                  cugraph=0.9 \
#                  nvstrings=0.9 \
#                  dask-cuda=0.9 && \
#          # Install pygpu - Required for theano: http://deeplearning.net/software/libgpuarray/
#          conda install -y pygpu && \
#          # nvidia python ml lib
#          pip install --upgrade --force-reinstall nvidia-ml-py3 && \ 
#          # Install graphvite graph embedding lib: https://github.com/DeepGraphLearning/graphvite
#          conda install -c milagraph graphvite cudatoolkit=10.0 && \ 
#          # Install Jupyterlab GPU Plugin: https://github.com/jacobtomlinson/jupyterlab-nvdashboard - TODO deactivate jupyter plugin
#          # pip install --no-cache-dir jupyterlab-nvdashboard && \
#          # jupyter labextension install jupyterlab-nvdashboard && \
#          # Cleanup
#          # Cleanup python bytecode files - not needed: https://jcrist.github.io/conda-docker-tips.html
#          find ${CONDA_DIR} -type f -name '*.pyc' -delete && \
#          find ${CONDA_DIR} -type l -name '*.pyc' -delete && \
#          clean-layer.sh
#      
#      # https://www.anaconda.com/getting-started-with-gpu-computing-in-anaconda/
#      
#      # By default, the majority of GPU memory will be allocated by the first
#      # execution of a TensorFlow graph. While this behavior can be desirable for
#      # production pipelines, it is less desirable for interactive use. Set
#      # TF_FORCE_GPU_ALLOW_GROWTH to change this default behavior as if the user had
#      ENV TF_FORCE_GPU_ALLOW_GROWTH true
#      
#      ### END DATA SCIENCE LIBRARIES ###
#      
#      ### GPU TOOLS ###
#      
#      # Install Glances & Netdata GPU Support
#      RUN \
#          apt-get update -y && \
#          apt-get install lm-sensors -y && \
#          apt-get install netcat -y && \
#          apt-get install iproute -y && \
#          apt-get clean && \
#          rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
#          git clone https://github.com/Splo0sh/netdata_nv_plugin --depth 1 /tmp/netdata_nv_plugin && \
#          cp /tmp/netdata_nv_plugin/nv.chart.py /usr/libexec/netdata/python.d/ && \
#          cp /tmp/netdata_nv_plugin/python_modules/pynvml.py /usr/libexec/netdata/python.d/python_modules/ && \
#          cp /tmp/netdata_nv_plugin/nv.conf /etc/netdata/python.d/ && \
#          # Cleanup
#          clean-layer.sh
#      
#      ### END GPU TOOLS ###
#      
#      ### CONFIGURATION ###
#      
#      # TODO what does this line do?
#      RUN \
#          echo 'Defaults env_keep += "ftp_proxy http_proxy https_proxy no_proxy"' >> /etc/sudoers
#      
# Overwrite & add Labels
ARG ARG_BUILD_DATE="unknown"
ARG ARG_VCS_REF="unknown"


# Overwrite & add Labels
LABEL \
    "maintainer"="is3mansour@gmail.com" \
    "workspace.version"=$WORKSPACE_VERSION \
    "workspace.flavor"=$WORKSPACE_FLAVOR \
    # Kubernetes Labels
    "io.k8s.description"="All-in-one web-based development environment for machine learning and Earth Observation Toolboxes." \
    "io.k8s.display-name"="Machine Learning and Earth Observation Workspace" \
    # Openshift labels: https://docs.okd.io/latest/creating_images/metadata.html
    "io.openshift.expose-services"="8080:http, 5901:xvnc" \
    "io.openshift.non-scalable"="true" \
    "io.openshift.tags"="workspace, machine learning, earth, observation, vnc, ubuntu, xfce" \
    "io.openshift.min-memory"="1Gi" \
    # Open Container labels: https://github.com/opencontainers/image-spec/blob/master/annotations.md
    "org.opencontainers.image.title"="Machine Learning Earth Observation Workspace" \
    "org.opencontainers.image.description"="All-in-one web-based development environment for machine learning and earth observation." \
    "org.opencontainers.image.documentation"="https://github.com/IslamAlam/ml-workspace" \
    "org.opencontainers.image.url"="https://github.com/IslamAlam/ml-workspace" \
    "org.opencontainers.image.source"="https://github.com/IslamAlam/ml-workspace" \
    # "org.opencontainers.image.licenses"="Apache-2.0" \
    "org.opencontainers.image.version"=$WORKSPACE_VERSION \
    "org.opencontainers.image.vendor"="ML Tooling for Earth Observation" \
    "org.opencontainers.image.authors"="Islam Mansour" \
    "org.opencontainers.image.revision"=$ARG_VCS_REF \
    "org.opencontainers.image.created"=$ARG_BUILD_DATE \ 
    # Label Schema Convention (deprecated): http://label-schema.org/rc1/
    "org.label-schema.name"="Machine Learning Workspace" \
    "org.label-schema.description"="All-in-one web-based development environment for machine learning and Earth Observation." \
    "org.label-schema.usage"="https://github.com/IslamAlam/ml-workspace" \
    "org.label-schema.url"="https://github.com/IslamAlam/ml-workspace" \
    "org.label-schema.vcs-url"="https://github.com/IslamAlam/ml-workspace" \
    "org.label-schema.vendor"="ML Tooling" \
    "org.label-schema.version"=$WORKSPACE_VERSION \
    "org.label-schema.schema-version"="1.0" \
    "org.label-schema.vcs-ref"=$ARG_VCS_REF \
    "org.label-schema.build-date"=$ARG_BUILD_DATE


# TODO use temp as data environment to use temp folder?
# DATA_ENVIRONMENT="temp"

# USER $NB_USER

#RUN \
#    echo "export PATH=$PATH" >> $HOME/.bashrc
