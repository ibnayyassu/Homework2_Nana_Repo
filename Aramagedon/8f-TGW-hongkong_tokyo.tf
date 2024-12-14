hongkong

# Attach hongkong VPC to Transit Gateway
resource "aws_ec2_transit_gateway_vpc_attachment" "Hongkong_attachment" {
  transit_gateway_id = aws_ec2_transit_gateway.hongkong-TGW01.id
  vpc_id             = aws_vpc.hongkong.id
  subnet_ids         = [aws_subnet.Hongkong_private_subnet_1.id, aws_subnet.Hongkong_private_subnet_2.id]
}

# Attach Tokyo VPC to Transit Gateway
resource "aws_ec2_transit_gateway_vpc_attachment" "Tokyo_attachment" {
  transit_gateway_id = aws_ec2_transit_gateway.hongkong-TGW01.id
  vpc_id             = aws_vpc.Tokyo.id
  subnet_ids         = [aws_subnet.Tokyo_private_subnet.id]
}

// Peerings go here 
# TGW Peering Attachment
resource "aws_ec2_transit_gateway_peering_attachment" "hongkong-tgw-peering" {
  peer_account_id         = aws_ec2_transit_gateway.Tokyo_TGW01.owner_id
  peer_region             = data.aws_region.peer.name                     #ap-northeast-1 or alias
  peer_transit_gateway_id = aws_ec2_transit_gateway.Tokyo_TGW01.id
  transit_gateway_id      = aws_ec2_transit_gateway.hongkong-TGW01.id

  tags = {
    Name = "TGW Peering Requestor"
  }
}

# TGW Peering Accepter
resource "aws_ec2_transit_gateway_peering_attachment_accepter" "Tokyo-tgw-accepting" {
  transit_gateway_attachment_id = aws_ec2_transit_gateway_peering_attachment.hongkong-tgw-peering.id

  tags = {
    Name = "TGW Peering Accepter"
  }
}

// Route Tables
resource "aws_ec2_transit_gateway_route_table" "hongkong-tgw" {
  transit_gateway_id = aws_ec2_transit_gateway.hongkong-TGW01.id
}

resource "aws_ec2_transit_gateway_route_table" "Tokyo-tgw" {
  transit_gateway_id = aws_ec2_transit_gateway.Tokyo_TGW01.id
}

 // Route table associations
resource "aws_ec2_transit_gateway_route_table_association" "hongkong_vpc-route" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.hongkong_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway.hongkong-TGW01.id
}
resource "aws_ec2_transit_gateway_route_table_association" "Tokyo_vpc-route" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.Tokyo_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway.Tokyo_TGW01.id
}
resource "aws_ec2_transit_gateway_route_table_association" "hongkong_peering-route" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.hongkong-tgw-peering.id  
  transit_gateway_route_table_id = aws_ec2_transit_gateway.hongkong-TGW01.id
}
resource "aws_ec2_transit_gateway_route_table_association" "Tokyo_peering-route" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.Tokyo-tgw-accepting.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway.Tokyo_TGW01.id
}

//Route
resource "aws_ec2_transit_gateway_route" "Hongkong_vpc-route" {
  destination_cidr_block         = aws_vpc.tokyo.cidr_block
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.hongkong.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway.Tokyo.TGW01.id
}
resource "aws_ec2_transit_gateway_route" "tokyo_vpc-route" {
  destination_cidr_block         = aws_vpc.hongkong.cidr_block
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.hongkong.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway.tokyo.TGW01.id
}
resource "aws_ec2_transit_gateway_route" "hongkong_peering-route" {
  destination_cidr_block         = aws_vpc.tokyo.cidr_block
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.hongkong.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway.tokyo.TGW01.id
}
resource "aws_ec2_transit_gateway_route" "tokyo_peering-route" {
  destination_cidr_block         = aws_vpc.hongkong.cidr_block
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.hongkong.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway.tokyo.TGW01.id
}