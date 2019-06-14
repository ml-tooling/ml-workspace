FROM consol/ubuntu-xfce-vnc:1.4.0

USER root

### BASICS ###
# Technical Environment Variables
ENV LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8 \
    SHELL="/bin/bash" \
    HOME="/root"  \
    NB_USER=root \
    XDG_CACHE_HOME="/root/.cache/" \
    WORKSPACE_BASE_URL="/" \
    RESOURCES_PATH="/resources" \
    WORKSPACE_HOME="/workspace" \
    DATA_ENVIRONMENT="/workspace/environment" \
    WORKSPACE_TYPE="cpu" \
    SSL_RESOURCES_PATH="/resources/ssl"

# Make folders
RUN \
    mkdir $RESOURCES_PATH && chmod a+rwx $RESOURCES_PATH &&\
    mkdir $WORKSPACE_HOME && chmod a+rwx $WORKSPACE_HOME &&\
    mkdir $SSL_RESOURCES_PATH && chmod a+rwx $SSL_RESOURCES_PATH

# Layer cleanup script
COPY docker-res/scripts/clean_layer.sh  /resources/clean_layer.sh

# Install basics
RUN \
    apt-get update --fix-missing && \
    apt-get install sudo --yes && \
    apt-get install -y -q debian-archive-keyring debian-keyring && \
    apt-get update --fix-missing && \
    apt-get install --yes --no-install-recommends \
        # This is necessary for apt to access HTTPS sources: 
        apt-transport-https \
        # Solve debconf warning
        apt-utils \
        ca-certificates \
        build-essential \
        locales \
        pkg-config \
        curl libcurl3 \
        libgnome-keyring* \
        software-properties-common \
        python-software-properties \
        lsof \
        net-tools \
        cron \
        vim \
        git \
        mercurial \
        subversion \
        # ping support
        iputils-ping \
        wget \
        maven \
        jed \
        libglib2.0-0 \
        libxext6 \
        libsm6 \
        libxext-dev \
        libxrender1 \
        lmodern \
        libjpeg-dev \
        libpng-dev \
        libpng12-dev \
        libzmq-dev \
        protobuf-compiler \
        libprotobuf-dev \
        # cntk deps
        autoconf \
        automake \
        libtool \
        # OpenMPI support
        libopenmpi-dev \
        openmpi-bin \
        libtiff-dev \
        libjasper-dev \
        libatlas-base-dev \
        libblas-dev \
        libprotoc-dev \
        cmake  \
        # File Converter
        pandoc \
        fonts-liberation \
        msttcorefonts \
        font-manager \
        # Compression Libs
        bzip2 \
        rsync \
        zip \
        gzip \
        unzip \
        zlib1g-dev \
        liblapack-dev \
        google-perftools \
        # Json Processor
        jq && \
    echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen && \
    # update-locale LANG=en_US.UTF-8?
    chmod -R a+rwx /usr/local/bin/ && \
    # configure dynamic linker run-time bindings
    ldconfig && \
    # Make clean layer executable
    chmod a+rwx /resources/clean_layer.sh && \ 
    # Cleanup
    /resources/clean_layer.sh

# Add tini
RUN wget --quiet https://github.com/krallin/tini/releases/download/v0.18.0/tini -O /tini && \
    chmod +x /tini

# Install Nginx. 
# Install apache2-utils to generate user:password file for nginx.
RUN \
    printf "deb http://nginx.org/packages/debian/ jessie nginx\ndeb-src http://nginx.org/packages/debian/ jessie nginx" | tee -a /etc/apt/sources.list && \
    curl http://nginx.org/keys/nginx_signing.key | apt-key add - && \
    apt-get update && \
    apt-get install -y nginx && \
    echo "\ndaemon off;" >> /etc/nginx/nginx.conf && \
    apt-get install -y apache2-utils && \
    # Cleanup
    /resources/clean_layer.sh

