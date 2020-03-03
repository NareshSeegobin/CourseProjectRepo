#!/bin/bash

## Based on https://www.mirantis.com/blog/how-to-install-openstack-on-your-local-machine-using-devstack/
## It is essential to create a stack user with sudo access or else you will get a HOST_IP error:
## https://stackoverflow.com/questions/46192965/error-in-running-stack-sh-in-devstack

## Revision History:
## 20200113-01 - NS - First version
##                    It is essential to create a stack user with sudo access or else you will get a HOST_IP error:
##                       https://stackoverflow.com/questions/46192965/error-in-running-stack-sh-in-devstack
## 20200115-01 - NS - Multiple updates. 
##                    Added timestamping. The script should be copied and pasted in a shell terminal
##                    Before executing the commands below, execute "sudo ls" to cache the password first.
## 20200115-02 - NS - NB: Very Important!!!, your local DNS server could prevent the script from connecting to the amazon web servers
##                    e.g. Connecting to github-production-release-asset-2e65be.s3.amazonaws.com (github-production-release-asset-2e65be.s3.amazonaws.com)|52.217.32.204|:443
##                         https://github.com/HaxeFoundation/haxe/issues/8900
##                    Please use a DNS server such as 8.8.8. or 1.1.1.1. You may have to add it manually on your local desktop or in your DHCP server add these as the first DNS servers.

## 20200228-01 - NS - Installtion of Cinder
##                    Pages: https://discoposse.com/2013/02/26/openstack-lab-on-vmware-workstation-adding-cinder-volume-features/
##                    
##                    

## 20200229-01 - NS - To use ubuntu 18.04.4 LTS
##                    Additional services require python 3.6
##                    
##   


## 20200302-01 - NS - To use ubuntu 16.04.4 LTS
##                    Installing Rocky release
##                    
##   

### https://askubuntu.com/questions/865554/how-do-i-install-python-3-6-using-apt-get
### sudo add-apt-repository ppa:deadsnakes/ppa -y
### sudo apt-get update -y
### sudo apt-get install python3.6 -y

## https://askubuntu.com/questions/590027/how-to-set-python-3-as-default-interpreter-in-ubuntu-14-04
## Must execute in new user environment - each time you sudo su -
### alias python=/usr/bin/python3.6

## https://stackoverflow.com/questions/6587507/how-to-install-pip-with-python-3
### sudo apt-get install python-pip -y
### sudo apt-get install python3-pip -y


## https://www.liquidweb.com/kb/how-to-install-pip-on-ubuntu-14-04-lts/
### sudo pip install --upgrade pip
### sudo pip3 install --upgrade pip

## Do not need this: http://devopspy.com/python/install-python-3-6-ubuntu-lts/
## https://askubuntu.com/questions/590027/how-to-set-python-3-as-default-interpreter-in-ubuntu-14-04
##alias pip=/usr/bin/python3.6


### Automatically disabled Acquire::http::Pipeline-Depth due to incorrect response from server/proxy. (man 5 apt.conf)
### https://www.serverlab.ca/tutorials/linux/administration-linux/how-to-set-the-proxy-for-apt-for-ubuntu-18-04/
### https://askubuntu.com/questions/344802/why-is-apt-get-always-using-proxy-although-no-proxy-is-configured

sudo su -
touch /etc/apt/apt.conf.d/proxy.conf
cat >  /etc/apt/apt.conf.d/proxy.conf <<EOF
Acquire::http::Proxy "false"; 
Acquire::https::Proxy "false";  
Acquire::ftp::Proxy "false";     
EOF

### https://gist.github.com/trastle/5722089
### https://askubuntu.com/questions/679233/failed-to-fetch-hash-sum-mismatch-tried-rm-apt-list-but-didnt-work
touch /etc/apt/apt.conf.d/99fixbadproxy
cat >  /etc/apt/apt.conf.d/99fixbadproxy <<EOF
Acquire::http::Pipeline-Depth "0";    
Acquire::http::Pipeline-Depth "0";    
Acquire::http::No-Cache=True;        
Acquire::https::Pipeline-Depth "0";  
Acquire::https::No-Cache=True;       
Acquire::ftp::Pipeline-Depth "0";     
Acquire::ftp::No-Cache=True;          
Acquire::BrokenProxy=true;           
EOF

