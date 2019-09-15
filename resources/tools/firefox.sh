#!/usr/bin/env bash

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


function disableUpdate() {
    ff_def="$1/browser/defaults/profile"
    mkdir -p $ff_def
    printf '
user_pref("app.update.auto", false);
user_pref("app.update.enabled", false);
user_pref("app.update.checkInstallTime", false);
user_pref("app.update.silent", false);
user_pref("app.update.staging.enabled", false);
user_pref("app.update.badge", false);
user_pref("browser.shell.checkDefaultBrowser", false);
user_pref("app.update.lastUpdateTime.addon-background-update-timer", 1182011519);
user_pref("app.update.lastUpdateTime.background-update-timer", 1182011519);
user_pref("app.update.lastUpdateTime.blocklist-background-update-timer", 1182010203);
user_pref("app.update.lastUpdateTime.microsummary-generator-update-timer", 1222586145);
user_pref("app.update.lastUpdateTime.search-engine-update-timer", 1182010203);' > $ff_def/user.js
}

function instFF() {
    if [ ! "${1:0:1}" == "" ]; then
        FF_VERS=$1
        if [ ! "${2:0:1}" == "" ]; then
            FF_INST=$2
            echo "download Firefox $FF_VERS and install it to '$FF_INST'."
            mkdir -p "$FF_INST"
            FF_URL=http://releases.mozilla.org/pub/firefox/releases/$FF_VERS/linux-x86_64/en-US/firefox-$FF_VERS.tar.bz2
            echo "FF_URL: $FF_URL"
            wget -qO- $FF_URL | tar xvj --strip 1 -C $FF_INST/
            ln -s "$FF_INST/firefox" /usr/bin/firefox
            # Create desktop icon
            printf "[Desktop Entry]\nVersion=1.0\nEncoding=UTF-8\nName=Firefox Web Browser\nComment=Webbrowser\nExec=firefox\nTerminal=false\nX-MultipleArgs=false\nType=Application\nIcon=/usr/lib/firefox/browser/icons/mozicon128.png\nCategories=GNOME;GTK;Network;WebBrowser;\nStartupNotify=true;" > /usr/share/applications/firefox.desktop
            # MimeType=text/html;text/xml;application/xhtml+xml;x-scheme-handler/http;x-scheme-handler/https;x-scheme-handler/ftp;x-scheme-handler/chrome;video/webm;application/x-xpinstall;
            disableUpdate $FF_INST
            exit $?
        fi
    fi
    echo "function parameter are not set correctly please call it like 'instFF [version] [install path]'"
    exit -1
}

if ! hash firefox 2>/dev/null; then
    echo "Installing Firefox. Please wait..."
    instFF '45.9.0esr' '/usr/lib/firefox'
else
    echo "Firefox is already installed"
fi

# Run
if [ $INSTALL_ONLY = 0 ] ; then
    echo "Starting Firefox"
    firefox
    sleep 10
fi

