#!/bin/bash

sudo apt update -y

timestamp=$(date '+%d%m%Y-%H%M%S')
myname="ankesh"
s3_bucket="upgrad-ankesh"

apacheInstallStatus=$(dpkg -s apache2 | grep Status | awk '{print $NF}')
if [ "$apacheInstallStatus" != "installed" ]
then
        echo "Apache2 not installed, Instaling it."
        sudo apt install apache2 -y
else
        echo "Apache2 is already installed."
fi

apacheiServiceStatus=$(service --status-all | grep apache2 | awk '{print $2}')
if [ "$apacheiServiceStatus" != "+" ]
then
        echo "Apache2 is not up, Starting it."
        sudo systemctl restart apache2
else
        echo "Apache2 is already up."
fi

apacheEnableStatus=$(service apache2 status | grep enabled | awk '{print $4}')
if [ "$apacheEnableStatus" != "enabled;" ]
then
        echo "Apache2 is not enabled, Enabling it."
        sudo systemctl enable apache2
else
        echo "Apache2 is already enabled."
fi

cd /var/log/apache2/ && tar -cvf /tmp/${myname}-httpd-logs-${timestamp}.tar *.log

aws s3 \
cp /tmp/${myname}-httpd-logs-${timestamp}.tar \
s3://${s3_bucket}/${myname}-httpd-logs-${timestamp}.tar 
