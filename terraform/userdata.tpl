#!/bin/bash

# If changes are made, rebuild using `terraform apply -replace="aws_instance.app_server"`
sudo apt update -y &&
sudo apt install -y nginx

rm -f /var/www/html/index.nginx-debian.html


systemctl enable nginx
systemctl start nginx

cat <<EOF> /var/www/html/index.html
    <h1>Hello from Terraform!</h1>
    <p>This page was provisioned automatically using Terraform and EC2 user_data via AWS.</p>
    <p>Find me: <a href="https://www.linkedin.com/in/kabirsghai/">LinkedIn</a></p>