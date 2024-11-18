resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.LizzoSunday.id

  tags = {
    Name    = "LizzoSunday_IG"
    Service = "application1"
    Owner   = "Luke"
    Planet  = "Musafar"
  }
}
