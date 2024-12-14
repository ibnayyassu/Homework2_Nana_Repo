# Transit Gateway for inter-region communication
resource "aws_ec2_transit_gateway" "tokyo-TGW01" {
  description = "Transit Gateway for inter-region routing"
  dns_support = "enable"
  vpn_ecmp_support = "disable"
  tags = {
    Name = "tokyo_tgw"
  }
  provider = aws.tokyo
}
resource "aws_ec2_transit_gateway" "virginia_TGW01" {
  description                     = "Transit Gateway for inter-region routing"
  auto_accept_shared_attachments  = "enable"
  dns_support                     = "enable"
  vpn_ecmp_support                = "enable"
  tags = {
    Name = "virginia_tgw"
  }
  provider = aws.virginia
}

# Attach Tokyo VPC to Transit Gateway
resource "aws_ec2_transit_gateway_vpc_attachment" "tokyo_attachment" {
  transit_gateway_id = aws_ec2_transit_gateway.tokyo-TGW01.id
  vpc_id             = aws_vpc.tokyo.id
  subnet_ids         = [aws_subnet.tokyo_private_subnet_1.id, aws_subnet.tokyo_private_subnet_2.id]
}

# Attach Virginia VPC to Transit Gateway
resource "aws_ec2_transit_gateway_vpc_attachment" "virginia_attachment" {
  transit_gateway_id = aws_ec2_transit_gateway.tokyo-TGW01.id
  vpc_id             = aws_vpc.virginia.id
  subnet_ids         = [aws_subnet.Virginia_private_subnet.id]
}

// Peerings go here 
# TGW Peering Attachment
resource "aws_ec2_transit_gateway_peering_attachment" "tokyo-tgw-peering" {
  peer_account_id         = aws_ec2_transit_gateway.virginia_TGW01.owner_id
  peer_region             = data.aws_region.peer.name                     #us-east-1 or alias
  peer_transit_gateway_id = aws_ec2_transit_gateway.virginia_TGW01.id
  transit_gateway_id      = aws_ec2_transit_gateway.tokyo-TGW01.id

  tags = {
    Name = "TGW Peering Requestor"
  }
}

# TGW Peering Accepter
resource "aws_ec2_transit_gateway_peering_attachment_accepter" "virginia-tgw-accepting" {
  transit_gateway_attachment_id = aws_ec2_transit_gateway_peering_attachment.tokyo-tgw-peering.id

  tags = {
    Name = "TGW Peering Accepter"
  }
}

// Route Tables
resource "aws_ec2_transit_gateway_route_table" "tokyo-tgw" {
  transit_gateway_id = aws_ec2_transit_gateway.tokyo-TGW01.id
}

resource "aws_ec2_transit_gateway_route_table" "virginia-tgw" {
  transit_gateway_id = aws_ec2_transit_gateway.virginia_TGW01.id
}

 // Route table associations
resource "aws_ec2_transit_gateway_route_table_association" "tokyo_vpc-route" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tokyo_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway.tokyo-TGW01.id
}
resource "aws_ec2_transit_gateway_route_table_association" "virginia_vpc-route" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.virginia_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway.virginia_TGW01.id
}
resource "aws_ec2_transit_gateway_route_table_association" "tokyo_peering-route" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.tokyo-tgw-peering.id  
  transit_gateway_route_table_id = aws_ec2_transit_gateway.tokyo-TGW01.id
}
resource "aws_ec2_transit_gateway_route_table_association" "virginia_peering-route" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.virginia-tgw-accepting.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway.virginia_TGW01.id
}

//Route
resource "aws_ec2_transit_gateway_route" "tokyo_vpc-route" {
  destination_cidr_block         = aws_vpc.tokyo.cidr_block
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tokyo_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway.tokyo-TGW01.id
}
resource "aws_ec2_transit_gateway_route" "virginia_vpc-route" {
  destination_cidr_block         = aws_vpc.virginia.cidr_block
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.virginia_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway.virginia_TGW01.id
}
resource "aws_ec2_transit_gateway_route" "tokyo_peering-route" {
  destination_cidr_block         = aws_vpc.tokyo.cidr_block
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tokyo_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway.tokyo-TGW01.id
}
resource "aws_ec2_transit_gateway_route" "virginia_peering-route" {
  destination_cidr_block         = aws_vpc.virginia.cidr_block
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.virginia_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway.virginia_TGW01.id  
}


















/* # Route from Tokyo to Virginia for Syslog traffic
resource "aws_route" "tokyo_to_virginia" {
  route_table_id              = aws_route_table.private.id  
  destination_cidr_block      = "10.125.0.0/16"  # CIDR block of Virginia VPC
  transit_gateway_id          = aws_ec2_transit_gateway.TGW01.id
}

# Route from Virginia to Tokyo for Syslog traffic
resource "aws_route" "virginia_to_tokyo" {
  route_table_id              = aws_route_table.Virginia_private_subnet.id
  destination_cidr_block      = "10.120.0.0/16"  # CIDR block of Tokyo VPC
  transit_gateway_id          = aws_ec2_transit_gateway.TGW01.id
}
 */




