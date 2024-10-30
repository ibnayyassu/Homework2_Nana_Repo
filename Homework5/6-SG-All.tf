
resource "aws_security_group" "VPC-A-Virginia-PROD-with-Bastion-01" {
  name        = "Bastion-01"
  description = "Security Group Bastion"
  vpc_id      = aws_vpc.VPC-A-Virginia-PROD.id

  tags = {
    Name = "Bastion-01"
  }

ingress {
    description = "RDP"
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "VPC-B-Virginia-DEV-with-Linux-01" {
  name        = "Linux-01"
  description = "Security Group Linux"
  vpc_id      = aws_vpc.VPC-B-Virginia-DEV.id   

  tags = {
    Name = "Linux-01"
  }

ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "ICMP"
    from_port   = -1
    to_port     = -1
    protocol    = "ICMP"
    cidr_blocks = ["0.0.0.0/0"]
  }
egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
