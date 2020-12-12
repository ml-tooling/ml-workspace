#!/bin/sh

# Stops script execution if a command has an error
set -e

INSTALL_ONLY=0
PORT=""
# Loop through arguments and process them: https://pretzelhands.com/posts/command-line-flags
for arg in "$@"; do
    case $arg in
        -i|--install) INSTALL_ONLY=1 ; shift ;;
        -p=*|--port=*) PORT="${arg#*=}" ; shift ;; # TODO Does not allow --port 1234
        *) break ;;
    esac
done

if [ ! -f "/usr/lib/rstudio-server/bin/rserver" ]; then
    cd $RESOURCES_PATH
    if ! hash Rscript 2>/dev/null; then
        echo "Installing R runtime. Please wait..."
        # R not installed: Install r-base and r-cairo (for displaying plots)
        conda install -y --freeze-installed r-base r-cairo
    fi
    apt-get update
    # required by rstudio server
    apt-get install -y --no-install-recommends libclang-dev
    echo "Installing RStudio Server. Please wait..."
    # TODO: RStudio version 1.3 does not support the no-auth setup, 1.4 will support it again
    wget -q https://download2.rstudio.org/server/trusty/amd64/rstudio-server-1.2.5042-amd64.deb -O ./rstudio.deb
    gdebi --non-interactive ./rstudio.deb
    rm ./rstudio.deb
    # Rstudio Server cannot run via root -> create rstudio user
    # https://support.rstudio.com/hc/en-us/articles/200552306-Getting-Started
    # https://stackoverflow.com/questions/33625593/rstudio-server-unable-to-connect-to-service
    # https://support.rstudio.com/hc/en-us/articles/217027968-Changing-the-system-account-for-RStudio-Server
    useradd -m -d /home/rstudio rstudio
    # Make rstudio able to use passwordless sudo
    usermod -aG sudo rstudio
    echo "rstudio ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
    # configure rserver:
    # https://docs.rstudio.com/ide/server-pro/1.0.34/r-sessions.html
    # https://support.rstudio.com/hc/en-us/articles/200552316-Configuring-the-Server
    # add conda lib to ld library -> otherwise plotting does not work: https://github.com/ml-tooling/ml-workspace/issues/6
    mkdir -p /etc/rstudio
    printf "rsession-ld-library-path="$CONDA_ROOT"/lib/" > /etc/rstudio/rserver.conf
    # configure working directory to workspace
    printf "session-default-working-dir="$WORKSPACE_HOME"\nsession-default-new-project-dir="$WORKSPACE_HOME > /etc/rstudio/rsession.conf
    printf "setwd ('"$WORKSPACE_HOME"')" > /home/rstudio/.Rprofile
    apt-get clean
else
    echo "RStudio Server is already installed"
fi

# Run
if [ $INSTALL_ONLY = 0 ] ; then
    if [ -z "$PORT" ]; then
        read -p "Please provide a port for starting the application: " PORT
    fi

    echo "Starting Rstudio server on port "$PORT
    # Create tool entry for tooling plugin
    echo '{"id": "rstudio-link", "name": "RStudio", "url_path": "/tools/'$PORT'/", "description": "Development environment for R"}' > $HOME/.workspace/tools/rstudio-server.json
    cd $RESOURCES_PATH
    # Fix tmp permissions - does not work if tmp permissions are wrong
    chmod 1777 /tmp
    # Run rstudio with rstudio user and empty ld_library_path (otherwise it gets stuck)
    LD_LIBRARY_PATH="" LD_PRELOAD="" USER=rstudio /usr/lib/rstudio-server/bin/rserver --server-working-dir=$WORKSPACE_HOME --server-daemonize=0 --auth-none=1 --auth-validate-users=0 --www-port $PORT
    sleep 10
fi

