#!/bin/bash
apt-get update
apt-get install -y apache2
INSTANCE_ID=$(curl http://169.254.169.254/latest/meta-data/instance-id)
INSTANCE_IP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
echo "<html><body><h1>Hello, World</h1><p>Instance ID: $INSTANCE_ID</p><p>Instance IP: $INSTANCE_IP</p></body></html>" > /var/www/html/index.html
systemctl start apache2
systemctl enable apache2