##############################
# VPC
##############################
resource "aws_vpc" "trend_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "trend-vpc"
  }
}

##############################
# Subnet
##############################
resource "aws_subnet" "trend_subnet" {
  vpc_id                  = aws_vpc.trend_vpc.id
  cidr_block              = var.subnet_cidr
  map_public_ip_on_launch = true

  tags = {
    Name = "trend-subnet"
  }
}

##############################
# Internet Gateway
##############################
resource "aws_internet_gateway" "trend_igw" {
  vpc_id = aws_vpc.trend_vpc.id

  tags = {
    Name = "trend-igw"
  }
}

##############################
# Route Table
##############################
resource "aws_route_table" "trend_rt" {
  vpc_id = aws_vpc.trend_vpc.id
}

resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.trend_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.trend_igw.id
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.trend_subnet.id
  route_table_id = aws_route_table.trend_rt.id
}

##############################
# Security Group
##############################
resource "aws_security_group" "trend_sg" {
  name        = "trend-sg"
  description = "Allow SSH, HTTP, Jenkins"
  vpc_id      = aws_vpc.trend_vpc.id

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

  tags = {
    Name = "trend-sg"
  }
}

##############################
# EC2 Instance with Jenkins + Docker
##############################
resource "aws_instance" "jenkins_server" {
  ami                         = "ami-07f07a6e1060cd2a8" # Ubuntu 22.04 LTS in ap-south-1
  instance_type               = var.instance_type
  key_name                    = var.key_name
  subnet_id                   = aws_subnet.trend_subnet.id
  vpc_security_group_ids      = [aws_security_group.trend_sg.id]
  associate_public_ip_address = true

  user_data = <<-EOF
#!/bin/bash
# Update system
apt-get update -y
apt-get upgrade -y

# Install Java (Jenkins dependency)
apt-get install -y openjdk-21-jre

# Install Jenkins
install -m 0755 -d /etc/apt/keyrings
wget -O /etc/apt/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" > /etc/apt/sources.list.d/jenkins.list
apt-get update -y
apt-get install -y jenkins

# Enable and start Jenkins
systemctl enable jenkins
systemctl start jenkins

# Install Docker
apt-get install -y ca-certificates curl gnupg lsb-release
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list
apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Add Jenkins and ubuntu users to docker group
usermod -aG docker ubuntu
usermod -aG docker jenkins

# Restart Jenkins to apply changes
systemctl restart jenkins
EOF

  tags = {
    Name = "jenkins-server-ubuntu"
  }
}
