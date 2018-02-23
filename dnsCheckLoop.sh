while :
do
  date >> diganswer.txt
  dig +noall +answer  soa @ns1.linode.com grantsolutionsusa.com >> diganswer.txt
  dig +noall +answer  soa @ns2.linode.com grantsolutionsusa.com >> diganswer.txt
  dig +noall +answer  soa @ns3.linode.com grantsolutionsusa.com >> diganswer.txt
  dig +noall +answer  soa @ns4.linode.com grantsolutionsusa.com >> diganswer.txt
  dig +noall +answer  soa @ns5.linode.com grantsolutionsusa.com >> diganswer.txt
  sleep 900
done
