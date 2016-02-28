# -*- mode: ruby -*-
# vi: set ft=ruby :
# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

require 'set'


PHD_VM_NAME_PREFIX ="phd"
PHD_HOSTNAME_PREFIX="phd"

CREATE_CLUSTER=1


#You can change this one to suit your interface
#BRIDGE_INTERFACE ="en0: Wi-Fi (AirPort)"


# Node(s) to be used as a master - default '<Hostname prefix>1.localdomain'. Exactly One master node must be provided
MASTER = [PHD_HOSTNAME_PREFIX+"1.localdomain"]

# Node(s) to be used as a Workers. Convention is: 'phd<Index>.localdomain'. At least one worker node is required
# The master node can be reused as a worker. 

# The total number of nodes in the cluster
NUMBER_OF_CLUSTER_NODES = 2



#It is important that this value matches the HAWQ plugin you want to install. Default value is the one released originally
#with PHD3.0 on March 31, 2015. Please update this value and plugin name in 
HAWQ_ORIGINAL_AMBARI_PLUGIN="hawq-plugin-phd-1.3.1-179.tar.gz"

# This script only supports Pivotal HD 3.0 
# for older versions please refer to github vagrantphd project under tzolov user account
PHD_30 = ["AMBARI-1.7.1-88-centos6.tar", "PHD-3.0.1.0-1-centos6.tar", "PADS-1.3.1.1-19631-rhel5_x86_64.tar", "PHD-UTILS-1.1.0.20-centos6.tar", HAWQ_ORIGINAL_AMBARI_PLUGIN]

#If you do not want to use out of the box plugin in PHD_30 components, and have an RPM of your own then you can put 
#it in the following variable and set OVERWRITE_HAWQ_PLUGIN to 1. The RPM must be available in the root vagrant directory
#along side the Vagrntfile
CUSTOM_HAWQ_AMBARI_PLUGIN_RPM="hawq-plugin-1.3.1-179.noarch.rpm"
OVERWRITE_HAWQ_AMBARI_PLUGIN=0


# Vagrant box name
#   bigdata/centos6.4_x86_64 - 40G disk space.
#   bigdata/centos6.4_x86_64_small - just 8G of disk space. Not enough for Hue!
VM_BOX = "bigdata/centos6.4_x86_64"

# Memory (MB) allocated for the master PHD VM
MASTER_PHD_MEMORY_MB = "3072"

# Memory (MB) allocated for every PHD node VM
#WORKER_PHD_MEMORY_MB = "1536"
WORKER_PHD_MEMORY_MB = "2048"

# Memory (MB) allocated for the AMBARI VM
AMBARI_MEMORY_MB = "1024"

# Amabari VM name
AMBARI_VM_NAME = "ambari"

# Ambari VM host name
AMBARI_HOSTNAME = "ambari.localdomain"

#You can change this range to whatever you want. it could be 10.55.1.
#This will be used as first 24 bit of ip 
IP_ADDRESS_RANGE="192.168.99."

#this number specify the starting ip of the cluster if you specify it 200 then 
#first vm (ambari vm) will get ip address range (192.168.0.) concatinated with 200 i.e. 192.168.0.200
#all other phd vms will take one ip higher than previous
START_IP=200

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.


 Vagrant.configure(2) do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://atlas.hashicorp.com/search.
  # config.vm.box = "base"
  
   
  #NOW CREATE AMBARI SERVER
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
      #ambari.vm.network :public_network, ip: "#{IP_ADDRESS_RANGE}#{START_IP}", bridge: "#{BRIDGE_INTERFACE}"
      ambari.vm.network :private_network, ip: IP_ADDRESS_RANGE+"#{START_IP}"
      ambari.vm.network :forwarded_port, guest: 5443, host: 5443
      
      ambari.vm.provision "shell" do |s|
          s.path ="prepare_host.sh"
          s.args =[NUMBER_OF_CLUSTER_NODES, AMBARI_HOSTNAME, IP_ADDRESS_RANGE, START_IP, PHD_HOSTNAME_PREFIX, CREATE_CLUSTER]
      end


      ambari.vm.provision "shell" do |s|
          s.path ="ambari_install.sh"
          s.args = PHD_30
      end
    
      ambari.vm.provision "shell" do |s|
              s.path = "hawq_plugin_install.sh"
              s.args = [HAWQ_ORIGINAL_AMBARI_PLUGIN, OVERWRITE_HAWQ_AMBARI_PLUGIN, CUSTOM_HAWQ_AMBARI_PLUGIN_RPM]
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
      phd_conf.vm.network :private_network, ip: IP_ADDRESS_RANGE+"#{i+START_IP}"
     
      phd_conf.vm.provision "shell" do |s|
        s.path = "prepare_host.sh"
        s.args = [NUMBER_OF_CLUSTER_NODES, phd_host_name, IP_ADDRESS_RANGE, START_IP, PHD_HOSTNAME_PREFIX, CREATE_CLUSTER]
      end 
	  
      #Fix hostname FQDN
      phd_conf.vm.provision :shell, :inline => "hostname #{phd_host_name}"
    end    
  end

end
