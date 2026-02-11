#!/bin/bash

# If changes are made, rebuild using `terraform apply -replace="aws_instance.app_server"`

sudo apt update -y
sudo apt install -y nginx

rm -f /var/www/html/index.nginx-debian.html

systemctl enable nginx
systemctl start nginx

# Fetch instance metadata
TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" \
-H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" \
-s http://169.254.169.254/latest/meta-data/instance-id)

AZ=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" \
-s http://169.254.169.254/latest/meta-data/placement/availability-zone)

PUBLIC_IP=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" \
-s http://169.254.169.254/latest/meta-data/public-ipv4)
# Write HTML file
cat <<EOF> /var/www/html/index.html
    <!DOCTYPE html>
    <html>

    <head>
        <meta charset="UTF-8">
        <title>Terraform AWS Demo</title>
        <style>
            body {
                margin: 0;
                font-family: system-ui, -apple-system, BlinkMacSystemFont, sans-serif;
                background: linear-gradient(135deg, #1e293b, #0f172a);
                color: white;
                display: flex;
                align-items: center;
                justify-content: center;
                height: 100vh;
            }

            .card {
                background: #1e293b;
                padding: 40px;
                border-radius: 12px;
                box-shadow: 0 10px 30px rgba(0, 0, 0, 0.4);
                text-align: center;
                max-width: 600px;
            }

            h1 {
                margin-bottom: 20px;
                font-size: 2.5rem;
            }

            p {
                opacity: 0.8;
                line-height: 1.6;
            }

            .meta {
                font-size: 0.9rem;
                margin-top: 15px;
                opacity: 0.7;
            }

            a.button {
                display: inline-block;
                margin-top: 20px;
                padding: 12px 20px;
                background: #3b82f6;
                color: white;
                text-decoration: none;
                border-radius: 8px;
                font-weight: bold;
            }

            a.button:hover {
                background: #2563eb;
            }
        </style>
    </head>

    <body>
        <div class="card">
            <h1>Terraform-Provisioned AWS Infrastructure</h1>
            <p>
                This web server was automatically deployed using Terraform,
                running on an EC2 instance inside a custom VPC.
            </p>

            <div class="meta">
                <p><strong>Instance ID:</strong> $INSTANCE_ID</p>
                <p><strong>Availability Zone:</strong> $AZ</p>
                <p><strong>Public IP:</strong> $PUBLIC_IP</p>
            </div>

            <a href="https://linkedin.com/in/kabirsghai" class="button">
                Connect on LinkedIn
            </a>
        </div>
    </body>

    </html>