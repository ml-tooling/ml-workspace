#! /usr/bin/env bash
# since vncserver is running as a daemon, we're creating a foreground process uppon vncserver for supervisord.

# Reason: vnc server fails to start via supervisor process:
# spawnerr: unknown error making dispatchers for 'vncserver': ENOENT
# alternative: /usr/bin/Xvnc $DISPLAY -depth $VNC_COL_DEPTH -geometry $VNC_RESOLUTION -Log *:stderr:100
# e.g.: /usr/bin/Xvnc :1 -auth $HOME/.Xauthority -depth 24 -desktop VNC -fp /usr/share/fonts/X11/misc,/usr/share/fonts/X11/Type1 -geometry 1600x900 -pn -rfbauth $HOME/.vnc/passwd -rfbport 5901 -rfbwait 30000
# $HOME/.vnc/xstartup
# vncserver uses Xvnc, all Xvnc options can be used (e.g. for logging)
# https://wiki.archlinux.org/index.php/TigerVNC

set -eu

mkdir -p $HOME/.vnc
touch $HOME/.vnc/passwd

# Set password:
echo "$VNC_PW" | vncpasswd -f >> $HOME/.vnc/passwd
chmod 600 $HOME/.vnc/passwd

# Setting pidfile + command to execute
pidfile="$HOME/.vnc/*:1.pid"
command="/usr/bin/vncserver $DISPLAY -geometry $VNC_RESOLUTION -depth $VNC_COL_DEPTH -name Desktop-GUI -autokill"

# Proxy signals
function kill_app(){
    # correct forwarding of shutdown signal
    kill -s SIGTERM $!
    trap - SIGTERM && kill -- -$$
    kill $(cat $pidfile)
    exit 0 # exit okay
}
trap "kill_app" SIGINT SIGTERM EXIT

#cleanup tmp from previous run 
# run vncserver kill in background
vncserver -kill $DISPLAY &
rm -rfv /tmp/.X*-lock /tmp/.x*-lock /tmp/.X11-unix
# Delete existing logs
find $HOME/.vnc/ -name '*.log' -delete
# rm -rf /tmp/.X* /tmp/.x* /tmp/ssh*

# Launch daemon

sleep 1
$command
sleep 4

tail -f -q --pid $(cat $pidfile) $HOME/.vnc/*.log &

# Disable screensaver and power management - needs to run after the vnc server is started
xset -dpms && xset s noblank && xset s off

# Loop while the pidfile and the process exist
echo "Starting monitoring pid file for vnc server"
while [ -f $pidfile ] && kill -0 $(cat $pidfile) ; do
    sleep 1
done


exit 1000 # exit unexpected