# prepare ssh for inter-container communication for remote python kernel
RUN \
    apt-get update && \
    apt-get install --yes --no-install-recommends \
        openssh-client \
        openssh-server \
        # SSLH for SSH + HTTP(s) Multiplexing
        sslh && \
    chmod go-w /root && \
    mkdir -p /root/.ssh/ && \
    # create empty config file if not exists
    touch /root/.ssh/config  && \
    sudo chown -R $NB_USER:users /root/.ssh && \
    chmod 700 /root/.ssh && \
    printenv >> /root/.ssh/environment && \
    chmod -R a+rwx /usr/local/bin/ && \
    # Cleanup
    /resources/clean_layer.sh

### END BASICS ###

### DEV BASICS ###
# Install newest nodejs version
RUN \
    apt-get update && \
    curl -sL https://deb.nodesource.com/setup_11.x | sudo -E bash - && \
    apt-get install nodejs --yes && \
    # Cleanup
    /resources/clean_layer.sh

# Install anaconda
ENV \
    CONDA_DIR=/opt/conda \
    CONDA_VERSION=2019.03 \
    CONDA_PYTHON_DIR=/opt/conda/lib/python3.6

RUN \
    # Anaconda packages: https://docs.anaconda.com/anaconda/packages/py3.6_linux-64/
    echo 'export PATH=$CONDA_DIR/bin:$PATH' > /etc/profile.d/conda.sh && \
    wget --quiet https://repo.continuum.io/archive/Anaconda3-${CONDA_VERSION}-Linux-x86_64.sh -O ~/anaconda.sh && \
    /bin/bash ~/anaconda.sh -b -p $CONDA_DIR && \
    export PATH=$CONDA_DIR/bin:$PATH && \
    rm ~/anaconda.sh && \
    # Update conda∂
    $CONDA_DIR/bin/conda update -n base conda && \
    # Update selected packages - install python 3.6
    $CONDA_DIR/bin/conda install python=3.6 && \
    $CONDA_DIR/bin/conda uninstall spyder && \
    $CONDA_DIR/bin/conda install cmake && \
    $CONDA_DIR/bin/conda update mkl qt jupyterlab notebook ipython cython numpy matplotlib numba ipykernel scipy scikit-learn && \
    # Add conda forge - Append so that conda forge has lower priority than the main channel
    $CONDA_DIR/bin/conda config --system --append channels conda-forge && \
    $CONDA_DIR/bin/conda config --system --set auto_update_conda false && \
    $CONDA_DIR/bin/conda config --system --set show_channel_urls true && \
    # Link Conda
    ln -s $CONDA_DIR/bin/python /usr/local/bin/python && \
    ln -s /opt/conda/bin/conda /usr/bin/conda && \
    # As conda is first in path, the commands 'node' and 'npm' reference to the version of conda. 
    # Replace those versions with the newly installed versions of node
    rm -f /opt/conda/bin/node && ln -s /usr/bin/node /opt/conda/bin/node && \
    rm -f /opt/conda/bin/npm && ln -s /usr/bin/npm /opt/conda/bin/npm && \
    # Update pip
    pip install --upgrade pip && \
    chmod -R a+rwx /usr/local/bin/ && \
    # Cleanup
    $CONDA_DIR/bin/conda clean --packages && \
    $CONDA_DIR/bin/conda clean -all -f -y  && \
    /resources/clean_layer.sh

ENV PATH=$CONDA_DIR/bin:$PATH

# There is nothing added yet to LD_LIBRARY_PATH, so we can overwrite
ENV LD_LIBRARY_PATH=$CONDA_DIR/lib 

# Install Git LFS
RUN \
    curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | sudo bash && \
    apt-get install git-lfs --yes && \
    git lfs install && \
    # Cleanup
    /resources/clean_layer.sh

# Install Java Runtime
RUN \
    apt-get update && \
    apt-get install -y openjdk-8-jdk && \
    # Cleanup
    /resources/clean_layer.sh

ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64

### END DEV BASICS ###

