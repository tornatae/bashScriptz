#!/bin/bash

main () {
    if [[ $EUID -ne 0 ]]; then
       echo "This script must be run as root"
       return 1
    fi
    cd  ;
    wget https://github.com/prometheus/node_exporter/releases/download/v0.15.1/node_exporter-0.15.1.linux-amd64.tar.gz
    tar -xvf node_exporter-0.15.1.linux-amd64.tar.gz
    mv node_exporter-0.15.1.linux-amd64 node_exporter
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

    firewall-cmd --zone=public --add-port=9104/tcp --permanent
    systemctl enable node_exporter
    systemctl start node_exporter

}
main
