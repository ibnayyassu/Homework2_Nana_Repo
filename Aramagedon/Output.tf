#Extra Credit

output "VPC-Tokyo" {
    description = "VPC-Tokyo"
  value = aws_vpc.Tokyo.id 
}

output "VPC-Virginia" {
    description = "VPC-Virginia"
  value = aws_vpc.Virginia_vpc.id
}

/* output "VPC-C" {
    description = "VPC-C-Virginia-TEST"
  value = aws_vpc.VPC-C-Virginia-TEST.id
}

output "Subnet-A-Public-Prod" {
    description = "Subnet-A-Public-Prod"
  value = aws_subnet.public-us-east-1a.id
}         

output "Subnet-A-Private-Prod" {
    description = "Subnet-A-Private-Prod"
  value = aws_subnet.private-us-east-1a.id
}

output "Subnet-B-Private-Dev" {
    description = "Subnet-B-Private-Dev"
  value = aws_subnet.private-us-east-1b.id
}

output "Subnet-C-Private-Test" {
    description = "Subnet-C-Private-Test"
  value = aws_subnet.private-us-east-1c.id
}

output "SG-Prod-A-Public" {
    description = "SG-Prod-A-Public"
  value = aws_security_group.VPC-A-Virginia-PROD-with-Bastion-01.id
}

output "SG-Dev-B-Private" {
    description = "SG-Dev-B-Private"
  value = aws_security_group.VPC-B-Virginia-DEV-with-Linux-01.id
}

output "Transit-A-Prod" {
    description = "TransitGateway-A-Prod"
  value = aws_ec2_transit_gateway.Virginia-TGW01.id
}

 */