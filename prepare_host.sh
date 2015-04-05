#!/bin/bash

NUMBER_OF_CLUSTER_NODES=$1
HOSTNAME=$2
IP_ADDRESS_RANGE=$3
START_IP=$4
PHD_HOSTNAME_PREFIX=$5

yum -y install openssl

yum -y install nc expect ed ntp dmidecode pciutils 

#Make sure umask is 0022
echo 'umask 022'|cat>> ~/.bashrc
source ~/.bashrc


/etc/init.d/ntpd stop; 
mv /etc/localtime /etc/localtime.bak; 
ln -s /usr/share/zoneinfo/Asia/Dubai /etc/localtime; 
/etc/init.d/ntpd start

sestatus; chkconfig iptables off; service iptables stop; service iptables status 
setenforce 0


cat > /etc/hosts <<EOF 
127.0.0.1     localhost.localdomain    localhost
::1           localhost6.localdomain6  localhost6
 
$IP_ADDRESS_RANGE$(($START_IP)) ambari.localdomain  ambari
EOF

for i in $(eval echo {1..$NUMBER_OF_CLUSTER_NODES}); do 

   HOST_IP=$IP_ADDRESS_RANGE$(($START_IP+$i))
   
   echo $HOST_IP $PHD_HOSTNAME_PREFIX$i.localdomain PHD_HOSTNAME_PREFIX$i >> /etc/hosts 
   
   #this mess is to avoid the host authenticity prompt when passwordless ssh connects to a host. making ambari happy.
   ssh-keygen -R $PHD_HOSTNAME_PREFIX$i.localdomain
   ssh-keygen -R $HOST_IP
   ssh-keygen -R $PHD_HOSTNAME_PREFIX$i.localdomain,$HOST_IP
   ssh-keyscan -H $PHD_HOSTNAME_PREFIX$i.localdomain,$HOST_IP >> ~/.ssh/known_hosts
   ssh-keyscan -H $HOST_IP >> ~/.ssh/known_hosts
   ssh-keyscan -H $PHD_HOSTNAME_PREFIX$i.localdomain >> ~/.ssh/known_hosts

done


#NOW Copy the keys for password less SSH
if [[ $HOSTNAME == *$PHD_HOSTNAME_PREFIX* ]]
then
    echo "copying the rsa keys"
    cat /vagrant/id_rsa.pub | cat >> ~/.ssh/authorized_keys
fi