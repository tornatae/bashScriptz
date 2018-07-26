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
    wget https://github.com/prometheus/mysqld_exporter/releases/download/v0.11.0/mysqld_exporter-0.11.0.linux-amd64.tar.gz
    tar -xvf mysqld_exporter-0.11.0.linux-amd64.tar.gz 
    mv mysqld_exporter-0.11.0.linux-amd64 mysqld_exporter
    useradd -s /bin/false/ prom_exporter
    chown -R prom_exporter: mysqld_exporter

    cp mysqld_exporter/mysqld_exporter /usr/bin/mysqld_exporter

    touch /etc/systemd/system/mysqld_exporter.service
    cat > /etc/systemd/system/mysqld_exporter.service<<__FILE__
[Unit]
Description=Mysqld Exporter
Wants=network-online.target
After=network-online.target
 
[Service]
User=prom_exporter
type=simple
ExecStart=/usr/bin/mysqld_exporter --config.my-cnf "/etc/mysqld_exporter/.my.cnf"
Restart=on-failure
RestartSec=5
 
[Install]
WantedBy=multi-user.target
__FILE__

mkdir /etc/mysqld_exporter
touch /etc/mysqld_exporter/.my.cnf
cat > /etc/mysqld_exporter/.my.cnf<<__FILE__
[client]
user=exporter
password=apassword
__FILE__
chown prom_exporter /etc/mysqld_exporter/.my.cnf
chmod og-r /etc/mysqld_exporter/.my.cnf

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


systemctl enable mysqld_exporter
systemctl start mysqld_exporter

}
main

