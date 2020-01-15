#!/bin/bash

## Based on https://www.mirantis.com/blog/how-to-install-openstack-on-your-local-machine-using-devstack/
## It is essential to create a stack user with sudo access or else you will get a HOTS_IP error:
## https://stackoverflow.com/questions/46192965/error-in-running-stack-sh-in-devstack

## Revision History:
## 20200113-01 - NS - First version


sudo useradd -s /bin/bash -d /opt/stack -m stack
echo "stack ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/stack

sudo su - stack


### git clone https://github.com/openstack-dev/devstack.git -b stable/pike devstack/
### Use latest stable as of 20200113 for latest Phyton versions
##git clone https://github.com/openstack-dev/devstack.git -b stable/train devstack/
### https://releases.openstack.org/
## git clone https://github.com/openstack-dev/devstack.git -b stable/stein devstack/
## git clone https://github.com/openstack-dev/devstack.git -b stable/rocky devstack/
## git clone https://github.com/openstack-dev/devstack.git -b stable/queens devstack/
## git clone https://github.com/openstack-dev/devstack.git -b stable/pike devstack/

git clone https://git.openstack.org/openstack-dev/devstack -b stable/train


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
## Use local host instead. Might get a broken pipe error
## HOST_IP=10.0.2.15
HOST_IP=127.0.0.1
## Try not to reclone, might get a proken pipe error
## RECLONE=yes
## GIT_BASE was from another setup manual. Remove as required.
GIT_BASE=http://git.openstack.org
EOF

./stack.sh



