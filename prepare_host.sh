#!/bin/bash

NUMBER_OF_CLUSTER_NODES=$1
HOSTNAME=$2
IP_ADDRESS_RANGE=$3
START_IP=$4
PHD_HOSTNAME_PREFIX=$5
CREATE_CLUSTER=$6

yum -y install openssl

yum -y install nc expect ed ntp dmidecode pciutils httpd createrepo

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
   
   echo $HOST_IP $PHD_HOSTNAME_PREFIX$i.localdomain $PHD_HOSTNAME_PREFIX$i >> /etc/hosts 

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
    cat /vagrant/tmp/id_rsa.pub | cat >> ~/.ssh/authorized_keys
    #Exporting yum ambari repository files
    cp -f /vagrant/tmp/ambari.repo  /etc/yum.repos.d
    cp -f /vagrant/tmp/PHD-3.0.0.0.repo /etc/yum.repos.d
    cp -f /vagrant/tmp/PADS-1.3.0.0.repo /etc/yum.repos.d
    cp -f /vagrant/tmp/PHD-UTILS-1.1.0.20.repo /etc/yum.repos.d
    cp -f /vagrant/tmp/hawq-plugin-phd-1.0-57.repo /etc/yum.repos.d
    yum -y install ambari-agent
    sed -i '16s/.*/hostname=ambari.localdomain/' /etc/ambari-agent/conf/ambari-agent.ini
    ambari-agent start 
fi

# When processing last node of the cluster, remove the temporary files and create cluster with blueprint
if [[ $HOSTNAME == *$NUMBER_OF_CLUSTER_NODES* ]]
then    #final node in the cluster
    echo "Creating PHD cluster....."
    cd /vagrant
    echo $CREATE_CLUSTER "- Cluster create.."
    if [[ $CREATE_CLUSTER == 1 ]]; then
    #Set Repository URL for PHD-3.0 in Ambari
      curl -i  -H "X-Requested-By: alim20"  -H "Authorization: Basic YWRtaW46YWRtaW4=" -X  PUT "http://ambari.localdomain:8080/api/v1/stacks/PHD/versions/3.0/operating_systems/redhat6/repositories/PHD-3.0" --data '{  "Repositories" : { "base_url" : "http://ambari.localdomain/PHD-3.0.0.0", "verify_base_url" : true , "default_base_url":"http://ambari.localdomain/PHD-3.0.0.0", "latest_base_url" : "http://ambari.localdomain/PHD-3.0.0.0"} }'
    
    #SET Repository for PHD-UTILS URL in Ambari
    curl -i  -H "X-Requested-By: alim20"  -H "Authorization: Basic YWRtaW46YWRtaW4=" -X  PUT "http://ambari.localdomain:8080/api/v1/stacks/PHD/versions/3.0/operating_systems/redhat6/repositories/PHD-UTILS-1.1.0.20" --data '{  "Repositories" : { "base_url" : "http://ambari.localdomain/PHD-UTILS-1.1.0.20", "verify_base_url" : true , "default_base_url":"http://ambari.localdomain/PHD-UTILS-1.1.0.20", "latest_base_url" : "http://ambari.localdomain/PHD-UTILS-1.1.0.20"} }'
    
    #Create blueprint in Ambari - 3 HOSTGROUP/HOST CLUSTER
      curl -i  -H "X-Requested-By: alim20"  -H "Authorization: Basic YWRtaW46YWRtaW4=" -X  POST "http://ambari.localdomain:8080/api/v1/blueprints/phddemo?validate_topology=false" --data @clusterblueprint.json
    
    #Create Cluster in Ambari - 3 nodes by default and name of the hosts are hardcoded in clustertemplate.json. FIXME.
    curl -i  -H "X-Requested-By: alim20"  -H "Authorization: Basic YWRtaW46YWRtaW4=" -X  POST "http://ambari.localdomain:8080/api/v1/clusters/phdcluster" --data @clustertemplate.json
    fi

  #Uncomment the following line if you want a vagrant temp folder clean up. This was used to copy file over between ambari
  #and other VMs. If you do not delete this directory then you can bring individual PHD vms up and down easily else you will
  #need to recreate all the VMs. I recommend to keep tmp folder.
  #rm -f -R /vagrant/tmp
    
fi