## exit sudo su -
exit


sudo apt-get update -y && sudo apt-get upgrade -y && sleep 5  



### Execute seprately from apt get update
### https://wiki.openstack.org/wiki/Python3
sudo -H apt-get install python3-dev -y && sudo -H apt-get install python3-pip -y && sudo -H pip3 install --upgrade pip && sudo -H python3 -m pip install python-memcached
## https://askubuntu.com/questions/712339/how-to-upgrade-pip-to-latest
## https://stackoverflow.com/questions/38613316/how-to-upgrade-pip3
sudo -H pip3 install --upgrade pip && sleep 10 && echo endSleep

## 20200303-01 - NS - May need to install django python module. Not so syre why they just didn't install it.
##                    https://docs.djangoproject.com/en/3.0/topics/install/
sudo -H python -m pip install Django && sleep 10 && echo endSleep


sudo useradd -s /bin/bash -d /opt/stack -m stack
echo "stack ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/stack

sudo su - stack

## https://askubuntu.com/questions/590027/how-to-set-python-3-as-default-interpreter-in-ubuntu-14-04
## Must execute in new user environment - each time you sudo su -
### alias python=/usr/bin/python3.6

echo [Time Stamp:]
## https://stackoverflow.com/questions/1401482/yyyy-mm-dd-format-date-in-shell-script
printf '%(%Y-%m-%d %H-%M-%S)T\n' -1 
echo [Time Stamp:]

### git clone https://github.com/openstack-dev/devstack.git -b stable/pike devstack/
### Use latest stable as of 20200113 for latest Phyton versions
##git clone https://github.com/openstack-dev/devstack.git -b stable/train devstack/
### https://releases.openstack.org/
## git clone https://github.com/openstack-dev/devstack.git -b stable/stein devstack/
## git clone https://github.com/openstack-dev/devstack.git -b stable/rocky devstack/
## git clone https://github.com/openstack-dev/devstack.git -b stable/queens devstack/
## git clone https://github.com/openstack-dev/devstack.git -b stable/pike devstack/

git clone https://git.openstack.org/openstack-dev/devstack -b stable/rocky

## https://www.techrepublic.com/article/how-to-install-openstack-on-a-single-ubuntu-server-virtual-machine/
## Testing to see if broken pipe will occur.
## Edit: 20200114-01 - Broken pipe error fixed. Not so sure why site01 script didn't have this error.
sudo chown -R stack:stack devstack/

cd devstack/

########    CAT local.conf   ############    CAT local.conf   ##########    CAT local.conf   #####

cat >  local.conf <<EOF
[[local|localrc]]

## https://wiki.openstack.org/wiki/Python3
## 20200302 - NS - using Ubuntu 16 - sdo not attempt with Pyton3 as yet
### 20200303-01 - NS - Add back as some packages need python3 explicitly installed.
USE_PYTHON3=True
## 20200303-02 - NS - TODO for heat.
## https://opendev.org/openstack/devstack/src/branch/stable/pike/stackrc?lang=zh-TW
# Control whether Python 3 is enabled for specific services by the
# base name of the directory from which they are installed. See
# enable_python3_package to edit this variable and use_python3_for to
# test membership.
## export ENABLED_PYTHON3_PACKAGES="nova,glance,cinder,uwsgi,python-openstackclient"
ENABLED_PYTHON3_PACKAGES=horizon
## https://docs.openstack.org/devstack/latest/configuration.html#use-python3
PIP_UPGRADE=True

## 20200303-01 - NS - Getting Syntax error for tis part - remove.
##   """+"="*78, file=sys.stdout)
##                      ^
##    SyntaxError: invalid syntax
## 20200303-02 - NS - Add back as the errror was replated to python3. 
## https://files.pythonhosted.org/packages/f0/bb/f41cbc8eaa807afb9d44418f092aa3e4acf0e4f42b439c49824348f1f45c/dnspython3-1.15.0.zip
INSTALL_TEMPEST=True


