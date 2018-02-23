#!/bin/bash

for host in {db1,db2,db3,repl}.orgname; do
    echo $host
    ssh $host "cat /etc/firewalld/zones/*.xml; cat /etc/firewalld/services/*.xml"
done
