resource "aws_ec2_transit_gateway" "tokyo-TGW01" {

  description = "Transit Gateway for inter-region routing"

  dns_support = "enable"

  vpn_ecmp_support = "disable"

  tags = {

    Name = "tokyo_tgw"

  }

  provider = aws.tokyo

}

resource "aws_ec2_transit_gateway" "Sydney_TGW01" {

  description                     = "Transit Gateway for inter-region routing"

  auto_accept_shared_attachments  = "enable"

  dns_support                     = "enable"

  vpn_ecmp_support                = "enable"

  tags = {

    Name = "Sydney_tgw"

  }

  provider = aws.sydney

}


# Attach Tokyo VPC to Transit Gateway

resource "aws_ec2_transit_gateway_vpc_attachment" "tokyo_attachment" {

  transit_gateway_id = aws_ec2_transit_gateway.tokyo-TGW01.id

  vpc_id             = aws_vpc.tokyo.id

  subnet_ids         = [aws_subnet.tokyo_private_subnet_1.id, aws_subnet.tokyo_private_subnet_2.id]

}


# Attach Virginia VPC to Transit Gateway

resource "aws_ec2_transit_gateway_vpc_attachment" "Sydney_attachment" {

  transit_gateway_id = aws_ec2_transit_gateway.Sydney-TGW01.id

  vpc_id             = aws_vpc.Sydney1.id

  subnet_ids         = [aws_subnet.private-ap-southeast-2a.id, aws_subnet.private-ap-southeast-2b.id]

}


// Peerings go here 

# TGW Peering Attachment

resource "aws_ec2_transit_gateway_peering_attachment" "tokyo-tgw-peering" {

  peer_account_id         = aws_ec2_transit_gateway.Sydney_TGW01.owner_id

  peer_region             = data.aws_region.peer.name                     #us-east-1 or alias

  peer_transit_gateway_id = aws_ec2_transit_gateway.Sydney_TGW01.id

  transit_gateway_id      = aws_ec2_transit_gateway.tokyo-TGW01.id


  tags = {

    Name = "TGW Peering Requestor"

  }

}


# TGW Peering Accepter

resource "aws_ec2_transit_gateway_peering_attachment_accepter" "Sydney-tgw-accepting" {

  transit_gateway_attachment_id = aws_ec2_transit_gateway_peering_attachment.tokyo-tgw-peering.id


  tags = {

    Name = "TGW Peering Accepter"

  }

}


// Route Tables

resource "aws_ec2_transit_gateway_route_table" "tokyo-tgw" {

  transit_gateway_id = aws_ec2_transit_gateway.tokyo-TGW01.id

}


resource "aws_ec2_transit_gateway_route_table" "Sydney-tgw" {

  transit_gateway_id = aws_ec2_transit_gateway.virginia_TGW01.id

}


 // Route table associations

resource "aws_ec2_transit_gateway_route_table_association" "tokyo_vpc-route" {

  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tokyo_attachment.id

  transit_gateway_route_table_id = aws_ec2_transit_gateway.tokyo-TGW01.id

}

resource "aws_ec2_transit_gateway_route_table_association" "Sydney_vpc-route" {

  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.Sydney_attachment.id

  transit_gateway_route_table_id = aws_ec2_transit_gateway.Sydney_TGW01.id

}

resource "aws_ec2_transit_gateway_route_table_association" "tokyo_peering-route" {

  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.tokyo-tgw-peering.id  

  transit_gateway_route_table_id = aws_ec2_transit_gateway.tokyo-TGW01.id

}

resource "aws_ec2_transit_gateway_route_table_association" "Sydney_peering-route" {

  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.Sydney-tgw-accepting.id

  transit_gateway_route_table_id = aws_ec2_transit_gateway.Sydney_TGW01.id

}


//Route

resource "aws_ec2_transit_gateway_route" "tokyo_vpc-route" {

  destination_cidr_block         = "aws_vpc.tokyo.cidr_block"

  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tokyo.id

  transit_gateway_route_table_id = aws_ec2_transit_gateway.tokyo-TGW01.id

}

resource "aws_ec2_transit_gateway_route" "Sydney_vpc-route" {

  destination_cidr_block         = "aws_vpc.Sydney1.cidr_block"

  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.Sydney.id

  transit_gateway_route_table_id = aws_ec2_transit_gateway.example.Sydney-TGW01.id

}

resource "aws_ec2_transit_gateway_route" "tokyo_vpc-route" {

  destination_cidr_block         = "aws_vpc.tokyo.cidr_block"

  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tokyo.id

  transit_gateway_route_table_id = aws_ec2_transit_gateway.tokyo-TGW01.id

}

resource "aws_ec2_transit_gateway_route" "Sydney" {

  destination_cidr_block         = "aws_vpc.Sydney1.cidr_block"

  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.Sydney.id

  transit_gateway_route_table_id = aws_ec2_transit_gateway.Sydney-TGW01.id

}