#!/bin/nope
#not meant to be run
# references
# http://www.compciv.org/topics/bash/conditional-branching/
# https://ryanstutorials.net/bash-scripting-tutorial/bash-if-statements.php
# http://mywiki.wooledge.org/
# http://mywiki.wooledge.org/BashPitfalls
# http://mywiki.wooledge.org/BashFAQ/031


if [ $# -gt 2 ]
then
    echo "supplied args greater than 2"
else
    echo "supplied args less than 2"
fi

# comments around the variable prevent a failure from an undefined var
# Double-brackets [[ ]] are used to enclose the conditional expression
# Basically a better version of the "old" test, [ ]

if [[ "$var" == 'something' ]]; then
    echo "thing"
elif [[ "$othervar" -eq 0 ]]; then
    echo "otherthing"
elif [[ "$var" != 'other thing' ]]; then
fi

if [[ $a -gt 42 && $a -lt 100 ]]; then
  echo "The value $a is greater than 42 but less than 100"
else
    echo "The value $a is not between 42 and 100"
fi

#  -z means empty (0 characters), -e is "entry file or dir exists".
if [ ! -z "$var" ] && [ -e "$var" ]; then


#-a filename - true if filename exists
#-f filename - true if filename exists and is a regular file
#-d filename - true if filename exists and is a directory
#-s filename - true if filename exists and has a size > 0
#-z $some_string - true if $some_string has 0 characters (i.e. is empty)
#-n $some_string - true if $some_string has more than 0 characters
#$string_a == $string_b - true if $string_a is equal to $string_b
#$string_a != $string_b - true if $string_a is not equal to $string_b
#$x -eq $y - true if integer $x is equal to integer $y
#$x -lt $y - true if integer $x is less than integer $y
#$x -gt $y - true if integer $x is greater than integer $y
