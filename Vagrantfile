# -*- mode: ruby -*-
# vi: set ft=ruby :
# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

require 'set'


PHD_VM_NAME_PREFIX ="phdX"
PHD_HOSTNAME_PREFIX="phdX"

# Node(s) to be used as a master. Convention is: 'phd<Number>.localdomain'. Exactly One master node must be provided
MASTER = [PHD_HOSTNAME_PREFIX+"1.localdomain"]

# Node(s) to be used as a Workers. Convention is: 'phd<Number>.localdomain'. At least one worker node is required
# The master node can be reused as a worker. 
WORKERS = [PHD_HOSTNAME_PREFIX+"2.localdomain", PHD_HOSTNAME_PREFIX+"3.localdomain"]

# Some commonly used PHD distributions are predefined below. Select one and assign it to PHD_DISTRIBUTION_TO_INSTALL 
# To install different packages versions put those packages in the Vagrantfile folder and define 
# a custom PHD_DISTRIBUTION_TO_INSTALL. For example: 
# PHD_DISTRIBUTION_TO_INSTALL=["PCC-<your version>", "PHD-<your version>", "PADS-<your version>", "PRTS-<your version>"]
#
# PCC and PHD are compulsory! To disable PADS and/or PRTS use "NA" in place of package name. (e.g. ["PCC-2.1.0-460", 
# "PHD-1.1.0.0-76", "NA", "NA"]).
# Note: When disabling packages be aware that the 'hawq' service requires the PADS package and the 'gfxd' 
#       service requires the PRTS package!

# Community PivotalHD 1.1.0 - NOT USE IN MY SCRIPT 
PHD_30 = ["AMBARI-1.7.1-87-centos6.tar", "PHD-3.0.0.0-249-centos6.tar", "PADS-1.3.0.0-12954.tar", "PHD-UTILS-1.1.0.20-centos6.tar"]
HAWQ_AMBARI_PLUGIN=["hawq-plugin-phd-1.0-57.tar.gz"]

# Set the distribution to install
PHD_DISTRIBUTION_TO_INSTALL = PHD_30

# Vagrant box name
#   bigdata/centos6.4_x86_64 - 40G disk space.
#   bigdata/centos6.4_x86_64_small - just 8G of disk space. Not enough for Hue!
VM_BOX = "bigdata/centos6.4_x86_64"

# Memory (MB) allocated for the master PHD VM
MASTER_PHD_MEMORY_MB = "2048"

# Memory (MB) allocated for every PHD node VM
#WORKER_PHD_MEMORY_MB = "1536"
WORKER_PHD_MEMORY_MB = "2048"

# Memory (MB) allocated for the AMBARI VM
AMBARI_MEMORY_MB = "1024"

# Amabari VM name
AMBARI_VM_NAME = "ambari2"

# Ambari VM host name
AMBARI_HOSTNAME = "ambari.localdomain"

#You can change this range to whatever you want. it could be 10.55.1.
#This will be used as first 24 bit of ip 
IP_ADDRESS_RANGE="192.168.0."

#this number specify the starting ip of the cluster if you specify it 200 then 
#first vm (ambari vm) will get ip address range (192.168.0.) concatinated with 200 i.e. 192.168.0.200
#all other phd vms will take one ip higher than previous
START_IP=200

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.

 # Compute the total number of nodes in the cluster 	    
  NUMBER_OF_CLUSTER_NODES = (MASTER + WORKERS).uniq.size

Vagrant.configure(2) do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://atlas.hashicorp.com/search.
  # config.vm.box = "base"
  
   
    config.vm.define AMBARI_VM_NAME do |ambari|
      ambari.vm.box = VM_BOX
      
      ambari.vm.provider "virtualbox" do |v|
          v.name = AMBARI_VM_NAME 
          v.memory = AMBARI_MEMORY_MB
        end
      
      ambari.vm.provider "vmware_fusion" do |v|
          v.name= AMBARI_VM_NAME
          v.vmx["memsize"] = AMBARI_MEMORY_MB
      end
      
      
      ambari.vm.hostname=AMBARI_HOSTNAME
      ambari.vm.network :public_network, ip: "192.168.0.200", bridge: "en0: Wi-Fi (AirPort)"
      
      ambari.vm.provision "shell" do |s|
          s.path ="prepare_host.sh"
          s.args =[NUMBER_OF_CLUSTER_NODES, AMBARI_HOSTNAME, IP_ADDRESS_RANGE, START_IP, PHD_HOSTNAME_PREFIX]
      end
        
          
      ambari.vm.provision "shell" do |s|
          s.path ="ambari_install.sh"
          s.args = PHD_30
      end
    end
   
  # Create VM for every PHD node
  (1..NUMBER_OF_CLUSTER_NODES).each do |i|

    phd_vm_name = PHD_VM_NAME_PREFIX+"#{i}"
    
    phd_host_name = PHD_HOSTNAME_PREFIX+"#{i}.localdomain"
    
    # Compute the memory
    vm_memory_mb = (MASTER.include? phd_host_name) ? MASTER_PHD_MEMORY_MB : WORKER_PHD_MEMORY_MB

    config.vm.define phd_vm_name.to_sym do |phd_conf|
      phd_conf.vm.box = VM_BOX
      phd_conf.vm.provider :virtualbox do |v|
        v.name = phd_vm_name
        v.customize ["modifyvm", :id, "--memory", vm_memory_mb]
      end
      phd_conf.vm.provider "vmware_fusion" do |v|
        v.name = phd_vm_name
        v.vmx["memsize"]  = vm_memory_mb
      end     	  

      phd_conf.vm.host_name = phd_host_name    
      phd_conf.vm.network :public_network, ip: "192.168.0.#{i+200}", bridge: "en0: Wi-Fi (AirPort)" 

      phd_conf.vm.provision "shell" do |s|
        s.path = "prepare_host.sh"
        s.args = [NUMBER_OF_CLUSTER_NODES, phd_host_name, IP_ADDRESS_RANGE, START_IP, PHD_HOSTNAME_PREFIX]
      end 
	  
      #Fix hostname FQDN
      phd_conf.vm.provision :shell, :inline => "hostname #{phd_host_name}"
    end    
  end

  

end
