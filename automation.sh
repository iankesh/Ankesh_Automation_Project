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
        echo "Apache2 is not up, Starting and Enabling it."
        sudo systemctl restart apache2
        sudo systemctl enable apache2
else
        echo "Apache2 is already up."
fi


if [ ! -f /var/www/html/inventory.html ]
then
    echo "File inventory.html does not exist."
    touch /var/www/html/inventory.html
    echo -e "Log Type\tTime Created\tType\tSize" > /var/www/html/inventory.html
else
    echo "File inventory.html found."
fi

cd /var/log/apache2/ && tar -cvf /tmp/${myname}-httpd-logs-${timestamp}.tar *.log

aws s3 \
cp /tmp/${myname}-httpd-logs-${timestamp}.tar \
s3://${s3_bucket}/${myname}-httpd-logs-${timestamp}.tar


tarLogType="httpd-logs"
tarFileName="${myname}-httpd-logs-${timestamp}.tar"
tarFileLocation="/tmp/${tarFileName}"
tarFileSize=$(ls -lh $tarFileLocation | awk '{print  $5}')
tarFileType=$(echo ${tarFileName}| cut -d. -f2)

#echo $tarLogType
#echo $tarFileName
#echo $tarFileLocation
#echo $tarFileSize
#echo $tarFileType

echo -e "$tarLogType\t$timestamp\t$tarFileType\t$tarFileSize" >> /var/www/html/inventory.html
cat /var/www/html/inventory.html


if [ ! -f /etc/cron.d/automation ]
then
        echo "Crontab automation is not set. Setting it up"
        echo "0 8 * * * root /root/Automation_Project/automation.sh" > /etc/cron.d/automation
else
        echo "Crontab is already set."
fi