ADMIN_PASSWORD=secret
DATABASE_PASSWORD=\$ADMIN_PASSWORD
RABBIT_PASSWORD=\$ADMIN_PASSWORD
SERVICE_PASSWORD=\$ADMIN_PASSWORD
## Code below was from site01 script without the preceding slashes.
## DATABASE_PASSWORD=$ADMIN_PASSWORD
## RABBIT_PASSWORD=$ADMIN_PASSWORD
## SERVICE_PASSWORD=$ADMIN_PASSWORD
## EDIT: Comment out this comment [Use local host instead. Might get a broken pipe error --- Didn't solve the issue]
## Use localhost IP for when conencting to compute nodes via 6080.
## HOST_IP=10.0.2.15
HOST_IP=127.0.0.1
## EDIT: Comment out this comment [Try not to reclone, might get a proken pipe error --- Didn't solve the issue]
RECLONE=yes
## GIT_BASE was from another setup manual. Remove as required.
GIT_BASE=http://git.openstack.org
## https://ask.openstack.org/en/question/11017/how-do-you-mount-an-additional-disk-for-cinder/

## https://gist.github.com/amotoki/b5ca4affd768177ed911
HORIZON_BRANCH=stable/rocky
KEYSTONE_BRANCH=stable/rocky
NOVA_BRANCH=stable/rocky
NEUTRON_BRANCH=stable/rocky
GLANCE_BRANCH=stable/rocky
CINDER_BRANCH=stable/rocky
### HEAT_BRANCH=stable/rocky


## https://docs.openstack.org/horizon/pike/contributor/ref/local_conf.html
# Enable Heat
### enable_plugin heat https://git.openstack.org/openstack/heat

## 20200302-01 - NS - https://docs.openstack.org/devstack/ocata/configuration.html#swift
### enable_service heat h-api h-api-cfn h-api-cw h-eng

# Enable Neutron - installtion parameter  duplicated below
### enable_plugin neutron https://git.openstack.org/openstack/neutron
# Enable the Trunks extension for Neutron
enable_service q-trunk
# Enable the QoS extension for Neutron
## 20200302 - NS - duplicated entry below
## enable_service q-qos


enable_service ceilometer-acompute ceilometer-acentral ceilometer-collector ceilometer-api
## https://docs.openstack.org/horizon/pike/contributor/ref/local_conf.html
## Enable Swift (Object Store) without replication
enable_service s-proxy s-object s-container s-account

## https://ask.openstack.org/en/question/57376/installing-devstack-unable-to-connect-to-gitopenstackorg/
## 20200303-01 - NS - django error with sahara dashboard
## 20200303-01 - NS - May need to install django python module. Not so syre why they just didn't install it.
##                    https://docs.djangoproject.com/en/3.0/topics/install/
 enable_plugin sahara https://git.openstack.org/openstack/sahara stable/rocky

## 20200301 - NS - Removed due to dhango ImportError: No module named django.core.management
## 20200302 - NS - added back, could be Python3 issue.
## 20200303-01 - NS - May need to install django python module. Not so syre why they just didn't install it.
##                    https://docs.djangoproject.com/en/3.0/topics/install/
enable_plugin trove https://git.openstack.org/openstack/trove stable/rocky

## 20200303-01 - NS - django error with sahara dashboard
## 20200303-01 - NS - May need to install django python module. Not so syre why they just didn't install it.
##                    https://docs.djangoproject.com/en/3.0/topics/install/
enable_plugin sahara-dashboard https://git.openstack.org/openstack/sahara-dashboard stable/rocky

## 20200301 - NS - Removed due to dhango ImportError: No module named django.core.management
## related to django
## 20200303-01 - NS - May need to install django python module. Not so syre why they just didn't install it.
##                    https://docs.djangoproject.com/en/3.0/topics/install/
## 20200302 - NS - added back, could be Python3 issue.
 enable_plugin trove-dashboard https://git.openstack.org/openstack/trove-dashboard stable/rocky

