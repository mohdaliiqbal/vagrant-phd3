# Vagrant PHD 3.0

Vagrant based Pivotal HD 3.0 cluster setup. The vagrant file and helper scripts sets up a 3 node cluster and an ambari host with all the required steps as mentioned in the Pivotal HD installation guide. The project is inspired by an existing [Vagrant PHD] (https://github.com/tzolov/vagrant-pivotalhd) project created by Christian Tzolov from Pivotal.


There are some pre-requisites files that must be downloaded to the root vagrant directory. Following is the list of files that must be present in the same directory as the Vagrantfile. You can get some of these files from http://network.pivotal.io. Jdk and UnlimitedJCEPolicyJDK7.zip can be found in Oralce website. More details are available at http://pivotalhd.docs.pivotal.io/docs/install-ambari.html

 - AMBARI-1.7.1-87-centos6.tar
 - PADS-1.3.0.0-12954.tar
 - PHD-3.0.0.0-249-centos6.tar
 - PHD-UTILS-1.1.0.20-centos6.tar
 - UnlimitedJCEPolicyJDK7.zip
 - hawq-plugin-phd-1.0-57.tar.gz
 - jdk-7u67-linux-x64.gz

Currently I have not installed HAWQ component using this setup. 

You directory structure should look like
```
/vagrant-phd3
|- <all above mentioned files>
|- Vagrantfile
|- ambari-install.sh
|- prepare-host.sh
|- generate-rsa-keys.sh
````
###Create the VMs
Once you've downloaded the above files and cloned the git the project to the same directory, you can just run following command from within the directory

`vagrant up` 

This will create 4 VMs 

1. Ambari x 1
2. Pivotal HD x 3 


###Default Settings
following are the default settings
- Default IP 192.168.0.200 for ambari - hostname ambari.localdomain
- Default IP 192.168.0.201 ... 192.168.0.203 for PHD nodes - phd1.localdomain, phd2.localdomain, phd3.localdomain respectively
- Ambari host becomes the local yum repository
- Ambari host gets passwordless ssh access to all other nodes
- All components from the above downloaded files are copied into yum repository inside the ambari host
- **very important** The VMs are bridged hardcoded with Wifi network interface on a public network. Read [Vagrant Network](http://docs.vagrantup.com/v2/networking/index.html) for more details. You can change the bridge to go on any other interface by changing `BRIDGE_INTERFACE` variable. Look inside Vagrantfile for more information.
- All nodes are bridged to public as some YUM updates were needed and they need to have access to the internet. You can use NAT, just make sure your nodes have internet access through the host.

###Configurations
- Ambari server is 1GB. You can change this value by setting ```AMBARI_MEMORY_MB``` variable
- PHD nodes are 2GB each. You can increase this value by setting ```MASTER_PHD_MEMORY_MB```, and ```WORKER_PHD_MEMORY_MB``` variables
- Default IP addresses can be controlled using ```IP_ADDRESS_RANGE``` and ``START_IP`` variable. IPs are created concatinating ```IP_ADDRESS_RANGE+START_IP``` for Ambari and ``IP_ADDRESS_RANGE+(START_IP+Node index)`` for PHD nodes 
- Default naming of VM and hostname of the nodes can be changed using `PHD_VM_NAME`, and `PHD_HOSTNAME_PREFIX`. You need to make relevant changes in `WORKERS` and `MASTER` arrays (i will fix this later).
- Default number of nodes can be controlled by increasing entries in `WORKERS` array, so for e.g. you want 4 worker nodes then you must provide node names `PHD_HOSTNAME_PREFIX+"2.localdomain"`, ... , `PHD_HOSTNAME_PREFIX+"5.localdomain"`

Once the provisioning is completed, you can visit [Ambari Server UI](http://192.168.0.200:8080/) and create the Hadoop cluster. 

###URLs that you will need for Ambari
```
http://ambari.localdomain/PHD-3.0.0.0
http://ambari.localdomain/hawq-plugin-phd-1.0-57
http://ambari.localdomain/PADS-1.3.0.0
http://ambari.localdomain/PHD-UTILS-1.1.0.20

```

###Some tips 
- Since this is supposed to be running in a Laptop for development purposes, keep your cluster footprint to minimum no. of components. If you're not going to benefit from any of the OOB components e.g. *HBase*, *Nagios* then don't include them when you're creating a cluster in Ambari. 
- To make a psuedo-singlenode PHD VM, tweek settings to have only `MASTER` array and keep `WORKERS` array empty. It should work, I have not tried it. Then from Ambari VM use only MASTER to install all required components
- Keep your Zookeeper instances to minimum.

###Things to follow
- Add HAWQ plugin to Ambari and have it ready within Ambari to provision HAWQ cluster.
- Add Optional Spring XD VMs
- Add Optional GemfireXD VMs
- Create the cluster without Ambari
