provider "aws" {
  region = "ap-south-1"
}

# -------------------------------------
# GENERATE LOCAL PRIVATE KEY
# -------------------------------------
resource "tls_private_key" "terraform_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "local_file" "private_key" {
  filename        = "${path.module}/terraform-key.pem"
  content         = tls_private_key.terraform_key.private_key_pem
  file_permission = "0400"
}

resource "aws_key_pair" "my_keypair" {
  key_name   = "terraform-key"
  public_key = tls_private_key.terraform_key.public_key_openssh
}

# -------------------------------------
# VPC
# -------------------------------------
resource "aws_vpc" "my_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = { Name = "my-vpc" }
}

# -------------------------------------
# SUBNET
# -------------------------------------
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true

  tags = { Name = "public-subnet" }
}

# -------------------------------------
# INTERNET GATEWAY
# -------------------------------------
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = { Name = "my-igw" }
}

# -------------------------------------
# ROUTE TABLE
# -------------------------------------
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = { Name = "public-rt" }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# -------------------------------------
# SECURITY GROUP
# -------------------------------------
resource "aws_security_group" "my_sg" {
  name        = "my-sg"
  description = "Allow SSH, HTTP, Jenkins"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "my-sg" }
}

# -------------------------------------
# ANSIBLE SERVER
# -------------------------------------
resource "aws_instance" "ansible_server" {
  ami           = "ami-0d176f79571d18a8f" # Amazon Linux 2
  instance_type = "t3.small"
  subnet_id     = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.my_sg.id]
  key_name      = aws_key_pair.my_keypair.key_name

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y python3
              curl -O https://bootstrap.pypa.io/get-pip.py
              python3 get-pip.py
              pip3 install ansible
              EOF

  tags = { Name = "ansible-server" }
}

# -------------------------------------
# DOCKER SERVER
# -------------------------------------
resource "aws_instance" "docker_server" {
  ami           = "ami-0d176f79571d18a8f"
  instance_type = "t3.small"
  subnet_id     = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.my_sg.id]
  key_name      = aws_key_pair.my_keypair.key_name

  tags = { Name = "docker-server" }
}
