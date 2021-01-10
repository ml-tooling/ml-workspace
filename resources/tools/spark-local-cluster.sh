#!/bin/bash

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

# Script inspired by: https://github.com/jupyter/docker-stacks/blob/master/pyspark-notebook/Dockerfile#L18
# https://github.com/apache/incubator-toree/blob/master/Dockerfile


# Todo: Add additional spark configuration:
# https://spark.apache.org/docs/latest/configuration.html
# TODO start spark master?
# https://medium.com/@marcovillarreal_40011/creating-a-spark-standalone-cluster-with-docker-and-docker-compose-ba9d743a157f
# ENV SPARK_MASTER_PORT 7077
# ENV SPARK_MASTER_WEBUI_PORT 8080
# ENV SPARK_WORKER_WEBUI_PORT 8081
# ENV SPARK_MASTER_LOG /spark/logs
# ENV SPARK_WORKER_LOG /spark/logs
# export SPARK_MASTER_HOST=`hostname`
# SPARK_WORKER_CORES=1
# SPARK_WORKER_MEMORY=1G
# SPARK_DRIVER_MEMORY=128m
# SPARK_EXECUTOR_MEMORY=256m

# TODO configure spark ui to be proxied with base path:
# https://stackoverflow.com/questions/45971127/wrong-css-location-of-spark-application-ui
# https://github.com/jupyterhub/jupyter-server-proxy/issues/57
# https://github.com/yuvipanda/jupyter-sparkui-proxy/blob/master/jupyter_sparkui_proxy/__init__.py


# Install scala 2.12
if [[ ! $(scala -version 2>&1) =~ "version 2.12" ]]; then
    # Update to Scala 2.12 is required for spark
    echo "Scala 2.12 is not installed. You should consider running the scala-utils.sh tool installer before continuing."
    sleep 10
else
    echo "Scala 2.12 already installed."
fi

export SPARK_HOME=/opt/spark

if [ ! -d "$SPARK_HOME" ]; then
    echo "Installing Spark. Please wait..."
    cd $RESOURCES_PATH
    SPARK_VERSION="3.0.1"
    HADOOP_VERSION="3.2"
    echo "Downloading. Please wait..."
    wget -q https://mirror.checkdomain.de/apache/spark/spark-$SPARK_VERSION/spark-$SPARK_VERSION-bin-hadoop$HADOOP_VERSION.tgz -O ./spark.tar.gz
    tar xzf spark.tar.gz
    mv spark-$SPARK_VERSION-bin-hadoop$HADOOP_VERSION/ $SPARK_HOME
    rm spark.tar.gz

    # create spark events dir
    mkdir -p /tmp/spark-events

    # Create empty spark config file
    printf "" > $SPARK_HOME/conf/spark-defaults.conf

    # Install Sparkmagic: https://github.com/jupyter-incubator/sparkmagic
    apt-get update
    apt-get install -y libkrb5-dev
    pip install --no-cache-dir sparkmagic
    jupyter serverextension enable --py sparkmagic

    # TODO: does not work right now: Install sparkmonitor: https://github.com/krishnan-r/sparkmonitor
    # pip install --no-cache-dir sparkmonitor
    # jupyter nbextension install sparkmonitor --py --sys-prefix --symlink
    # jupyter nbextension enable sparkmonitor --py --sys-prefix
    # jupyter serverextension enable --py --sys-prefix sparkmonitor
    # ipython profile create && echo "c.InteractiveShellApp.extensions.append('sparkmonitor.kernelextension')" >>  $(ipython profile locate default)/ipython_kernel_config.py

    # Deprecated: jupyter-spark: https://github.com/mozilla/jupyter-spark
    # jupyter serverextension enable --py jupyter_spark && \
    # jupyter nbextension install --py jupyter_spark && \
    # jupyter nbextension enable --py jupyter_spark && \
    # python -m spylon_kernel install
    # Install Jupyter kernels
    # Install beakerX? https://github.com/twosigma/beakerx
    # link spark folder to /usr/local/spark
    # ln -s /usr/local/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION} /usr/local/spark && \
else
    echo "Spark is already installed"
fi

export PATH=$PATH:$SPARK_HOME/bin

# Install python dependencies
pip install --no-cache-dir pyspark findspark pyarrow spylon-kernel
# downgrades sklearn: spark-sklearn \

# Install Apache Toree Kernel: https://github.com/apache/incubator-toree
if [[ ! $(jupyter kernelspec list) =~ "toree" ]]; then
    echo "Installing Toree Kernel for Jupyter. Please wait..."
    TOREE_VERSION=0.5.0
    echo "Torre Kernel does not seem to work with the installed spark and scala verison."
    # TODO: Fix installation
    # pip install --no-cache-dir https://dist.apache.org/repos/dist/dev/incubator/toree/$TOREE_VERSION-incubating-rc1/toree-pip/toree-$TOREE_VERSION.tar.gz
    # jupyter toree install --sys-prefix --spark_home=$SPARK_HOME
else
    echo "Toree Kernel for Jupyter is already installed."
fi


# TODO: Install R Spark integration
# wget -q https://www.apache.org/dyn/closer
# ENV R_LIBS_USER $SPARK_HOME/R/lib

#RUN conda install --yes 'r-sparklyr' && \
    # Cleanup
#    clean-layer.sh

# Run
if [ $INSTALL_ONLY = 0 ] ; then
    if [ -z "$PORT" ]; then
        read -p "Please provide a port for starting a local Spark cluster: " PORT
    fi

    echo "Starting local Spark Master with WebUI on port "$PORT
    echo "spark.ui.proxyBase /tools/"$PORT >> $SPARK_HOME/conf/spark-defaults.conf;
    $SPARK_HOME/sbin/stop-master.sh
    $SPARK_HOME/sbin/start-master.sh --webui-port $PORT --host 0.0.0.0 --port 7077
    # Connect Slaves
    echo "Starting local Spark Worker with WebUI on port 7066"
    $SPARK_HOME/sbin/stop-slave.sh
    $SPARK_HOME/sbin/start-slave.sh spark://0.0.0.0:7077 --webui-port 7066 --host 0.0.0.0
    echo "Spark cluster is started. To access the dashboard, use the link in the open tools menu."
    echo '{"id": "spark-link", "name": "Spark Master", "url_path": "/tools/'$PORT'/", "description": "Apache Spark Master Dashboard"}' > $HOME/.workspace/tools/spark.json
    sleep 20
fi

