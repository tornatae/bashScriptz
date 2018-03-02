#!/bin/bash
function main () {
#If the amount of args is less than 1..
if [ "$#" -lt 1  ]; then
        >&2 echo "usage: iptables-add.sh ip .. ip"
        echo "$#"
        return 1
fi

#Loop through provided arguments
for var in "$@"
do
        if valid_ip $var; then
                echo "    iptables -I INPUT -s $var/32 -p tcp -j DROP"
                echo "    iptables -I OUTPUT -d $var/32 -p tcp -j DROP"
                #iptables -I INPUT -s $1/32 -p tcp -j DROP
                #iptables -I OUTPUT -d $1/32 -p tcp -j DROP

                echo "    iptables -I INPUT -s $var/32 -p udp -j DROP"
                echo "    iptables -I OUTPUT -d $var/32 -p udp -j DROP"
                #iptables -I INPUT -s $1/32 -p udp -j DROP
                #iptables -I OUTPUT -d $1/32 -p udp -j DROP
        else
                echo "Invalid IP $var!"
        fi
done
}


function valid_ip()
{
    local  ip=$1
    local  stat=1

    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        OIFS=$IFS
        IFS='.'
        ip=($ip)
        IFS=$OIFS
        [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 \
            && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
        stat=$?
    fi
    return $stat
}

# Pass all cmdline args to main function
main "$@"
