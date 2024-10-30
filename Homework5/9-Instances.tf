#Terraform code to launch EC2 Instance

resource "aws_instance" "VPC-A-Prod-Windows" {
  ami = "ami-0324a83b82023f0b3"
  instance_type = "t2.medium"
  key_name = "terraform"
  subnet_id = aws_subnet.public-us-east-1a.id
  vpc_security_group_ids = [aws_security_group.VPC-A-Virginia-PROD-with-Bastion-01.id] 
  tags = {
    Name = "VPC-A-Prod-Windows"
  }
}

resource "aws_instance" "VPC-B-Dev-Linux" {
  ami           = "ami-0cff7528ff583bf9a"
  instance_type = "t2.micro"
  key_name = "terraform"
  subnet_id = aws_subnet.private-us-east-1b.id
  vpc_security_group_ids = [aws_security_group.VPC-B-Virginia-DEV-with-Linux-01.id] 
  tags = {
    Name ="Basic Linux"
  }
}

