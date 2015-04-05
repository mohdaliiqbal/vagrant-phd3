# vagrant-phd3

Vagrant based Pivotal HD cluster setup. The vagrant file and helper scripts sets up a 3 node cluster and an ambari host with all the required steps as mentioned in the Pivotal HD installation guide.


There are some pre-requise files that must be downloaded to the root vagrant directory. Following is the list of files that must be present in the same directory as the Vagrantfile. You can get some of these files from http://network.pivotal.io. Jdk and UnlimitedJCEPolicyJDK7.zip can be found in Oralce website. More details are available at http://pivotalhd.docs.pivotal.io/docs/install-ambari.html

  AMBARI-1.7.1-87-centos6.tar
	PADS-1.3.0.0-12954.tar
	PHD-3.0.0.0-249-centos6.tar
	PHD-UTILS-1.1.0.20-centos6.tar
	UnlimitedJCEPolicyJDK7.zip
	hawq-plugin-phd-1.0-57.tar.gz
	jdk-7u67-linux-x64.gz

This is a work in progress so expect details to follow.

Once you've downloaded the above files and cloned the git the project to the same directory, you can just run 

vagrant up 

This will create 4 VMs 

1. Ambari x 1
2. Pivotal HD x 3 

Once the provisioning is completed, you can visit http://192.168.0.200:8080/ and create the cluster. 

The project is inspired by an existing Vagrant project created by Christian Tzolov from Pivotal.
