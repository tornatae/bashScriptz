#!/bin/bash
time=5
orig=$(mysql -e "show status" | awk '{if ($1 == "Queries") print $2}')
sleep $time
last=$(mysql -e "show status" | awk '{if ($1 == "Queries") print $2}')
diff=$(expr $last - $orig)
avg=$(expr $diff / $time)
echo "$avg"
