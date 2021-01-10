#!/bin/bash

# Stops script execution if a command has an error
set -e

INSTALL_ONLY=0
# Loop through arguments and process them: https://pretzelhands.com/posts/command-line-flags
for arg in "$@"; do
    case $arg in
        -i|--install) INSTALL_ONLY=1 ; shift ;;
        *) break ;;
    esac
done

# Script inspired by: https://tecadmin.net/setup-hadoop-on-ubuntu/

export HADOOP_HOME=/opt/hadoop
export HADOOP_INSTALL=$HADOOP_HOME
export HADOOP_MAPRED_HOME=$HADOOP_HOME
export HADOOP_COMMON_HOME=$HADOOP_HOME
export HADOOP_HDFS_HOME=$HADOOP_HOME
export YARN_HOME=$HADOOP_HOME
export HADOOP_COMMON_LIB_NATIVE_DIR=$HADOOP_HOME/lib/native
export HADOOP_OPTS="-Djava.library.path=$HADOOP_COMMON_LIB_NATIVE_DIR"
export PATH=$PATH:$HADOOP_HOME/sbin:$HADOOP_HOME/bin

export HDFS_NAMENODE_USER=$NB_USER
export HDFS_DATANODE_USER=$NB_USER
export HDFS_SECONDARYNAMENODE_USER=$NB_USER
export YARN_RESOURCEMANAGER_USER=$NB_USER
export YARN_NODEMANAGER_USER=$NB_USER

if [ ! -d "$HADOOP_HOME" ]; then
    echo "Installing Hadoop. Please wait..."
    cd $RESOURCES_PATH
    HADOOP_VERSION=3.3.0
    echo "Downloading..."
    wget -q https://apache.mirror.digionline.de/hadoop/common/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz -O ./hadoop.tar.gz
    tar xzf hadoop.tar.gz
    mv hadoop-$HADOOP_VERSION $HADOOP_HOME
    rm hadoop.tar.gz
    # Set Configuration
    printf "<configuration>\n<property>\n<name>fs.default.name</name>\n<value>hdfs://localhost:9000</value>\n</property>\n</configuration>" > $HADOOP_HOME/etc/hadoop/core-site.xml
    printf "<configuration>\n<property>\n<name>dfs.replication</name>\n<value>1</value>\n</property>\n<property>\n<name>dfs.name.dir</name>\n<value>file:///$HOME/hadoopdata/hdfs/namenode</value>\n</property>\n<property>\n<name>dfs.data.dir</name>\n<value>file://$HOME/hadoopdata/hdfs/datanode</value>\n</property>\n</configuration>\n" > $HADOOP_HOME/etc/hadoop/hdfs-site.xml
    printf "<configuration>\n<property>\n<name>mapreduce.framework.name</name>\n<value>yarn</value>\n</property>\n</configuration>" > $HADOOP_HOME/etc/hadoop/mapred-site.xml
    printf "<configuration>\n<property>\n<name>yarn.nodemanager.aux-services</name>\n<value>mapreduce_shuffle</value>\n</property>\n</configuration>" > $HADOOP_HOME/etc/hadoop/yarn-site.xml
    echo "export JAVA_HOME=$JAVA_HOME" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh
else
    echo "Hadoop is already installed"
fi

# Run
if [ $INSTALL_ONLY = 0 ] ; then
    echo "Start local Hadoop cluster..."
    hdfs namenode -format
    chsh -s /bin/bash
    $HADOOP_HOME/sbin/start-dfs.sh
    $HADOOP_HOME/sbin/start-yarn.sh
    echo "Hadoop cluster is started. To access the dashboards, please use the WebBrowser within VNC:"
    echo "NameNode: http://localhost:9870"
    echo "DataNode: http://localhost:9864"
    echo "Yarn NodeManager: http://localhost:8042"
    sleep 20
fi

