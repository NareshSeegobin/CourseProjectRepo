#!/bin/bash

####sudo su -
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
####exit


sudo apt-get update -y && sudo apt-get upgrade -y && sleep 5  



### Execute seprately from apt get update

apt-get install python -y 
sleep 5 
apt-get install python-dev -y 
sleep 5 
apt-get install python-pip -y 
python -m pip install "Django<2" 
sleep 5

### https://wiki.openstack.org/wiki/Python3
apt-get install python3-dev -y 
apt-get install python3-pip -y 
pip3 install --upgrade pip 
python3 -m pip install python-memcached 
sleep 5
## https://askubuntu.com/questions/712339/how-to-upgrade-pip-to-latest
## https://stackoverflow.com/questions/38613316/how-to-upgrade-pip3
 pip3 install --upgrade pip 
 sleep 10
 echo endSleep

## 20200303-01 - NS - May need to install django python module. Not so syre why they just didn't install it.
##                    https://docs.djangoproject.com/en/3.0/topics/install/

python3 -m pip install Django 
sleep 10 
echo endSleep

## 20200303-01 - NS - Might have to diable sahara
## ImportError: No module named openstack_dashboard.settings
## https://answers.launchpad.net/horizon/+question/239533
## https://duckduckgo.com/?q=DJANGO_SETTINGS_MODULE%3Dopenstack_dashboard.settings&t=brave&ia=web
## https://ask.openstack.org/en/question/69331/importerror-could-not-import-settings-openstack_dashboardsettings-is-it-on-syspath-is-there-an-import-error-in-the-settings-file-no-module-named/
 
 apt-get install python-pbr -y



