#!/bin/bash

COUNTER=0
while :
do
  let COUNTER=COUNTER+1
  BEGINDATE=$(date +"%m-%d-%y-%H:%m:%S")
  tcpdump -i br0 -G 300 -W 1 -w /tcp-capture/$BEGINDATE.pcap
done

