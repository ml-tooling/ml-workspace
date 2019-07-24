FROM ubuntu:16.04

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
COPY docker-res/scripts/clean-layer.sh  /usr/bin/clean-layer.sh
COPY docker-res/scripts/fix-permissions.sh  /usr/bin/fix-permissions.sh

 # Make clean-layer and fix-permissions executable
 RUN \
    chmod a+rwx /usr/bin/clean-layer.sh && \ 
    chmod a+rwx /usr/bin/fix-permissions.sh

# Generate and Set locals
# https://stackoverflow.com/questions/28405902/how-to-set-the-locale-inside-a-debian-ubuntu-docker-container#38553499
RUN \
    apt-get update && \
    apt-get install locales --yes && \
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
        pkg-config \
        curl libcurl3 \
        libgnome-keyring* \
        software-properties-common \
        python-software-properties \
        lsof \
        net-tools \
        cron \
        tmux \
        nano \
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
    chmod -R a+rwx /usr/local/bin/ && \
    # configure dynamic linker run-time bindings
    ldconfig && \
    # Fix permissions
    fix-permissions.sh $HOME && \
    # Cleanup
    clean-layer.sh

# Add tini
RUN wget --quiet https://github.com/krallin/tini/releases/download/v0.18.0/tini -O /tini && \
    chmod +x /tini

RUN \
    apt-get update && \
    apt-get purge -y nginx nginx-common && \
    # libpcre required, otherwise you get a 'the HTTP rewrite module requires the PCRE library' error
    # Install apache2-utils to generate user:password file for nginx.
    apt-get install -y libssl-dev libpcre3 libpcre3-dev apache2-utils && \
    mkdir $RESOURCES_PATH"/openresty" && \
    cd $RESOURCES_PATH"/openresty" && \
    wget --quiet https://openresty.org/download/openresty-1.15.8.1.tar.gz  -O ./openresty.tar.gz && \
    tar xfz ./openresty.tar.gz && \
    rm ./openresty.tar.gz && \
    cd ./openresty-1.15.8.1/ && \
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

COPY docker-res/nginx/lua-extensions /etc/nginx/nginx_plugins

# prepare ssh for inter-container communication for remote python kernel
RUN \
    apt-get update && \
    apt-get install --yes --no-install-recommends \
        openssh-client \
        openssh-server \
        # SSLH for SSH + HTTP(s) Multiplexing
        sslh && \
    chmod go-w $HOME && \
    mkdir -p $HOME/.ssh/ && \
    # create empty config file if not exists
    touch $HOME/.ssh/config  && \
    sudo chown -R $NB_USER:users $HOME/.ssh && \
    chmod 700 $HOME/.ssh && \
    printenv >> $HOME/.ssh/environment && \
    chmod -R a+rwx /usr/local/bin/ && \
    # Install X11 tools - TODO really necessary?
    # https://github.com/fcwu/docker-ubuntu-vnc-desktop/blob/master/image/etc/supervisor/conf.d/supervisord.conf
    # TODO isntall dbus-x11 x11-xserver-utils
    apt-get install --yes --no-install-recommends xvfb x11-utils wmctrl x11-apps  && \
    # Fix permissions
    fix-permissions.sh $HOME && \
    # Cleanup
    clean-layer.sh

### END BASICS ###

### RUNTIMES ###
# Install anaconda
ENV \
    CONDA_DIR=/opt/conda \
    CONDA_VERSION=4.6.14 \
    CONDA_PYTHON_DIR=/opt/conda/lib/python3.6

RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-${CONDA_VERSION}-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p $CONDA_DIR && \
    export PATH=$CONDA_DIR/bin:$PATH && \
    rm ~/miniconda.sh && \
    # Update conda
    $CONDA_DIR/bin/conda update -n base -c defaults conda && \
    $CONDA_DIR/bin/conda install conda-build && \
    # Add conda forge - Append so that conda forge has lower priority than the main channel
    $CONDA_DIR/bin/conda config --system --append channels conda-forge && \
    $CONDA_DIR/bin/conda config --system --set auto_update_conda false && \
    $CONDA_DIR/bin/conda config --system --set show_channel_urls true && \
    # Update selected packages - install python 3.6
    $CONDA_DIR/bin/conda install python=3.6 && \
    $CONDA_DIR/bin/conda install cmake && \
    # Link Conda
    ln -s $CONDA_DIR/bin/python /usr/local/bin/python && \
    ln -s $CONDA_DIR/bin/conda /usr/bin/conda && \
    # Update pip
    pip install --upgrade pip && \
    chmod -R a+rwx /usr/local/bin/ && \
    # Install Python 2
    # anaconda=$CONDA_VERSION - do not install anaconda, it is too big
    conda create --yes -p $CONDA_DIR/envs/python2 python=2.7 && \
    ln -s $CONDA_DIR/envs/python2/bin/pip $CONDA_DIR/bin/pip2 && \
    ln -s $CONDA_DIR/envs/python2/bin/ipython2 $CONDA_DIR/bin/ipython2 && \
    $CONDA_DIR/bin/pip2 install --upgrade pip && \
    # Install compatibility libraries
    $CONDA_DIR/bin/pip2 install future enum34 six typing && \
    # Cleanup
    # find /opt/conda/ -follow -type f -name '*.a' -delete && \
    # find /opt/conda/ -follow -type f -name '*.js.map' -delete && \
    $CONDA_DIR/bin/conda clean --packages && \
    $CONDA_DIR/bin/conda clean -all -f -y  && \
    # Fix permissions
    fix-permissions.sh $CONDA_DIR && \
    clean-layer.sh

ENV PATH=$CONDA_DIR/bin:$PATH

# There is nothing added yet to LD_LIBRARY_PATH, so we can overwrite
ENV LD_LIBRARY_PATH=$CONDA_DIR/lib 

# Install node.js
RUN \
    apt-get update && \
    curl -sL https://deb.nodesource.com/setup_11.x | sudo -E bash - && \
    apt-get install nodejs --yes && \
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
    # Install YARN
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list && \
    apt-get update && \
    apt-get install --yes --no-install-recommends yarn && \
    # Cleanup
    clean-layer.sh

ENV PATH=/opt/node/bin:$PATH

# Install Java Runtime
RUN \
    apt-get update && \
    apt-get install -y openjdk-8-jdk && \
    # Cleanup
    clean-layer.sh

ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64

# Install Go Runtime
RUN \
    apt-get update && \
    apt-get install -y golang-go && \
    # Cleanup
    clean-layer.sh

# Install Ruby Runtime
RUN \
    apt-get update && \
    apt-get install -y ruby-full && \
    # Cleanup
    clean-layer.sh

### END RUNTIMES ###

### PROCESS TOOLS ###

### Install xfce UI
RUN \
    apt-get update && \
    # Install custom font
    apt-get install -y ttf-wqy-zenhei && \
    apt-get install -y supervisor xfce4 xfce4-terminal xterm && \
    apt-get purge -y pm-utils xscreensaver* && \
    # Cleanup
    clean-layer.sh

# Install Git LFS
RUN \
    apt-get update && \
    curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | sudo bash && \
    apt-get install git-lfs --yes && \
    git lfs install && \
    # Cleanup
    clean-layer.sh

# Install minio mc 
RUN \
    wget --quiet https://dl.min.io/client/mc/release/linux-amd64/mc -O /usr/sbin/mc && \
    chmod +x /usr/sbin/mc && \
    # Cleanup
    clean-layer.sh

# Install rdp support via xrdp
RUN \
    apt-get update && \
    apt-get install --yes --no-install-recommends xrdp && \
    # use xfce
    sudo sed -i.bak '/fi/a #xrdp multiple users configuration \n xfce-session \n' /etc/xrdp/startwm.sh && \
    # generate /etc/xrdp/rsakeys.ini
    cd /etc/xrdp/ && xrdp-keygen xrdp && \
    # Cleanup
    clean-layer.sh

# Install supervisor for process supervision
RUN \
    apt-get update && \
    # Create sshd run directory - required for starting process via supervisor
    mkdir -p /var/run/sshd && chmod 400 /var/run/sshd && \
    # Install rsyslog for syslog logging
    apt-get install --yes --no-install-recommends rsyslog && \
    pip install --no-cache-dir --upgrade supervisor supervisor-stdout && \
    # Cleanup
    clean-layer.sh

