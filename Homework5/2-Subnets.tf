#These are   for  public

resource "aws_subnet" "public-us-east-1a" {     //aws_vpc.app1.id
  vpc_id                  = aws_vpc.VPC-A-Virginia-PROD.id
  cidr_block              = "10.120.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name    = "public-us-east-1a"
    Service = "VPC-A-Virginia-PROD"
    Owner   = "Naaman"
    Planet  = "Earth"
  }
}

#these are for private
resource "aws_subnet" "private-us-east-1a" {
  vpc_id            = aws_vpc.VPC-A-Virginia-PROD.id
  cidr_block        = "10.120.11.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name    = "private-us-east-1a"
    Service = "VPC-A-Virginia-PROD"
    Owner   = "Naaman"
    Planet  = "Earth"
  }
}

resource "aws_subnet" "private-us-east-1b" {
  vpc_id            = aws_vpc.VPC-B-Virginia-DEV.id
  cidr_block        = "10.121.12.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true
  tags = {
    Name    = "private-us-east-1b"
    Service = "VPC-B-Virginia-DEV"
    Owner   = "Naaman"
    Planet  = "Earth"
  }
}
resource "aws_subnet" "private-us-east-1c" {
  vpc_id            = aws_vpc.VPC-C-Virginia-TEST.id
  cidr_block        = "10.122.13.0/24"
  availability_zone = "us-east-1c"
  map_public_ip_on_launch = true
  tags = {
    Name    = "private-us-east-1c"
    Service = "VPC-C-Virginia-TEST"
    Owner   = "Naaman"
    Planet  = "Earth"
  }
}
