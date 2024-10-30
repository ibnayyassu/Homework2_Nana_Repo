
resource "aws_ec2_transit_gateway_vpc_attachment" "VPC-A-Prod-Virginia-Attachment" {
    subnet_ids = [aws_subnet.public-us-east-1a.id]
    transit_gateway_id = aws_ec2_transit_gateway.Virginia-TGW01.id
    vpc_id = aws_vpc.VPC-A-Virginia-PROD.id
    tags = {
        Name = "VPC-A-Prod-Virginia-Attachment"
    }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "VPC-B-Dev-Virginia-Attachment" {
    subnet_ids = [aws_subnet.private-us-east-1b.id]
    transit_gateway_id = aws_ec2_transit_gateway.Virginia-TGW01.id
    vpc_id = aws_vpc.VPC-B-Virginia-DEV.id
    tags = {
        Name = "VPC-B-Dev-Virginia-Attachment"
    }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "VPC-C-Test-Virginia-Attachment" {
    subnet_ids = [aws_subnet.private-us-east-1c.id]
    transit_gateway_id = aws_ec2_transit_gateway.Virginia-TGW01.id
    vpc_id = aws_vpc.VPC-C-Virginia-TEST.id
    tags = {
        Name = "VPC-C-Test-Virginia-Attachment"
    }
}