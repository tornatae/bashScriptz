#!/bin/bash





for i in {1..99999};
do
#    tempVar=$(dig @ns1.linode.com git.build2.org)
#    tempVar2=$(cat tempVar | grep -F '>>HEADER<<-')
#    tempVar3=$(cat tempVar | grep -F '>>HEADER<<-')
    var1=$(dig @ns1.linode.com git.build2.org | grep -o 'NOERROR')
    var2=$(date)
    var3="$var1 $var2"
#    if [ "%a" -ne "%b" ]; then
        echo $var3 &>>dnsTest.txt
#    else
#        echo $var3 &>>dnsTest.txt
#    fi
    #echo $var3
    #cat dnsTest.txt >&i1
    sleep 10
done
