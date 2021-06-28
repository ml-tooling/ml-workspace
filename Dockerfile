FROM ubuntu:20.04

USER root

### BASICS ###
# Technical Environment Variables
ENV \
    SHELL="/bin/bash" \
    HOME="/root"  \
    # Nobteook server user: https://github.com/jupyter/docker-stacks/blob/master/base-notebook/Dockerfile#L33
    NB_USER="root" \
    USER_GID=0 \
    XDG_CACHE_HOME="/root/.cache/" \
    XDG_RUNTIME_DIR="/tmp" \
    DISPLAY=":1" \
    TERM="xterm" \
    DEBIAN_FRONTEND="noninteractive" \
    RESOURCES_PATH="/resources" \
    SSL_RESOURCES_PATH="/resources/ssl" \
    WORKSPACE_HOME="/workspace"

WORKDIR $HOME

# Make folders
RUN \
    mkdir $RESOURCES_PATH && chmod a+rwx $RESOURCES_PATH && \
    mkdir $WORKSPACE_HOME && chmod a+rwx $WORKSPACE_HOME && \
    mkdir $SSL_RESOURCES_PATH && chmod a+rwx $SSL_RESOURCES_PATH

# Layer cleanup script
COPY resources/scripts/clean-layer.sh  /usr/bin/clean-layer.sh
COPY resources/scripts/fix-permissions.sh  /usr/bin/fix-permissions.sh

 # Make clean-layer and fix-permissions executable
 RUN \
    chmod a+rwx /usr/bin/clean-layer.sh && \
    chmod a+rwx /usr/bin/fix-permissions.sh

# Generate and Set locals
# https://stackoverflow.com/questions/28405902/how-to-set-the-locale-inside-a-debian-ubuntu-docker-container#38553499
RUN \
    apt-get update && \
    apt-get install -y locales && \
    # install locales-all?
    sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8 && \
    # Cleanup
    clean-layer.sh

ENV LC_ALL="en_US.UTF-8" \
    LANG="en_US.UTF-8" \
    LANGUAGE="en_US:en"

# Install basics
RUN \
    # TODO add repos?
    # add-apt-repository ppa:apt-fast/stable
    # add-apt-repository 'deb http://security.ubuntu.com/ubuntu xenial-security main'
    apt-get update --fix-missing && \
    apt-get install -y sudo apt-utils && \
    apt-get upgrade -y && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        # This is necessary for apt to access HTTPS sources:
        apt-transport-https \
        gnupg-agent \
        gpg-agent \
        gnupg2 \
        ca-certificates \
        build-essential \
        pkg-config \
        software-properties-common \
        lsof \
        net-tools \
        libcurl4 \
        curl \
        wget \
        cron \
        openssl \
        iproute2 \
        psmisc \
        tmux \
        dpkg-sig \
        uuid-dev \
        csh \
        xclip \
        clinfo \
        time \
        libssl-dev \
        libgdbm-dev \
        libncurses5-dev \
        libncursesw5-dev \
        # required by pyenv
        libreadline-dev \
        libedit-dev \
        xz-utils \
        gawk \
        # Simplified Wrapper and Interface Generator (5.8MB) - required by lots of py-libs
        swig \
        # Graphviz (graph visualization software) (4MB)
        graphviz libgraphviz-dev \
        # Terminal multiplexer
        screen \
        # Editor
        nano \
        # Find files
        locate \
        # Dev Tools
        sqlite3 \
        # XML Utils
        xmlstarlet \
        # GNU parallel
        parallel \
        #  R*-tree implementation - Required for earthpy, geoviews (3MB)
        libspatialindex-dev \
        # Search text and binary files
        yara \
        # Minimalistic C client for Redis
        libhiredis-dev \
        # postgresql client
        libpq-dev \
        # mysql client (10MB)
        libmysqlclient-dev \
        # mariadb client (7MB)
        # libmariadbclient-dev \
        # image processing library (6MB), required for tesseract
        libleptonica-dev \
        # GEOS library (3MB)
        libgeos-dev \
        # style sheet preprocessor
        less \
        # Print dir tree
        tree \
        # Bash autocompletion functionality
        bash-completion \
        # ping support
        iputils-ping \
        # Map remote ports to localhosM
        socat \
        # Json Processor
        jq \
        rsync \
        # sqlite3 driver - required for pyenv
        libsqlite3-dev \
        # VCS:
        git \
        subversion \
        jed \
        # odbc drivers
        unixodbc unixodbc-dev \
        # Image support
        libtiff-dev \
        libjpeg-dev \
        libpng-dev \
        libglib2.0-0 \
        libxext6 \
        libsm6 \
        libxext-dev \
        libxrender1 \
        libzmq3-dev \
        # protobuffer support
        protobuf-compiler \
        libprotobuf-dev \
        libprotoc-dev \
        autoconf \
        automake \
        libtool \
        cmake  \
        fonts-liberation \
        google-perftools \
        # Compression Libs
        # also install rar/unrar? but both are propriatory or unar (40MB)
        zip \
        gzip \
        unzip \
        bzip2 \
        lzop \
	    # deprecates bsdtar (https://ubuntu.pkgs.org/20.04/ubuntu-universe-i386/libarchive-tools_3.4.0-2ubuntu1_i386.deb.html)
        libarchive-tools \
        zlibc \
        # unpack (almost) everything with one command
        unp \
        libbz2-dev \
        liblzma-dev \
        zlib1g-dev && \
    # Update git to newest version
    add-apt-repository -y ppa:git-core/ppa  && \
    apt-get update && \
    apt-get install -y --no-install-recommends git && \
    # Fix all execution permissions
    chmod -R a+rwx /usr/local/bin/ && \
    # configure dynamic linker run-time bindings
    ldconfig && \
    # Fix permissions
    fix-permissions.sh $HOME && \
    # Cleanup
    clean-layer.sh

# Add tini
RUN wget --no-verbose https://github.com/krallin/tini/releases/download/v0.19.0/tini -O /tini && \
    chmod +x /tini

# prepare ssh for inter-container communication for remote python kernel
RUN \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        openssh-client \
        openssh-server \
        # SSLH for SSH + HTTP(s) Multiplexing
        sslh \
        # SSH Tooling
        autossh \
        mussh && \
    chmod go-w $HOME && \
    mkdir -p $HOME/.ssh/ && \
    # create empty config file if not exists
    touch $HOME/.ssh/config  && \
    sudo chown -R $NB_USER:users $HOME/.ssh && \
    chmod 700 $HOME/.ssh && \
    printenv >> $HOME/.ssh/environment && \
    chmod -R a+rwx /usr/local/bin/ && \
    # Fix permissions
    fix-permissions.sh $HOME && \
    # Cleanup
    clean-layer.sh

