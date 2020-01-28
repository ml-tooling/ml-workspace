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

if ! hash rstudio 2>/dev/null; then
    echo "Installing RStudio Desktop. Please wait..."
    cd $RESOURCES_PATH
    apt-get update
    #apt-get install --yes r-base
    wget https://download1.rstudio.org/desktop/xenial/amd64/rstudio-1.2.5033-amd64.deb -O ./rstudio.deb
    # ld library path makes problems
    LD_LIBRARY_PATH="" gdebi --non-interactive ./rstudio.deb
    rm ./rstudio.deb
else
    echo "RStudio is already installed"
fi

# Fix tmp permission - are changed by rstudio start -> problem
nohup sleep 4 && chown root:root /tmp && chmod a+rwx /tmp &

# Run
if [ $INSTALL_ONLY = 0 ] ; then
    echo "Run Rstudio Desktop"
    LD_LIBRARY_PATH="" rstudio --no-sandbox 
    sleep 10
fi

# Fix tmp permission 
sleep 5
chown root:root /tmp
chmod a+rwx /tmp
