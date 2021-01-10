ARG ARG_WORKSPACE_BASE_IMAGE="mltooling/ml-workspace-r:latest"
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

# Install Hadoop
RUN \
    /bin/bash $RESOURCES_PATH/tools/hadoop-local-cluster.sh --install && \
    # Cleanup
    clean-layer.sh

# Needs to be seperated, otherwise it does not exist yet
ENV HADOOP_HOME="/opt/hadoop"

ENV \
    HADOOP_INSTALL=$HADOOP_HOME \
    HADOOP_MAPRED_HOME=$HADOOP_HOME \
    HADOOP_COMMON_HOME=$HADOOP_HOME \
    HADOOP_HDFS_HOME=$HADOOP_HOME \
    HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop \
    # HADOOP_CLASSPATH=$HADOOP_HOME/share/hadoop/tools/lib/* \
    HADOOP_COMMON_LIB_NATIVE_DIR=$HADOOP_HOME/lib/native \
    HADOOP_OPTS="-Djava.library.path=$HADOOP_COMMON_LIB_NATIVE_DIR" \
    HDFS_NAMENODE_USER=$NB_USER \
    HDFS_DATANODE_USER=$NB_USER \
    HDFS_SECONDARYNAMENODE_USER=$NB_USER \
    YARN_HOME=$HADOOP_HOME \
    YARN_RESOURCEMANAGER_USER=$NB_USER \
    YARN_NODEMANAGER_USER=$NB_USER \
    PATH=$PATH:$HADOOP_HOME/sbin:$HADOOP_HOME/bin

# Install Spark
RUN \
    /bin/bash $RESOURCES_PATH/tools/spark-local-cluster.sh --install && \
    # Cleanup
    clean-layer.sh

# Configure Spark
ENV SPARK_HOME="/opt/spark"

ENV \
    # PYSPARK_DRIVER_PYTHON="jupyter"
    # PYSPARK_DRIVER_PYTHON_OPTS='notebook'
    # https://zeppelin.apache.org/docs/latest/interpreter/spark.html
    # export SPARK_DIST_CLASSPATH=`hadoop classpath`
    PYSPARK_PYTHON=$CONDA_ROOT/bin/python \
    PYSPARK_DRIVER_PYTHON=$CONDA_ROOT/bin/python \
    SPARK_OPTS="--driver-java-options=-Xms1024M --driver-java-options=-Xmx4096M --driver-java-options=-Dlog4j.logLevel=info" \
    # http://blog.stuart.axelbrooke.com/python-3-on-spark-return-of-the-pythonhashseed
    PYTHONHASHSEED=0 \
    PYTHONPATH=$SPARK_HOME/python:$SPARK_HOME/python/lib/py4j-0.10.9-src.zip:$PYTHONPATH \
    PATH=$PATH:$SPARK_HOME/bin

# Install Zeppelin
RUN \
    /bin/bash $RESOURCES_PATH/tools/zeppelin.sh --install && \
    # Cleanup
    clean-layer.sh

RUN \
    # Install almond jupyter scala kernel: https://almond.sh/
    # TODO: The installation in scala-utils does not seem to work currently, cleanup layer the probelm?
    curl -Lo coursier https://git.io/coursier-cli && \
    chmod +x coursier && \
    ./coursier launch --fork almond -- --install --force && \
    rm -f coursier

### CONFIGURATION ###

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