enable_plugin neutron https://git.openstack.org/openstack/neutron stable/rocky
#enable_plugin neutron-lbaas https://git.openstack.org/openstack/neutron-lbaas
#NEUTRON_LBAAS_SERVICE_PROVIDERV2="LOADBALANCERV2:Haproxy:neutron_lbaas.drivers.haproxy.plugin_driver.HaproxyOnHostPluginDriver:default"
#NEUTRON_LBAAS_SERVICE_PROVIDERV2="LOADBALANCERV2:Octavia:neutron_lbaas.drivers.octavia.driver.OctaviaDriver:default"
#enable_plugin neutron-lbaas-dashboard https://git.openstack.org/openstack/neutron-lbaas-dashboard
#enable_plugin neutron-lbaas-dashboard file:///home/ubuntu/work/neutron-lbaas-dashboard review/akihiro_motoki/devstack-plugin
enable_plugin neutron-vpnaas https://git.openstack.org/openstack/neutron-vpnaas stable/rocky

enable_plugin magnum https://git.openstack.org/openstack/magnum master
enable_plugin magnum-ui https://git.openstack.org/openstack/magnum-ui master

# designate-dashboard is installed by designate devstack plugin
## 20200303-01 - NS - Seems to be error with python3 and the install. Syntax error.
## enable_plugin designate https://git.openstack.org/openstack/designate stable/rocky
## DESIGNATE_BACKEND_DRIVER=fake
## DESIGNATE_BRANCH=stable/rocky
## DESIGNATEDASHBOARD_BRANCH=stable/rocky

# murano-dashboard is installed by murano devstack plugin
enable_plugin murano https://git.openstack.org/openstack/murano stable/rocky
MURANO_BRANCH=stable/rocky
MURANO_DASHBOARD_BRANCH=stable/rocky
enable_service murano-cfapi
MURANO_APPS=io.murano.apps.apache.Tomcat,io.murano.apps.Guacamole

# Some more processing for translation check site
enable_plugin horizon-i18n-tools https://github.com/amotoki/horizon-i18n-tools.git

## 20200302-10 - NS - https://docs.openstack.org/horizon/latest/install/plugin-registry.html
## TODO


## 20200301 - NS - Removed due to dhango ImportError: No module named django.core.management
## LIBS_FROM_GIT=django_openstack_auth
HORIZONAUTH_BRANCH=stable/rocky

## 20200229-01 - NS - removed becasue of keystone launch error
## 20200302-02 - NS - See lines below...
## KEYSTONE_TOKEN_FORMAT=UUID

## 20200302-02 - NS - See lines below...
## https://wiki.openstack.org/wiki/Swift/DevstackSetupForKeystoneV3
# Select Keystone's token format
# Choose from 'UUID', 'PKI', or 'PKIZ'
# INSERT THIS LINE...
## KEYSTONE_TOKEN_FORMAT=${KEYSTONE_TOKEN_FORMAT:-UUID}
## KEYSTONE_TOKEN_FORMAT=$(echo ${KEYSTONE_TOKEN_FORMAT} | tr '[:upper:]' '[:lower:]')
## End result - 20200303-01 - NS - See lines below:

## 20200303-01 - NS - https://bugs.launchpad.net/kolla-ansible/+bug/1757520
##                    https://bugs.launchpad.net/keystone/+bug/1753584
##                          Unable to find 'uuid' driver in 'keystone.token.provider'.
##                          Remove uuid as keystone_token_provider
##                          Keystone removed uuid token provider in Rocky
##                          This patch change the default value and fix comments for the option.
##                          Change-Id: Idca0004852b688fcdd34ef47c38dec6b8bf05f86
##                          Closes-Bug: #1757520

## KEYSTONE_TOKEN_FORMAT=UUID
 
 

## 20200302 - NS - may not be keystone but python3 related.
PRIVATE_NETWORK_NAME=net1
PUBLIC_NETWORK_NAME=ext_net


