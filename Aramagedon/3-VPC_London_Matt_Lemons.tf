#authentication

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "eu-west-2"
}

# Create a VPC
resource "aws_vpc" "TokyoMidtownLondon" {
  cidr_block = "10.126.0.0/16"
               
tags = {
    Name    = "TokyoMidtownLondon"
    Service = "Medical Center"
    Owner   = "TokyoMidtownMedicalCenter"
    Country  = "United Kingdom/Japan"
  }
}

# Create a Public Subnet
resource "aws_subnet" "public-eu-west-2a" {
  vpc_id     = aws_vpc.TokyoMidtownLondon.id
  cidr_block = "10.126.1.0/24"
  availability_zone       = "eu-west-2a"
  map_public_ip_on_launch = true

  tags = {
    Name    = "public-eu-west-2a"
    Service = "Medical Center"
    Owner   = "TokyoMidtownMedicalCenter"
   Country  = "United Kingdom/Japan"
  }
}

# Create a Private Subnet

resource "aws_subnet" "private-eu-west-2a" {
  vpc_id     = aws_vpc.TokyoMidtownLondon.id
  cidr_block = "10.126.11.0/24"
  availability_zone       = "eu-west-2a"

  tags = {
    Name    = "private-eu-west-2a"
    Service = "Medical Center"
    Owner   = "TokyoMidtownMedicalCenter"
    Country  = "United Kingdom/Japan"
  }
}

# Create a Public Subnet

resource "aws_subnet" "public-eu-west-2b" {
  vpc_id     = aws_vpc.TokyoMidtownLondon.id
  cidr_block = "10.126.2.0/24"
  availability_zone       = "eu-west-2b"
  map_public_ip_on_launch = true

  tags = {
    Name    = "public-eu-west-2b"
    Service = "Medical Center"
    Owner   = "TokyoMidtownMedicalCenter"
    Country  = "United Kingdom/Japan"
  }
}

# Create a Private Subnet

resource "aws_subnet" "private-eu-west-2b" {
  vpc_id     = aws_vpc.TokyoMidtownLondon.id
  cidr_block = "10.126.12.0/24"
  availability_zone       = "eu-west-2b"

  tags = {
    Name    = "private-eu-west-2b"
    Service = "Medical Center"
    Owner   = "TokyoMidtownMedicalCenter"
    Country  = "United Kingdom/Japan"
  }
}
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.TokyoMidtownLondon.id

  tags = {
    Name = "TokyoMidtownLondon"
  }
}
resource "aws_instance" "TokyoMidtownLondon"  {
  ami           = "ami-0c76bd4bd302b30ec"
  instance_type = "t2.micro"
  security_groups = [aws_security_group.TokyoMidtownLondon-sg01.id]
  subnet_id = aws_subnet.private-eu-west-2b.id
  tags = {
    Name = "TMLondon"
  }
}
resource "aws_NAT" "London" {
  vpc = true

  tags = {
    Name = "London"
  }
}

resource "aws_nat_gateway" "London" {
  allocation_id = aws_eip.London.id
  subnet_id     = aws_subnet.public-eu-west-2a.id

  tags = {
    Name = "London"
  }

  depends_on = [aws_internet_gateway.igw]
}
resource "aws_route_table" "London" {
  vpc_id = aws_vpc.London.id

  route {
    cidr_block = "10.126.0.0/16"
    gateway_id = aws_internet_gateway.London.id
  }

}
  route {
    ipv4_cidr_block = "10.126.1.0/24"
    egress_only_gateway_id = aws_egress_only_internet_gateway.London.id
  
    tags = {
    Name = "London"
  }
}

resource "aws_security_group" "London-sg01" {
  name        = "TokyoMidtownLondon"
  description = "London"
  vpc_id      = aws_vpc.London.id

  ingress {
    description = "MyHomePage"
    from_port   = 80
    to_port     = 80
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
    Name    = "TokyoMidtownLondon"
    Service = "Medical Center"
    Owner   = "TokyoMidtownMedicalCenter"
    Country  = "United Kingdom/Japan"
  }

}
resource "aws_security_group" "london-sg02-LB01" {
  name        = "london-sg02-LB01"
  description = "london-sg02-LB01"
  vpc_id      = aws_vpc.london.id

  ingress {
    description = "MyHomePage"
    from_port   = 80
    to_port     = 80
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
    Name    = "london"
    Service = "Medical Center"
    Owner   = "MedicalCenter"
    Country  = "United Kingdom/Japan"
  }
}
resource "aws_launch_template" "london" {
  name_prefix   = "london"
  image_id      = "ami-1a2b3c"
  instance_type = "t2.micro"
}

resource "aws_lb_target_group" "london_tg" {
  name     = "london-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.london.id
  target_type = "instance"

  

  tags  {
    Name    = "londonTargetGroup"
    Service = "london"
    Owner   = "User"
    Project = "Web Service"
  }
}
resource "aws_LB01" "London" {
  name               ="London-LB01-tf"
  internal           = false
  load_balancer_type = "network"
  subnets            = [for subnet in aws_subnet.public : subnet.id]

  enable_deletion_protection = true

  tags = {
    Environment = "production"
  }
}
resource "aws_launch_template" "TokyoMidtownLondon" {
  name_prefix   = "TokyoMidtownLondon"
  image_id      = "ami-1a2b3c"
  instance_type = "t2.micro"
}

resource "aws_autoscaling_group" "TokyoMidtownLondon" {
  availability_zones = ["eu-west-2a"]
  desired_capacity   = 4
  max_size           = 8
  min_size           = 2

  launch_template {
    id      = aws_launch_template.TokyoMidtownLondon.id
    version = "$Latest"
  }
}