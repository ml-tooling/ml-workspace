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

if ! hash kubectl 2>/dev/null; then
    echo "Installing Kubernetes Client (kubectl). Please wait..."
    mkdir -p $RESOURCES_PATH"/kubernetes"
    cd $RESOURCES_PATH"/kubernetes"
    curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
    mv ./kubectl /usr/local/bin
    chmod a+rwx /usr/local/bin/kubectl
    # kube-prompt
    wget https://github.com/c-bata/kube-prompt/releases/download/v1.0.10/kube-prompt_v1.0.10_linux_amd64.zip
    unzip kube-prompt_v1.0.10_linux_amd64.zip
    chmod +x kube-prompt
    mv ./kube-prompt /usr/local/bin/kube-prompt
    # Install python kubernetes client
    pip install --no-cache-dir kubernetes
    # Install helm 
    curl -L https://git.io/get_helm.sh | bash
    # Remove temp dir
    cd $RESOURCES_PATH
    rm -rf ./kubernetes
else
    echo " Kubernetes Client is already installed"
fi

# Install vscode docker extension 
if hash code 2>/dev/null; then
    # https://marketplace.visualstudio.com/items?itemName=ms-kubernetes-tools.vscode-kubernetes-tools
    LD_LIBRARY_PATH="" LD_PRELOAD="" code --user-data-dir=$HOME/.config/Code/ --extensions-dir=$HOME/.vscode/extensions/ --install-extension ms-kubernetes-tools.vscode-kubernetes-tools
else
    echo "Please install the desktop version of vscode via the vs-code-desktop.sh script to install kubernetes vscode extensions."
fi

# Run
if [ $INSTALL_ONLY = 0 ] ; then
    echo "Use Kubernetes Client via command line:"
    kubectl --help
    sleep 20
fi