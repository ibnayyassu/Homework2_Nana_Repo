# this  makes  vpc.id which is aws_vpc.app1.id
resource "aws_vpc" "VPC-A-Virginia-PROD" {      //"aws_vpc"
  cidr_block = "10.120.0.0/16"    // VPC-A-Virginia-PROD

  tags = {
    Name = "VPC-A-Virginia-PROD"
    Service = "PROD"
    Owner = "Naaman"
    Planet = "Earth"
  }
}

resource "aws_vpc" "VPC-B-Virginia-DEV" {
  cidr_block = "10.121.0.0/16"      // VPC-A-Virginia-DEV

  tags = {
    Name = "VPC-B-Virginia-DEV"
    Service = "DEV"
    Owner = "Naaman"
    Planet = "Earth"
  }
}

resource "aws_vpc" "VPC-C-Virginia-TEST" {
  cidr_block = "10.122.0.0/16"      // VPC-A-Virginia-TEST

  tags = {
    Name = "VPC-C-Virginia-TEST"
    Service = "TEST"
    Owner = "Naaman"
    Planet = "Earth"
  }
}