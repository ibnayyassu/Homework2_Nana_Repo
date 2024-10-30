resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.VPC-A-Virginia-PROD.id

  tags = {
    Name    = "PROD_IG"
    Service = "VPC-A-Virginia-PROD"
    Owner   = "Naaman"
    Planet  = "Earth"
  }
}
