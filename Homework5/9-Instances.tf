#Terraform code to launch EC2 Instance

resource "aws_instance" "VPC-A-Prod-Windows" {
  ami = "ami-0324a83b82023f0b3"
  instance_type = "t2.medium"
  tags = {
    Name = "VPC-A-Prod-Windows"
  }
}

resource "aws_instance" "VPC-B-Dev-Linux" {
  ami           = "ami-0cff7528ff583bf9a"
  instance_type = "t2.micro"
  tags = {
    Name ="Basic Linux"
  }
}
