FROM ubuntu:18.04

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
        tmux \
        dpkg-sig \
        uuid-dev \
        csh \
        xclip \
        clinfo \
        libgdbm-dev \
        libncurses5-dev \
        gawk \
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
        # Search text and binary files
        yara \
        # Minimalistic C client for Redis
        libhiredis-dev \
        # style sheet preprocessor
        less \
        # Print dir tree
        tree \
        # Bash autocompletion functionality
        bash-completion \
        # ping support
        iputils-ping \
        # Json Processor
        jq \
        rsync \
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
        # TODO: no 18.04 installation candidate: libjasper-dev \
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
        # also install rar/unrar? but both are propriatory
        zip \
        gzip \
        unzip \
        unrar \
        bzip2 \
        lzop \
        bsdtar \
        zlibc \
        libbz2-dev \
        liblzma-dev \
        zlib1g-dev && \
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

########### OpeResty Install
# https://github.com/IntimateMerger/docker-openresty/blob/master/Dockerfile
# Docker Build Arguments
ARG RESTY_IMAGE_TAG
ARG RESTY_VERSION="1.15.8.2"
ARG RESTY_OPENSSL_VERSION="1.1.1c"
ARG RESTY_PCRE_VERSION="8.43"
ARG RESTY_J="nproc"

# These are not intended to be user-specified
ARG _RESTY_CONFIG_OPTIONS="\
    --with-http_stub_status_module \
    --with-http_sub_module\
    --with-http_addition_module \
    --with-http_auth_request_module \
    --with-http_gunzip_module \
    --with-http_gzip_static_module \
    --with-http_realip_module \
    --with-http_ssl_module \
    --with-http_stub_status_module \
    --with-http_v2_module \
    --with-pcre-jit \
    --with-threads \
    "

ARG RESTY_CONFIG_OPTIONS=""
ARG RESTY_LUAJIT_OPTIONS="--with-luajit-xcflags='-DLUAJIT_NUMMODE=2 -DLUAJIT_ENABLE_LUA52COMPAT'"

ARG RESTY_ADD_PACKAGE_BUILDDEPS=""
ARG RESTY_ADD_PACKAGE_RUNDEPS=""
ARG RESTY_EVAL_PRE_CONFIGURE=""
ARG RESTY_EVAL_POST_MAKE=""

# These are not intended to be user-specified
ARG _RESTY_CONFIG_DEPS="--with-pcre \
    --with-cc-opt='-DNGX_LUA_ABORT_AT_PANIC -I/usr/local/openresty/pcre/include -I/usr/local/openresty/openssl/include' \
    --with-ld-opt='-L/usr/local/openresty/pcre/lib -L/usr/local/openresty/openssl/lib -Wl,-rpath,/usr/local/openresty/pcre/lib:/usr/local/openresty/openssl/lib' \
    "

LABEL resty.image="alpine:${RESTY_IMAGE_TAG}" \
      resty.version="${RESTY_VERSION}" \
      resty.openssl_version="${RESTY_OPENSSL_VERSION}" \
      resty.pcre_version="${RESTY_PCRE_VERSION}" \
      resty.config_options="${_RESTY_CONFIG_OPTIONS} ${RESTY_CONFIG_OPTIONS}" \
      resty.add_package_builddeps="${RESTY_ADD_PACKAGE_BUILDDEPS}" \
      resty.add_package_rundeps="${RESTY_ADD_PACKAGE_RUNDEPS}" \
      resty.eval_pre_configure="${RESTY_EVAL_PRE_CONFIGURE}" \
      resty.eval_post_make="${RESTY_EVAL_POST_MAKE}"

# 1) Install apt dependencies
# 2) Download and untar OpenSSL, PCRE, and OpenResty
# 3) Build OpenResty
# 4) Cleanup

