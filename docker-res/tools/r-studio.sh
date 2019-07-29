#!/bin/sh

INSTALL_ONLY=0
# Loop through arguments and process them: https://pretzelhands.com/posts/command-line-flags
for arg in "$@"; do
    case $arg in
        -i|--install) INSTALL_ONLY=1 ; shift ;;
        *) break ;;
    esac
done

if ! hash rstudio 2>/dev/null; then
    echo "Installing RStudio Desktop"
    cd $RESOURCES_PATH
    wget https://download1.rstudio.org/desktop/xenial/amd64/rstudio-1.2.1335-amd64.deb -O ./rstudio.deb
    dpkg -i ./rstudio.deb
    rm ./rstudio.deb
    # Fix missing dependencies
    apt-get -f install
else
    echo "RStudio is already installed"
fi

# Run
if [ $INSTALL_ONLY = 0 ] ; then
    echo "Run Rstudio Desktop"
    rstudio --no-sandbox
    sleep 20
fi