### GUI TOOLS ###
# Install Terminal / GDebi (Package Manager) / Glogg (Stream file viewer) & archive tools
RUN \
    apt-get update && \
    apt-get install xfce4-terminal --yes && \
    apt-get install xfce4-taskmanager --yes --allow-unauthenticated && \
    apt-get install gnome-tweak-tool --yes && \
    apt-get install gnome-search-tool --yes && \
    apt-get install gdebi --yes && \
    apt-get install glogg --yes && \
    apt-get install filezilla --yes && \
    apt-get install baobab --yes && \
    # Install Zipping Tools 
    apt-get install unrar zip unzip --yes && \
    apt-get install p7zip p7zip-rar --yes && \
    apt-get install thunar-archive-plugin --yes && \
    apt-get install file-roller --yes && \
    # Install Git Tools
    # one tool is enough? apt-get install giggle --yes && \
    apt-get install gitg --yes && \
    # DB Utils
    apt-get install sqlitebrowser --yes  && \
    # Cleanup
    /resources/clean_layer.sh

# Add the defaults from /lib/x86_64-linux-gnu, otherwise lots of no version errors
# cannot be added above otherwise there are errors in the installation of the gui tools
ENV LD_LIBRARY_PATH=/lib/x86_64-linux-gnu:$CONDA_DIR/lib 

# Install Visual Studio Code
RUN \
   wget --quiet https://go.microsoft.com/fwlink/?LinkID=760868 -O ./vscode.deb && \
   dpkg -i ./vscode.deb && \
   apt-get install -f -y && \
   rm ./vscode.deb && \
   rm /etc/apt/sources.list.d/vscode.list && \
   # Cleanup
   /resources/clean_layer.sh

## VS Code Webapp: https://github.com/codercom/code-server
RUN \
    apt-get update --fix-missing && \
    apt-get install --yes openssl && \
    wget --quiet https://github.com/cdr/code-server/releases/download/1.1119-vsc1.33.1/code-server1.1119-vsc1.33.1-linux-x64.tar.gz -O ./vscode-web.tar.gz && \
    tar xfz ./vscode-web.tar.gz && \
    mv ./code-server1.1119-vsc1.33.1-linux-x64/code-server /usr/local/bin && \
    rm ./vscode-web.tar.gz && \
    rm -rf ./code-server1.1119-vsc1.33.1-linux-x64 && \
    # Cleanup
    /resources/clean_layer.sh

# Install Web Tools - Offered via Jupyter Tooling Plugin
COPY docker-res/icons $RESOURCES_PATH/icons

## ungit
RUN \
    npm update && \
    npm install -g ungit@1.4.44 && \
    # Create desktop icon
    echo "[Desktop Entry]\nVersion=1.0\nType=Link\nName=Ungit\nComment=Git Client\nCategories=Development;\nIcon=/resources/icons/ungit-icon.png\nURL=http://localhost:8091/tools/ungit" > /usr/share/applications/ungit.desktop && \
    chmod +x /usr/share/applications/ungit.desktop && \
    # Cleanup
    /resources/clean_layer.sh

## netdata
RUN \
    apt-get update && \
    apt-get install --yes \
        lm-sensors \
        netcat \
        # already installed via anaconda: uuid-dev \
        iproute && \
    wget --quiet https://my-netdata.io/kickstart.sh -O $RESOURCES_PATH/netdata-install.sh && \
    /bin/bash $RESOURCES_PATH/netdata-install.sh --dont-wait --dont-start-it --stable-channel --disable-telemetry && \
    # Create desktop icon
    echo "[Desktop Entry]\nVersion=1.0\nType=Link\nName=Netdata\nComment=Hardware Monitoring\nCategories=System;Utility;Development;\nIcon=/resources/icons/netdata-icon.png\nURL=http://localhost:8091/tools/netdata" > /usr/share/applications/netdata.desktop && \
    chmod +x /usr/share/applications/netdata.desktop && \
    # Cleanup
    /resources/clean_layer.sh

## Glances
RUN \
    pip install --no-cache glances py-cpuinfo netifaces matplotlib hddtemp docker bottle && \
     # Create desktop icon
    echo "[Desktop Entry]\nVersion=1.0\nType=Link\nName=Glances\nComment=Hardware Monitoring\nCategories=System;Utility;\nIcon=/resources/icons/glances-icon.png\nURL=http://localhost:8091/tools/glances" > /usr/share/applications/glances.desktop && \
    chmod +x /usr/share/applications/glances.desktop && \
    # Cleanup
    /resources/clean_layer.sh

### END GUI TOOLS ###

### DATA SCIENCE BASICS ###

