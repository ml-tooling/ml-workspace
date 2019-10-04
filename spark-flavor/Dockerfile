ARG ARG_WORKSPACE_VERSION="latest"
# Build from full flavor of workspace with same version
FROM mltooling/ml-workspace-r:$ARG_WORKSPACE_VERSION

ARG ARG_WORKSPACE_FLAVOR="spark"
ENV WORKSPACE_FLAVOR=$ARG_WORKSPACE_FLAVOR
# argument needs to be initalized again
ARG ARG_WORKSPACE_VERSION="latest"
ENV WORKSPACE_VERSION=$ARG_WORKSPACE_VERSION

# Inspirations:
# https://github.com/jupyter/docker-stacks/blob/master/all-spark-notebook/Dockerfile

# Install Scala
RUN \
    apt-get update && \
    apt-get install scala
    # default-jdk

# Install Spark
ENV \
    SPARK_VERSION="2.4.4" \
    HADOOP_VERSION="2.7"

RUN \
    # https://github.com/jupyter/docker-stacks/blob/master/pyspark-notebook/Dockerfile#L18
    wget -q https://www-eu.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz -O ./spark.tar.gz && \
    tar xfz spark.tar.gz -C /usr/local --owner root --group root --no-same-owner && \
    rm spark.tar.gz && \
    # link spark folder to /usr/local/spark
    ln -s /usr/local/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION} /usr/local/spark && \
    # Cleanup
    clean-layer.sh

# Install spark python libraries
RUN \
    # pyspark
    pip install --no-cache-dir \
                        findspark \
                        pyarrow \
                        spark-sklearn \
                        # Improved performance: https://github.com/mozilla/jupyter-spark
                        lxml \
                        # Spylon - Jupyter kernel for scala and spark
                        spylon-kernel && \
    # Deprecated: jupyter-spark: https://github.com/mozilla/jupyter-spark
    # jupyter serverextension enable --py jupyter_spark && \
    # jupyter nbextension install --py jupyter_spark && \
    # jupyter nbextension enable --py jupyter_spark && \
    # python -m spylon_kernel install
    # Install Jupyter kernels
    # Install beakerX? https://github.com/twosigma/beakerx
    # Cleanup
    clean-layer.sh

# Install Sparkmagic: https://github.com/jupyter-incubator/sparkmagic
RUN \
    pip install --no-cache-dir sparkmagic && \
    jupyter serverextension enable --py sparkmagic && \
    # Cleanup
    clean-layer.sh

# Install Apache Torre Kernel: https://github.com/apache/incubator-toree
RUN \ 
    pip install --no-cache-dir toree && \
    jupyter toree install --sys-prefix && \
    # Cleanup
    clean-layer.sh

# Install Spark Monitor: https://github.com/krishnan-r/sparkmonitor
RUN \ 
    # git+https://github.com/krishnan-r/sparkmonitor#subdirectory=extension && \
    pip install --no-cache-dir sparkmonitor && \ 
    jupyter nbextension install sparkmonitor --py --user --symlink && \
    jupyter nbextension enable sparkmonitor --py --user && \    
    jupyter serverextension enable --py --user sparkmonitor && \
    ipython profile create && echo "c.InteractiveShellApp.extensions.append('sparkmonitor.kernelextension')" >>  $(ipython profile locate default)/ipython_kernel_config.py && \
    # Cleanup
    clean-layer.sh

# Install Zeppelin 
RUN \
    /bin/bash $RESOURCES_PATH/tools/zeppelin.sh --install && \
    # Cleanup
    clean-layer.sh

# R Spark support
ENV R_LIBS_USER $SPARK_HOME/R/lib

RUN conda install --quiet --yes 'r-sparklyr' && \
    # Cleanup
    clean-layer.sh

### CONFIGURATION ###

