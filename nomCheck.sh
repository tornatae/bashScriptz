#!/usr/bin/env bash

SITES=(insert.domains or.ips here.com)
for i in "${SITES[@]}"

#Still a work in progress to grab an HTTP error! Should be easy but I'm lazy

do
    ip=$(dig +short $i | awk '{ print ; exit }');
    nc -dzv $ip 80 1&> text.txt; printf '\e[0;32m %s \e[0m' $i; cat text.txt | sed '$!d';
    curl hbl.fi > temp.txt  2>&1;
     #in the above command we have the structure "command > temp.txt > 2>&1.
     #This has the benefit of hiding curls stupid annoying meter bar by redirecting stdout
    ISITAREDIRECT=$(grep "<title>301" temp.txt)
    isitadatabaseerror=$(egrep -iw 'database.*error|error.*database' temp.txt);
#if var is empty or doesn't exist, then.
echo "$ISITAREDIRECT"
    if [ -z $isitaredirect ]; then
        printf '\e[0;33 %s \e[0m 1st if' #then we got a 301
        #if not, check for a database error
    elif [ -z $isitadatabaseerror ]; then
        printf '\e[0;33 %s \e[0m 2nd if'
    fi
done