# MKL and Hardware Optimization
# Fix problem with MKL with duplicated libiomp5: https://github.com/dmlc/xgboost/issues/1715
# Alternative - use openblas instead of Intel MKL: conda install -y nomkl 
# http://markus-beuckelmann.de/blog/boosting-numpy-blas.html
# MKL:
# https://software.intel.com/en-us/articles/tips-to-improve-performance-for-popular-deep-learning-frameworks-on-multi-core-cpus
# https://github.com/intel/pytorch#bkm-on-xeon
# http://astroa.physics.metu.edu.tr/MANUALS/intel_ifc/mergedProjects/optaps_for/common/optaps_par_var.htm
ENV KMP_DUPLICATE_LIB_OK="True" \
    # TensorFlow uses less than half the RAM with tcmalloc relative to the default. - requires google-perftools
    LD_PRELOAD="/usr/lib/libtcmalloc.so.4" \
    # set number of threads mkl should use, if not-set, it tries to use all
    # this can be problematic since docker restricts CPUs by stil showing all
    OMP_NUM_THREADS="8" \
    # Control how to bind OpenMP* threads to physical processing units
    KMP_AFFINITY="granularity=fine,compact,1,0"
    # KMP_BLOCKTIME="1" -> is not faster in my tests

## Python 3

# Install FastText
RUN \
    mkdir $RESOURCES_PATH"/fasttext" && \
    cd $RESOURCES_PATH"/fasttext" && \
    wget --quiet https://github.com/facebookresearch/fastText/archive/v0.2.0.zip && \
    unzip -q v0.2.0.zip && \
    rm v0.2.0.zip && \
    cd fastText-0.2.0 && \
    make && \
    chmod -R a+rwx $RESOURCES_PATH"/fasttext" && \
    cp "fasttext" /usr/local/bin && \
    # Install fasttext python binding
    pip install . && \
    # Cleanup
    /resources/clean_layer.sh

# Data science libraries requirements
COPY docker-res/requirements.txt ${RESOURCES_PATH}

### Install main workspace libs
RUN \
    # upgrade pip
    pip install --upgrade pip && \
    # Install Packages
    apt-get update --yes && \
    apt-get install --yes graphviz  && \
    # Install mkl-include & mkldnn
    conda install --yes -c mingfeima mkldnn && \
    conda install --yes mkl-include && \
    # Install tensorflow - cpu only -  mkl support
    conda install --yes tensorflow && \
    # Install pytorch - cpu only
    conda install --yes -c pytorch pytorch-cpu torchvision-cpu && \
    conda install --yes faiss-cpu -c pytorch && \
    # Install pip requirements
    pip install --no-cache-dir --upgrade -r ${RESOURCES_PATH}/requirements.txt && \
    # Cleanup
    /resources/clean_layer.sh

RUN \ 
    # Spacy - download and large language removal
    python -m spacy download en && \
    # Remove unneeded languages - otherwise it takes up too much space
    cd $CONDA_PYTHON_DIR/site-packages/spacy/lang && \
    rm -rf tr pt da sv ca && \
    # Cleanup
    /resources/clean_layer.sh

## python 2
RUN \
    # anaconda=$CONDA_VERSION - do not install anaconda, it is too big
    conda create --yes -p $CONDA_DIR/envs/python2 python=2.7 && \
    ln -s $CONDA_DIR/envs/python2/bin/pip $CONDA_DIR/bin/pip2 && \
    ln -s $CONDA_DIR/envs/python2/bin/ipython2 $CONDA_DIR/bin/ipython2 && \
    # Install compatibility libraries
    pip2 install future enum34 six typing && \
    # Add as Python 2 kernel
    # Install Python 2 kernel spec globally to avoid permission problems when NB_UID
    # switching at runtime and to allow the notebook server running out of the root
    # environment to find it. Also, activate the python2 environment upon kernel launch.
    pip install kernda --no-cache && \
    $CONDA_DIR/envs/python2/bin/python -m pip install ipykernel && \
    $CONDA_DIR/envs/python2/bin/python -m ipykernel install && \
    pip2 install --upgrade pip && \
    kernda -o -y /usr/local/share/jupyter/kernels/python2/kernel.json && \
    pip uninstall kernda -y && \
    # Cleanup
    /resources/clean_layer.sh

