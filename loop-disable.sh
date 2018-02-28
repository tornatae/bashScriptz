#!/bin/bash

filez=$(ls -d */ | grep -v ".dis" | sed 's/\///')
for file in $filez
do
    echo "mv" $file{,.dis}
    mv $file{,.dis}
#    sleep 5
done

filez=$(ls -d */ | grep ".dis" | sed 's/\.dis//' | sed 's/\///')
for file in $filez
do
    echo "$file{.dis,}"
    mv $file{.dis,}
#    sleep 5
done