## 20200302 - 01 - NS - https://ask.openstack.org/en/question/27081/enable-swift-in-openstack-devstack/
## ENABLED_SERVICES+=,s-proxy,s-object,s-container,s-account ????

#-----------------------------
# Neutron
#-----------------------------
disable_service n-net
enable_service neutron q-svc q-agt
enable_service q-dhcp
enable_service q-l3
enable_service q-meta
#enable_service q-lbaas
enable_service q-lbaasv2
enable_service q-fwaas
enable_service q-vpn
enable_service q-qos
enable_service q-flavors
# murano devstack enables q-metering by default
disable_service q-metering

Q_PLUGIN=ml2
#Q_USE_DEBUG_COMMAND=True
if [ "$Q_PLUGIN" = "ml2" ]; then
  #Q_ML2_TENANT_NETWORK_TYPE=gre
  Q_ML2_TENANT_NETWORK_TYPE=vxlan
  :
fi

### 20200302-10 NS - https://docs.openstack.org/devstack/train/guides/neutron.html
## TODO


## 20200302 - NS - https://wiki.openstack.org/wiki/Swift/DevstackSetupForKeystoneV3
## https://stackoverflow.com/questions/21270426/enabled-services-in-devstack
enable_service swift

## https://github.com/openstack/devstack/blob/master/samples/local.conf
SWIFT_HASH=66a3d6b56c1f479c8b4e70ab5c2000f5

## https://docs.openstack.org/horizon/pike/contributor/ref/local_conf.html
SWIFT_REPLICAS=3
SWIFT_DATA_DIR=$DEST/data/swift



## https://wiki.openstack.org/wiki/Swift/DevstackSetupForKeystoneV3
## Configure Keystone
iniset ${SWIFT_CONFIG_PROXY_SERVER} filter:authtoken auth_version v3.0


## https://www.rushiagr.com/blog/2014/01/16/playing-around-with-cinder-backend/
CINDER_MULTI_LVM_BACKEND=True

## https://stackoverflow.com/questions/20390267/installing-openstack-errors
## https://ask.openstack.org/en/question/57376/installing-devstack-unable-to-connect-to-gitopenstackorg/
### Didn't work - need to change git:// to https://
### GIT_BASE=${GIT_BASE:-https://git.openstack.org}

## 20200302-01 - NS - https://docs.openstack.org/horizon/pike/contributor/ref/local_conf.html
[[post-config|$GLANCE_API_CONF]]
[DEFAULT]
default_store=file


## End of File
EOF

###############    EOF   #########################    EOF   ######################    EOF   ####


./stack.sh


## 20200301 - Run tests after install completes  succesfully.
## ./run_tests.sh

### https://github.com/openstack/devstack/blob/master/samples/local.sh
### https://raw.githubusercontent.com/openstack/devstack/master/samples/local.sh
wget https://raw.githubusercontent.com/openstack/devstack/master/samples/local.sh
chmod 777 ./local.sh

### 20200301 - NS - error executing
## stack@dcit-ubuntu18:~/devstack$ ./local.sh
## WARNING: setting legacy OS_TENANT_NAME to support cli tools.
## ./local.sh



echo [Time Stamp:]
## https://stackoverflow.com/questions/1401482/yyyy-mm-dd-format-date-in-shell-script
printf '%(%Y-%m-%d %H-%M-%S)T\n' -1 
echo [Time Stamp:]






## Cinder Volume Config [Install] - 20200228-01 - NS

## Install ruby for Chef-client
## https://docs.oracle.com/cd/E78305_01/E78304/html/openstack-envars.html

## $ export OS_AUTH_URL=http://10.0.0.10:5000/v3
export OS_AUTH_URL=http://127.0.0.1/identity
export OS_TENANT_NAME=admin
export OS_PROJECT_NAME=admin
export OS_USERNAME=admin
export OS_PASSWORD=secret
export OS_PROJECT_DOMAIN_ID=default
export OS_PROJECT_DOMAIN_NAME=Default
export OS_USER_DOMAIN_ID=default
export OS_USER_DOMAIN_NAME=Default