### END DATA SCIENCE BASICS ###

### JUPYTER ###

COPY \
    docker-res/jupyter/start.sh \
    docker-res/jupyter/start-notebook.sh \
    docker-res/jupyter/start-singleuser.sh \
    /usr/local/bin/

# Jupyter pip requirements - components and extensions
COPY docker-res/jupyter_requirements.txt ${RESOURCES_PATH}

# install jupyter extensions
RUN \
    apt-get update && \
    conda install 'ipython=7.5.*' --yes && \
    conda install 'notebook=5.7.*' --yes && \
    npm update && \
    npm install -g webpack && \
    conda install --yes -c conda-forge libsodium && \
    # Install jupyter pip requirements
    pip install --no-cache-dir --upgrade -r ${RESOURCES_PATH}/jupyter_requirements.txt && \
    # Activate and configure extensions
    jupyter contrib nbextension install --user && \
    # Enable useful extensions
    jupyter nbextension enable skip-traceback/main && \
    jupyter nbextension enable comment-uncomment/main && \
    jupyter nbextension enable varInspector/main && \
    jupyter nbextension enable toc2/main && \
    jupyter nbextension enable spellchecker/main && \
    jupyter nbextension enable execute_time/ExecuteTime && \
    jupyter nbextension enable collapsible_headings/main && \
    jupyter nbextension enable codefolding/main && \
    # nbextensions configurator
    jupyter nbextensions_configurator enable --user && \
    # Configure nbdime
    nbdime config-git --enable --global && \
    # Active nbresuse
    jupyter serverextension enable --py nbresuse && \
    # Activate Jupytext
    jupyter nbextension enable --py jupytext && \
    # Activate qgrid
    jupyter nbextension enable --py --sys-prefix qgrid && \
    # Activate Colab support
    jupyter serverextension enable --py jupyter_http_over_ws && \
    # Activate Voila Rendering 
    jupyter serverextension enable voila --sys-prefix && \
    # Activate Jupyter Tensorboard
    jupyter tensorboard enable && \
    # Edit notebook config
    cat /root/.jupyter/nbconfig/notebook.json | jq '.toc2={"moveMenuLeft": false}' > tmp.$$.json && mv tmp.$$.json /root/.jupyter/nbconfig/notebook.json && \
    # Disable the cluster tab for now
    ipcluster nbextension enable && \
    # Cleanup
    /resources/clean_layer.sh

# install jupyterlab
RUN \
    conda install --yes 'jupyterlab=0.35.*' && \
    jupyter labextension install @jupyter-widgets/jupyterlab-manager@0.38 && \
    jupyter labextension install @jupyterlab/toc && \
    jupyter labextension install jupyterlab_tensorboard && \
    jupyter labextension install qgrid && \
    # Install Statusbar
    jupyter labextension install @jupyterlab/statusbar && \
    # For Bokeh
    jupyter labextension install jupyterlab_bokeh && \
    # For Plotly
    jupyter labextension install @jupyterlab/plotly-extension && \
    jupyter labextension install jupyterlab-chart-editor && \
    # For holoview
    jupyter labextension install @pyviz/jupyterlab_pyviz && \
    # install jupyterlab git
    jupyter labextension install @jupyterlab/git && \
    pip install jupyterlab-git==0.6.0 && \ 
    jupyter serverextension enable --py jupyterlab_git && \
    # Install jupyterlab_iframe - https://github.com/timkpaine/jupyterlab_iframe
    pip install jupyterlab_iframe==0.0.12 && \
    jupyter labextension install jupyterlab_iframe && \
    jupyter serverextension enable --py jupyterlab_iframe && \
    # Install jupyterlab_templates - https://github.com/timkpaine/jupyterlab_templates
    pip install jupyterlab_templates==0.0.8 && \
    jupyter labextension install jupyterlab_templates && \
    jupyter serverextension enable --py jupyterlab_templates && \
    # Install go-to-definition extension
    jupyter labextension install @krassowski/jupyterlab_go_to_definition && \
    # Install jupyterlab variable inspector - https://github.com/lckr/jupyterlab-variableInspector
    jupyter labextension install @lckr/jupyterlab_variableinspector && \
    # Activate ipygrid in jupterlab
    jupyter labextension install ipyaggrid && \
    # Cleanup
    # Remove build folder -> is not needed
    rm -rf $CONDA_DIR/share/jupyter/lab/staging && \
    /resources/clean_layer.sh

