provider "aws" {
  region = "eu-west-2"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter { # Finds the AMI ID for the latest Ubuntu image
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  owners = ["099720109477"] # Canonical
}

# This block creates an EC2 instance
resource "aws_instance" "app_server" {
  ami                    = data.aws_ami.ubuntu.id # Uses the previous AMI
  instance_type          = "t3.micro"             # Free tier chosen
  subnet_id              = aws_subnet.subnet.id
  vpc_security_group_ids = [aws_security_group.app_sg.id]

  key_name = "learn-terraform-key"

  tags = {
    Name = "learn-terraform" # Good tag?
  }
}

resource "aws_vpc" "vpc" {
  cidr_block       = "10.0.0.0/16" # As a reminder, the first 16 bits in this case is the network, the rest are for identifying the hosts
  instance_tenancy = "default"

  tags = {
    Name = "VPC for learn-terraform"
  }
}

resource "aws_subnet" "subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-west-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "Public Subnet for learn-terraform"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "Internet Gateway for learn-terraform"
  }
}

resource "aws_route_table" "rtable" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0" # This is basically saying "Only send traffic from devices on this CIDr range to the Internet Gateway", in this case all IPv4 addresses
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "Route Table for learn-terraform"
  }
}

resource "aws_security_group" "app_sg" {
  name        = "app-sg"
  description = "Security group for app server"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    Name = "app-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = aws_security_group.app_sg.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 22 # Standard SSH port
  to_port     = 22
  ip_protocol = "tcp"

  description = "Allow SSH from anywhere"
}

resource "aws_vpc_security_group_egress_rule" "all_outbound" {
  security_group_id = aws_security_group.app_sg.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"

  description = "Allow all outbound traffic"
}

resource "aws_route_table_association" "a" { # Link the route table to the subnet
  subnet_id      = aws_subnet.subnet.id
  route_table_id = aws_route_table.rtable.id
}

resource "aws_key_pair" "app_key" { # Creates an SSH key pair so we can connect to the instance
  key_name   = "learn-terraform-key"
  public_key = file("~/.ssh/learn-terraform.pub")
}

output "public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.app_server.public_ip
}
