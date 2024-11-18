# this  makes  vpc.id which is aws_vpc.app1.id
resource "aws_vpc" "LizzoSunday" {
  cidr_block = "10.121.0.0/16"

  tags = {
    Name = "LizzoSunday"
    Service = "application1"
    Owner = "Chewbacca"
    Planet = "Mustafar"
  }
}