RUN set -x && apt-get update && apt-get -y install --no-install-recommends \
        software-properties-common \
        ${RESTY_ADD_PACKAGE_BUILDDEPS} \
    && cd /tmp \
    && if [ -n "${RESTY_EVAL_PRE_CONFIGURE}" ]; then eval $(echo ${RESTY_EVAL_PRE_CONFIGURE}); fi \
    && cd /tmp \
    && curl -sfSL https://www.openssl.org/source/openssl-${RESTY_OPENSSL_VERSION}.tar.gz -o openssl-${RESTY_OPENSSL_VERSION}.tar.gz \
    && tar xzf openssl-${RESTY_OPENSSL_VERSION}.tar.gz \
    && cd openssl-${RESTY_OPENSSL_VERSION} \
    && if [ $(echo ${RESTY_OPENSSL_VERSION} | cut -c 1-5) = "1.1.1" ] ; then \
        echo 'patching OpenSSL 1.1.1 for OpenResty' \
        && curl -s https://raw.githubusercontent.com/openresty/openresty/master/patches/openssl-1.1.1c-sess_set_get_cb_yield.patch | patch -p1 ; \
    fi \
    && if [ $(echo ${RESTY_OPENSSL_VERSION} | cut -c 1-5) = "1.1.0" ] ; then \
        echo 'patching OpenSSL 1.1.0 for OpenResty' \
        && curl -s https://raw.githubusercontent.com/openresty/openresty/ed328977028c3ec3033bc25873ee360056e247cd/patches/openssl-1.1.0j-parallel_build_fix.patch | patch -p1 \
        && curl -s https://raw.githubusercontent.com/openresty/openresty/master/patches/openssl-1.1.0d-sess_set_get_cb_yield.patch | patch -p1 ; \
    fi \
    && ./config \
      no-threads shared zlib -g \
      enable-ssl3 enable-ssl3-method \
      --prefix=/usr/local/openresty/openssl \
      # This flag can change the ssl dir --openssldir=/etc/ssl/ \
      --libdir=lib \
      -Wl,-rpath,/usr/local/openresty/openssl/lib \
    && make -j"$(${RESTY_J})" \
    && make -j"$(${RESTY_J})" install_sw \
    && cd /tmp \
    && curl -sfSL https://ftp.pcre.org/pub/pcre/pcre-${RESTY_PCRE_VERSION}.tar.gz -o pcre-${RESTY_PCRE_VERSION}.tar.gz \
    && tar xzf pcre-${RESTY_PCRE_VERSION}.tar.gz \
    && cd /tmp/pcre-${RESTY_PCRE_VERSION} \
    && ./configure \
        --prefix=/usr/local/openresty/pcre \
        --disable-cpp \
        --enable-jit \
        --enable-utf \
        --enable-unicode-properties \
    && make -j"$(${RESTY_J})" \
    && make -j"$(${RESTY_J})" install \
    && cd /tmp \
    && curl -sfSL https://github.com/openresty/openresty/releases/download/v${RESTY_VERSION}/openresty-${RESTY_VERSION}.tar.gz -o openresty-${RESTY_VERSION}.tar.gz \
    && tar xzf openresty-${RESTY_VERSION}.tar.gz \
    && cd /tmp/openresty-${RESTY_VERSION} \
    && eval ./configure -j"$(${RESTY_J})" ${_RESTY_CONFIG_DEPS} ${_RESTY_CONFIG_OPTIONS} ${RESTY_CONFIG_OPTIONS} ${RESTY_LUAJIT_OPTIONS} \
             \
    && make -j"$(${RESTY_J})" \
    && make -j"$(${RESTY_J})" install \
    && cd /tmp \
    && if [ -n "${RESTY_EVAL_POST_MAKE}" ]; then eval $(echo ${RESTY_EVAL_POST_MAKE}); fi \
    && rm -rf \
        openssl-${RESTY_OPENSSL_VERSION}.tar.gz openssl-${RESTY_OPENSSL_VERSION} \
        pcre-${RESTY_PCRE_VERSION}.tar.gz pcre-${RESTY_PCRE_VERSION} \
        openresty-${RESTY_VERSION}.tar.gz openresty-${RESTY_VERSION} \
    && strip /usr/local/openresty/nginx/sbin/nginx \
    && mkdir -p /var/log/openresty \
    # Link ssl cert for openssl not to have cert error 
    && mkdir -p /usr/local/openresty/openssl/ssl/ && ln -sf /etc/ssl/* /usr/local/openresty/openssl/ssl/ \
    && ln -sf /dev/stdout /var/log/openresty/access.log \
    && ln -sf /dev/stderr /var/log/openresty/error.log \
    && mkdir -p /var/log/nginx/ && \
    touch /var/log/nginx/upstream.log && \
    # create log dir and file - otherwise openresty will throw an error
    mkdir -p /var/log/nginx/ && \
    touch /var/log/nginx/upstream.log && \
    cd $RESOURCES_PATH && \
    # Fix permissions
    chmod -R a+rwx $RESOURCES_PATH && \
    # Cleanup
    clean-layer.sh

# Add additional binaries into PATH for convenience
ENV PATH=$PATH:/usr/local/openresty/luajit/bin:/usr/local/openresty/nginx/sbin:/usr/local/openresty/bin


## 
## https://openresty.org/en/installation.html
## https://openresty.org/en/linux-packages.html
##  https://github.com/andriichyzh/docker-best-practices#

## Base optimization
## FROM debian:stretch-slim
## 
## RUN apt-get -y update && \
##     apt-get -y install gnupg2 lsb-release software-properties-common wget && \
##     wget -qO - https://openresty.org/package/pubkey.gpg | apt-key add - && \
##     add-apt-repository -y "deb http://openresty.org/package/debian $(lsb_release -sc) openresty" && \
##     apt-get update && \
##     apt-get -y install openresty && \
##     apt-get remove -y --purge gnupg2 lsb-release software-properties-common wget && \
##     apt-get -y autoremove && \
##     rm -rf /var/lib/apt/lists/*
## 
## ENV PATH="${PATH}:/usr/local/openresty/luajit/bin:/usr/local/openresty/nginx/sbin:/usr/local/openresty/bin"
## 
## COPY nginx.conf /usr/local/openresty/nginx/conf/nginx.conf
## 
## EXPOSE 80
## 
## CMD ["/usr/bin/openresty", "-g", "daemon off;"]#

#RUN \
#    OPEN_RESTY_VERSION="1.15.8.2" && \
#    apt-get update && \
#    apt-get purge -y nginx nginx-common && \
#    # libpcre required, otherwise you get a 'the HTTP rewrite module requires the PCRE library' error
#    # Install apache2-utils to generate user:password file for nginx.
#    apt-get install -y libssl-dev libpcre3 libpcre3-dev apache2-utils && \
#    mkdir $RESOURCES_PATH"/openresty" && \
#    cd $RESOURCES_PATH"/openresty" && \
#    wget --quiet https://openresty.org/download/openresty-$OPEN_RESTY_VERSION.tar.gz  -O ./openresty.tar.gz && \
#    tar xfz ./openresty.tar.gz && \
#    rm ./openresty.tar.gz && \
#    cd ./openresty-$OPEN_RESTY_VERSION/ && \
#    # Surpress output - if there is a problem remove  > /dev/null
#    ./configure --with-http_stub_status_module --with-http_sub_module > /dev/null && \
#    make -j2 > /dev/null && \
#    make install > /dev/null && \
#    # create log dir and file - otherwise openresty will throw an error
#    mkdir -p /var/log/nginx/ && \
#    touch /var/log/nginx/upstream.log && \
#    cd $RESOURCES_PATH && \
#    rm -r $RESOURCES_PATH"/openresty" && \
#    # Fix permissions
#    chmod -R a+rwx $RESOURCES_PATH && \
#    # Cleanup
#    clean-layer.sh#

COPY resources/nginx/lua-extensions /etc/nginx/nginx_plugins

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

### END BASICS ###

### RUNTIMES ###
# Install Miniconda: https://repo.continuum.io/miniconda/
ENV \
    CONDA_DIR=/opt/conda \
    PYTHON_VERSION="3.7.5" \
    CONDA_PYTHON_DIR=/opt/conda/lib/python3.7

RUN CONDA_VERSION="4.7.12" && \
    wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-${CONDA_VERSION}-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p $CONDA_DIR && \
    export PATH=$CONDA_DIR/bin:$PATH && \
    rm ~/miniconda.sh && \
    # Update conda
    $CONDA_DIR/bin/conda update -y -n base -c defaults conda && \
    $CONDA_DIR/bin/conda update -y setuptools && \
    $CONDA_DIR/bin/conda install -y conda-build && \
    # Add conda forge - Append so that conda forge has lower priority than the main channel
    $CONDA_DIR/bin/conda config --system --append channels conda-forge && \
    $CONDA_DIR/bin/conda config --system --set auto_update_conda false && \
    $CONDA_DIR/bin/conda config --system --set show_channel_urls true && \
    # Update selected packages - install python 3.7.x
    $CONDA_DIR/bin/conda install -y --update-all python=$PYTHON_VERSION && \
    # Link Conda
    ln -s $CONDA_DIR/bin/python /usr/local/bin/python && \
    ln -s $CONDA_DIR/bin/conda /usr/bin/conda && \
    # Update pip
    $CONDA_DIR/bin/pip install --upgrade pip && \
    chmod -R a+rwx /usr/local/bin/ && \
    # Cleanup - Remove all here since conda is not in path as of now
    # find /opt/conda/ -follow -type f -name '*.a' -delete && \
    # find /opt/conda/ -follow -type f -name '*.js.map' -delete && \
    $CONDA_DIR/bin/conda clean -y --packages && \
    $CONDA_DIR/bin/conda clean -y --all -f  && \
    $CONDA_DIR/bin/conda build purge-all && \
    # Fix permissions
    fix-permissions.sh $CONDA_DIR && \
    clean-layer.sh

ENV PATH=$CONDA_DIR/bin:$PATH

# There is nothing added yet to LD_LIBRARY_PATH, so we can overwrite
ENV LD_LIBRARY_PATH=$CONDA_DIR/lib 

# Install node.js
RUN \
    apt-get update && \
    curl -sL https://deb.nodesource.com/setup_13.x | sudo -E bash - && \
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
    # Install YARN
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends yarn && \
    # Install typescript 
    /usr/bin/npm install -g typescript && \
    # Install webpack - 32 MB
    /usr/bin/npm install -g webpack && \
    # Cleanup
    clean-layer.sh

ENV PATH=/opt/node/bin:$PATH

# Install Java Runtime
RUN \
    apt-get update && \
    # libgl1-mesa-dri > 150 MB -> Install jdk-headless version (without gui support)?
    # java runtime is extenable via the java-utils.sh tool intstaller script
    apt-get install -y --no-install-recommends openjdk-11-jdk maven scala && \
    # Cleanup
    clean-layer.sh

ENV JAVA_HOME="/usr/lib/jvm/java-11-openjdk-amd64" 
# TODO add MAVEN_HOME?

### END RUNTIMES ###

### PROCESS TOOLS ###

### Install xfce UI
RUN \
    apt-get update && \
    # Install custom font
    apt-get install -y xfce4 xfce4-terminal xterm && \
    apt-get purge -y pm-utils xscreensaver* && \
    # Cleanup
    clean-layer.sh

# Install rdp support via xrdp
RUN \
    apt-get update && \
    apt-get install -y --no-install-recommends xrdp && \
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
    apt-get install -y --no-install-recommends rsyslog && \
    pip install --no-cache-dir --upgrade supervisor supervisor-stdout && \
    # supervisor needs this logging path
    mkdir -p /var/log/supervisor/ && \
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
    wget -qO- https://dl.bintray.com/tigervnc/stable/tigervnc-1.10.0.x86_64.tar.gz | tar xz --strip 1 -C / && \
    # Install websockify
    mkdir -p ./novnc/utils/websockify && \
    # Before updating the noVNC version, we need to make sure that our monkey patching scripts still work!!
    wget -qO- https://github.com/novnc/noVNC/archive/v1.1.0.tar.gz | tar xz --strip 1 -C ./novnc && \
    # use older version of websockify to prevent hanging connections on offline containers?, see https://github.com/ConSol/docker-headless-vnc-container/issues/50
    wget -qO- https://github.com/novnc/websockify/archive/v0.9.0.tar.gz | tar xz --strip 1 -C ./novnc/utils/websockify && \
    chmod +x -v ./novnc/utils/*.sh && \
    # create user vnc directory
    mkdir -p $HOME/.vnc && \
    # Fix permissions
    fix-permissions.sh ${RESOURCES_PATH} && \
    # Cleanup
    clean-layer.sh

# Install Terminal / GDebi (Package Manager) / Glogg (Stream file viewer) & archive tools
# Discover Tools:
# https://wiki.ubuntuusers.de/Startseite/
# https://wiki.ubuntuusers.de/Xfce_empfohlene_Anwendungen/
# https://goodies.xfce.org/start
# https://linux.die.net/man/1/
RUN \
    apt-get update && \
    apt-get install -y --no-install-recommends xfce4-terminal && \
    apt-get install -y --no-install-recommends --allow-unauthenticated xfce4-taskmanager  && \
    # Install gdebi deb installer
    apt-get install -y --no-install-recommends gdebi && \
    # Search for files
    apt-get install -y --no-install-recommends catfish && \
    # TODO: Unable to locate package:  apt-get install -y --no-install-recommends gnome-search-tool && 
    apt-get install -y --no-install-recommends font-manager && \
    # vs support for thunar
    apt-get install -y thunar-vcs-plugin && \
    # Streaming text editor for large files
    apt-get install -y --no-install-recommends glogg  && \
    apt-get install -y --no-install-recommends baobab && \
    # Lightweight text editor
    apt-get install -y mousepad && \
    apt-get install -y --no-install-recommends vim && \
    apt-get install -y htop && \
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
    apt-get install -y --no-install-recommends xfce4-systemload-plugin && \
    # Leightweight ftp client that supports sftp, http, ...
    apt-get install -y --no-install-recommends gftp && \
    # Install chrome
    apt-get install -y chromium-browser chromium-browser-l10n chromium-codecs-ffmpeg && \
    ln -s /usr/bin/chromium-browser /usr/bin/google-chrome && \
    # Cleanup
    # Large package: gnome-user-guide 50MB app-install-data 50MB
    apt-get remove -y app-install-data gnome-user-guide && \ 
    clean-layer.sh

# Add the defaults from /lib/x86_64-linux-gnu, otherwise lots of no version errors
# cannot be added above otherwise there are errors in the installation of the gui tools
# Call order: https://unix.stackexchange.com/questions/367600/what-is-the-order-that-linuxs-dynamic-linker-searches-paths-in
ENV LD_LIBRARY_PATH=/lib/x86_64-linux-gnu:/usr/lib/x86_64-linux-gnu:$CONDA_DIR/lib 

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

## Glances webtool is installed in python section below

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
    #ln -s -f $CONDA_DIR/bin/python /usr/bin/python3 && \
    # if removed -> cannot use add-apt-repository
    # rm /usr/bin/python3 && \
    # rm /usr/bin/python3.5
    ln -s -f $CONDA_DIR/bin/python /usr/bin/python && \
    apt-get update && \
    # upgrade pip
    pip install --upgrade pip && \
    # If minimal flavor - install 
    if [ "$WORKSPACE_FLAVOR" = "minimal" ]; then \
        # Install nomkl - mkl needs lots of space
        conda install -y --update-all nomkl ; \
    else \
        # Install mkl for faster computations
        conda install -y --update-all mkl ; \
    fi && \
    # Install some basics - required to run container
    conda install -y --update-all \
            'python='$PYTHON_VERSION \
            tqdm \
            pyzmq \
            cython \
            graphviz \
            numpy \
            matplotlib \
            scipy \
            requests \
            urllib3 \
            pandas \
            six \
            future \
            protobuf \
            zlib \
            boost \
            psutil \
            PyYAML \
            python-crontab \
            ipykernel \
            cmake \
            Pillow \
            'ipython=7.10.*' \
            'notebook=6.0.*' \
            'jupyterlab=1.2.*' && \
    # Install minimal pip requirements
    pip install --no-cache-dir --upgrade -r ${RESOURCES_PATH}/libraries/requirements-minimal.txt && \
    # If minimal flavor - exit here
    if [ "$WORKSPACE_FLAVOR" = "minimal" ]; then \
        # Fix permissions
        fix-permissions.sh $CONDA_DIR && \
        # Cleanup
        clean-layer.sh && \
        exit 0 ; \
    fi && \
    # OpenMPI support
    apt-get install -y --no-install-recommends libopenmpi-dev openmpi-bin && \
    # Install mkl, mkl-include & mkldnn
    conda install -y mkl-include && \
    # TODO - Install was not working conda install -y -c mingfeima mkldnn && \
    # Install numba
    conda install -y numba && \
    # Install tensorflow - cpu only -  mkl support
    conda install -y 'tensorflow=2.0.*' && \
    # Install pytorch - cpu only
    conda install -y -c pytorch "pytorch==1.3.*" torchvision cpuonly && \
    # Install light pip requirements
    pip install --no-cache-dir --upgrade -r ${RESOURCES_PATH}/libraries/requirements-light.txt && \
    # If light light flavor - exit here
    if [ "$WORKSPACE_FLAVOR" = "light" ]; then \
        # Fix permissions
        fix-permissions.sh $CONDA_DIR && \
        # Cleanup
        clean-layer.sh && \
        exit 0 ; \
    fi && \
    # libartals == 40MB liblapack-dev == 20 MB
    apt-get install -y --no-install-recommends liblapack-dev libatlas-base-dev libeigen3-dev pandoc libblas-dev && \
    # Faiss - A library for efficient similarity search and clustering of dense vectors. 
    conda install -y -c pytorch faiss-cpu && \
    # Install full pip requirements
    pip install --no-cache-dir --upgrade -r ${RESOURCES_PATH}/libraries/requirements-full.txt && \
    # Setup Spacy
    # Spacy - download and large language removal
    python -m spacy download en && \
    # Remove unneeded languages - otherwise it takes up too much space
    cd $CONDA_PYTHON_DIR/site-packages/spacy/lang && \
    rm -rf tr pt da sv ca nb && \
    # Fix permissions
    fix-permissions.sh $CONDA_DIR && \
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

# install jupyter extensions
RUN \
    # Activate and configure extensions
    jupyter contrib nbextension install --user && \
    # nbextensions configurator
    jupyter nbextensions_configurator enable --user && \
    # Active nbresuse
    jupyter serverextension enable --py nbresuse && \
    # Activate Jupytext
    jupyter nbextension enable --py jupytext && \
    # Disable Jupyter Server Proxy
    jupyter nbextension disable jupyter_server_proxy/tree && \
    # If minimal flavor - exit here
    if [ "$WORKSPACE_FLAVOR" = "minimal" ]; then \
        # Cleanup
        clean-layer.sh && \
        exit 0 ; \
    fi && \
    # Configure nbdime
    nbdime config-git --enable --global && \
    # Enable useful extensions
    jupyter nbextension enable skip-traceback/main && \
    # jupyter nbextension enable comment-uncomment/main && \
    # Do not enable variable inspector: causes trouble: https://github.com/ml-tooling/ml-workspace/issues/10
    # jupyter nbextension enable varInspector/main && \
    #jupyter nbextension enable spellchecker/main && \
    jupyter nbextension enable toc2/main && \
    jupyter nbextension enable execute_time/ExecuteTime && \
    jupyter nbextension enable collapsible_headings/main && \
    jupyter nbextension enable codefolding/main && \
    # Activate Jupyter Tensorboard
    jupyter tensorboard enable && \
    # Edit notebook config
    cat $HOME/.jupyter/nbconfig/notebook.json | jq '.toc2={"moveMenuLeft": false}' > tmp.$$.json && mv tmp.$$.json $HOME/.jupyter/nbconfig/notebook.json && \
    # If light flavor - exit here
    if [ "$WORKSPACE_FLAVOR" = "light" ]; then \
        # Cleanup
        clean-layer.sh && \
        exit 0 ; \
    fi && \
    # Activate qgrid
    jupyter nbextension enable --py --sys-prefix qgrid && \
    # Activate Colab support
    jupyter serverextension enable --py jupyter_http_over_ws && \
    # Activate Voila Rendering 
    # currently not working jupyter serverextension enable voila --sys-prefix && \
    # Enable ipclusters
    ipcluster nbextension enable && \
    # Fix permissions? fix-permissions.sh $CONDA_DIR && \
    # Cleanup
    clean-layer.sh

# install jupyterlab
RUN \
    # Required for jupytext and matplotlib plugins
    jupyter lab build && \
    # jupyterlab installed in requirements section
    jupyter labextension install @jupyter-widgets/jupyterlab-manager && \
    # If minimal flavor - do not install jupyterlab extensions
    if [ "$WORKSPACE_FLAVOR" = "minimal" ]; then \
        # Cleanup
        jupyter lab clean && \
        jlpm cache clean && \
        rm -rf $CONDA_DIR/share/jupyter/lab/staging && \
        clean-layer.sh && \
        exit 0 ; \
    fi && \
    jupyter labextension install @jupyterlab/toc && \
    jupyter labextension install jupyterlab_tensorboard && \
    # install jupyterlab git
    jupyter labextension install @jupyterlab/git && \
    pip install jupyterlab-git && \ 
    jupyter serverextension enable --py jupyterlab_git && \
    # For Matplotlib: https://github.com/matplotlib/jupyter-matplotlib
    jupyter labextension install jupyter-matplotlib && \
    # Do not install any other jupyterlab extensions
    if [ "$WORKSPACE_FLAVOR" = "light" ]; then \
        # Cleanup
        jupyter lab clean && \
        jlpm cache clean && \
        rm -rf $CONDA_DIR/share/jupyter/lab/staging && \
        clean-layer.sh && \
        exit 0 ; \
    fi && \
    # Install jupyterlab language server support
    pip install --pre jupyter-lsp && \
    jupyter labextension install @krassowski/jupyterlab-lsp && \
    # For Bokeh
    jupyter labextension install jupyterlab_bokeh && \
    # For Plotly
    jupyter labextension install @jupyterlab/plotly-extension && \
    jupyter labextension install jupyterlab-chart-editor && \
    # For holoview
    jupyter labextension install @pyviz/jupyterlab_pyviz && \
    # Install jupyterlab_iframe - https://github.com/timkpaine/jupyterlab_iframe
    pip install jupyterlab_iframe && \
    jupyter labextension install jupyterlab_iframe && \
    jupyter serverextension enable --py jupyterlab_iframe && \
    # Install jupyterlab variable inspector - https://github.com/lckr/jupyterlab-variableInspector
    jupyter labextension install @lckr/jupyterlab_variableinspector && \
    # Install jupyterlab code formattor - https://github.com/ryantam626/jupyterlab_code_formatter
    jupyter labextension install @ryantam626/jupyterlab_code_formatter && \
    pip install jupyterlab_code_formatter && \
    jupyter serverextension enable --py jupyterlab_code_formatter && \
    # Install go-to-definition extension 
    jupyter labextension install @krassowski/jupyterlab_go_to_definition && \
    # Install ipysheet jupyterlab extension
    jupyter labextension install ipysheet && \
    # Deprecation and validations:
    # Install jupyterlab_templates - https://github.com/timkpaine/jupyterlab_templates
    # Does not work currently
    # pip install jupyterlab_templates && \
    # jupyter labextension install jupyterlab_templates && \
    # jupyter serverextension enable --py jupyterlab_templates && \
    # Install jupyterlab-data-explorer: https://github.com/jupyterlab/jupyterlab-data-explorer
    # alpha version jupyter labextension install @jupyterlab/dataregistry-extension && \
    # Install jupyterlab system monitor: https://github.com/jtpio/jupyterlab-system-monitor
    # Activate ipygrid in jupterlab
    # Problems with terminal: jupyter labextension install ipyaggrid && \
    # Install qgrid
    # Not compatible to jupyterlab 1.x: https://github.com/quantopian/qgrid/issues/261
    # DO not install for now jupyter labextension install jupyterlab-topbar-extension jupyterlab-system-monitor && \
     # Install voyagar data grid
    # Does not work with 1.1.1: jupyter labextension install jupyterlab_voyager && \
    # Too big dependency: https://github.com/InsightSoftwareConsortium/itkwidgets
    # Too Big: Install ipyleaflet
    # pip install --no-cache-dir ipyleaflet && \
    # jupyter labextension install jupyter-leaflet && \
    jupyter lab build && \
    # Cleanup
    # Clean jupyter lab cache: https://github.com/jupyterlab/jupyterlab/issues/4930
    jupyter lab clean && \
    jlpm cache clean && \
    # Remove build folder -> should be remove by lab clean as well?
    rm -rf $CONDA_DIR/share/jupyter/lab/staging && \
    clean-layer.sh

# Install Jupyter Tooling Extension
COPY resources/jupyter/extensions $RESOURCES_PATH/jupyter-extensions

RUN \
    pip install --no-cache-dir $RESOURCES_PATH/jupyter-extensions/tooling-extension/ && \
    # Cleanup
    clean-layer.sh

COPY resources/tools/oh-my-zsh.sh $RESOURCES_PATH/tools/oh-my-zsh.sh

RUN \
    # If minimal flavor -> exit here
    if [ "$WORKSPACE_FLAVOR" = "minimal" ]; then \
        exit 0 ; \
    fi && \
    # Install ZSH
    /bin/bash $RESOURCES_PATH/tools/oh-my-zsh.sh --install && \
    # Make zsh the default shell
    # Initialize conda for command line activation
    # TODO do not activate for now, opening the bash shell is a bit slow
    # conda init bash && \
    # conda init zsh
    chsh -s $(which zsh) $NB_USER && \
    # Cleanup
    clean-layer.sh

### VSCODE ###

# Install vscode extension
# https://github.com/cdr/code-server/issues/171
# Alternative install: /usr/local/bin/code-server --user-data-dir=$HOME/.config/Code/ --extensions-dir=$HOME/.vscode/extensions/ --install-extension ms-python-release && \
RUN \
    # If minimal or light flavor -> exit here
    if [ "$WORKSPACE_FLAVOR" = "minimal" ] || [ "$WORKSPACE_FLAVOR" = "light" ]; then \
        exit 0 ; \
    fi && \
    cd $RESOURCES_PATH && \
    mkdir -p $HOME/.vscode/extensions/ && \
    # Install python extension
    VS_PYTHON_VERSION="2019.11.50794" && \
    wget --quiet --no-check-certificate https://github.com/microsoft/vscode-python/releases/download/$VS_PYTHON_VERSION/ms-python-release.vsix && \
    bsdtar -xf ms-python-release.vsix extension && \
    rm ms-python-release.vsix && \
    mv extension $HOME/.vscode/extensions/ms-python.python-$VS_PYTHON_VERSION && \
    # Install vscode-java: https://github.com/redhat-developer/vscode-java/releases
    VS_JAVA_VERSION="0.47.0" && \
    wget --quiet --no-check-certificate https://github.com/redhat-developer/vscode-java/releases/download/v$VS_JAVA_VERSION/redhat.java-$VS_JAVA_VERSION.vsix && \
    bsdtar -xf redhat.java-$VS_JAVA_VERSION.vsix extension && \
    rm redhat.java-$VS_JAVA_VERSION.vsix && \
    mv extension $HOME/.vscode/extensions/redhat.java-$VS_JAVA_VERSION && \
    # Install git lens: https://github.com/eamodio/vscode-gitlens
    VS_GITLENS_VERSION="10.2.0" && \
    wget --quiet --no-check-certificate https://github.com/eamodio/vscode-gitlens/releases/download/v$VS_GITLENS_VERSION/gitlens-$VS_GITLENS_VERSION.vsix && \
    bsdtar -xf gitlens-$VS_GITLENS_VERSION.vsix extension && \
    rm gitlens-$VS_GITLENS_VERSION.vsix && \
    mv extension $HOME/.vscode/extensions/eamodio.gitlens-$VS_GITLENS_VERSION && \
    # Install code runner: https://github.com/formulahendry/vscode-code-runner/releases/latest
    VS_CODE_RUNNER_VERSION="0.9.15" && \
    wget --quiet --no-check-certificate https://github.com/formulahendry/vscode-code-runner/releases/download/$VS_CODE_RUNNER_VERSION/code-runner-$VS_CODE_RUNNER_VERSION.vsix && \
    bsdtar -xf code-runner-$VS_CODE_RUNNER_VERSION.vsix extension && \
    rm code-runner-$VS_CODE_RUNNER_VERSION.vsix && \
    mv extension $HOME/.vscode/extensions/code-runner-$VS_CODE_RUNNER_VERSION && \
    # Install ESLint extension: https://marketplace.visualstudio.com/items?itemName=dbaeumer.vscode-eslint
    VS_ESLINT_VERSION="1.9.1" && \
    wget --quiet --no-check-certificate https://marketplace.visualstudio.com/_apis/public/gallery/publishers/dbaeumer/vsextensions/vscode-eslint/$VS_ESLINT_VERSION/vspackage -O dbaeumer.vscode-eslint.vsix && \
    bsdtar -xf dbaeumer.vscode-eslint.vsix extension && \
    rm dbaeumer.vscode-eslint.vsix && \
    mv extension $HOME/.vscode/extensions/dbaeumer.vscode-eslint-$VS_ESLINT_VERSION.vsix && \
    # Install Markdown lint extension: https://marketplace.visualstudio.com/items?itemName=DavidAnson.vscode-markdownlint
    VS_MARKDOWN_LINT_VERSION="0.32.0" && \
    wget --quiet --no-check-certificate https://marketplace.visualstudio.com/_apis/public/gallery/publishers/DavidAnson/vsextensions/vscode-markdownlint/$VS_MARKDOWN_LINT_VERSION/vspackage -O davidanson.vscode-markdownlint.vsix && \
    bsdtar -xf davidanson.vscode-markdownlint.vsix extension && \
    rm davidanson.vscode-markdownlint.vsix && \
    mv extension $HOME/.vscode/extensions/davidanson.vscode-markdownlint-$VS_MARKDOWN_LINT_VERSION.vsix && \
    # Install remote development extension
    VS_REMOTE_SSH_VERSION="0.47.2" && \
    # https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-ssh
    wget --quiet https://marketplace.visualstudio.com/_apis/public/gallery/publishers/ms-vscode-remote/vsextensions/remote-ssh/$VS_REMOTE_SSH_VERSION/vspackage -O ms-vscode-remote.remote-ssh.vsix && \
    bsdtar -xf ms-vscode-remote.remote-ssh.vsix extension && \
    rm ms-vscode-remote.remote-ssh.vsix && \
    mv extension $HOME/.vscode/extensions/ms-vscode-remote.remote-ssh-$VS_REMOTE_SSH_VERSION && \
    # Install remote development ssh - editing configuration files
    # https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-ssh-edit
    wget --quiet https://marketplace.visualstudio.com/_apis/public/gallery/publishers/ms-vscode-remote/vsextensions/remote-ssh-edit/$VS_REMOTE_SSH_VERSION/vspackage -O ms-vscode-remote.remote-ssh-edit.vsix && \
    bsdtar -xf ms-vscode-remote.remote-ssh-edit.vsix extension && \
    rm ms-vscode-remote.remote-ssh-edit.vsix && \
    mv extension $HOME/.vscode/extensions/ms-vscode-remote.remote-ssh-edit-$VS_REMOTE_SSH_VERSION && \
    # TODO install beautify (smaller - 16MB) or prettier?
    # Fix permissions
    fix-permissions.sh $HOME/.vscode/extensions/ && \
    # Cleanup
    clean-layer.sh

### END VSCODE ###

### INCUBATION ZONE ### 

RUN \
    # Install sdkman
    curl -s https://get.sdkman.io | bash && \
   # If minimal or light flavor -> exit here
    if [ "$WORKSPACE_FLAVOR" = "minimal" ] || [ "$WORKSPACE_FLAVOR" = "light" ]; then \
        exit 0 ; \
    fi && \
    # New Python Libraries:
    pip install --no-cache-dir \
                lazycluster && \
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

# Configure Jupyter / JupyterLab
# Add as jupyter system configuration
COPY resources/jupyter/nbconfig /etc/jupyter/nbconfig
COPY resources/jupyter/jupyter_notebook_config.py resources/jupyter/jupyter_notebook_config.json resources/jupyter/nbconfig /etc/jupyter/
COPY resources/jupyter/sidebar.jupyterlab-settings $HOME/.jupyter/lab/user-settings/@jupyterlab/application-extension/
COPY resources/jupyter/plugin.jupyterlab-settings $HOME/.jupyter/lab/user-settings/@jupyterlab/extensionmanager-extension/
# TODO: don't use tensorboard fix: Add tensorboard patch - use tensorboard jupyter plugin instead of the actual tensorboard magic
# COPY resources/jupyter/tensorboard_notebook_patch.py $CONDA_PYTHON_DIR/site-packages/tensorboard/notebook.py

# Branding of various components
RUN \
    # Jupyter Bradning
    cp -f $RESOURCES_PATH/branding/logo.png $CONDA_PYTHON_DIR"/site-packages/notebook/static/base/images/logo.png" && \
    cp -f $RESOURCES_PATH/branding/favicon.ico $CONDA_PYTHON_DIR"/site-packages/notebook/static/base/images/favicon.ico" && \
    cp -f $RESOURCES_PATH/branding/favicon.ico $CONDA_PYTHON_DIR"/site-packages/notebook/static/favicon.ico" && \
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

# Configure netdata
COPY resources/netdata/ /etc/netdata/

# Configure Matplotlib
RUN \
    # Import matplotlib the first time to build the font cache.
    MPLBACKEND=Agg python -c "import matplotlib.pyplot" \
    # Stop Matplotlib printing junk to the console on first load
    sed -i "s/^.*Matplotlib is building the font cache using fc-list.*$/# Warning removed/g" $CONDA_PYTHON_DIR/site-packages/matplotlib/font_manager.py && \
    # Make matplotlib output in Jupyter notebooks display correctly
    mkdir -p /etc/ipython/ && echo "c = get_config(); c.IPKernelApp.matplotlib = 'inline'" > /etc/ipython/ipython_config.py

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
    rm /usr/share/applications/exo-mail-reader.desktop && \
    rm /usr/share/applications/xfce4-session-logout.desktop

# Copy resources into workspace
COPY resources/tools $RESOURCES_PATH/tools
COPY resources/tests $RESOURCES_PATH/tests
COPY resources/tutorials $RESOURCES_PATH/tutorials
COPY resources/licenses $RESOURCES_PATH/licenses
COPY resources/reports $RESOURCES_PATH/reports

# Nginx ELF file does not startup without the specific compiled libraries for openresty 
ENV LD_LIBRARY_PATH=/usr/local/openresty/luajit/lib:/usr/local/openresty/zlib/lib:/usr/local/openresty/pcre/lib:/usr/local/openresty/openssl/lib:$LD_LIBRARY_PATH

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
    chmod a+rwx /tmp && \
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
# https://www.tensorflow.org/guide/performance/overview#tuning_mkl_for_the_best_performance
# https://software.intel.com/en-us/articles/maximize-tensorflow-performance-on-cpu-considerations-and-recommendations-for-inference
ENV KMP_DUPLICATE_LIB_OK="True" \
    # Control how to bind OpenMP* threads to physical processing units # verbose
    KMP_AFFINITY="granularity=fine,compact,1,0" \
    KMP_BLOCKTIME=0
    # KMP_BLOCKTIME="1" -> is not faster in my tests
    # TensorFlow uses less than half the RAM with tcmalloc relative to the default. - requires google-perftools
    # Too many issues: LD_PRELOAD="/usr/lib/libtcmalloc.so.4" \
    # TODO set PYTHONDONTWRITEBYTECODE
    # TODO set XDG_CONFIG_HOME, CLICOLOR?

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
    LS_COLORS=$LS_COLORS:'di=0;96:' \
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
    "org.opencontainers.image.authors"="Lukas Masuch & Benjamin Raehtlein" \
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