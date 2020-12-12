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

if ! hash trivy 2>/dev/null; then
    # https://github.com/aquasecurity/trivy
    echo "Installing trivy vulnerabiliy scanner..."
    curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/master/contrib/install.sh | sh -s -- -b /usr/local/bin
else
    echo "Trivy is already installed"
fi

# Run
if [ $INSTALL_ONLY = 0 ] ; then
    echo "Running trivy scan. This can take several minutes..."
    mkdir -p  $WORKSPACE_HOME/reports
    trivy fs --timeout=20m0s --vuln-type=os -f json -o $WORKSPACE_HOME/reports/trivy-vulnerability-scan.txt /
    # Show high and critical vulnerabilities in stdout
    trivy fs --timeout=20m0s --severity HIGH,CRITICAL /
    sleep 30
fi
