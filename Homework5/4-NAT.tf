resource "aws_eip" "ElasticIP-Virginia" {
  vpc = true

  tags = {
    Name = "ElasticIP-Virginia"
  }
}

resource "aws_nat_gateway" "Nat-GW-Virginia" {
  allocation_id = aws_eip.ElasticIP-Virginia.id 
  subnet_id     = aws_subnet.public-us-east-1a.id

  tags = {
    Name = "ElasticIP-Virginia"
  }

  #depends_on = [aws_internet_gateway.igw]
}
