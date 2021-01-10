ARG ARG_WORKSPACE_BASE_IMAGE="mltooling/ml-workspace:latest"
# Build from full flavor of workspace with same version
FROM $ARG_WORKSPACE_BASE_IMAGE

ARG ARG_WORKSPACE_FLAVOR="spark"
ENV WORKSPACE_FLAVOR=$ARG_WORKSPACE_FLAVOR
# argument needs to be initalized again
ARG ARG_WORKSPACE_VERSION="latest"
ENV WORKSPACE_VERSION=$ARG_WORKSPACE_VERSION

# Inspirations:
# https://github.com/jupyter/docker-stacks/blob/master/all-spark-notebook/Dockerfile
# https://github.com/jupyter/docker-stacks/blob/master/pyspark-notebook/Dockerfile

# Install Java Utils
RUN \
    /bin/bash $RESOURCES_PATH/tools/java-utils.sh --install && \
    # Cleanup
    clean-layer.sh

# Install Scala Utils
RUN \
    /bin/bash $RESOURCES_PATH/tools/scala-utils.sh --install && \
    # Cleanup
    clean-layer.sh

# Install Spark
RUN \
    /bin/bash $RESOURCES_PATH/tools/spark-local-cluster.sh --install && \
    # Cleanup
    clean-layer.sh

# Configure Spark
ENV SPARK_HOME=/opt/spark \
    PATH=$PATH:$SPARK_HOME/bin

# Install Zeppelin
RUN \
    /bin/bash $RESOURCES_PATH/tools/zeppelin.sh --install && \
    # Cleanup
    clean-layer.sh

### CONFIGURATION ###

ENV \
    PYSPARK_PYTHON="python" \
    PYTHONPATH=$SPARK_HOME/python:$SPARK_HOME/python/lib/py4j-0.10.9-src.zip:$PYTHONPATH \
    SPARK_OPTS="--driver-java-options=-Xms1024M --driver-java-options=-Xmx4096M --driver-java-options=-Dlog4j.logLevel=info" \
    # http://blog.stuart.axelbrooke.com/python-3-on-spark-return-of-the-pythonhashseed
    PYTHONHASHSEED=0

# Todo: Add additional spark configuration:
# https://spark.apache.org/docs/latest/configuration.html
# https://zeppelin.apache.org/docs/latest/interpreter/spark.html

# PYSPARK_DRIVER_PYTHON / PYSPARK_DRIVER_PYTHON_OPTS / HADOOP_HOME / HADOOP_CLASSPATH / SPARK_DIST_CLASSPATH
# export HADOOP_HOME=~/hadoop-2.7.0 export PATH=$HADOOP_HOME/bin:$PATH export HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
# export HADOOP_CLASSPATH=$HADOOP_HOME/share/hadoop/tools/lib/*
# export SPARK_DIST_CLASSPATH=`hadoop classpath`
# export PYSPARK_DRIVER_PYTHON="jupyter"
# export PYSPARK_DRIVER_PYTHON_OPTS="notebook"
# HADOOP_CONF_DIR=/usr/lib/hadoop

# TODO start spark master?
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

# TODO configure spark ui to be proxied with base path:
# https://stackoverflow.com/questions/45971127/wrong-css-location-of-spark-application-ui
# https://github.com/jupyterhub/jupyter-server-proxy/issues/57
# https://github.com/yuvipanda/jupyter-sparkui-proxy/blob/master/jupyter_sparkui_proxy/__init__.py

# Add supervisor config to start zeppelin on port 8072
COPY resources/zeppelin-service.conf  /etc/supervisor/conf.d/

# TODO: current tests are empty:
# COPY resources/tests/ /resources/tests

# Add spark tutorials
COPY resources/tutorials $RESOURCES_PATH/tutorials/tutorials

# Overwrite & add Labels
ARG ARG_BUILD_DATE="unknown"
ARG ARG_VCS_REF="unknown"

LABEL \
    "workspace.version"=$WORKSPACE_VERSION \
    "workspace.flavor"=$WORKSPACE_FLAVOR \
    "workspace.baseimage"=$ARG_WORKSPACE_BASE_IMAGE \
    "org.opencontainers.image.version"=$WORKSPACE_VERSION \
    "org.opencontainers.image.revision"=$ARG_VCS_REF \
    "org.opencontainers.image.created"=$ARG_BUILD_DATE \
    "org.label-schema.version"=$WORKSPACE_VERSION \
    "org.label-schema.vcs-ref"=$ARG_VCS_REF \
    "org.label-schema.build-date"=$ARG_BUILD_DATE
