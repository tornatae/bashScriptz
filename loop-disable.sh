#!/bin/bash

filez=$(ls -d *.dis)
for file in $filez
do
    echo $file{,.dis}
    mv $file{,.dis}
    sleep 5
done

filez=$(ls -d *.dis | sed 's/\.dis//')
for file in $filez
do
    echo "$file{.dis,}"
    mv $file{.dis,}
    sleep 5
done
