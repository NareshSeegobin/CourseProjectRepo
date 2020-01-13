#!/bin/bash

## Based on https://www.bogotobogo.com/DevOps/OpenStack-Install-On-Ubuntu-16-Server.php
## It is essential to create a stack user with sudo access or else you will get a HOTS_IP error:
## https://stackoverflow.com/questions/46192965/error-in-running-stack-sh-in-devstack

## Revision History:
## 20200113-01 - NS - First version



sudo adduser stack
echo "stack ALL=(ALL) NOPASSWD: ALL" |sudo tee -a /etc/sudoers
su stack
cd
pwd

git clone https://git.openstack.org/openstack-dev/devstack
cd devstack

cd devstack/

cat >  local.conf <<EOF
[[local|localrc]]
HOST_IP=127.0.0.1
GIT_BASE=http://git.openstack.org
ADMIN_PASSWORD=secret
DATABASE_PASSWORD=$ADMIN_PASSWORD
RABBIT_PASSWORD=$ADMIN_PASSWORD
SERVICE_PASSWORD=$ADMIN_PASSWORD
EOF

./stack.sh

