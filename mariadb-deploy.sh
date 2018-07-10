#!/bin/bash
touch /etc/yum.repos.d/MariaDB.repo

if [ ! -s /etc/yum.repos.d/MariaDB.repo ]
then
cat >> /etc/yum.repos.d/MariaDB.repo <<__FILE__
# MariaDB 10.3 CentOS repository list - created 2018-07-10 19:39 UTC
# http://downloads.mariadb.org/mariadb/repositories/
[mariadb]
name = MariaDB
baseurl = http://yum.mariadb.org/10.3/centos7-amd64
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck=1
__FILE__
fi

yum install epel-release -y
yum install MariaDB-server MariaDB-client ntp -y
systemctl enable ntpd
systemctl start ntpd

sed '$d' /etc/security/limits.conf > /etc/security/limits.conf
echo -e "*                -       nofile          16384" >> /etc/security.limits.conf
echo -e "# End of file" >> /etc/security/limits.conf

echo -e "vm.swappiness = 1" >> /etc/sysctl.conf

sed -i "/sda/ s/defaults/defaults,noatime/" /etc/fstab

cat >> /etc/systemd/journald.conf <<__FILE__
Storage=persistent
SystemMaxUse=500M
__FILE__
systemd-tmpfiles --create --prefix /var/log/journal/
systemctl restart systemd-journald;

if [ ! -s /etc/profile.d/color-prompt.sh ]
then
cat >> /etc/profile.d/color-prompt.sh <<__FILE__
# vim:ts=4:sw=4
if [[ $EUID -ne 0 ]]; then
    PS1='[\[\033[36m\]\u\[\033[m\]@\[\033[01;32m\]\H\[\033[00m\] \W]\$ '
else
    PS1='[\[\033[91m\]\u\[\033[m\]@\[\033[01;32m\]\H\[\033[00m\] \W]\$ '
fi
__FILE__
fi

cat >> /etc/profile.d/instant-history.sh <<__FILE__
shopt -s histappend
export PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"
__FILE__

if [ ! -s /etc/firewalld/zones/private.xml ]
then
cat >> /etc/firewalld/zones/private.xml <<__FILE__
<?xml version="1.0" encoding="utf-8"?>
<zone>
  <short>Private</short>
  <description>Rules for the private network</description>
  <service name="ssh"/>
  <service name="mysql"/>
</zone>
__FILE__
fi

systemctl enable firewalld
systemctl start firewalld
