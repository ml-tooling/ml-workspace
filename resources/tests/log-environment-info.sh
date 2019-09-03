#!/bin/sh

INSTALL_ONLY=0
# Loop through arguments and process them: https://pretzelhands.com/posts/command-line-flags
for arg in "$@"; do
    case $arg in
        -i|--install) INSTALL_ONLY=1 ; shift ;;
        *) break ;;
    esac
done

echo "Installing pipdeptree and pip-licenses"
# https://pypi.org/project/pip-licenses/
pip install pipdeptree pip-licenses
if [ ! -f "$RESOURCES_PATH/dpkg-licenses/dpkg-licenses"  ]; then
    cd $RESOURCES_PATH
    git clone https://github.com/daald/dpkg-licenses.git
fi

# Other pip/requirements tools: https://github.com/jazzband/pip-tools https://github.com/Yelp/requirements-tools

# Run
if [ $INSTALL_ONLY = 0 ] ; then
    mkdir -p $WORKSPACE_HOME/reports/
    echo "Starting environment variables scan"
    printenv > $WORKSPACE_HOME/reports/environment-variables.txt
    echo "Starting largest file scan"
    find / -type f -printf "%k\t %p\n" 2>/dev/null | sort -rn | awk '{printf("%7.1f MB\t%s\n", ($1/1024),$0)}' | head -100 > $WORKSPACE_HOME/reports/largest-files.txt
    echo "Starting root folders scan"
    du -sh /* | sort -rh > $WORKSPACE_HOME/reports/largest-root-folders.txt
    echo "Starting largest files and folders scan"
    du -a / | sort -n -r | head -n 200 > $WORKSPACE_HOME/reports/largest-files-and-folders.txt
    # Python environment
    echo "Starting pipdeptree scan"
    pipdeptree > $WORKSPACE_HOME/reports/python-package-tree.txt 2> $WORKSPACE_HOME/reports/python-package-conflicts.txt
    echo "Starting license scan via pip-licenses"
    pip-licenses --from=mixed --with-authors --with-urls --with-description --with-license-file --format=json > $WORKSPACE_HOME/reports/python-package-licenses.json
    pip-licenses --from=mixed --order=license --with-urls --format=markdown > $WORKSPACE_HOME/reports/python-package-licenses-overview.md
    echo "Starting scan for largest pip-packages"
    pip list | sed '/Package/d' | sed '/----/d' | sed -r 's/\S+//2' | xargs pip show | grep -E 'Location:|Name:' | cut -d ' ' -f 2 | paste -d ' ' - - | awk '{print $2 "/" $(find $2 -maxdepth 1 -iname $1)}' | xargs du -sh  | sort -rh  > $WORKSPACE_HOME/reports/python-package-sizes.txt 
    # Ubuntu environment
    echo "Starting scan for dpkg-packages licenses"
    $RESOURCES_PATH/dpkg-licenses/dpkg-licenses > $WORKSPACE_HOME/reports/dpkg-package-licenses.txt
    echo "Starting scan for largest dpkg-packages"
    dpkg-query -Wf '${Installed-Size}\t${Package}\n' | sort -rn > $WORKSPACE_HOME/reports/dpkg-package-sizes.txt
    sleep 20
fi