ENV \
    # PYSPARK_DRIVER_PYTHON / PYSPARK_DRIVER_PYTHON_OPTS / HADOOP_HOME / HADOOP_CLASSPATH / SPARK_DIST_CLASSPATH
    # export HADOOP_HOME=~/hadoop-2.7.0 export PATH=$HADOOP_HOME/bin:$PATH export HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
    # export HADOOP_CLASSPATH=$HADOOP_HOME/share/hadoop/tools/lib/*
    # export SPARK_DIST_CLASSPATH=`hadoop classpath` 
    # export PYSPARK_DRIVER_PYTHON="jupyter"
    # export PYSPARK_DRIVER_PYTHON_OPTS="notebook"
    # HADOOP_CONF_DIR=/usr/lib/hadoop
    SPARK_HOME="/usr/local/spark" \
    PYSPARK_PYTHON="python3" \
    SPARK_OPTS="--driver-java-options=-Xms1024M --driver-java-options=-Xmx4096M --driver-java-options=-Dlog4j.logLevel=info" \
    PYTHONPATH=$SPARK_HOME/python:$SPARK_HOME/python/lib/py4j-0.10.7-src.zip:$PYTHONPATH \
    PATH=$SPARK_HOME/bin:$PATH \
    # http://blog.stuart.axelbrooke.com/python-3-on-spark-return-of-the-pythonhashseed
    PYTHONHASHSEED=0

RUN \
    # spark events dir
    mkdir -p /tmp/spark-events

# https://medium.com/@marcovillarreal_40011/creating-a-spark-standalone-cluster-with-docker-and-docker-compose-ba9d743a157f
# ENV SPARK_MASTER_PORT 7077
# ENV SPARK_MASTER_WEBUI_PORT 8080
# ENV SPARK_WORKER_WEBUI_PORT 8081
# ENV SPARK_MASTER_LOG /spark/logs
# ENV SPARK_WORKER_LOG /spark/logs
# CMD ["/bin/bash", "/start-master.sh"]
# export SPARK_MASTER_HOST=`hostname`
# SPARK_WORKER_CORES=1
# SPARK_WORKER_MEMORY=1G
# SPARK_DRIVER_MEMORY=128m
# SPARK_EXECUTOR_MEMORY=256m

# TODO start spark master? 
# TODO configure spark ui to be proxied with base path: 
# https://stackoverflow.com/questions/45971127/wrong-css-location-of-spark-application-ui
# https://github.com/jupyterhub/jupyter-server-proxy/issues/57
# https://github.com/yuvipanda/jupyter-sparkui-proxy/blob/master/jupyter_sparkui_proxy/__init__.py

# Todo: Add additional spark configuration: 
# https://spark.apache.org/docs/latest/configuration.html
# https://zeppelin.apache.org/docs/latest/interpreter/spark.html

# Add default configuration
COPY resources/spark-defaults.conf ${SPARK_HOME}/conf/

# Add supervisor config to start zeppelin on port 8072
COPY resources/zeppelin-service.conf  /etc/supervisor/conf.d/

# Add spark tutorials
COPY resources/tutorials $RESOURCES_PATH/tutorials/tutorials

# Overwrite & add Labels
ARG ARG_BUILD_DATE="unknown"
ARG ARG_VCS_REF="unknown"

LABEL \
    "workspace.version"=$WORKSPACE_VERSION \
    "workspace.flavor"=$WORKSPACE_FLAVOR \
    "workspace.baseimage"=mltooling/ml-workspace:$WORKSPACE_VERSION \
    "org.opencontainers.image.version"=$WORKSPACE_VERSION \
    "org.opencontainers.image.revision"=$ARG_VCS_REF \
    "org.opencontainers.image.created"=$ARG_BUILD_DATE \ 
    "org.label-schema.version"=$WORKSPACE_VERSION \
    "org.label-schema.vcs-ref"=$ARG_VCS_REF \
    "org.label-schema.build-date"=$ARG_BUILD_DATE
