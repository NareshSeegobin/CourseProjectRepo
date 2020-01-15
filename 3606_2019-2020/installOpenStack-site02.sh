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
HOST_IP=10.0.2.15
## HOST_IP=127.0.0.1
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









