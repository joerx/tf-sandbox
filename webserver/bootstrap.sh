#!/bin/sh

yum -y update
yum -y install httpd
chkconfig httpd on

IPV4=`curl http://169.254.169.254/latest/meta-data/public-ipv4`
INSTANCEID=`curl http://169.254.169.254/latest/meta-data/instance-id`

aws s3 cp s3://${source_bucket_name}/wordpress-logo.png /var/www/html/ --region=${aws_region}

echo "<h1>$$INSTANCEID</h1><p>Public IP: $$IPV4</p><p><img src='wordpress-logo.png'></p>" > /var/www/html/index.html

service httpd start
