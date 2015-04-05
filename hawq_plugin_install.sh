#!/bin/bash
HAWQ_ORIGINAL_PLUGIN=$1
OVERWRITE_HAWQ_PLUGIN=$2
HAWQ_PLUGIN_RPM=$3


filename=$(basename "$HAWQ_ORIGINAL_PLUGIN")
#This mess is to dynamically determine the name of the plugin file from the plugin.tar.gz files
#first clear the tar.gz, then determine the version no, then append .noarch.rpm to create the original rpm name that 
#should be overwritten and installed.

if [[ $HAWQ_ORIGINAL_PLUGIN == *"tar.gz"* ]]
then
    #file is not tar.gz, so we will use following expression twice
    filename="${filename%.*}"
    filename="${filename%.*}"
else
    filename="${filename%.*}"
fi
#remove the hawq-plugin-phd part because phd substring is not in the rpm file name which is released by pivotal
prefix="hawq-plugin-phd-"
version_no=${filename#$prefix}

#creating original file name
original_filename="hawq-plugin-$version_no.noarch.rpm"

#NOW Overwrite if required
if [[ $OVERWRITE_HAWQ_PLUGIN == 1 ]]
then
    echo "Overwriting /staging/$filename/$original_filename plugin with "$HAWQ_PLUGIN_RPM
    yes | cp /vagrant/$HAWQ_PLUGIN_RPM /staging/$filename/$original_filename
fi


rpm -ivh /staging/$filename/$original_filename

ambari-server restart

