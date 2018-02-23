#!/bin/bash
cd
yum install epel-release -y; yum install wget -y
wget --no-check-certificate https://fah.stanford.edu/file-releases/public/release/fahclient/centos-5.3-64bit/v7.4/fahclient-7.4.4-1.x86_64.rpm
su -c 'rpm -i --nodeps fahclient-7.4.4-1.x86_64.rpm'
/etc/init.d/FAHClient stop
sleep 2
systemctl start FAHClient
systemctl stop FAHClient
sleep 2
cat > /etc/fahclient/config.xml << EOL
<config>
  <!-- Configuration file created by FAHClient on 2018-02-12T16:38:39Z -->
  <user value='roland'/>
  <team value='229129'/>
  <power value="light"/>
  <cpus v='2'/>
  <cpu-usage v='50'/>

  <passkey value='FA9BmWZGt23xke7eQ8noRksRJ3woWdnd'/>
  <smp value='true'/>
  <gpu value='false'/>
  <slot id='0' type='CPU'/>
</config>
EOL
systemctl enable FAHClient
systemctl start FAHClient
