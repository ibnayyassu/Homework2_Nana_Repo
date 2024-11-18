resource "aws_security_group" "LizzoSunday-TG01-SG01-80" {
  name        = "LizzoSunday-TG01-SG01-80"
  description = "LizzoSunday-TG01-SG01-80"
  vpc_id      = aws_vpc.LizzoSunday.id

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
    Name    = "LizzoSunday-TG01-SG01-80"
    Service = "application1"
    Owner   = "Luke"
    Planet  = "Musafar"
  }

}





resource "aws_security_group" "LizzoSunday-sg02-LB01" {
  name        = "LizzoSunday-sg02-LB01"
  description = "LizzoSunday-sg02-LB01"
  vpc_id      = aws_vpc.LizzoSunday.id

  ingress {
    description = "MyHomePage"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

ingress {
    description = "Secure"
    from_port   = 443
    to_port     = 443
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
    Name    = "LizzoSunday-sg02-LB01"
    Service = "application1"
    Owner   = "Luke"
    Planet  = "Musafar"
  }

}


resource "aws_security_group" "LizzoSunday-TG02-SG01-443" {
  name        = "LizzoSunday-TG02-SG01-443"
  description = "LizzoSunday-TG02-SG01-443"
  vpc_id      = aws_vpc.LizzoSunday.id

  ingress {
    description = "MyHomePage"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Secure"
    from_port   = 443
    to_port     = 443
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
    Name    = "LizzoSunday-TG02-SG01-443"
    Service = "application1"
    Owner   = "Luke"
    Planet  = "Musafar"
  }

}
