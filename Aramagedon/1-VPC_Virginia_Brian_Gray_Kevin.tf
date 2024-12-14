# Create the VPC and subnets in virginia (us-east-1)
provider "aws" {
    alias = "virginia"
  region = "us-east-1"
}
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}
resource "aws_vpc" "virginia" {
  cidr_block = "10.125.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  provider = aws.virginia
  tags = {
    Name = "Virginia_VPC"
  }
}

resource "aws_subnet" "virginia_public_subnet_1" {
  vpc_id                  = aws_vpc.virginia.id
  cidr_block              = "10.125.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  provider = aws.virginia
}

resource "aws_subnet" "virginia_public_subnet_2" {
  vpc_id                  = aws_vpc.virginia.id
  cidr_block              = "10.125.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  provider = aws.virginia
}

resource "aws_subnet" "virginia_private_subnet_1" {
  vpc_id                  = aws_vpc.virginia.id
  cidr_block              = "10.125.11.0/24"
  availability_zone       = "us-east-1a"
  provider = aws.virginia
}

resource "aws_subnet" "virginia_private_subnet_2" {
  vpc_id                  = aws_vpc.virginia.id
  cidr_block              = "10.125.12.0/24"
  availability_zone       = "us-east-1b"
  provider = aws.virginia
}

# Internet Gateway
resource "aws_internet_gateway" "virginia_igw" {
  vpc_id = aws_vpc.virginia.id

    tags = {
      Name = "virginia_igw"
    }
}

# Route Table Associate with Internet Gateway
resource "aws_route_table_association" "virginia_public_subnet_1_association" {
  route_table_id = aws_route_table.virginia_public_subnet_1_association.id
  
  subnet_id = aws_subnet.virginia_public_subnet_1.id  
  provider = aws.virginia
}

# Elastic IP for NAT Gateway
resource "aws_eip" "virginia_eip" {
  domain  = "vpc"
  vpc = true
  provider = aws.virginia
}

# NAT
resource "aws_nat_gateway" "virginia_nat" {
  allocation_id = aws_eip.virginia_eip.id
  subnet_id     = aws_subnet.virginia_public_subnet_1.id
  provider = aws.virginia
  tags = {
    Name = "virginia_nat"
  }
  depends_on = [aws_internet_gateway.virginia_igw]
}

resource "aws_default_route_table" "Virginia_Hub" {
  default_route_table_id = aws_vpc.virginia.default_route_table_id

  tags = {
    Name = "Virginia_Hub"
  }
}
resource "aws_route" "Virginia_to_Tokyo" {
  route_table_id = aws_default_route_table.Virginia_Hub.id
  destination_cidr_block = "10.125.0.0/16"
  gateway_id = aws_internet_gateway.virginia_igw.id
  depends_on = [ aws_vpc.virginia ]
}
// RT for private Subnet
resource "aws_route_table" "virginia_route_table_private_subnet" {
  vpc_id   = aws_vpc.virginia.id
  provider = aws.virginia
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.virginia_nat.id
  }
  route {
    cidr_block         = "10.120.0.0/16" # CIDR of the Tokyo VP
    #transit_gateway_id = aws_ec2_transit_gateway.local_virginia.id
  }
  tags = {
    Name = "Route Table for Private Subnet",
  }
}

# Route for Private Association
resource "aws_route_table_association" "virginia_private_subnet_1_association" {
  subnet_id      = aws_subnet.virginia_private_subnet_1.id
  route_table_id = aws_route_table.virginia_route_table_private_subnet.id
  provider = aws.virginia
}

# Security Groups
resource "aws_security_group" "virginia_alb_sg" {
  name        = "virginia_alb_sg"
  description = "Security Group for Application Load Balancer"
  vpc_id      = aws_vpc.virginia.id
  provider = aws.virginia

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
    Name = "virginia_alb_sg"
  }
}





# Create a peering connection between virginia and Tokyo
resource "aws_vpc_peering_connection" "Virginia_to_Tokyo" {
  vpc_id        = aws_vpc.virginia.id
  peer_vpc_id   = aws_vpc.Tokyo.id
  auto_accept   = true
  peer_region   = "ap-northeast-1"

  tags = {
    Name = "virginia to Tokyo Peering"
  }
}
