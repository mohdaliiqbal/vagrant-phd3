# Vagrant PHD 3.0

Vagrant based Pivotal HD 3.0 cluster setup. The vagrant file and helper scripts sets up a 2 node cluster and an ambari host with all the required steps as mentioned in the Pivotal HD installation guide. By default it provisions a PHD cluster with HDFS, YARN, HAWQ, Nagios, and Ganglia components. You can add/modify the placement of the component using the clusterblueprint.json, and clustertemplate.json files. The project is inspired by an existing [Vagrant PHD] (https://github.com/tzolov/vagrant-pivotalhd) project created by Christian Tzolov from Pivotal.

***Its import that you read the vm.overcommit_memory issue under the tips and diagonstic section*** 


There are some pre-requisites files that must be downloaded to the root vagrant directory. Following is the list of files that must be present in the same directory as the Vagrantfile. You can get some of these files from http://network.pivotal.io. Jdk and UnlimitedJCEPolicyJDK7.zip can be found in Oralce website. More details are available at http://pivotalhd.docs.pivotal.io/docs/install-ambari.html

 - [AMBARI-1.7.1-88-centos6.tar](https://network.pivotal.io/products/pivotal-hd)
 - [PADS-1.3.1.1-19631-rhel5_x86_64.tar](https://network.pivotal.io/products/pivotal-hawq)
 - [PHD-3.0.1.0-1-centos6.tar](https://network.pivotal.io/products/pivotal-hd)
 - [PHD-UTILS-1.1.0.20-centos6.tar](https://network.pivotal.io/products/pivotal-hd)
 - [UnlimitedJCEPolicyJDK7.zip](http://www.oracle.com/technetwork/jp/java/javase/downloads/jce-7-download-432124.html)
 - [hawq-plugin-phd-1.3.1-179.tar.gz](https://network.pivotal.io/products/pivotal-hawq)
 - [jdk-7u67-linux-x64.tar.gz](http://www.oracle.com/technetwork/java/javase/downloads/java-archive-downloads-javase7-521261.html#jdk-7u67-oth-JPR)
  
The creation of cluster can be controlled using a variable in Vagrantfile called `CREATE_CLUSTER`, set its value to 0 or anything other than 1.

Your directory structure should look like
```
/vagrant-phd3
|- <all above mentioned files>
|- Vagrantfile
|- ambari-install.sh
|- prepare-host.sh
|- generate-rsa-keys.sh
|- hawq_plugin_install.sh
|- clustertemplate.json
|- clusterblueprint.json
```
###Create the VMs
Once you've downloaded the above files and cloned the git the project to the same directory, you can just run following command from within the directory

`vagrant up` 

This will create 3 VMs and create a PHD cluster

1. Ambari x 1
2. Pivotal HD x 2


###Default Settings
following are the default settings
- For ambari - hostname ambari.localdomain
- PHD nodes - phd1.localdomain, phd2.localdomain respectively
- Ambari host becomes the local yum repository
- Ambari host gets passwordless ssh access to all other nodes
- All components from the above downloaded files are copied into yum repository inside the ambari host
- Ambari server and agents are installed and yum repositories are updated in all hosts.
- PHD cluster is created by first creating a blueprint from `clusterblueprint.json` file and then a cluster is created using hosts mapping given in `clustertemplate.json`. You can modify these files to change component mapping or drop component as per your requirement. All of this is done when final node of the cluster is created successfully.
- All nodes are on private network with NAT to host and they need to have access to the internet. 

###Configurations
- Ambari server is 1GB. You can change this value by setting ```AMBARI_MEMORY_MB``` variable
- PHD nodes are 3GB for MASTER and 2GB for slave. You can increase this value by setting ```MASTER_PHD_MEMORY_MB```, and ```WORKER_PHD_MEMORY_MB``` variables
- Default IP addresses can be controlled using ```IP_ADDRESS_RANGE``` and ``START_IP`` variable. IPs are created concatinating ```IP_ADDRESS_RANGE+START_IP``` for Ambari and ``IP_ADDRESS_RANGE+(START_IP+Node index)`` for PHD nodes 
- Default naming of VM and hostname of the nodes can be changed using `PHD_VM_NAME`, and `PHD_HOSTNAME_PREFIX`. You need to make relevant changes in `WORKERS` and `MASTER` arrays (i will fix this later).
- Default number of nodes can be controlled by increasing entries in `WORKERS` array, so for e.g. you want 4 worker nodes then you must provide node names `PHD_HOSTNAME_PREFIX+"2.localdomain"`, ... , `PHD_HOSTNAME_PREFIX+"5.localdomain"`

Once the provisioning is completed, you can visit [Ambari Server UI](http://192.168.55.200:8080/) and create the Hadoop cluster. 

###How to know if everything went fine?
If you have ran it with default settings, then after the provisioning is completed you should see a dashboard in Ambari server and the top bar should indicate you that some operations are in progress. These operations are for creation of the cluster. If you see a Wizard to create cluster then there must be something wrong, by default you should not see wizard unless you have manually edited the value for ``CREATE_CLUSTER`` variable.

***URLs that you will need for Ambari, if you did not select to create the cluster***
```
http://ambari.localdomain/PHD-3.0.0.0
http://ambari.localdomain/hawq-plugin-phd-1.0-57
http://ambari.localdomain/PADS-1.3.0.0
http://ambari.localdomain/PHD-UTILS-1.1.0.20

```

###Tips & Diagonostics 
If you see services failing to start and the problem is JVM out of memory then you may need to set vm.overcommit_memory = 0 in sysctl.conf.  Unfortunately this is not easy to automate because HAWQ plugin rpm distributed by Pivotal sets this value to 2 during cluster creation, so once cluster is created you may need to fix this value to start services successfully. Following are the steps to change this configuration. Following steps need to be repeated for every node in the cluster (PHD1, PHD2, PHD3)

```
vagrant ssh phd1
sudo vi /etc/sysctl.conf
```
- Change the line ```vm.overcommit_memory = 2``` to ```vm.overcommit_memory = 0```

- Save the file and run the following command

```
sudo sysctl -p
```


###Youtube Vdo
You can watch the VDO for this project from the link below. This vdo is a bit out dated, it tells you to create cluster using Ambari, however, the latest script does the cluster creation for you automatically, so you can skip the Ambari steps to create cluster.

<a href="http://www.youtube.com/watch?feature=player_embedded&v=ZSjygc7V2dM
" target="_blank"><img src="http://img.youtube.com/vi/ZSjygc7V2dM/0.jpg" 
alt="IMAGE ALT TEXT HERE" width="240" height="180" border="10" /></a>
