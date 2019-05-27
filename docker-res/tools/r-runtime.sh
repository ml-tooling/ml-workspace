#!/bin/sh
echo "Installing R Runtime"
# See https://github.com/jupyter/docker-stacks/blob/master/r-notebook/Dockerfile
apt-get update
# R pre-requisites
apt-get install -y --no-install-recommends fonts-dejavu unixodbc unixodbc-dev r-cran-rodbc gfortran
# R basics and essentials: https://docs.anaconda.com/anaconda/packages/r-language-pkg-docs/
conda install --yes r-base r-irkernel r-reticulate r-essentials rpy2