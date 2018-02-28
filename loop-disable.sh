#!/bin/bash

filez=$(ls test.d)
for file in $filez
do
    echo test.d/$file{,.dis}
    mv test.d/$file{,.dis}
    #sleep 5
done

for file in $filez
do
    echo "test.d/$file{.dis,}"
    mv test.d/$file{.dis,}
    #sleep 5
done