### END PROCESS TOOLS ###

### GUI TOOLS ###
# Install VNC
RUN \
    apt-get update  && \
    # required for websockify
    # apt-get install -y python-numpy  && \
    cd ${RESOURCES_PATH} && \
    # Tiger VNC
    wget -qO- https://dl.bintray.com/tigervnc/stable/tigervnc-1.9.0.x86_64.tar.gz | tar xz --strip 1 -C / && \
    # Install websockify
    mkdir -p ./novnc/utils/websockify && \
    # Before updating the noVNC version, we need to make sure that our monkey patching scripts still work!!
    wget -qO- https://github.com/novnc/noVNC/archive/v1.1.0.tar.gz | tar xz --strip 1 -C ./novnc && \
    # use older version of websockify to prevent hanging connections on offline containers, see https://github.com/ConSol/docker-headless-vnc-container/issues/50
    # Use newest version of websockify instead of: https://github.com/novnc/websockify/archive/v0.8.0.tar.gz 
    wget -qO- https://github.com/novnc/websockify/tarball/master | tar xz --strip 1 -C ./novnc/utils/websockify && \
    chmod +x -v ./novnc/utils/*.sh && \
    # create user vnc directory
    mkdir -p $HOME/.vnc && \
    # Fix permissions
    fix-permissions.sh ${RESOURCES_PATH} && \
    # Cleanup
    clean-layer.sh

# Install Terminal / GDebi (Package Manager) / Glogg (Stream file viewer) & archive tools
RUN \
    apt-get update && \
    apt-get install xfce4-terminal --yes && \
    apt-get install xfce4-taskmanager --yes --allow-unauthenticated && \
    apt-get install gnome-tweak-tool --yes && \
    apt-get install gnome-search-tool --yes && \
    apt-get install gdebi --yes && \
    # Streaming text editor for large files
    apt-get install glogg --yes && \
    apt-get install filezilla --yes && \
    apt-get install baobab --yes && \
    # Lightweight text editor
    apt-get install mousepad --yes && \
    apt-get install htop --yes && \
    # Install Zipping Tools 
    apt-get install unrar zip unzip --yes && \
    apt-get install p7zip p7zip-rar --yes && \
    apt-get install bsdtar --yes && \
    apt-get install thunar-archive-plugin --yes && \
    apt-get install file-roller --yes && \
    # Install Git Tools
    # one tool is enough? apt-get install giggle --yes && \
    apt-get install gitg --yes && \
    # DB Utils
    apt-get install sqlitebrowser --yes  && \
    # Install nautilus and support for sftp mounting
    apt-get install --no-install-recommends nautilus gvfs-backends --yes && \
    # Cleanup
    clean-layer.sh

RUN \
    apt-get update && \
    apt-get install -y chromium-browser chromium-browser-l10n chromium-codecs-ffmpeg && \
    ln -s /usr/bin/chromium-browser /usr/bin/google-chrome && \
    # Cleanup
    clean-layer.sh

COPY docker-res/scripts/install-firefox.sh $RESOURCES_PATH/scripts/install-firefox.sh

RUN \
    /bin/bash $RESOURCES_PATH/scripts/install-firefox.sh && \
    # Cleanup
    clean-layer.sh

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
   clean-layer.sh

## VS Code Webapp: https://github.com/codercom/code-server
RUN \
    cd ${RESOURCES_PATH} && \
    VS_CODE_VERSION=1.1156-vsc1.33.1 && \
    apt-get update --fix-missing && \
    apt-get install --yes openssl && \
    wget --quiet https://github.com/cdr/code-server/releases/download/$VS_CODE_VERSION/code-server$VS_CODE_VERSION-linux-x64.tar.gz -O ./vscode-web.tar.gz && \
    tar xfz ./vscode-web.tar.gz && \
    mv ./code-server$VS_CODE_VERSION-linux-x64/code-server /usr/local/bin && \
    rm ./vscode-web.tar.gz && \
    rm -rf ./code-server$VS_CODE_VERSION-linux-x64 && \
    # Fix permissions
    fix-permissions.sh ${RESOURCES_PATH} && \
    # Cleanup
    clean-layer.sh
# Install Web Tools - Offered via Jupyter Tooling Plugin

## ungit
RUN \
    npm update && \
    npm install -g ungit@1.4.46 && \
    # Cleanup
    clean-layer.sh

## netdata
RUN \
    apt-get update && \
    wget --quiet https://my-netdata.io/kickstart.sh -O $RESOURCES_PATH/netdata-install.sh && \
    # Surpress output - if there is a problem remove to see logs > /dev/null
    /bin/bash $RESOURCES_PATH/netdata-install.sh --dont-wait --dont-start-it --stable-channel --disable-telemetry > /dev/null && \
    rm $RESOURCES_PATH/netdata-install.sh && \
    # Cleanup
    clean-layer.sh

## Glances webtool is installed in python section below

## Filebrowser
RUN \
    cd $RESOURCES_PATH && \
    curl -fsSL https://raw.githubusercontent.com/filebrowser/get/master/get.sh | bash && \
    # Cleanup
    clean-layer.sh

### END GUI TOOLS ###

### DATA SCIENCE BASICS ###

# TODO move down
RUN \
    # Link Conda - All python are linke to the conda instances 
    # Linking python 3 crashes conda -> cannot install anyting - remove instead
    #ln -s -f $CONDA_DIR/bin/python /usr/bin/python3 && \
    # if removed -> cannot use add-apt-repository
    # rm /usr/bin/python3 && \
    ln -s -f $CONDA_DIR/bin/python /usr/bin/python && \
    ln -s -f $CONDA_DIR/envs/python2/bin/python /usr/bin/python2 && \
    rm /usr/bin/python2.7
    # rm /usr/bin/python3.5

## Python 3

# Install FastText
RUN \
    mkdir $RESOURCES_PATH"/fasttext" && \
    cd $RESOURCES_PATH"/fasttext" && \
    wget --quiet https://github.com/facebookresearch/fastText/archive/v0.9.1.zip && \
    unzip -q v0.9.1.zip && \
    rm v0.9.1.zip && \
    cd fastText-0.9.1 && \
    # Surpress output - if there is a problem remove to see logs > /dev/null
    make > /dev/null && \
    chmod -R a+rwx $RESOURCES_PATH"/fasttext" && \
    cp "fasttext" /usr/local/bin && \
    # cd back otherwise clean layer will fail since it is deleted
    cd $RESOURCES_PATH && \
    rm -r $RESOURCES_PATH"/fasttext" && \
    # pip install moved to requirements file
    # Cleanup 
    clean-layer.sh

# Data science libraries requirements
COPY docker-res/requirements.txt ${RESOURCES_PATH}

### Install main data science libs
RUN \
    # upgrade pip
    pip install --upgrade pip && \
    # Install Packages
    apt-get update -y && \
    apt-get install -y --no-install-recommends graphviz pandoc && \
    # Install some basics - required to run container
    conda install -y --update-all \
            mkl \
            cython \
            numpy \
            matplotlib \
            numba \
            scipy \
            requests \
            urllib3 \
            ipykernel \
            protobuf \
            zlib \
            python-crontab \
            'ipython=7.6.*' \
            'notebook=6.0.*' \
            'jupyterlab=1.0.*' \
            libsodium && \
    # Install glances and requirements
    pip install --no-cache-dir glances py-cpuinfo requests netifaces matplotlib bottle && \
    # Install mkl-include & mkldnn
    conda install -y -c mingfeima mkldnn && \
    conda install -y mkl-include && \
    # Install tensorflow - cpu only -  mkl support
    conda install -y tensorflow && \
    # Install pytorch - cpu only
    conda install -y -c pytorch pytorch-cpu torchvision-cpu && \
    # Faiss - A library for efficient similarity search and clustering of dense vectors. 
    conda install -y -c pytorch faiss-cpu && \
    # Install pip requirements
    pip install --no-cache-dir --upgrade -r ${RESOURCES_PATH}/requirements.txt && \
    # Install libjpeg-turbo and Pillow-SIMD for faster Image Processing
    # https://docs.fast.ai/performance.html#faster-image-processing
    # Use better pillow simd install: https://github.com/uploadcare/pillow-simd/issues/44
    conda uninstall -y --force pillow pil jpeg libtiff libjpeg-turbo && \
    pip uninstall -y pillow pil jpeg libtiff libjpeg-turbo  && \
    conda install -y --no-deps -c conda-forge libjpeg-turbo  && \
    CFLAGS="${CFLAGS} -mavx2" pip install --upgrade --no-cache-dir --force-reinstall --no-binary :all: --compile pillow-simd==6.0.0.post0  && \
    conda install -y --no-deps jpeg libtiff  && \
    # Conda installs wrong node version - relink conda node to the actual node 
    rm -f /opt/conda/bin/node && ln -s /usr/bin/node /opt/conda/bin/node && \
    rm -f /opt/conda/bin/npm && ln -s /usr/bin/npm /opt/conda/bin/npm && \
    # Fix permissions
    fix-permissions.sh $CONDA_DIR && \
    # Cleanup
    clean-layer.sh

RUN \ 
    # Spacy - download and large language removal
    python -m spacy download en && \
    # Remove unneeded languages - otherwise it takes up too much space
    cd $CONDA_PYTHON_DIR/site-packages/spacy/lang && \
    rm -rf tr pt da sv ca nb && \
    # Cleanup
    clean-layer.sh

### END DATA SCIENCE BASICS ###

### JUPYTER ###

COPY \
    docker-res/jupyter/start.sh \
    docker-res/jupyter/start-notebook.sh \
    docker-res/jupyter/start-singleuser.sh \
    /usr/local/bin/

# Jupyter pip requirements - components and extensions
COPY docker-res/jupyter/jupyter_requirements.txt ${RESOURCES_PATH}

# install jupyter extensions
RUN \
    npm update && \
    npm install -g webpack && \
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
    # currently not working jupyter serverextension enable voila --sys-prefix && \
    # Activate Jupyter Tensorboard
    jupyter tensorboard enable && \
    # Edit notebook config
    cat $HOME/.jupyter/nbconfig/notebook.json | jq '.toc2={"moveMenuLeft": false}' > tmp.$$.json && mv tmp.$$.json $HOME/.jupyter/nbconfig/notebook.json && \
    # Disable the cluster tab for now
    ipcluster nbextension enable && \
    # Add as Python 2 kernel
    # Install Python 2 kernel spec globally to avoid permission problems when NB_UID
    # switching at runtime and to allow the notebook server running out of the root
    # environment to find it. Also, activate the python2 environment upon kernel launch.
    pip install --no-cache-dir kernda && \
    $CONDA_DIR/envs/python2/bin/python -m pip install ipykernel && \
    $CONDA_DIR/envs/python2/bin/python -m ipykernel install && \
    kernda -o -y /usr/local/share/jupyter/kernels/python2/kernel.json && \
    # Fix permissions? fix-permissions.sh $CONDA_DIR && \
    # Cleanup
    clean-layer.sh

# install jupyterlab
RUN \
    # jupyterlab installed in requirements section
    jupyter labextension install @jupyter-widgets/jupyterlab-manager && \
    jupyter labextension install @jupyterlab/toc && \
    jupyter labextension install jupyterlab_tensorboard && \
    jupyter labextension install qgrid && \
    # Install Statusbar
    # Already integrated jupyter labextension install @jupyterlab/statusbar && \
    # For Bokeh
    jupyter labextension install jupyterlab_bokeh && \
    # For Plotly
    jupyter labextension install @jupyterlab/plotly-extension && \
    jupyter labextension install jupyterlab-chart-editor && \
    # For holoview
    jupyter labextension install @pyviz/jupyterlab_pyviz && \
    # install jupyterlab git
    jupyter labextension install @jupyterlab/git && \
    pip install jupyterlab-git && \ 
    jupyter serverextension enable --py jupyterlab_git && \
    # Install jupyterlab_iframe - https://github.com/timkpaine/jupyterlab_iframe
    pip install jupyterlab_iframe&& \
    jupyter labextension install jupyterlab_iframe && \
    jupyter serverextension enable --py jupyterlab_iframe && \
    # Install jupyterlab_templates - https://github.com/timkpaine/jupyterlab_templates
    pip install jupyterlab_templates && \
    jupyter labextension install jupyterlab_templates && \
    jupyter serverextension enable --py jupyterlab_templates && \
    # Install jupyterlab-data-explorer: https://github.com/jupyterlab/jupyterlab-data-explorer
    # Install go-to-definition extension
    # Does not work with newest jupyterlab: jupyter labextension install @krassowski/jupyterlab_go_to_definition && \
    # Install jupyterlab variable inspector - https://github.com/lckr/jupyterlab-variableInspector
    # Does not work with newest jupyterlab: jupyter labextension install @lckr/jupyterlab_variableinspector && \
    # Activate ipygrid in jupterlab
    # Does not work with newest version: jupyter labextension install ipyaggrid && \
    # Cleanup
    # Remove build folder -> is not needed
    rm -rf $CONDA_DIR/share/jupyter/lab/staging && \
    clean-layer.sh

# Install Jupyter Tooling Extension
COPY docker-res/jupyter/extensions $RESOURCES_PATH/jupyter-extensions

RUN \
    pip install --no-cache-dir $RESOURCES_PATH/jupyter-extensions/tooling-extension/ && \
    # Cleanup
    clean-layer.sh

### VSCODE ###

# Install vscode extension
# https://github.com/cdr/code-server/issues/171
# Alternative install: /usr/local/bin/code-server --user-data-dir=$HOME/.config/Code/ --extensions-dir=$HOME/.vscode/extensions/ --install-extension ms-python-release && \
RUN \
    cd $RESOURCES_PATH && \
    mkdir -p $HOME/.vscode/extensions/ && \
    # Install python extension
    wget --quiet https://github.com/microsoft/vscode-python/releases/download/2019.6.24221/ms-python-release.vsix && \
    bsdtar -xf ms-python-release.vsix extension && \
    rm ms-python-release.vsix && \
    mv extension $HOME/.vscode/extensions/ms-python.python-2019.6.24221 && \
    # Install remote development extension
    # https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-ssh
    wget --quiet https://marketplace.visualstudio.com/_apis/public/gallery/publishers/ms-vscode-remote/vsextensions/remote-ssh/0.44.2/vspackage -O ms-vscode-remote.remote-ssh.vsix && \
    bsdtar -xf ms-vscode-remote.remote-ssh.vsix extension && \
    rm ms-vscode-remote.remote-ssh.vsix && \
    mv extension $HOME/.vscode/extensions/ms-vscode-remote.remote-ssh-0.44.2 && \
    # Install remote development ssh - editing configuration files
    # https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-ssh-edit
    wget --quiet https://marketplace.visualstudio.com/_apis/public/gallery/publishers/ms-vscode-remote/vsextensions/remote-ssh-edit/0.44.2/vspackage -O ms-vscode-remote.remote-ssh-edit.vsix && \
    bsdtar -xf ms-vscode-remote.remote-ssh-edit.vsix extension && \
    rm ms-vscode-remote.remote-ssh-edit.vsix && \
    mv extension $HOME/.vscode/extensions/ms-vscode-remote.remote-ssh-edit-0.44.2 && \
    # Install remote development ssh - explorer
    # https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-ssh-explorer
    wget --quiet https://marketplace.visualstudio.com/_apis/public/gallery/publishers/ms-vscode-remote/vsextensions/remote-ssh-explorer/0.44.2/vspackage -O ms-vscode-remote.remote-ssh-explorer.vsix && \
    bsdtar -xf ms-vscode-remote.remote-ssh-explorer.vsix extension && \
    rm ms-vscode-remote.remote-ssh-explorer.vsix && \
    mv extension $HOME/.vscode/extensions/ms-vscode-remote.remote-ssh-explorer-0.44.2 && \
    # Fix permissions
    fix-permissions.sh $HOME/.vscode/extensions/ && \
    # Cleanup
    clean-layer.sh

### END VSCODE ###

### INCUBATION ZONE ### 

### END INCUBATION ZONE ###

### CONFIGURATION ###

# Copy files into workspace
COPY \
    docker-res/run.py \
    docker-res/5xx.html \
    $RESOURCES_PATH/

# Copy scripts into workspace
COPY docker-res/scripts $RESOURCES_PATH/scripts
COPY docker-res/tools $RESOURCES_PATH/tools

# Create Desktop Icons for Tooling
COPY docker-res/branding $RESOURCES_PATH/branding

# Copy some configuration files
COPY docker-res/config/ssh_config $HOME/.ssh/config
COPY docker-res/config/sshd_config /etc/ssh/sshd_config
COPY docker-res/nginx/nginx.conf /etc/nginx/nginx.conf
COPY docker-res/config/xrdp.ini /etc/xrdp/xrdp.ini
COPY docker-res/config/netdata.conf /etc/netdata/netdata.conf
COPY docker-res/config/supervisord.conf /etc/supervisor/supervisord.conf
COPY docker-res/config/mimeapps.list $HOME/.config/mimeapps.list
COPY docker-res/config/bookmarks $HOME/.config/gtk-3.0/bookmarks
COPY docker-res/config/chromium-browser.init $HOME/.chromium-browser.init
# Assume yes to all apt commands, to avoid user confusion around stdin.
COPY docker-res/config/90assumeyes /etc/apt/apt.conf.d/
# Configure xfce
COPY docker-res/xfce/ $HOME/

# Monkey Patching novnc: Styling and added clipboard support. All changed sections are marked with CUSTOM CODE
COPY docker-res/novnc/ $RESOURCES_PATH/novnc/

RUN \
    ## create index.html to forward automatically to `vnc.html`
    # Needs to be run after patching
    ln -s $RESOURCES_PATH/novnc/vnc.html $RESOURCES_PATH/novnc/index.html

# Basic VNC Settings - no password
ENV \
    VNC_PW=vncpassword \
    VNC_RESOLUTION=1600x900 \
    VNC_COL_DEPTH=24

# Configure Jupyter / JupyterLab
COPY docker-res/jupyter/jupyter_notebook_config.py /etc/jupyter/
COPY docker-res/jupyter/sidebar.jupyterlab-settings $HOME/.jupyter/lab/user-settings/@jupyterlab/application-extension/
COPY docker-res/jupyter/plugin.jupyterlab-settings $HOME/.jupyter/lab/user-settings/@jupyterlab/extensionmanager-extension/
# Add tensorboard patch - use tensorboard jupyter plugin instead of the actual tensorboard magic
COPY docker-res/jupyter/tensorboard_notebook_patch.py /opt/conda/lib/python3.6/site-packages/tensorboard/notebook.py

# Branding of various components
RUN \
    # Jupyter Bradning
    cp -f $RESOURCES_PATH/branding/logo.png $CONDA_DIR"/lib/python3.6/site-packages/notebook/static/base/images/logo.png" && \
    cp -f $RESOURCES_PATH/branding/favicon.ico $CONDA_DIR"/lib/python3.6/site-packages/notebook/static/base/images/favicon.ico" && \
    cp -f $RESOURCES_PATH/branding/favicon.ico $CONDA_DIR"/lib/python3.6/site-packages/notebook/static/favicon.ico" && \
    # Fielbrowser Branding
    mkdir -p $RESOURCES_PATH"/filebrowser/img/icons/" && \
    cp -f $RESOURCES_PATH/branding/favicon.ico $RESOURCES_PATH"/filebrowser/img/icons/favicon.ico" && \
    # Todo - use actual png
    cp -f $RESOURCES_PATH/branding/favicon.ico $RESOURCES_PATH"/filebrowser/img/icons/favicon-32x32.png" && \
    cp -f $RESOURCES_PATH/branding/favicon.ico $RESOURCES_PATH"/filebrowser/img/icons/favicon-16x16.png" && \
    cp -f $RESOURCES_PATH/branding/ml-workspace-logo.svg $RESOURCES_PATH"/filebrowser/img/logo.svg"

# Configure git
RUN \
    git config --global core.fileMode false && \
    git config --global http.sslVerify false && \
    # Use store or credentialstore instead? timout == 365 days validity
    git config --global credential.helper 'cache --timeout=31540000'

# Configure Matplotlib
RUN \
    # Import matplotlib the first time to build the font cache.
    MPLBACKEND=Agg python -c "import matplotlib.pyplot" \
    # Stop Matplotlib printing junk to the console on first load
    sed -i "s/^.*Matplotlib is building the font cache using fc-list.*$/# Warning removed/g" $CONDA_PYTHON_DIR/site-packages/matplotlib/font_manager.py && \
    # Make matplotlib output in Jupyter notebooks display correctly
    mkdir -p /etc/ipython/ && echo "c = get_config(); c.IPKernelApp.matplotlib = 'inline'" > /etc/ipython/ipython_config.py

# Create Desktop Icons for Tooling
COPY docker-res/icons $RESOURCES_PATH/icons

RUN \
    # ungit:
    echo "[Desktop Entry]\nVersion=1.0\nType=Link\nName=Ungit\nComment=Git Client\nCategories=Development;\nIcon=/resources/icons/ungit-icon.png\nURL=http://localhost:8091/tools/ungit" > /usr/share/applications/ungit.desktop && \
    chmod +x /usr/share/applications/ungit.desktop && \
    # netdata:
    echo "[Desktop Entry]\nVersion=1.0\nType=Link\nName=Netdata\nComment=Hardware Monitoring\nCategories=System;Utility;Development;\nIcon=/resources/icons/netdata-icon.png\nURL=http://localhost:8091/tools/netdata" > /usr/share/applications/netdata.desktop && \
    chmod +x /usr/share/applications/netdata.desktop && \
    # glances:
    echo "[Desktop Entry]\nVersion=1.0\nType=Link\nName=Glances\nComment=Hardware Monitoring\nCategories=System;Utility;\nIcon=/resources/icons/glances-icon.png\nURL=http://localhost:8091/tools/glances" > /usr/share/applications/glances.desktop && \
    chmod +x /usr/share/applications/glances.desktop && \
    # Remove mail and logout desktop icons
    rm /usr/share/applications/exo-mail-reader.desktop && \
    rm /usr/share/applications/xfce4-session-logout.desktop

# Various configurations
RUN \
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
    # Set /workspace as default directory to navigate to as root user
    echo  'cd '$WORKSPACE_HOME >> $HOME/.bashrc 

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
    # Control how to bind OpenMP* threads to physical processing units
    KMP_AFFINITY="granularity=fine,compact,1,0"
    # KMP_BLOCKTIME="1" -> is not faster in my tests

# Set default values for environment variables
ENV WORKSPACE_CONFIG_BACKUP="true" \
    SHUTDOWN_INACTIVE_KERNELS="false" \
    AUTHENTICATE_VIA_JUPYTER="false" \
    DATA_ENVIRONMENT="/workspace/environment" \
    WORKSPACE_BASE_URL="/" \
    # set number of threads various programs should use, if not-set, it tries to use all
    # this can be problematic since docker restricts CPUs by stil showing all
    MAX_NUM_THREADS="8" \
    WORKSPACE_TYPE="cpu"

### END CONFIGURATION ###

ARG workspace_version="unknown"
ENV WORKSPACE_VERSION=$workspace_version

# refresh ssh environment variables here again
# TODO remove?
RUN printenv > $HOME/.ssh/environment

# Overwrite & add Labels
LABEL \
    "io.k8s.description"="All-in-one web-based IDE specialized for machine learning and data science." \
    "io.k8s.display-name"="Machine Learning Workspace" \
    "io.openshift.expose-services"="8091:http, 5901:xvnc" \
    "io.openshift.non-scalable"="true" \
    "io.openshift.tags"="vnc, ubuntu, xfce, workspace, machine learning" \
    "io.openshift.min-memory"="1Gi" \
    "workspace.version"=$workspace_version \
    "workspace.type"=$WORKSPACE_TYPE

# This assures we have a volume mounted even if the user forgot to do bind mount.
# So that they do not lose their data if they delete the container.
# TODO: VOLUME [ "/workspace" ]

# use global option with tini to kill full process groups: https://github.com/krallin/tini#process-group-killing
ENTRYPOINT ["/tini", "-g", "--", "python", "/resources/run.py"]

# Port 8091 is the main access port (also includes SSH)
# Port 5091 is the VNC port
# Port 3389 is the RDP port
# Port 8090 is the Jupyter Notebook Server
# See supervisor.conf for more ports

EXPOSE 8091
###
