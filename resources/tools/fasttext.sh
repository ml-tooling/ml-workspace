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

if ! hash fasttext 2>/dev/null; then
    echo "Installing Fasttext. Please wait..."
    mkdir $RESOURCES_PATH"/fasttext"
    cd $RESOURCES_PATH"/fasttext"
    wget https://github.com/facebookresearch/fastText/archive/v0.9.1.zip
    unzip -q v0.9.1.zip
    rm v0.9.1.zip
    cd fastText-0.9.1
    # Surpress output - if there is a problem remove to see logs > /dev/null
    make > /dev/null
    chmod -R a+rwx $RESOURCES_PATH"/fasttext"
    cp "fasttext" /usr/local/bin
    # cd back otherwise clean layer will fail since it is deleted
    cd $RESOURCES_PATH
    rm -r $RESOURCES_PATH"/fasttext"
    # pip install moved to requirements file
else
    echo "Fasttext is already installed"
fi

# Run
if [ $INSTALL_ONLY = 0 ] ; then
    echo "Use Fasttext via command line:"
    fasttext --help
    sleep 20
fi

