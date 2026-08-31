# 1. Terraform Core Settings
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# 2. Region Configuration
provider "aws" {
  region = var.aws_region # Frankfurt region
}

#3 Virtual Network Layer(vps,internt_gateway,subnet,route_table)
resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "k8s-vpc"
  }
}
resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "k8s-subnet"
  }
}
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "k8s-igw"
  }
}
resource "aws_route_table" "example" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "k8s-route-table"
  }
}
resource "aws_route_table_association" "main_assoc" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.example.id
}

#4 Security Layer
resource "aws_security_group" "k8s_sg" {
  name        = "k8s-cluster-sg"
  description = "Security Group for Kubernetes Cluster"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "k8s-security-group"
  }
}
data "aws_ami" "ubuntu" {
  most_recent      = true
  owners           = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd*/ubuntu-*-26.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
resource "aws_instance" "k8s_master" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.main.id
  vpc_security_group_ids = [aws_security_group.k8s_sg.id]
  key_name      = var.key_name

  tags = {
    Name = "k8s-master"
  }
}
resource "aws_instance" "k8s_worker" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  count         = var.node_count
  subnet_id     = aws_subnet.main.id
  vpc_security_group_ids = [aws_security_group.k8s_sg.id]
  key_name      = var.key_name

  tags = {
    Name = "k8s-worker-${count.index + 1}"
  }
}