# Add tensorboard patch - use tensorboard jupyter plugin instead of the actual tensorboard magic
COPY docker-res/jupyter/tensorboard_notebook_patch.py /opt/conda/lib/python3.6/site-packages/tensorboard/notebook.py

# Install Jupyter Tooling Extension
COPY docker-res/jupyter/extensions $RESOURCES_PATH/jupyter-extensions

RUN \
    pip install --no-cache-dir $RESOURCES_PATH/jupyter-extensions/tooling-extension/ && \
    # Cleanup
    /resources/clean_layer.sh

### END JUPYTER ###

### INCUBATION ZONE ###

RUN \
    apt-get update && \
    apt-get install --yes --no-install-recommends tmux nano && \
    # Cleanup
    /resources/clean_layer.sh

### END INCUBATION ZONE ###

### CONFIGURATION ###

# Configure git
RUN \
    git config --global core.fileMode false && \
    git config --global http.sslVerify false && \
    # Use store or credentialstore instead? timout == 365 days validity
    git config --global credential.helper 'cache --timeout=31540000'

# Configure Jupyter
COPY docker-res/jupyter/jupyter_notebook_config.py /etc/jupyter/
COPY docker-res/jupyter/logo.png $CONDA_DIR"/lib/python3.6/site-packages/notebook/static/base/images/logo.png"
COPY docker-res/jupyter/favicon.ico $CONDA_DIR"/lib/python3.6/site-packages/notebook/static/base/images/favicon.ico"
COPY docker-res/jupyter/favicon.ico $CONDA_DIR"/lib/python3.6/site-packages/notebook/static/favicon.ico"

# Configure Matplotlib
RUN \
    # Import matplotlib the first time to build the font cache.
    MPLBACKEND=Agg python -c "import matplotlib.pyplot" \
    # Stop Matplotlib printing junk to the console on first load
    sed -i "s/^.*Matplotlib is building the font cache using fc-list.*$/# Warning removed/g" $CONDA_PYTHON_DIR/site-packages/matplotlib/font_manager.py && \
    # Make matplotlib output in Jupyter notebooks display correctly
    mkdir -p /etc/ipython/ && echo "c = get_config(); c.IPKernelApp.matplotlib = 'inline'" > /etc/ipython/ipython_config.py

# Configure VNC
# Overwrite Backgrounds
COPY docker-res/bg_ml_foundation.png "/root/.config/bg_sakuli.png"
COPY docker-res/bg_ml_foundation.png "/headless/.config/bg_sakuli.png"

# Basic VNC Settings - no password
ENV \
    VNC_PW=vncpassword \
    VNC_RESOLUTION=1600x900

# vnc screen changes
RUN \
    sed -i "s@UI.initSetting('path', 'websockify')@UI.initSetting('path', 'workspace/tools/vnc/websockify')@g" /headless/noVNC/app/ui.js && \
    sed -i "s@UI.updateSetting('path')@UI.updateSetting('path', 'workspace/tools/vnc/websockify')@g" /headless/noVNC/app/ui.js && \
    sed -i "s@UI.initSetting('resize', 'off')@UI.initSetting('resize', 'remote')@g" /headless/noVNC/app/ui.js && \
    sed -i "s@UI.initSetting('reconnect', false)@UI.initSetting('reconnect', true)@g" /headless/noVNC/app/ui.js && \
    sed -i 's/<div id="noVNC_container">/<div id="noVNC_container" style="border-radius: 0 0 0 0">/g' /headless/noVNC/vnc.html && \
    sed -i 's@</head>@<link href="https://fonts.googleapis.com/css?family=Roboto" rel="stylesheet"></head>@g' /headless/noVNC/vnc.html && \
    sed -i 's@<div class="noVNC_logo" translate="no"><span>no</span>VNC</div>@<h1 id="noVNC_logo" style="color: white; text-shadow:none; font-family:'Roboto', sans-serif; line-height: initial; text-align: center; font-size: 120px;">Workspace<br />Desktop<br />VNC</h1>@g' /headless/noVNC/vnc.html && \
    sed -i 's@<div id="noVNC_control_bar">@<div id="noVNC_control_bar" style="background: #313131;">@g' /headless/noVNC/vnc.html && \
    perl -0pi.original -e 's@<div id="noVNC_connect_button"><div>\n\s*<img src="app/images/connect.svg"> Connect\n\s*</div></div>@<div id="noVNC_connect_button" style="background: #ffffff; box-shadow: initial;"><div style="color: black; border: initial; background: initial;">Connect</div></div>@g' /headless/noVNC/vnc.html

