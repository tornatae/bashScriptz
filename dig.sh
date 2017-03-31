dig-function() {

    echo -n "Resolver: 173.230.129.5 :" >> diganswer.txt
    { time  dig +noall +answer  soa @173.230.129.5 linode.com;} 2>&1 | grep real

    echo -n "Resolver: 173.230.136.5 :" >> diganswer.txt
    { time  dig +noall +answer  soa @173.230.129.5 linode.com;} 2>&1 | grep real >> diganswer.txt

    echo -n "Resolver: 173.230.140.5 :" >> diganswer.txt
    { time  dig +noall +answer  soa @173.230.140.5 linode.com;} 2>&1 | grep real >> diganswer.txt

    echo -n "Resolver: 66.228.59.5 :" >> diganswer.txt
    { time  dig +noall +answer  soa @66.228.59.5 linode.com;} 2>&1 | grep real >> diganswer.txt

    echo -n "Resolver: 66.228.62.5 :" >> diganswer.txt
    { time  dig +noall +answer  soa @66.228.62.5 linode.com;} 2>&1 | grep real >> diganswer.txt

    echo -n "Resolver: 50.116.35.5 :" >> diganswer.txt
    { time  dig +noall +answer  soa @50.116.35.5 linode.com;} 2>&1 | grep real >> diganswer.txt

    echo -n "Resolver: 50.116.41.5 :" >> diganswer.txt
    { time  dig +noall +answer  soa @50.116.41.5 linode.com;} 2>&1 | grep real >> diganswer.txt

    echo -n "Resolver: 23.239.18.5 :" >> diganswer.txt
    { time  dig +noall +answer  soa @23.239.18.5 linode.com;} 2>&1 | grep real >> diganswer.txt

    echo -n "Resolver: 75.127.97.6 :" >> diganswer.txt
    { time  dig +noall +answer  soa @75.127.97.6 linode.com;} 2>&1 | grep real >> diganswer.txt

    echo -n "Resolver: 75.127.97.7 :" >> diganswer.txt
    { time  dig +noall +answer  soa @75.127.97.7 linode.com;} 2>&1 | grep real >> diganswer.txt
}

while :
do
  beginDate=$(date)
  echo "!!!! Begin run on $beginDate !!!!!" >> diganswer.txt
  dig-function 
  echo "!!!!! End run !!!!!" >> diganswer.txt
  sleep 9
done


