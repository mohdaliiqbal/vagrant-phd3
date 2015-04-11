# Vagrant PHD 3.0

Vagrant based Pivotal HD 3.0 cluster setup. The vagrant file and helper scripts sets up a 3 node cluster and an ambari host with all the required steps as mentioned in the Pivotal HD installation guide. By default it provisions a PHD cluster with HDFS, YARN, HAWQ, Hive, Nagios, Ganglia, Knox components. You can modify the placement of the component using the blueprint.json, and clustertemplate.json files. The project is inspired by an existing [Vagrant PHD] (https://github.com/tzolov/vagrant-pivotalhd) project created by Christian Tzolov from Pivotal.


There are some pre-requisites files that must be downloaded to the root vagrant directory. Following is the list of files that must be present in the same directory as the Vagrantfile. You can get some of these files from http://network.pivotal.io. Jdk and UnlimitedJCEPolicyJDK7.zip can be found in Oralce website. More details are available at http://pivotalhd.docs.pivotal.io/docs/install-ambari.html

 - [AMBARI-1.7.1-87-centos6.tar](https://network.pivotal.io/products/pivotal-hd)
 - [PADS-1.3.0.0-12954.tar](https://network.pivotal.io/products/pivotal-hawq)
 - [PHD-3.0.0.0-249-centos6.tar](https://network.pivotal.io/products/pivotal-hd)
 - [PHD-UTILS-1.1.0.20-centos6.tar](https://network.pivotal.io/products/pivotal-hd)
 - [UnlimitedJCEPolicyJDK7.zip](http://www.oracle.com/technetwork/jp/java/javase/downloads/jce-7-download-432124.html)
 - [hawq-plugin-phd-1.0-57.tar.gz](https://network.pivotal.io/products/pivotal-hawq)
 - [jdk-7u67-linux-x64.gz] (http://www.oracle.com/technetwork/java/javase/downloads/java-archive-downloads-javase7-521261.html#jdk-7u67-oth-JPR)
 -

The creation of cluster can be controlled using a variable in Vagrantfile called `CREATE_CLUSTER`, set its value to 0 or anything other than 1.

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

This will create 4 VMs and create a PHD cluster

1. Ambari x 1
2. Pivotal HD x 3 


###Default Settings
following are the default settings
- Default IP 10.211.55.200 for ambari - hostname ambari.localdomain
- Default IP 10.211.55.201 ... 10.211.55.203 for PHD nodes - phd1.localdomain, phd2.localdomain, phd3.localdomain respectively
- Ambari host becomes the local yum repository
- Ambari host gets passwordless ssh access to all other nodes
- All components from the above downloaded files are copied into yum repository inside the ambari host
- Ambari server and agents are installed and yum repositories are updated in all hosts.
- PHD cluster is created by first creating a blueprint from `clusterblueprint.json` file and then a cluster is created using hosts mapping given in `clustertemplate.json`. You can modify these files to change component mapping or drop component as per your requirement. All of this is done when final node of the cluster is created successfully.
- All nodes are on private network with NAT to host and they need to have access to the internet. 

###Configurations
- Ambari server is 1GB. You can change this value by setting ```AMBARI_MEMORY_MB``` variable
- PHD nodes are 2GB each. You can increase this value by setting ```MASTER_PHD_MEMORY_MB```, and ```WORKER_PHD_MEMORY_MB``` variables
- Default IP addresses can be controlled using ```IP_ADDRESS_RANGE``` and ``START_IP`` variable. IPs are created concatinating ```IP_ADDRESS_RANGE+START_IP``` for Ambari and ``IP_ADDRESS_RANGE+(START_IP+Node index)`` for PHD nodes 
- Default naming of VM and hostname of the nodes can be changed using `PHD_VM_NAME`, and `PHD_HOSTNAME_PREFIX`. You need to make relevant changes in `WORKERS` and `MASTER` arrays (i will fix this later).
- Default number of nodes can be controlled by increasing entries in `WORKERS` array, so for e.g. you want 4 worker nodes then you must provide node names `PHD_HOSTNAME_PREFIX+"2.localdomain"`, ... , `PHD_HOSTNAME_PREFIX+"5.localdomain"`

Once the provisioning is completed, you can visit [Ambari Server UI](http://10.211.55.200:8080/) and create the Hadoop cluster. 

###URLs that you will need for Ambari, if you did not select to create the cluster.
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


