#!/bin/bash

## Based on https://www.bogotobogo.com/DevOps/OpenStack-Install-On-Ubuntu-16-Server.php
## It is essential to create a stack user with sudo access or else you will get a HOTS_IP error:
## https://stackoverflow.com/questions/46192965/error-in-running-stack-sh-in-devstack

## Revision History:
## 20200113-01 - NS - First version
## 20200114-01 - NS - Second revision, merging from other setup blogs.


sudo adduser stack
echo "stack ALL=(ALL) NOPASSWD: ALL" | sudo tee -a /etc/sudoers
su stack
cd
pwd

## Original URL for this script
## git clone https://git.openstack.org/openstack-dev/devstack

## From other blog (script 2)
## git clone https://git.openstack.org/openstack-dev/devstack -b stable/stein devstack/
## git clone https://git.openstack.org/openstack-dev/devstack -b stable/rocky devstack/
## git clone https://git.openstack.org/openstack-dev/devstack -b stable/queens devstack/
## git clone https://git.openstack.org/openstack-dev/devstack -b stable/pike devstack/
git clone https://git.openstack.org/openstack-dev/devstack -b stable/train

cd devstack

cd devstack/

cat >  local.conf <<EOF
[[local|localrc]]
HOST_IP=127.0.0.1
GIT_BASE=http://git.openstack.org
ADMIN_PASSWORD=secret
## DATABASE_PASSWORD=$ADMIN_PASSWORD
## RABBIT_PASSWORD=$ADMIN_PASSWORD
## SERVICE_PASSWORD=$ADMIN_PASSWORD
## Seems to need \ infront of password variable.
DATABASE_PASSWORD=\$ADMIN_PASSWORD
RABBIT_PASSWORD=\$ADMIN_PASSWORD
SERVICE_PASSWORD=\$ADMIN_PASSWORD
EOF

./stack.sh



