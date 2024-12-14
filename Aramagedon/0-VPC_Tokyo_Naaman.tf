provider "aws" {
  alias  = "tokyo"
  region = "ap-northeast-1"
}
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

resource "aws_vpc" "tokyo" {
  cidr_block = "10.120.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  provider = aws.tokyo
  tags = {
    Name = "tokyo"
  }
}

resource "aws_subnet" "tokyo_public_subnet_1" {
  vpc_id                  = aws_vpc.tokyo.id
  cidr_block              = "10.120.1.0/24"
  availability_zone       = "ap-northeast-1a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "tokyo_public_subnet_2" {
  vpc_id                  = aws_vpc.tokyo.id
  cidr_block              = "10.120.2.0/24"
  availability_zone       = "ap-northeast-1c"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "tokyo_private_subnet_1" {
  vpc_id                  = aws_vpc.tokyo.id
  cidr_block              = "10.120.11.0/24"
  availability_zone       = "ap-northeast-1a"
}

resource "aws_subnet" "tokyo_private_subnet_2" {
  vpc_id                  = aws_vpc.tokyo.id
  cidr_block              = "10.120.12.0/24"
  availability_zone       = "ap-northeast-1c"
}

# Internet Gateway
resource "aws_internet_gateway" "tokyo_igw" {
  vpc_id = aws_vpc.tokyo.id

  tags = {
    Name = "Tokyo_igw"
  }
}

# Route Table Associate with Internet Gateway
resource "aws_route_table_association" "tokyo_public_subnet_1_association" {
  route_table_id = aws_route_table.tokyo_route_table_public_subnet.id

  subnet_id = aws_subnet.tokyo_public_subnet_1.id  
  provider = aws.tokyo
}

# Elastic IP for NAT Gateway
resource "aws_eip" "tokyo_eip" {
  domain  = "vpc"
  vpc = true
  provider = aws.tokyo
}

# NAT
resource "aws_nat_gateway" "tokyo_nat" {
  allocation_id = aws_eip.tokyo_eip.id
  subnet_id     = aws_subnet.tokyo_public_subnet_1.id
  provider = aws.tokyo
  tags = {
    Name = "tokyo_nat"
  }
  depends_on = [aws_internet_gateway.tokyo_igw]
}

# Route Table
resource "aws_default_route_table" "Tokyo_Main" {
  default_route_table_id = aws_vpc.tokyo.default_route_table_id   

    tags = {
    Name = "Tokyo_Main"
  }
}
# Route
resource "aws_route" "Tokyo_Main" {
  route_table_id = aws_default_route_table.Tokyo_Main.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.tokyo_igw.id
  depends_on = [ aws_vpc.tokyo ]
}

# Route Table for private subnet
resource "aws_route_table" "tokyo_route_table_private_subnet" {
  vpc_id   = aws_vpc.tokyo.id
  provider = aws.tokyo
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.tokyo_nat.id
  }
  route {
    cidr_block         = "10.120.0.0/16" # CIDR of the Tokyo VP
    transit_gateway_id = aws_ec2_transit_gateway.tokyo-TGW01.id    #aws_ec2_transit_gateway.local_new_york.id
  }
  tags = {
    Name = "Route Table for Private Subnet",
  }
}

# Route Table for public subnet
resource "aws_route_table" "tokyo_route_table_public_subnet" {
  vpc_id   = aws_vpc.tokyo.id
  provider = aws.tokyo
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tokyo_igw.id
  }
  route {
    cidr_block         = "10.120.0.0/16" # CIDR of the Tokyo VP
    transit_gateway_id = aws_ec2_transit_gateway.tokyo-TGW01.id   #aws_ec2_transit_gateway.local_new_york.id
  }
  tags = {
    Name = "Route Table for Public Subnet",
  }
}

# Route for Private Association
resource "aws_route_table_association" "tokyo_private_subnet_1_association" {
  subnet_id      = aws_subnet.tokyo_private_subnet_1.id
  route_table_id = aws_route_table.tokyo_route_table_private_subnet.id
  provider = aws.tokyo
}
resource "aws_route_table_association" "tokyo_private_subnet_2_association" {
  subnet_id      = aws_subnet.tokyo_private_subnet_2.id
  route_table_id = aws_route_table.tokyo_route_table_private_subnet.id
  provider = aws.tokyo
}

# Route Table for Public Association
resource "aws_route_table_association" "tokyo_public_subnet_1_association" {
  subnet_id      = aws_subnet.tokyo_public_subnet_1.id
  route_table_id = aws_route_table.tokyo_route_table_public_subnet.id
  provider = aws.tokyo
}
resource "aws_route_table_association" "tokyo_public_subnet_2_association" {
  subnet_id      = aws_subnet.tokyo_public_subnet_2.id
  route_table_id = aws_route_table.tokyo_route_table_public_subnet.id
  provider = aws.tokyo
}

# Security Groups
resource "aws_security_group" "tokyo_alb_sg" {
  name        = "tokyo_alb_sg"
  description = "Security Group for Application Load Balancer"
  vpc_id      = aws_vpc.tokyo.id
  provider = aws.tokyo

  ingress {
    description      = "TCP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  tags = {
    Name = "tokyo_alb_sg"
  }
}
