#!/bin/bash
 
# Install Oracle Java 7 on AMBARI (e.g Admin) node.
#sudo yum -y install $JAVA_RPM_PATH ; java -version
sudo yum -y install httpd

mkdir -p /vagrant/tmp
 
chmod a+x /vagrant/generate-rsa-keys.sh
/vagrant/generate-rsa-keys.sh
cp -f /vagrant/tmp/id_rsa /root/.ssh/id_rsa
cp -f /vagrant/tmp/id_rsa /root/.ssh/id_rsa.pub

service httpd start

#create a staging folder
mkdir /staging
chmod a+rx /staging

#untar all the downloaded files in staging folder

for var in "$@" 
do

tar -xzf /vagrant/$var -C /staging/

#filename=$(basename "$var")
#filename="${filename%.*}"

#/staging/$filename/setup_repo.sh 
#tar -xzf /vagrant/AMBARI-1.7.1-87-centos6.tar -C /staging/
#tar -xzf /vagrant/PHD-3.0.0.0-249-centos6.tar -C /staging/
#tar -xzf /vagrant/PADS-1.3.0.0-12954.tar -C /staging/
#tar -xzf /vagrant/hawq-plugin-phd-1.0-57.tar.gz -C /staging
#tar -xzf /vagrant/PHD-UTILS-1.1.0.20-centos6.tar -C /staging

done

#making Ambari available in local yum repository
/staging/AMBARI-1.7.1/setup_repo.sh

#now installing ambari server. it will use local repository
yum -y install ambari-server

#copy jdk-7u67-linux-x64.gz to ambari resources directory
cp /vagrant/jdk-7u67-linux-x64.gz /var/lib/ambari-server/resources/jdk-7u67-linux-x64.tar.gz
chmod 644 /var/lib/ambari-server/resources/jdk-7u67-linux-x64.tar.gz 

#copy UnlimitedJCEPolicyJDK7.zip to Ambari resources folder
cp /vagrant/UnlimitedJCEPolicyJDK7.zip /var/lib/ambari-server/resources/
chmod 644 /var/lib/ambari-server/resources/UnlimitedJCEPolicyJDK7.zip 

#Run Ambari setup
ambari-server setup -s

#Start ambari server
ambari-server start

#Check ambari server status
ambari-server status

#Now setup all PHD components available in local yum repository
/staging/PHD-3.0.0.0/setup_repo.sh
/staging/hawq-plugin-phd-1.0-57/setup_repo.sh 
/staging/PADS-1.3.0.0/setup_repo.sh 
/staging/PHD-UTILS-1.1.0.20/setup_repo.sh

#http://ambari.localdomain/PHD-3.0.0.0
#http://ambari.localdomain/hawq-plugin-phd-1.0-57
#http://ambari.localdomain/PADS-1.3.0.0
#http://ambari.localdomain/PHD-UTILS-1.1.0.20

#Exporting yum ambari repository files
cp -f /etc/yum.repos.d/ambari.repo /vagrant/tmp
cp -f /etc/yum.repos.d/PHD-3.0.0.0.repo /vagrant/tmp
cp -f /etc/yum.repos.d/PADS-1.3.0.0.repo /vagrant/tmp
cp -f /etc/yum.repos.d/PHD-UTILS-1.1.0.20.repo /tmp
cp -f /etc/yum.repos.d/hawq-plugin-phd-1.0-57.repo /vagrant/tmp