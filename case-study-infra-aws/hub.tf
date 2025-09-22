// Create a VPC for the hub
resource "aws_vpc" "hub" {
  cidr_block           = var.hub_vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = { Name = "hub-vpc" }
}

// Create an Internet Gateway for the hub VPC
resource "aws_internet_gateway" "hub" {
  vpc_id = aws_vpc.hub.id
  tags   = { Name = "hub-igw" }
}

//two small public subnets
locals {
  hub_public_subnets = slice(cidrsubnets(var.hub_vpc_cidr, 4, 4), 0, 2)
}

// Create two public subnets in different AZs
resource "aws_subnet" "hub_public" {
  count                   = 2
  vpc_id                  = aws_vpc.hub.id
  availability_zone       = var.azs[count.index]
  cidr_block              = local.hub_public_subnets[count.index]
  map_public_ip_on_launch = true
  tags                    = { Name = "hub-public-${count.index}" }
}
// Create a route table for the public subnets
resource "aws_route_table" "hub_public" {
  vpc_id = aws_vpc.hub.id
  tags   = { Name = "hub-public-rt" }
}
// Associate the public subnets with the route table
resource "aws_route" "hub_inet" {
  route_table_id         = aws_route_table.hub_public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.hub.id
}
// Associate the public subnets with the route table
resource "aws_route_table_association" "hub_public_assoc" {
  count          = 2
  subnet_id      = aws_subnet.hub_public[count.index].id
  route_table_id = aws_route_table.hub_public.id
}



