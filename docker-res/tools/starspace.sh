#!/bin/sh
if ! hash starspace 2>/dev/null; then
    cd /resources
    echo "Installing Boost"
    mkdir "/resources/boost" 
    cd "/resources/boost"
    wget https://dl.bintray.com/boostorg/release/1.63.0/source/boost_1_63_0.zip
    unzip -q boost_1_63_0.zip 
    rm boost_1_63_0.zip
    mv boost_1_63_0 /usr/local/bin
    cd /usr/local/bin/boost_1_63_0
    echo "Installing Starspace"
    mkdir "/resources/starspace"
    cd "/resources/starspace"
    git clone https://github.com/facebookresearch/Starspace.git
    cd Starspace
    make
    chmod -R a+rwx "/resources/starspace"
    cp "starspace" /usr/local/bin
fi

# Run
echo "Starting Starspace"
starspace --help