# Copy files into workspace
COPY \
    docker-res/run.py \
    docker-res/5xx.html \
    $RESOURCES_PATH/

# Copy scripts into workspace
COPY docker-res/scripts $RESOURCES_PATH/scripts
COPY docker-res/tools $RESOURCES_PATH/tools

# Copy some configuration files
COPY docker-res/config/ssh_config /root/.ssh/config
COPY docker-res/config/sshd_config /etc/ssh/sshd_config
COPY docker-res/config/nginx.conf /etc/nginx/nginx.conf
COPY docker-res/config/netdata.conf /etc/netdata/netdata.conf
COPY docker-res/config/mimeapps.list /root/.config/mimeapps.list
COPY docker-res/config/chromium-browser.init /root/.chromium-browser.init
COPY docker-res/jupyter/sidebar.jupyterlab-settings /root/.jupyter/lab/user-settings/@jupyterlab/application-extension/
COPY docker-res/jupyter/plugin.jupyterlab-settings /root/.jupyter/lab/user-settings/@jupyterlab/extensionmanager-extension/
# Assume yes to all apt commands, to avoid user confusion around stdin.
COPY docker-res/config/90assumeyes /etc/apt/apt.conf.d/

# Various configurations
RUN \
    # clear chome init file - not needed since we load settings manually
    > /dockerstartup/chrome-init.sh && \
    chmod -R a+rwx $WORKSPACE_HOME && \
    chmod -R a+rwx $RESOURCES_PATH && \
    cp -r /headless/Desktop $HOME/Desktop/ && \
    ln -s $RESOURCES_PATH/tools/ $HOME/Desktop/Tools && \
    ln -s $WORKSPACE_HOME $HOME/Desktop/workspace && \
    cp -r /headless/.config/xfce4/ /root/.config/ && \
    chmod a+rwx /usr/local/bin/start-notebook.sh && \
    chmod a+rwx /usr/local/bin/start.sh && \
    # Set /workspace as default directory to navigate to as root user
    echo  'cd '$WORKSPACE_HOME >> $HOME/.bashrc 

# Set default values for environment variables
ENV WORKSPACE_CONFIG_BACKUP="true"

### END CONFIGURATION ###

ARG workspace_version="unknown"
ENV WORKSPACE_VERSION=$workspace_version

# refresh ssh environment variables here again
RUN printenv > $HOME/.ssh/environment

# Overwrite & add Labels
LABEL "io.k8s.description"="All-in-one web-based IDE specialized for machine learning and data science." \
    "io.k8s.display-name"="Machine Learning Workspace" \
    "io.openshift.expose-services"="8091:http, 5901:xvnc" \
    "io.openshift.non-scalable"="true" \
    "io.openshift.tags"="	vnc, ubuntu, xfce, workspace, machine learning" \
    "io.openshift.min-memory"="1Gi" \
    "workspace.version"=$workspace_version \
    "workspace.type"=$WORKSPACE_TYPE

# This assures we have a volume mounted even if the user forgot to do bind mount.
# So that they do not lose their data if they delete the container.
# TODO: VOLUME [ "/workspace" ]

ENTRYPOINT ["/tini", "--", "python", "/resources/run.py"]

# Port 8091 is the main access port (also includes SSH)
# Port 5091 is the VNC port
# Port 8090 is the Jupyter Notebook Server

EXPOSE 8091
###