## https://www.tecmint.com/add-new-disks-using-lvm-to-linux/
## http://www.devops-engineer.com/how-to-create-linux-lvm-step-by-step/
## https://www.certdepot.net/sys-manage-physical-volumes-volume-groups-and-logical-volumes/
pvcreate /dev/sdb1
pvcreate /dev/sdc1
pvscan

## https://fatmin.com/2015/04/28/openstack-cinder-add-additional-backend-volumes/
vgscan | grep cinder
vgcreate cinder-volumes-1 /dev/sdb1 /dev/sdc1
## vgcreate cinder-volumes-2-c /dev/sdc1
vgscan | grep cinder

## /etc/cinder/cinder.conf
### [lvm1]
### volume_group=cinder-volumes-1
### volume_driver=cinder.volume.drivers.lvm.LVMISCSIDriver
### volume_backend_name=lvm1

### [lvm2]
### volume_group=cinder-volumes-2-c
### volume_driver=cinder.volume.drivers.lvm.LVMISCSIDriver
### volume_backend_name=lvm2

cat >>  /etc/cinder/cinder.conf <<EOF

[lvm1]
volume_group=cinder-volumes-1
volume_driver=cinder.volume.drivers.lvm.LVMISCSIDriver
volume_backend_name=lvm1
## END
EOF




### service cinder-volume restart

## cinder type-create lvm1
## cinder type-create lvm2

## cinder type-key lvm1 set volume_backend_name=cinder-volumes-1-b
## cinder type-key lvm2 set volume_backend_name=cinder-volumes-2-c

## https://blog.csdn.net/weixin_30919235/article/details/99755648
## vgs
## cinder type-list
## cinder extra-specs-list

## cinder create --volume-type lvm1 --display-name test_multi_backend 1

##  cinder-manage service list
 
 


## These below  don't help:
## https://ask.openstack.org/en/question/27569/admin-openrcsh/
### https://docs.openstack.org/mitaka/install-guide-obs/keystone-openrc.html

### cd /opt/stack/devstack
### source /opt/stack/devstack/openrc

### hostname --fqdn
### knife node show DCIT-ubuntu

## Little help: https://docs.chef.io/knife/
## Some help: https://www.rubydoc.info/gems/knife-openstack/0.6.2

## https://www.amazon.com/Mastering-OpenStack-Second-Design-infrastructures/dp/1786463989
### apt install chef -y
## URL: http://127.0.0.1:4000


### wget https://packages.chef.io/files/stable/chefworkstation/0.14/ubuntu/18.04/chefworkstation_0.14.16-1_amd64.deb
## wget https://packages.chef.io/files/stable/chef-workstation/0.16.31/ubuntu/16.04/chef-workstation_0.16.31-1_amd64.deb
## dpkg -i chef-workstation_0.16.31-1_amd64.deb
## chef -v

### https://docs.chef.io/workstation_setup/


## which ruby
## echo 'eval "$(chef shell-init bash)"' >> ~/.bash_profile
## which ruby

## echo 'export PATH="/opt/chef-workstation/embedded/bin:$PATH"' >> ~/.configuration_file && source ~/.configuration_file
## echo 'export PATH="/opt/chef-workstation/embedded/bin:$PATH"' >> ~/.bash_profile && source ~/.bash_profile

## chef generate repo chef-repo
## ## mkdir -p ~/chef-repo/.chef
## echo '.chef' >> ~/chef-repo/.gitignore

## chef-server-ctl org-create "DCIT-ubuntu-org" "DCIT-ubuntu-org-fullname" -f /tmp/chef.key


## From this link: https://www.rubydoc.info/gems/knife-openstack/0.6.2
## gem install knife-openstack
### knife configure -initial
## https://127.0.0.1:443



echo [Time Stamp:]
## https://stackoverflow.com/questions/1401482/yyyy-mm-dd-format-date-in-shell-script
printf '%(%Y-%m-%d %H-%M-%S)T\n' -1 
echo [Time Stamp



