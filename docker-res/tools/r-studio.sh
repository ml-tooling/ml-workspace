#!/bin/sh
if ! hash rstudio 2>/dev/null; then
    echo "Installing RStudio Desktop"
    cd /resources
    wget https://download1.rstudio.org/desktop/xenial/amd64/rstudio-1.2.1335-amd64.deb -O ./rstudio.deb
    dpkg -i ./rstudio.deb
    rm ./rstudio.deb
fi

# Run
rstudio --no-sandbox