RUN \
    OPEN_RESTY_VERSION="1.19.3.2" && \
    mkdir $RESOURCES_PATH"/openresty" && \
    cd $RESOURCES_PATH"/openresty" && \
    apt-get update && \
    apt-get purge -y nginx nginx-common && \
    # libpcre required, otherwise you get a 'the HTTP rewrite module requires the PCRE library' error
    # Install apache2-utils to generate user:password file for nginx.
    apt-get install -y libssl-dev libpcre3 libpcre3-dev apache2-utils && \
    wget --no-verbose https://openresty.org/download/openresty-$OPEN_RESTY_VERSION.tar.gz  -O ./openresty.tar.gz && \
    tar xfz ./openresty.tar.gz && \
    rm ./openresty.tar.gz && \
    cd ./openresty-$OPEN_RESTY_VERSION/ && \
    # Surpress output - if there is a problem remove  > /dev/null
    ./configure --with-http_stub_status_module --with-http_sub_module > /dev/null && \
    make -j2 > /dev/null && \
    make install > /dev/null && \
    # create log dir and file - otherwise openresty will throw an error
    mkdir -p /var/log/nginx/ && \
    touch /var/log/nginx/upstream.log && \
    cd $RESOURCES_PATH && \
    rm -r $RESOURCES_PATH"/openresty" && \
    # Fix permissions
    chmod -R a+rwx $RESOURCES_PATH && \
    # Cleanup
    clean-layer.sh

ENV PATH=/usr/local/openresty/nginx/sbin:$PATH

COPY resources/nginx/lua-extensions /etc/nginx/nginx_plugins

### END BASICS ###

### RUNTIMES ###
# Install Miniconda: https://repo.continuum.io/miniconda/

ENV \
    # TODO: CONDA_DIR is deprecated and should be removed in the future
    CONDA_DIR=/opt/conda \
    CONDA_ROOT=/opt/conda \
    PYTHON_VERSION="3.8.10" \
    CONDA_PYTHON_DIR=/opt/conda/lib/python3.8 \
    MINICONDA_VERSION=4.9.2 \
    MINICONDA_MD5=122c8c9beb51e124ab32a0fa6426c656 \
    CONDA_VERSION=4.9.2

RUN wget --no-verbose https://repo.anaconda.com/miniconda/Miniconda3-py38_${CONDA_VERSION}-Linux-x86_64.sh -O ~/miniconda.sh && \
    echo "${MINICONDA_MD5} *miniconda.sh" | md5sum -c - && \
    /bin/bash ~/miniconda.sh -b -p $CONDA_ROOT && \
    export PATH=$CONDA_ROOT/bin:$PATH && \
    rm ~/miniconda.sh && \
    # Configure conda
    # TODO: Add conde-forge as main channel -> remove if testted
    # TODO, use condarc file
    $CONDA_ROOT/bin/conda config --system --add channels conda-forge && \
    $CONDA_ROOT/bin/conda config --system --set auto_update_conda False && \
    $CONDA_ROOT/bin/conda config --system --set show_channel_urls True && \
    $CONDA_ROOT/bin/conda config --system --set channel_priority strict && \
    # Deactivate pip interoperability (currently default), otherwise conda tries to uninstall pip packages
    $CONDA_ROOT/bin/conda config --system --set pip_interop_enabled false && \
    # Update conda
    $CONDA_ROOT/bin/conda update -y -n base -c defaults conda && \
    $CONDA_ROOT/bin/conda update -y setuptools && \
    $CONDA_ROOT/bin/conda install -y conda-build && \
    # Update selected packages - install python 3.8.x
    $CONDA_ROOT/bin/conda install -y --update-all python=$PYTHON_VERSION && \
    # Link Conda
    ln -s $CONDA_ROOT/bin/python /usr/local/bin/python && \
    ln -s $CONDA_ROOT/bin/conda /usr/bin/conda && \
    # Update
    $CONDA_ROOT/bin/conda install -y pip && \
    $CONDA_ROOT/bin/pip install --upgrade pip && \
    chmod -R a+rwx /usr/local/bin/ && \
    # Cleanup - Remove all here since conda is not in path as of now
    # find /opt/conda/ -follow -type f -name '*.a' -delete && \
    # find /opt/conda/ -follow -type f -name '*.js.map' -delete && \
    $CONDA_ROOT/bin/conda clean -y --packages && \
    $CONDA_ROOT/bin/conda clean -y -a -f  && \
    $CONDA_ROOT/bin/conda build purge-all && \
    # Fix permissions
    fix-permissions.sh $CONDA_ROOT && \
    clean-layer.sh

ENV PATH=$CONDA_ROOT/bin:$PATH

# There is nothing added yet to LD_LIBRARY_PATH, so we can overwrite
ENV LD_LIBRARY_PATH=$CONDA_ROOT/lib

# Install pyenv to allow dynamic creation of python versions
RUN git clone https://github.com/pyenv/pyenv.git $RESOURCES_PATH/.pyenv && \
    # Install pyenv plugins based on pyenv installer
    git clone https://github.com/pyenv/pyenv-virtualenv.git $RESOURCES_PATH/.pyenv/plugins/pyenv-virtualenv  && \
    git clone git://github.com/pyenv/pyenv-doctor.git $RESOURCES_PATH/.pyenv/plugins/pyenv-doctor && \
    git clone https://github.com/pyenv/pyenv-update.git $RESOURCES_PATH/.pyenv/plugins/pyenv-update && \
    git clone https://github.com/pyenv/pyenv-which-ext.git $RESOURCES_PATH/.pyenv/plugins/pyenv-which-ext && \
    apt-get update && \
    # TODO: lib might contain high vulnerability
    # Required by pyenv
    apt-get install -y --no-install-recommends libffi-dev && \
    clean-layer.sh

# Add pyenv to path
ENV PATH=$RESOURCES_PATH/.pyenv/shims:$RESOURCES_PATH/.pyenv/bin:$PATH \
    PYENV_ROOT=$RESOURCES_PATH/.pyenv

# Install pipx
RUN pip install pipx && \
    # Configure pipx
    python -m pipx ensurepath && \
    # Cleanup
    clean-layer.sh
ENV PATH=$HOME/.local/bin:$PATH

# Install node.js
RUN \
    apt-get update && \
    # https://nodejs.org/en/about/releases/ use even numbered releases, i.e. LTS versions
    curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash - && \
    apt-get install -y nodejs && \
    # As conda is first in path, the commands 'node' and 'npm' reference to the version of conda.
    # Replace those versions with the newly installed versions of node
    rm -f /opt/conda/bin/node && ln -s /usr/bin/node /opt/conda/bin/node && \
    rm -f /opt/conda/bin/npm && ln -s /usr/bin/npm /opt/conda/bin/npm && \
    # Fix permissions
    chmod a+rwx /usr/bin/node && \
    chmod a+rwx /usr/bin/npm && \
    # Fix node versions - put into own dir and before conda:
    mkdir -p /opt/node/bin && \
    ln -s /usr/bin/node /opt/node/bin/node && \
    ln -s /usr/bin/npm /opt/node/bin/npm && \
    # Update npm
    /usr/bin/npm install -g npm && \
    # Install Yarn
    /usr/bin/npm install -g yarn && \
    # Install typescript
    /usr/bin/npm install -g typescript && \
    # Install webpack - 32 MB
    /usr/bin/npm install -g webpack && \
    # Install node-gyp
    /usr/bin/npm install -g node-gyp && \
    # Update all packages to latest version
    /usr/bin/npm update -g && \
    # Cleanup
    clean-layer.sh

