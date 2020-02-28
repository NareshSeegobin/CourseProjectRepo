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



sudo useradd -s /bin/bash -d /opt/stack -m stack
echo "stack ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/stack

sudo su - stack

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

git clone https://git.openstack.org/openstack-dev/devstack -b stable/train

## https://www.techrepublic.com/article/how-to-install-openstack-on-a-single-ubuntu-server-virtual-machine/
## Testing to see if broken pipe will occur.
## Edit: 20200114-01 - Broken pipe error fixed. Not so sure why site01 script didn't have this error.
sudo chown -R stack:stack devstack/

cd devstack/

cat >  local.conf <<EOF
[[local|localrc]]
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
EOF

./stack.sh

echo [Time Stamp:]
## https://stackoverflow.com/questions/1401482/yyyy-mm-dd-format-date-in-shell-script
printf '%(%Y-%m-%d %H-%M-%S)T\n' -1 
echo [Time Stamp:]

## Cinder Install - 20200228-01 - NS

## Install ruby for Chef-client
apt install ruby -y


## https://discoposse.com/2013/02/26/openstack-lab-on-vmware-workstation-adding-cinder-volume-features/

## Install chef SErver and Client first
## https://docs.chef.io/install_workstation/
## https://downloads.chef.io/chef-workstation/
wget https://packages.chef.io/files/stable/chef-workstation/0.16.31/ubuntu/16.04/chef-workstation_0.16.31-1_amd64.deb
sudo dpkg -i chef-workstation_0.16.31-1_amd64.deb
chef -v

## https://docs.openstack.org/project-deploy-guide/openstack-chef/latest/deploy.html 
git clone https://opendev.org/openstack/openstack-chef
cd openstack-chef
mkdir -p /etc/chef && cp .chef/encrypted_data_bag_secret /etc/chef/openstack_data_bag_secret
chef-client -z -E allinone -r 'role[allinone]'




sudo su -

## Need to go to the location of the local.conf file
## It should have been created when openstack was being installed
## e.g. 
## cd devstack/
## cat >  local.conf <<EOF


pvcreate /dev/sdb
pvcreate /dev/sdc
vgcreate cinder-volumes /dev/sdb
vgcreate cinder-volumes /dev/sdc

service cinder-volume restart


## These below  don't help:
## https://ask.openstack.org/en/question/27569/admin-openrcsh/
## https://docs.openstack.org/mitaka/install-guide-obs/keystone-openrc.html


cd /opt/stack/devstack
source openrc

hostname --fqdn
knife node show DCIT-ubuntu

## Little help: https://docs.chef.io/knife/
## Some help: https://www.rubydoc.info/gems/knife-openstack/0.6.2

## https://www.amazon.com/Mastering-OpenStack-Second-Design-infrastructures/dp/1786463989
apt install chef -y
## URL: http://127.0.0.1:4000

## From this link: https://www.rubydoc.info/gems/knife-openstack/0.6.2
## gem install knife-openstack
knife configure -initial
## https://127.0.0.1:443




echo [Time Stamp:]
## https://stackoverflow.com/questions/1401482/yyyy-mm-dd-format-date-in-shell-script
printf '%(%Y-%m-%d %H-%M-%S)T\n' -1 
echo [Time Stamp






