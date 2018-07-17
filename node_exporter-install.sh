#!/bin/bash

#!/bin/bash
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
    #wget https://github.com/prometheus/node_exporter/releases/download/v0.15.1/node_exporter-0.15.1.linux-amd64.tar.gz
    wget https://github.com/prometheus/node_exporter/releases/download/v0.16.0/node_exporter-0.16.0.linux-amd64.tar.gz
    #tar -xvf node_exporter-0.15.1.linux-amd64.tar.gz
    tar -xvf node_exporter-0.16.0.linux-amd64.tar.gz
    #mv node_exporter-0.15.1.linux-amd64 node_exporter
    mv node_exporter-0.16.0.linux-amd64.tar.gz node_exporter
    useradd -s /bin/false/ node_exporter
    chown -R node_exporter: node_exporter/

    cp node_exporter/node_exporter /usr/bin/node_exporter

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

firewalld_running=$(systemctl list-units --type=service --state=running | grep firewalld)
ufw_running=$(systemctl list-units --type=service --state=active --no-pager | grep ufw)

if [[ "$DISTRO" == 'centos' && -n "$firewalld_running" ]]
then
firewall-cmd --permanent --zone=public --add-rich-rule='
  rule family="ipv4"
  source address="97.107.134.73/32"
  port protocol="tcp" port="9104" accept'
firewall-cmd --permanent --zone=public --add-rich-rule='
  rule family="ipv4"
  source address="97.107.134.73/32"
  port protocol="tcp" port="9100" accept'
fi

if [[ "$DISTRO" == "Ubuntu" && -n "$ufw_running" ]]
then
    ufw allow from 97.107.134.73/32 to any port 9100
    ufw allow from 97.107.134.73/32 to any port 9104
fi


systemctl enable node_exporter
systemctl start node_exporter

}
main
