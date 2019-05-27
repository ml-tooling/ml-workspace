#!/bin/sh
echo Installing and starting netdata on port $1

if [ ! -f /usr/sbin/netdata  ]; then
    apt-get update -y
    apt-get install lm-sensors -y
    apt-get install netcat -y
    apt-get install iproute -y

    yes | bash -c "$(curl -Ss https://my-netdata.io/kickstart.sh)"
fi

killall netdata
# remove tab characters in netdata config, otherwise it cannot be read as a config file
sed -i -e 's/[ \t]*//' /etc/netdata/netdata.conf
port=$1;
# replace values in netdata config:
# - set port to passed port
# - set 'registry = enabled' and 'registry to announce = http://localhost:$port' to don't contact external netdata registry
echo "import ConfigParser; Config = ConfigParser.RawConfigParser(); Config.read('/etc/netdata/netdata.conf'); Config.set('registry', 'enabled', 'yes'); Config.set('registry', 'registry to announce', 'http://localhost:$port'); Config.set('web', 'default port', '$port'); Config.write(open('/etc/netdata/netdata.conf', 'w'))" | python2
/usr/sbin/netdata
sleep 5
