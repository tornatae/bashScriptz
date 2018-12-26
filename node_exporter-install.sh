#!/bin/bash

GIT_URL=https://github.com/prometheus/node_exporter/releases/download/v0.17.0/node_exporter-0.17.0.linux-amd64.tar.gz
TAR=node_exporter-0.17.0.linux-amd64.tar.gz
DIR=node_exporter-0.17.0.linux-amd64

PROM_IP=0.0.0.0

# If available, use LSB to identify distribution
if [ -f /etc/lsb-release -o -d /etc/lsb-release.d ]; then
    export DISTRO=$(lsb_release -i 2>/dev/null | cut -d: -f2 | sed s/'^\t'//)
    export RELEASE=$(lsb_release -a 2>/dev/null | grep Release | cut -d: -f2 | sed s/'^\t'//)
    echo $DISTRO
# Otherwise, use release info file
else
    export DISTRO=$(ls -d /etc/[A-Za-z]*[_-][rv]e[lr]* | grep -v "lsb" | cut -d'/' -f3 | cut -d'-' -f1 | cut -d'_' -f1 | head -1)
    echo $DISTRO
fi

main () {
    if [[ $EUID -ne 0 ]]; then
       echo "This script must be run as root"
       return 1
    fi
    cd  ;
    wget $GIT_URL 
    tar -xvf $TAR
    useradd -s /bin/false/ node_exporter
    chown -R node_exporter: $DIR 

    cp $DIR/node_exporter /usr/bin/node_exporter

    touch /etc/systemd/system/node_exporter.service
    cat > /etc/systemd/system/node_exporter.service<<__FILE__
[Unit]
Description=Node Exporter

[Service]
User=node_exporter
ExecStart=/usr/bin/node_exporter
Restart=on-failure
RestartSec=5

[Install]
WantedBy=default.target
__FILE__

FIREWALLD_RUNNING=$(systemctl list-units --type=service --state=running | grep firewalld)
FIREWALLD_ENABLED=$(systemctl list-units --type=service --state=enabled | grep firewalld)

UFW_RUNNING=$(systemctl list-units --type=service --state=running --no-pager | grep ufw)
UFW_ENABLED=$(systemctl list-units --type=service --state=enabled --no-pager | grep ufw)

IPTABLES_ENABLED=$(systemctl list-unit-files --state=enabled --no-pager | grep netfilter)

if [[ -n "$FIREWALLD_ENABLED" ]]
then
firewall-cmd --permanent --zone=public --add-rich-rule='
  rule family="ipv4"
  source address="$PROM_IP"
  port protocol="tcp" port="9100" accept'

elif [[ -n "$UFW_ENABLED" ]]
then
    ufw allow from $PROM_IP to any port 9100

elif [[ -n "$IPTABLES_ENABLED" ]]
then
    iptables -I INPUT -p tcp -s $PROM_IP --dport 9100 -j ACCEPT
    iptables -A INPUT -p tcp --dport 9100 -j DROP
fi

systemctl enable node_exporter
systemctl start node_exporter

}
main
