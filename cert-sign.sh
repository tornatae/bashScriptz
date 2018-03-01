#!/bin/bash
main-cert-sign () {
#    if [[ $EUID -ne 0 ]]; then
#       echo "This script must be run as root"
#       return 1
#    fi

    echo "Enter a nick for the client machine >> "
    read nick
    cd /home/admin/pki/logstash-ca.d/
    #Generate a key
    openssl genrsa -out ./clients-d/$nick.key 4096

    #Generate a csr from the key. Specificying
    #openssl req -config san.conf -new -key $nick.key -out $nick.csr -subj "/CN=example.com"
    openssl req -new -key ./clients-d/$nick.key -out ./clients-d/$nick.csr -subj "/CN=example.com"

    openssl x509 -req -in ./clients-d/$nick.csr -CA logstash-CA-root.crt -CAkey logstash-CA.key -CAcreateserial -out ./clients-d/$nick.crt -days 1825 -sha256

    echo "Certs saved in /home/admin/logstash-ca.d/clients-d/"
    cd -
}
main-cert-sign
