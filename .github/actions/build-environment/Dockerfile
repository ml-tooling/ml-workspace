FROM ubuntu:20.04

# Fix for pipe operations: https://github.com/hadolint/hadolint/wiki/DL4006
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Generate and Set locals
# https://stackoverflow.com/questions/28405902/how-to-set-the-locale-inside-a-debian-ubuntu-docker-container#38553499
RUN apt-get update \
    && apt-get install -y --no-install-recommends locales \
    && sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
    && locale-gen \
    && dpkg-reconfigure --frontend=noninteractive locales \
    && update-locale LANG=en_US.UTF-8 \
    # Clean up
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

ENV LC_ALL="en_US.UTF-8" \
    LANG="en_US.UTF-8" \
    LANGUAGE="en_US:en" \
    TZ="Europe/Berlin" \
    DEBIAN_FRONTEND="noninteractive"

# Install basics
# hadolint ignore=DL3005
RUN apt-get update --fix-missing \
    && apt-get install -y --no-install-recommends apt-utils \
    && apt-get -y upgrade \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        apt-transport-https \
        ca-certificates \
        curl \
        wget \
        gnupg2 \
        git \
        jq \
        software-properties-common \
        openssh-client \
    # Clean up
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Add tini
RUN wget --quiet https://github.com/krallin/tini/releases/download/v0.19.0/tini -O /tini && \
    chmod +x /tini

# Install Docker in Container
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - \
    && add-apt-repository \
        "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
        $(lsb_release -cs) \
        stable" \
    && apt-get update -y \
    && apt-get install -y --no-install-recommends docker-ce=5:19.03.13~3-0~ubuntu-focal \
    # Clean up
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Python
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        python3 \
        python3-pip \
    && ln -s /usr/bin/python3 /usr/bin/python \
    && ln -s /usr/bin/pip3 /usr/bin/pip \
    # Clean up
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
#coverage tox pytest-runner

# Install Universal-Build
# hadolint ignore=DL3013
RUN pip install --upgrade git+https://github.com/ml-tooling/universal-build.git
RUN pip install docker
RUN pip install pytest

COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh
RUN mkdir -p /github/home/.ssh/ && \
    # create empty config file if not exists
    touch /github/home/.ssh/config  && \
    chown -R root:root /github/home/.ssh && \
    chmod 700 /github/home/.ssh && \
    # create a symlink because ssh looks in the /root/.ssh folder (home of root user) and not in the
    # actual $HOME directory
    ln -s /github/home/.ssh /root/.ssh

ENTRYPOINT ["/tini", "-g", "--", "/entrypoint.sh"]