ENV PATH=/opt/node/bin:$PATH

# Java - removed

### END RUNTIMES ###

### PROCESS TOOLS ###

# Removed XRDP

# Install supervisor for process supervision
RUN \
    apt-get update && \
    # Create sshd run directory - required for starting process via supervisor
    mkdir -p /var/run/sshd && chmod 400 /var/run/sshd && \
    # Install rsyslog for syslog logging
    apt-get install -y --no-install-recommends rsyslog && \
    pipx install supervisor && \
    pipx inject supervisor supervisor-stdout && \
    # supervisor needs this logging path
    mkdir -p /var/log/supervisor/ && \
    # Cleanup
    clean-layer.sh

### END PROCESS TOOLS ###

### GUI TOOLS ###

# Install xfce4 & gui tools
RUN \
    # Use staging channel to get newest xfce4 version (4.16)
    add-apt-repository -y ppa:xubuntu-dev/staging && \
    apt-get update && \
    apt-get install -y --no-install-recommends xfce4 && \
    apt-get install -y --no-install-recommends gconf2 && \
    apt-get install -y --no-install-recommends xfce4-terminal && \
    apt-get install -y --no-install-recommends xfce4-clipman && \
    apt-get install -y --no-install-recommends xterm && \
    apt-get install -y --no-install-recommends --allow-unauthenticated xfce4-taskmanager  && \
    # Install dependencies to enable vncserver
    apt-get install -y --no-install-recommends xauth xinit dbus-x11 && \
    # Install gdebi deb installer
    apt-get install -y --no-install-recommends gdebi && \
    # Search for files
    apt-get install -y --no-install-recommends catfish && \
    apt-get install -y --no-install-recommends font-manager && \
    # vs support for thunar
    apt-get install -y thunar-vcs-plugin && \
    # Streaming text editor for large files - klogg is alternative to glogg
    apt-get install -y --no-install-recommends libqt5concurrent5 libqt5widgets5 libqt5xml5 && \
    wget --no-verbose https://github.com/variar/klogg/releases/download/v20.12/klogg-20.12.0.813-Linux.deb -O $RESOURCES_PATH/klogg.deb && \
    dpkg -i $RESOURCES_PATH/klogg.deb && \
    rm $RESOURCES_PATH/klogg.deb && \
    # Disk Usage Visualizer
    apt-get install -y --no-install-recommends baobab && \
    # Lightweight text editor
    apt-get install -y --no-install-recommends mousepad && \
    apt-get install -y --no-install-recommends vim && \
    # Process monitoring
    apt-get install -y --no-install-recommends htop && \
    # Install Archive/Compression Tools: https://wiki.ubuntuusers.de/Archivmanager/
    apt-get install -y p7zip p7zip-rar && \
    apt-get install -y --no-install-recommends thunar-archive-plugin && \
    apt-get install -y xarchiver && \
    # DB Utils
    apt-get install -y --no-install-recommends sqlitebrowser && \
    # Install nautilus and support for sftp mounting
    apt-get install -y --no-install-recommends nautilus gvfs-backends && \
    # Install gigolo - Access remote systems
    apt-get install -y --no-install-recommends gigolo gvfs-bin && \
    # xfce systemload panel plugin - needs to be activated
    # apt-get install -y --no-install-recommends xfce4-systemload-plugin && \
    # Leightweight ftp client that supports sftp, http, ...
    apt-get install -y --no-install-recommends gftp && \
    # Install chrome
    # sudo add-apt-repository ppa:system76/pop
    add-apt-repository ppa:saiarcot895/chromium-beta && \
    apt-get update && \
    apt-get install -y chromium-browser chromium-browser-l10n chromium-codecs-ffmpeg && \
    ln -s /usr/bin/chromium-browser /usr/bin/google-chrome && \
    # Cleanup
    apt-get purge -y pm-utils xscreensaver* && \
    # Large package: gnome-user-guide 50MB app-install-data 50MB
    apt-get remove -y app-install-data gnome-user-guide && \
    clean-layer.sh

# Add the defaults from /lib/x86_64-linux-gnu, otherwise lots of no version errors
# cannot be added above otherwise there are errors in the installation of the gui tools
# Call order: https://unix.stackexchange.com/questions/367600/what-is-the-order-that-linuxs-dynamic-linker-searches-paths-in
ENV LD_LIBRARY_PATH=/lib/x86_64-linux-gnu:/usr/lib/x86_64-linux-gnu:$CONDA_ROOT/lib

