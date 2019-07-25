#!/bin/sh
if ! hash rstudio 2>/dev/null; then
    echo "Installing RStudio Desktop"
    cd /resources
    wget https://download1.rstudio.org/desktop/xenial/amd64/rstudio-1.2.1335-amd64.deb -O ./rstudio.deb
    dpkg -i ./rstudio.deb
    rm ./rstudio.deb
    # Fix missing dependencies
    apt-get -f install
fi

# Run
echo "Run Rstudio Desktop"
rstudio --no-sandbox
sleep 20