//transit gateway file

resource "aws_ec2_transit_gateway" "tgw" {
  tags = { Name = "hub-tgw" }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "app" {
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  vpc_id             = aws_vpc.app.id
  subnet_ids         = [aws_subnet.app_private["0"].id, aws_subnet.app_private["1"].id]
  tags               = { Name = "tgw-attach-app" }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "data" {
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  vpc_id             = aws_vpc.data.id
  subnet_ids         = [aws_subnet.data_private["0"].id, aws_subnet.data_private["1"].id]
  tags               = { Name = "tgw-attach-data" }
}

# Add routes in each spoke so they reach the other via TGW
resource "aws_route" "app_to_data" {
  route_table_id         = aws_route_table.app_private.id
  destination_cidr_block = var.data_vpc_cidr
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
  depends_on             = [aws_ec2_transit_gateway_vpc_attachment.app]
}

resource "aws_route" "data_to_app" {
  route_table_id         = aws_route_table.data_private.id
  destination_cidr_block = var.app_vpc_cidr
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
  depends_on             = [aws_ec2_transit_gateway_vpc_attachment.data]
}