# Install VNC
RUN \
    apt-get update  && \
    # required for websockify
    # apt-get install -y python-numpy  && \
    cd ${RESOURCES_PATH} && \
    # Tiger VNC
    wget -qO- https://sourceforge.net/projects/tigervnc/files/stable/1.11.0/tigervnc-1.11.0.x86_64.tar.gz/download | tar xz --strip 1 -C / && \
    # Install websockify
    mkdir -p ./novnc/utils/websockify && \
    # Before updating the noVNC version, we need to make sure that our monkey patching scripts still work!!
    wget -qO- https://github.com/novnc/noVNC/archive/v1.2.0.tar.gz | tar xz --strip 1 -C ./novnc && \
    wget -qO- https://github.com/novnc/websockify/archive/v0.9.0.tar.gz | tar xz --strip 1 -C ./novnc/utils/websockify && \
    chmod +x -v ./novnc/utils/*.sh && \
    # create user vnc directory
    mkdir -p $HOME/.vnc && \
    # Fix permissions
    fix-permissions.sh ${RESOURCES_PATH} && \
    # Cleanup
    clean-layer.sh

# Install Web Tools - Offered via Jupyter Tooling Plugin

## VS Code Server: https://github.com/codercom/code-server
COPY resources/tools/vs-code-server.sh $RESOURCES_PATH/tools/vs-code-server.sh
RUN \
    /bin/bash $RESOURCES_PATH/tools/vs-code-server.sh --install && \
    # Cleanup
    clean-layer.sh

## ungit
COPY resources/tools/ungit.sh $RESOURCES_PATH/tools/ungit.sh
RUN \
    /bin/bash $RESOURCES_PATH/tools/ungit.sh --install && \
    # Cleanup
    clean-layer.sh

## netdata
COPY resources/tools/netdata.sh $RESOURCES_PATH/tools/netdata.sh
RUN \
    /bin/bash $RESOURCES_PATH/tools/netdata.sh --install && \
    # Cleanup
    clean-layer.sh

## Glances webtool is installed in python section below via requirements.txt

## Filebrowser
COPY resources/tools/filebrowser.sh $RESOURCES_PATH/tools/filebrowser.sh
RUN \
    /bin/bash $RESOURCES_PATH/tools/filebrowser.sh --install && \
    # Cleanup
    clean-layer.sh

ARG ARG_WORKSPACE_FLAVOR="full"
ENV WORKSPACE_FLAVOR=$ARG_WORKSPACE_FLAVOR

# Install Visual Studio Code
COPY resources/tools/vs-code-desktop.sh $RESOURCES_PATH/tools/vs-code-desktop.sh
RUN \
    # If minimal flavor - do not install
    if [ "$WORKSPACE_FLAVOR" = "minimal" ]; then \
        exit 0 ; \
    fi && \
    /bin/bash $RESOURCES_PATH/tools/vs-code-desktop.sh --install && \
    # Cleanup
    clean-layer.sh

# Install Firefox

COPY resources/tools/firefox.sh $RESOURCES_PATH/tools/firefox.sh

RUN \
    # If minimal flavor - do not install
    if [ "$WORKSPACE_FLAVOR" = "minimal" ]; then \
        exit 0 ; \
    fi && \
    /bin/bash $RESOURCES_PATH/tools/firefox.sh --install && \
    # Cleanup
    clean-layer.sh

### END GUI TOOLS ###

### DATA SCIENCE BASICS ###

## Python 3
# Data science libraries requirements
COPY resources/libraries ${RESOURCES_PATH}/libraries

### Install main data science libs
RUN \
    # Link Conda - All python are linke to the conda instances
    # Linking python 3 crashes conda -> cannot install anyting - remove instead
    # ln -s -f $CONDA_ROOT/bin/python /usr/bin/python3 && \
    # if removed -> cannot use add-apt-repository
    # rm /usr/bin/python3 && \
    # rm /usr/bin/python3.5
    ln -s -f $CONDA_ROOT/bin/python /usr/bin/python && \
    apt-get update && \
    # upgrade pip
    pip install --upgrade pip && \
    # If minimal flavor - install
    if [ "$WORKSPACE_FLAVOR" = "minimal" ]; then \
        # Install nomkl - mkl needs lots of space
        conda install -y --update-all 'python='$PYTHON_VERSION nomkl ; \
    else \
        # Install mkl for faster computations
        conda install -y --update-all 'python='$PYTHON_VERSION mkl-service mkl ; \
    fi && \
    # Install some basics - required to run container
    conda install -y --update-all \
            'python='$PYTHON_VERSION \
            'ipython=7.24.*' \
            'notebook=6.4.*' \
            'jupyterlab=3.0.*' \
            # TODO: nbconvert 6.x makes problems with template_path
            'nbconvert=5.6.*' \
            # TODO: temp fix: yarl version 1.5 is required for lots of libraries.
            'yarl==1.5.*' \
            # TODO install scipy, numpy, sklearn, and numexpr via conda for mkl optimizaed versions: https://docs.anaconda.com/mkl-optimizations/
            'scipy==1.7.*' \
            'numpy==1.19.*' \
            scikit-learn \
            numexpr && \
            # installed via apt-get and pip: protobuf \
            # installed via apt-get: zlib  && \
    # Switch of channel priority, makes some trouble
    conda config --system --set channel_priority false && \
    # Install minimal pip requirements
    pip install --no-cache-dir --upgrade --upgrade-strategy only-if-needed -r ${RESOURCES_PATH}/libraries/requirements-minimal.txt && \
    # If minimal flavor - exit here
    if [ "$WORKSPACE_FLAVOR" = "minimal" ]; then \
        # Remove pandoc - package for markdown conversion - not needed
        # TODO: conda remove -y --force pandoc && \
        # Fix permissions
        fix-permissions.sh $CONDA_ROOT && \
        # Cleanup
        clean-layer.sh && \
        exit 0 ; \
    fi && \
    # OpenMPI support
    apt-get install -y --no-install-recommends libopenmpi-dev openmpi-bin && \
    conda install -y --freeze-installed  \
        'python='$PYTHON_VERSION \
        boost \
        mkl-include && \
    # Install mkldnn
    conda install -y --freeze-installed -c mingfeima mkldnn && \
    # Install pytorch - cpu only
    conda install -y -c pytorch "pytorch==1.9.*" cpuonly && \
    # Install light pip requirements
    pip install --no-cache-dir --upgrade --upgrade-strategy only-if-needed -r ${RESOURCES_PATH}/libraries/requirements-light.txt && \
    # If light light flavor - exit here
    if [ "$WORKSPACE_FLAVOR" = "light" ]; then \
        # Fix permissions
        fix-permissions.sh $CONDA_ROOT && \
        # Cleanup
        clean-layer.sh && \
        exit 0 ; \
    fi && \
    # libartals == 40MB liblapack-dev == 20 MB
    apt-get install -y --no-install-recommends liblapack-dev libatlas-base-dev libeigen3-dev libblas-dev && \
    # pandoc -> installs libluajit -> problem for openresty
    # HDF5 (19MB)
    apt-get install -y --no-install-recommends libhdf5-dev && \
    # TBB threading optimization
    apt-get install -y --no-install-recommends libtbb-dev && \
    # required for tesseract: 11MB - tesseract-ocr-dev?
    apt-get install -y --no-install-recommends libtesseract-dev && \
    pip install --no-cache-dir tesserocr && \
    # TODO: installs tenserflow 2.4 - Required for tensorflow graphics (9MB)
    apt-get install -y --no-install-recommends libopenexr-dev && \
    #pip install --no-cache-dir tensorflow-graphics==2020.5.20 && \
    # GCC OpenMP (GOMP) support library
    apt-get install -y --no-install-recommends libgomp1 && \
    # Install Intel(R) Compiler Runtime - numba optimization
    # TODO: don't install, results in memory error: conda install -y --freeze-installed -c numba icc_rt && \
    # Install libjpeg turbo for speedup in image processing
    conda install -y --freeze-installed libjpeg-turbo && \
    # Add snakemake for workflow management
    conda install -y -c bioconda -c conda-forge snakemake-minimal && \
    # Add mamba as conda alternativ
    conda install -y -c conda-forge mamba && \
    # Faiss - A library for efficient similarity search and clustering of dense vectors.
    conda install -y --freeze-installed faiss-cpu && \
    # Install full pip requirements
    pip install --no-cache-dir --upgrade --upgrade-strategy only-if-needed --use-deprecated=legacy-resolver -r ${RESOURCES_PATH}/libraries/requirements-full.txt && \
    # Setup Spacy
    # Spacy - download and large language removal
    python -m spacy download en && \
    # Fix permissions
    fix-permissions.sh $CONDA_ROOT && \
    # Cleanup
    clean-layer.sh

# Fix conda version
RUN \
    # Conda installs wrong node version - relink conda node to the actual node
    rm -f /opt/conda/bin/node && ln -s /usr/bin/node /opt/conda/bin/node && \
    rm -f /opt/conda/bin/npm && ln -s /usr/bin/npm /opt/conda/bin/npm

### END DATA SCIENCE BASICS ###

### JUPYTER ###

COPY \
    resources/jupyter/start.sh \
    resources/jupyter/start-notebook.sh \
    resources/jupyter/start-singleuser.sh \
    /usr/local/bin/

# Configure Jupyter / JupyterLab
# Add as jupyter system configuration
COPY resources/jupyter/nbconfig /etc/jupyter/nbconfig
COPY resources/jupyter/jupyter_notebook_config.json /etc/jupyter/

# install jupyter extensions
RUN \
    # Create empty notebook configuration
    mkdir -p $HOME/.jupyter/nbconfig/ && \
    printf "{\"load_extensions\": {}}" > $HOME/.jupyter/nbconfig/notebook.json && \
    # Activate and configure extensions
    jupyter contrib nbextension install --sys-prefix && \
    # nbextensions configurator
    jupyter nbextensions_configurator enable --sys-prefix && \
    # Configure nbdime
    nbdime config-git --enable --global && \
    # Activate Jupytext
    jupyter nbextension enable --py jupytext --sys-prefix && \
    # Enable useful extensions
    jupyter nbextension enable skip-traceback/main --sys-prefix && \
    # jupyter nbextension enable comment-uncomment/main && \
    jupyter nbextension enable toc2/main --sys-prefix && \
    jupyter nbextension enable execute_time/ExecuteTime --sys-prefix && \
    jupyter nbextension enable collapsible_headings/main --sys-prefix && \
    jupyter nbextension enable codefolding/main --sys-prefix && \
    # Disable pydeck extension, cannot be loaded (404)
    jupyter nbextension disable pydeck/extension && \
    # Install and activate Jupyter Tensorboard
    pip install --no-cache-dir git+https://github.com/InfuseAI/jupyter_tensorboard.git && \
    jupyter tensorboard enable --sys-prefix && \
    # TODO moved to configuration files = resources/jupyter/nbconfig Edit notebook config
    # echo '{"nbext_hide_incompat": false}' > $HOME/.jupyter/nbconfig/common.json && \
    cat $HOME/.jupyter/nbconfig/notebook.json | jq '.toc2={"moveMenuLeft": false,"widenNotebook": false,"skip_h1_title": false,"sideBar": true,"number_sections": false,"collapse_to_match_collapsible_headings": true}' > tmp.$$.json && mv tmp.$$.json $HOME/.jupyter/nbconfig/notebook.json && \
    # If minimal flavor - exit here
    if [ "$WORKSPACE_FLAVOR" = "minimal" ]; then \
        # Cleanup
        clean-layer.sh && \
        exit 0 ; \
    fi && \
    # TODO: Not installed. Disable Jupyter Server Proxy
    # jupyter nbextension disable jupyter_server_proxy/tree --sys-prefix && \
    # Install jupyter black
    jupyter nbextension install https://github.com/drillan/jupyter-black/archive/master.zip --sys-prefix && \
    jupyter nbextension enable jupyter-black-master/jupyter-black --sys-prefix && \
    # If light flavor - exit here
    if [ "$WORKSPACE_FLAVOR" = "light" ]; then \
        # Cleanup
        clean-layer.sh && \
        exit 0 ; \
    fi && \
    # Install and activate what if tool
    pip install witwidget && \
    jupyter nbextension install --py --symlink --sys-prefix witwidget && \
    jupyter nbextension enable --py --sys-prefix witwidget && \
    # Activate qgrid
    jupyter nbextension enable --py --sys-prefix qgrid && \
    # TODO: Activate Colab support
    # jupyter serverextension enable --py jupyter_http_over_ws && \
    # Activate Voila Rendering
    # currently not working jupyter serverextension enable voila --sys-prefix && \
    # Enable ipclusters
    ipcluster nbextension enable && \
    # Fix permissions? fix-permissions.sh $CONDA_ROOT && \
    # Cleanup
    clean-layer.sh

# install jupyterlab
RUN \
    # without es6-promise some extension builds fail
    npm install -g es6-promise && \
    # define alias command for jupyterlab extension installs with log prints to stdout
    jupyter lab build && \
    lab_ext_install='jupyter labextension install -y --debug-log-path=/dev/stdout --log-level=WARN --minimize=False --no-build' && \
    # jupyterlab installed in requirements section
    $lab_ext_install @jupyter-widgets/jupyterlab-manager && \
    # If minimal flavor - do not install jupyterlab extensions
    if [ "$WORKSPACE_FLAVOR" = "minimal" ]; then \
        # Final build with minimization
        jupyter lab build -y --debug-log-path=/dev/stdout --log-level=WARN && \
        # Cleanup
        jupyter lab clean && \
        jlpm cache clean && \
        rm -rf $CONDA_ROOT/share/jupyter/lab/staging && \
        clean-layer.sh && \
        exit 0 ; \
    fi && \
    $lab_ext_install @jupyterlab/toc && \
    # install temporarily from gitrepo due to the issue that jupyterlab_tensorboard does not work with 3.x yet as described here: https://github.com/chaoleili/jupyterlab_tensorboard/issues/28#issuecomment-783594541
    #$lab_ext_install jupyterlab_tensorboard && \
    pip install git+https://github.com/chaoleili/jupyterlab_tensorboard.git && \
    # install jupyterlab git
    # $lab_ext_install @jupyterlab/git && \
    pip install jupyterlab-git && \
    # jupyter serverextension enable --py jupyterlab_git && \
    # For Matplotlib: https://github.com/matplotlib/jupyter-matplotlib
    #$lab_ext_install jupyter-matplotlib && \
    # Do not install any other jupyterlab extensions
    if [ "$WORKSPACE_FLAVOR" = "light" ]; then \
        # Final build with minimization
        jupyter lab build -y --debug-log-path=/dev/stdout --log-level=WARN && \
        # Cleanup
        jupyter lab clean && \
        jlpm cache clean && \
        rm -rf $CONDA_ROOT/share/jupyter/lab/staging && \
        clean-layer.sh && \
        exit 0 ; \
    fi \
    # Install jupyterlab language server support
    && pip install jupyterlab-lsp==3.7.0 jupyter-lsp==1.3.0 && \
    # $lab_ext_install install @krassowski/jupyterlab-lsp@2.0.8 && \
    # For Plotly
    $lab_ext_install jupyterlab-plotly && \
    $lab_ext_install install @jupyter-widgets/jupyterlab-manager plotlywidget && \
    # produces build error: jupyter labextension install jupyterlab-chart-editor && \
    $lab_ext_install jupyterlab-chart-editor && \
    # Install jupyterlab variable inspector - https://github.com/lckr/jupyterlab-variableInspector
    pip install lckr-jupyterlab-variableinspector && \
    # For holoview
    # TODO: pyviz is not yet supported by the current JupyterLab version
    #     $lab_ext_install @pyviz/jupyterlab_pyviz && \
    # Install Debugger in Jupyter Lab
    # pip install --no-cache-dir xeus-python && \
    # $lab_ext_install @jupyterlab/debugger && \
    # Install jupyterlab code formattor - https://github.com/ryantam626/jupyterlab_code_formatter
    $lab_ext_install @ryantam626/jupyterlab_code_formatter && \
    pip install jupyterlab_code_formatter && \
    jupyter serverextension enable --py jupyterlab_code_formatter \
    # Final build with minimization
    && jupyter lab build -y --debug-log-path=/dev/stdout --log-level=WARN && \
    jupyter lab build && \
    # Cleanup
    # Clean jupyter lab cache: https://github.com/jupyterlab/jupyterlab/issues/4930
    jupyter lab clean && \
    jlpm cache clean && \
    # Remove build folder -> should be remove by lab clean as well?
    rm -rf $CONDA_ROOT/share/jupyter/lab/staging && \
    clean-layer.sh

# Install Jupyter Tooling Extension
COPY resources/jupyter/extensions $RESOURCES_PATH/jupyter-extensions

RUN \
    pip install --no-cache-dir $RESOURCES_PATH/jupyter-extensions/tooling-extension/ && \
    # Cleanup
    clean-layer.sh

# Install and activate ZSH
COPY resources/tools/oh-my-zsh.sh $RESOURCES_PATH/tools/oh-my-zsh.sh

RUN \
    # Install ZSH
    /bin/bash $RESOURCES_PATH/tools/oh-my-zsh.sh --install && \
    # Make zsh the default shell
    # Initialize conda for command line activation
    # TODO do not activate for now, opening the bash shell is a bit slow
    # conda init bash && \
    conda init zsh && \
    chsh -s $(which zsh) $NB_USER && \
    # Install sdkman - needs to be executed after zsh
    curl -s https://get.sdkman.io | bash && \
    # Cleanup
    clean-layer.sh

# Install Git LFS
COPY resources/tools/git-lfs.sh $RESOURCES_PATH/tools/git-lfs.sh

RUN \
    /bin/bash $RESOURCES_PATH/tools/git-lfs.sh --install && \
    # Cleanup
    clean-layer.sh

### VSCODE ###

# Install vscode extension
# https://github.com/cdr/code-server/issues/171
# Alternative install: /usr/local/bin/code-server --user-data-dir=$HOME/.config/Code/ --extensions-dir=$HOME/.vscode/extensions/ --install-extension ms-python-release && \
RUN \
    SLEEP_TIMER=25 && \
    # If minimal flavor -> exit here
    if [ "$WORKSPACE_FLAVOR" = "minimal" ]; then \
        exit 0 ; \
    fi && \
    cd $RESOURCES_PATH && \
    mkdir -p $HOME/.vscode/extensions/ && \
    # Install vs code jupyter - required by python extension
    VS_JUPYTER_VERSION="2021.6.832593372" && \
    wget --retry-on-http-error=429 --waitretry 15 --tries 5 --no-verbose https://marketplace.visualstudio.com/_apis/public/gallery/publishers/ms-toolsai/vsextensions/jupyter/$VS_JUPYTER_VERSION/vspackage -O ms-toolsai.jupyter-$VS_JUPYTER_VERSION.vsix && \
    bsdtar -xf ms-toolsai.jupyter-$VS_JUPYTER_VERSION.vsix extension && \
    rm ms-toolsai.jupyter-$VS_JUPYTER_VERSION.vsix && \
    mv extension $HOME/.vscode/extensions/ms-toolsai.jupyter-$VS_JUPYTER_VERSION && \
    sleep $SLEEP_TIMER && \
    # Install python extension - (newer versions are 30MB bigger)
    VS_PYTHON_VERSION="2021.5.926500501" && \
    wget --no-verbose https://github.com/microsoft/vscode-python/releases/download/$VS_PYTHON_VERSION/ms-python-release.vsix && \
    bsdtar -xf ms-python-release.vsix extension && \
    rm ms-python-release.vsix && \
    mv extension $HOME/.vscode/extensions/ms-python.python-$VS_PYTHON_VERSION && \
    # && code-server --install-extension ms-python.python@$VS_PYTHON_VERSION \
    sleep $SLEEP_TIMER && \
    # If light flavor -> exit here
    if [ "$WORKSPACE_FLAVOR" = "light" ]; then \
        exit 0 ; \
    fi && \
    # Install prettie: https://github.com/prettier/prettier-vscode/releases
    PRETTIER_VERSION="6.4.0" && \
    wget --no-verbose https://github.com/prettier/prettier-vscode/releases/download/v$PRETTIER_VERSION/prettier-vscode-$PRETTIER_VERSION.vsix && \
    bsdtar -xf prettier-vscode-$PRETTIER_VERSION.vsix extension && \
    rm prettier-vscode-$PRETTIER_VERSION.vsix && \
    mv extension $HOME/.vscode/extensions/prettier-vscode-$PRETTIER_VERSION.vsix && \
    # Install code runner: https://github.com/formulahendry/vscode-code-runner/releases/latest
    VS_CODE_RUNNER_VERSION="0.9.17" && \
    wget --no-verbose https://github.com/formulahendry/vscode-code-runner/releases/download/$VS_CODE_RUNNER_VERSION/code-runner-$VS_CODE_RUNNER_VERSION.vsix && \
    bsdtar -xf code-runner-$VS_CODE_RUNNER_VERSION.vsix extension && \
    rm code-runner-$VS_CODE_RUNNER_VERSION.vsix && \
    mv extension $HOME/.vscode/extensions/code-runner-$VS_CODE_RUNNER_VERSION && \
    # && code-server --install-extension formulahendry.code-runner@$VS_CODE_RUNNER_VERSION \
    sleep $SLEEP_TIMER && \
    # Install ESLint extension: https://marketplace.visualstudio.com/items?itemName=dbaeumer.vscode-eslint
    VS_ESLINT_VERSION="2.1.23" && \
    wget --retry-on-http-error=429 --waitretry 15 --tries 5 --no-verbose https://marketplace.visualstudio.com/_apis/public/gallery/publishers/dbaeumer/vsextensions/vscode-eslint/$VS_ESLINT_VERSION/vspackage -O dbaeumer.vscode-eslint.vsix && \
    # && wget --no-verbose https://github.com/microsoft/vscode-eslint/releases/download/$VS_ESLINT_VERSION-insider.2/vscode-eslint-$VS_ESLINT_VERSION.vsix -O dbaeumer.vscode-eslint.vsix && \
    bsdtar -xf dbaeumer.vscode-eslint.vsix extension && \
    rm dbaeumer.vscode-eslint.vsix && \
    mv extension $HOME/.vscode/extensions/dbaeumer.vscode-eslint-$VS_ESLINT_VERSION.vsix && \
    # && code-server --install-extension dbaeumer.vscode-eslint@$VS_ESLINT_VERSION \
    # Fix permissions
    fix-permissions.sh $HOME/.vscode/extensions/ && \
    # Cleanup
    clean-layer.sh

### END VSCODE ###

### INCUBATION ZONE ###

RUN \
    apt-get update && \
    # Required by magenta
    # apt-get install -y libasound2-dev && \
    # required by rodeo ide (8MB)
    # apt-get install -y libgconf2-4 && \
    # required for pvporcupine (800kb)
    # apt-get install -y portaudio19-dev && \
    # Audio drivers for magenta? (3MB)
    # apt-get install -y libasound2-dev libjack-dev && \
    # libproj-dev required for cartopy (15MB)
    # apt-get install -y libproj-dev && \
    # mysql server: 150MB
    # apt-get install -y mysql-server && \
    # If minimal or light flavor -> exit here
    if [ "$WORKSPACE_FLAVOR" = "minimal" ] || [ "$WORKSPACE_FLAVOR" = "light" ]; then \
        # Cleanup
        clean-layer.sh  && \
        exit 0 ; \
    fi && \
    # Install fkill-cli program  TODO: 30MB, remove?
    # npm install --global fkill-cli && \
    # Activate pretty-errors
    # python -m pretty_errors -u -p && \
    # Cleanup
    clean-layer.sh

### END INCUBATION ZONE ###

### CONFIGURATION ###

# Copy files into workspace
COPY \
    resources/docker-entrypoint.py \
    resources/5xx.html \
    $RESOURCES_PATH/

# Copy scripts into workspace
COPY resources/scripts $RESOURCES_PATH/scripts

# Create Desktop Icons for Tooling
COPY resources/branding $RESOURCES_PATH/branding

# Configure Home folder (e.g. xfce)
COPY resources/home/ $HOME/

# Copy some configuration files
COPY resources/ssh/ssh_config resources/ssh/sshd_config  /etc/ssh/
COPY resources/nginx/nginx.conf /etc/nginx/nginx.conf
COPY resources/config/xrdp.ini /etc/xrdp/xrdp.ini

# Configure supervisor process
COPY resources/supervisor/supervisord.conf /etc/supervisor/supervisord.conf
# Copy all supervisor program definitions into workspace
COPY resources/supervisor/programs/ /etc/supervisor/conf.d/

# Assume yes to all apt commands, to avoid user confusion around stdin.
COPY resources/config/90assumeyes /etc/apt/apt.conf.d/

# Monkey Patching novnc: Styling and added clipboard support. All changed sections are marked with CUSTOM CODE
COPY resources/novnc/ $RESOURCES_PATH/novnc/

RUN \
    ## create index.html to forward automatically to `vnc.html`
    # Needs to be run after patching
    ln -s $RESOURCES_PATH/novnc/vnc.html $RESOURCES_PATH/novnc/index.html

# Basic VNC Settings - no password
ENV \
    VNC_PW=vncpassword \
    VNC_RESOLUTION=1600x900 \
    VNC_COL_DEPTH=24

# Add tensorboard patch - use tensorboard jupyter plugin instead of the actual tensorboard magic
COPY resources/jupyter/tensorboard_notebook_patch.py $CONDA_PYTHON_DIR/site-packages/tensorboard/notebook.py

# Additional jupyter configuration
COPY resources/jupyter/jupyter_notebook_config.py /etc/jupyter/
COPY resources/jupyter/sidebar.jupyterlab-settings $HOME/.jupyter/lab/user-settings/@jupyterlab/application-extension/
COPY resources/jupyter/plugin.jupyterlab-settings $HOME/.jupyter/lab/user-settings/@jupyterlab/extensionmanager-extension/
COPY resources/jupyter/ipython_config.py /etc/ipython/ipython_config.py

# Branding of various components
RUN \
    # Jupyter Branding
    cp -f $RESOURCES_PATH/branding/logo.png $CONDA_PYTHON_DIR"/site-packages/notebook/static/base/images/logo.png" && \
    cp -f $RESOURCES_PATH/branding/favicon.ico $CONDA_PYTHON_DIR"/site-packages/notebook/static/base/images/favicon.ico" && \
    cp -f $RESOURCES_PATH/branding/favicon.ico $CONDA_PYTHON_DIR"/site-packages/notebook/static/favicon.ico" && \
    # Fielbrowser Branding
    mkdir -p $RESOURCES_PATH"/filebrowser/img/icons/" && \
    cp -f $RESOURCES_PATH/branding/favicon.ico $RESOURCES_PATH"/filebrowser/img/icons/favicon.ico" && \
    cp -f $RESOURCES_PATH/branding/favicon.ico $RESOURCES_PATH"/filebrowser/img/icons/favicon-32x32.png" && \
    cp -f $RESOURCES_PATH/branding/favicon.ico $RESOURCES_PATH"/filebrowser/img/icons/favicon-16x16.png" && \
    cp -f $RESOURCES_PATH/branding/ml-workspace-logo.svg $RESOURCES_PATH"/filebrowser/img/logo.svg"

# Configure git
RUN \
    git config --global core.fileMode false && \
    git config --global http.sslVerify false && \
    # Use store or credentialstore instead? timout == 365 days validity
    git config --global credential.helper 'cache --timeout=31540000'

# Configure netdata
COPY resources/netdata/ /etc/netdata/
COPY resources/netdata/cloud.conf /var/lib/netdata/cloud.d/cloud.conf

# Configure Matplotlib
RUN \
    # Import matplotlib the first time to build the font cache.
    MPLBACKEND=Agg python -c "import matplotlib.pyplot" \
    # Stop Matplotlib printing junk to the console on first load
    sed -i "s/^.*Matplotlib is building the font cache using fc-list.*$/# Warning removed/g" $CONDA_PYTHON_DIR/site-packages/matplotlib/font_manager.py

# Create Desktop Icons for Tooling
COPY resources/icons $RESOURCES_PATH/icons

RUN \
    # ungit:
    echo "[Desktop Entry]\nVersion=1.0\nType=Link\nName=Ungit\nComment=Git Client\nCategories=Development;\nIcon=/resources/icons/ungit-icon.png\nURL=http://localhost:8092/tools/ungit" > /usr/share/applications/ungit.desktop && \
    chmod +x /usr/share/applications/ungit.desktop && \
    # netdata:
    echo "[Desktop Entry]\nVersion=1.0\nType=Link\nName=Netdata\nComment=Hardware Monitoring\nCategories=System;Utility;Development;\nIcon=/resources/icons/netdata-icon.png\nURL=http://localhost:8092/tools/netdata" > /usr/share/applications/netdata.desktop && \
    chmod +x /usr/share/applications/netdata.desktop && \
    # glances:
    echo "[Desktop Entry]\nVersion=1.0\nType=Link\nName=Glances\nComment=Hardware Monitoring\nCategories=System;Utility;\nIcon=/resources/icons/glances-icon.png\nURL=http://localhost:8092/tools/glances" > /usr/share/applications/glances.desktop && \
    chmod +x /usr/share/applications/glances.desktop && \
    # Remove mail and logout desktop icons
    rm /usr/share/applications/xfce4-mail-reader.desktop && \
    rm /usr/share/applications/xfce4-session-logout.desktop

# Copy resources into workspace
COPY resources/tools $RESOURCES_PATH/tools
COPY resources/tests $RESOURCES_PATH/tests
COPY resources/tutorials $RESOURCES_PATH/tutorials
COPY resources/licenses $RESOURCES_PATH/licenses
COPY resources/reports $RESOURCES_PATH/reports

# Various configurations
RUN \
    touch $HOME/.ssh/config && \
    # clear chome init file - not needed since we load settings manually
    chmod -R a+rwx $WORKSPACE_HOME && \
    chmod -R a+rwx $RESOURCES_PATH && \
    # make all desktop launchers executable
    chmod -R a+rwx /usr/share/applications/ && \
    ln -s $RESOURCES_PATH/tools/ $HOME/Desktop/Tools && \
    ln -s $WORKSPACE_HOME $HOME/Desktop/workspace && \
    chmod a+rwx /usr/local/bin/start-notebook.sh && \
    chmod a+rwx /usr/local/bin/start.sh && \
    chmod a+rwx /usr/local/bin/start-singleuser.sh && \
    chown root:root /tmp && \
    chmod 1777 /tmp && \
    # TODO: does 1777 work fine? chmod a+rwx /tmp && \
    # Set /workspace as default directory to navigate to as root user
    echo 'cd '$WORKSPACE_HOME >> $HOME/.bashrc

# MKL and Hardware Optimization
# Fix problem with MKL with duplicated libiomp5: https://github.com/dmlc/xgboost/issues/1715
# Alternative - use openblas instead of Intel MKL: conda install -y nomkl
# http://markus-beuckelmann.de/blog/boosting-numpy-blas.html
# MKL:
# https://software.intel.com/en-us/articles/tips-to-improve-performance-for-popular-deep-learning-frameworks-on-multi-core-cpus
# https://github.com/intel/pytorch#bkm-on-xeon
# http://astroa.physics.metu.edu.tr/MANUALS/intel_ifc/mergedProjects/optaps_for/common/optaps_par_var.htm
# https://www.tensorflow.org/guide/performance/overview#tuning_mkl_for_the_best_performance
# https://software.intel.com/en-us/articles/maximize-tensorflow-performance-on-cpu-considerations-and-recommendations-for-inference
ENV KMP_DUPLICATE_LIB_OK="True" \
    # Control how to bind OpenMP* threads to physical processing units # verbose
    KMP_AFFINITY="granularity=fine,compact,1,0" \
    KMP_BLOCKTIME=0 \
    # KMP_BLOCKTIME="1" -> is not faster in my tests
    # TensorFlow uses less than half the RAM with tcmalloc relative to the default. - requires google-perftools
    # Too many issues: LD_PRELOAD="/usr/lib/libtcmalloc.so.4" \
    # TODO set PYTHONDONTWRITEBYTECODE
    # TODO set XDG_CONFIG_HOME, CLICOLOR?
    # https://software.intel.com/en-us/articles/getting-started-with-intel-optimization-for-mxnet
    # KMP_AFFINITY=granularity=fine, noduplicates,compact,1,0
    # MXNET_SUBGRAPH_BACKEND=MKLDNN
    # TODO: check https://github.com/oneapi-src/oneTBB/issues/190
    # TODO: https://github.com/pytorch/pytorch/issues/37377
    # use omp
    MKL_THREADING_LAYER=GNU \
    # To avoid over-subscription when using TBB, let the TBB schedulers use Inter Process Communication to coordinate:
    ENABLE_IPC=1 \
    # will cause pretty_errors to check if it is running in an interactive terminal
    PYTHON_PRETTY_ERRORS_ISATTY_ONLY=1 \
    # TODO: evaluate - Deactivate hdf5 file locking
    HDF5_USE_FILE_LOCKING=False

# Set default values for environment variables
ENV CONFIG_BACKUP_ENABLED="true" \
    SHUTDOWN_INACTIVE_KERNELS="false" \
    SHARED_LINKS_ENABLED="true" \
    AUTHENTICATE_VIA_JUPYTER="false" \
    DATA_ENVIRONMENT=$WORKSPACE_HOME"/environment" \
    WORKSPACE_BASE_URL="/" \
    INCLUDE_TUTORIALS="true" \
    # Main port used for sshl proxy -> can be changed
    WORKSPACE_PORT="8080" \
    # Set zsh as default shell (e.g. in jupyter)
    SHELL="/usr/bin/zsh" \
    # Fix dark blue color for ls command (unreadable):
    # https://askubuntu.com/questions/466198/how-do-i-change-the-color-for-directories-with-ls-in-the-console
    # USE default LS_COLORS - Dont set LS COLORS - overwritten in zshrc
    # LS_COLORS="" \
    # set number of threads various programs should use, if not-set, it tries to use all
    # this can be problematic since docker restricts CPUs by stil showing all
    MAX_NUM_THREADS="auto"

### END CONFIGURATION ###
ARG ARG_BUILD_DATE="unknown"
ARG ARG_VCS_REF="unknown"
ARG ARG_WORKSPACE_VERSION="unknown"
ENV WORKSPACE_VERSION=$ARG_WORKSPACE_VERSION

# Overwrite & add Labels
LABEL \
    "maintainer"="mltooling.team@gmail.com" \
    "workspace.version"=$WORKSPACE_VERSION \
    "workspace.flavor"=$WORKSPACE_FLAVOR \
    # Kubernetes Labels
    "io.k8s.description"="All-in-one web-based development environment for machine learning." \
    "io.k8s.display-name"="Machine Learning Workspace" \
    # Openshift labels: https://docs.okd.io/latest/creating_images/metadata.html
    "io.openshift.expose-services"="8080:http, 5901:xvnc" \
    "io.openshift.non-scalable"="true" \
    "io.openshift.tags"="workspace, machine learning, vnc, ubuntu, xfce" \
    "io.openshift.min-memory"="1Gi" \
    # Open Container labels: https://github.com/opencontainers/image-spec/blob/master/annotations.md
    "org.opencontainers.image.title"="Machine Learning Workspace" \
    "org.opencontainers.image.description"="All-in-one web-based development environment for machine learning." \
    "org.opencontainers.image.documentation"="https://github.com/ml-tooling/ml-workspace" \
    "org.opencontainers.image.url"="https://github.com/ml-tooling/ml-workspace" \
    "org.opencontainers.image.source"="https://github.com/ml-tooling/ml-workspace" \
    # "org.opencontainers.image.licenses"="Apache-2.0" \
    "org.opencontainers.image.version"=$WORKSPACE_VERSION \
    "org.opencontainers.image.vendor"="ML Tooling" \
    "org.opencontainers.image.authors"="Lukas Masuch & Benjamin Raethlein" \
    "org.opencontainers.image.revision"=$ARG_VCS_REF \
    "org.opencontainers.image.created"=$ARG_BUILD_DATE \
    # Label Schema Convention (deprecated): http://label-schema.org/rc1/
    "org.label-schema.name"="Machine Learning Workspace" \
    "org.label-schema.description"="All-in-one web-based development environment for machine learning." \
    "org.label-schema.usage"="https://github.com/ml-tooling/ml-workspace" \
    "org.label-schema.url"="https://github.com/ml-tooling/ml-workspace" \
    "org.label-schema.vcs-url"="https://github.com/ml-tooling/ml-workspace" \
    "org.label-schema.vendor"="ML Tooling" \
    "org.label-schema.version"=$WORKSPACE_VERSION \
    "org.label-schema.schema-version"="1.0" \
    "org.label-schema.vcs-ref"=$ARG_VCS_REF \
    "org.label-schema.build-date"=$ARG_BUILD_DATE

# Removed - is run during startup since a few env variables are dynamically changed: RUN printenv > $HOME/.ssh/environment

# This assures we have a volume mounted even if the user forgot to do bind mount.
# So that they do not lose their data if they delete the container.
# TODO: VOLUME [ "/workspace" ]
# TODO: WORKDIR /workspace?

# use global option with tini to kill full process groups: https://github.com/krallin/tini#process-group-killing
ENTRYPOINT ["/tini", "-g", "--"]

CMD ["python", "/resources/docker-entrypoint.py"]

# Port 8080 is the main access port (also includes SSH)
# Port 5091 is the VNC port
# Port 3389 is the RDP port
# Port 8090 is the Jupyter Notebook Server
# See supervisor.conf for more ports

EXPOSE 8080
###
