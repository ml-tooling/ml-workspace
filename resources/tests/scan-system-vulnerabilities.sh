#!/bin/sh

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

if ! hash vuls 2>/dev/null; then
    # https://github.com/future-architect/vuls
    # Installed using this: https://vuls.io/docs/en/install-manually-centos.html
    # https://linoxide.com/linux-how-to/setup-vulnerable-scan-vuls-linux/
    # -> used: https://vuls.io/docs/en/install-manually-centos.html
    echo "Installing Vuls - VULnerability Scanner"
    mkdir -p $RESOURCES_PATH/vuls
    cd $RESOURCES_PATH/vuls
    apt-get update
    apt-get install -y sqlite3 libsqlite3-dev debian-goodies
    wget https://dl.google.com/go/go1.12.9.linux-amd64.tar.gz
    sudo tar -C /usr/local -xzf go1.12.9.linux-amd64.tar.gz
    mkdir -p $HOME/go
    export GOROOT=/usr/local/go
    export GOPATH=$HOME/go
    export PATH=$PATH:$GOROOT/bin:$GOPATH/bin
    mkdir -p /var/log/vuls
    chmod 700 /var/log/vuls
    echo "Installing go-cve-dictionary"
    mkdir -p $GOPATH/src/github.com/kotakanbe
    cd $GOPATH/src/github.com/kotakanbe
    git clone https://github.com/kotakanbe/go-cve-dictionary.git
    cd go-cve-dictionary
    make install
    cd $HOME
    for i in `seq 2002 $(date +"%Y")`; do go-cve-dictionary fetchnvd -years $i; done
    echo "Installing goval-dictionary"
    mkdir -p $GOPATH/src/github.com/kotakanbe
    cd $GOPATH/src/github.com/kotakanbe
    git clone https://github.com/kotakanbe/goval-dictionary.git
    cd goval-dictionary
    make install
    ln -s $GOPATH/src/github.com/kotakanbe/goval-dictionary/oval.sqlite3 $HOME/oval.sqlite3
    goval-dictionary fetch-ubuntu 16
    echo "Installing gost"
    sudo mkdir /var/log/gost
    sudo chmod 700 /var/log/gost
    mkdir -p $GOPATH/src/github.com/knqyf263
    cd $GOPATH/src/github.com/knqyf263
    git clone https://github.com/knqyf263/gost.git
    cd gost
    make install
    ln -s $GOPATH/src/github.com/knqyf263/gost/gost.sqlite3 $HOME/gost.sqlite3
    gost fetch debian
    echo "Installing go-exploitdb"
    sudo mkdir /var/log/go-exploitdb
    sudo chmod 700 /var/log/go-exploitdb
    mkdir -p $GOPATH/src/github.com/mozqnet
    cd $GOPATH/src/github.com/mozqnet
    git clone https://github.com/vulsio/go-exploitdb.git
    cd go-exploitdb
    make install
    ln -s $GOPATH/src/github.com/mozqnet/go-exploitdb/go-exploitdb.sqlite3 $HOME/go-exploitdb.sqlite3
    go-exploitdb fetch exploitdb
    echo "Installing vuls"
    mkdir -p $GOPATH/src/github.com/future-architect
    cd $GOPATH/src/github.com/future-architect
    git clone https://github.com/future-architect/vuls.git
    cd vuls
    make install
    # Configure to run locally
    printf "[servers]\n\n[servers.localhost]\nhost=\"localhost\"\nport=\"local\"\nscanMode=[\"fast-root\"]\n" > $HOME/config.toml
else
    echo "Vuls is already installed" 
fi

# Run
if [ $INSTALL_ONLY = 0 ] ; then
    echo "Starting local vuls scan"
    cd $HOME
    vuls scan
    mkdir -p $WORKSPACE_HOME/reports/
    vuls report -format-full-text > $WORKSPACE_HOME/reports/vuls-vulnerability-scan.txt
    vuls tui
    sleep 50
fi