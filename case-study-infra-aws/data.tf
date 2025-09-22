// Data VPC (hosts RDS etc.)
resource "aws_vpc" "data" {
  cidr_block           = var.data_vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = { Name = "data-vpc" }
}

// Derive Data VPC subnet CIDRs
// Create 4 subnets from the Data VPC CIDR
// First two = PUBLIC, next two = PRIVATE
locals {
  data_subnets         = cidrsubnets(var.data_vpc_cidr, 4, 4, 4, 4)
  data_public_subnets  = slice(local.data_subnets, 0, 2)
  data_private_subnets = slice(local.data_subnets, 2, 4)
}


// Internet Gateway (for public)
resource "aws_internet_gateway" "data" {
  vpc_id = aws_vpc.data.id
  tags   = { Name = "data-igw" }
}

// Public subnets (2 AZs)
resource "aws_subnet" "data_public" {
  count                   = 2
  vpc_id                  = aws_vpc.data.id
  availability_zone       = var.azs[count.index]
  cidr_block              = cidrsubnet(aws_vpc.data.cidr_block, 4, count.index)
  map_public_ip_on_launch = true
  tags                    = { Name = "data-public-${count.index}" }
}

// Private subnets (2 AZs)
resource "aws_subnet" "data_private" {
  count             = 2
  vpc_id            = aws_vpc.data.id
  availability_zone = var.azs[count.index]
  cidr_block        = cidrsubnet(aws_vpc.data.cidr_block, 4, count.index + 2)
  tags              = { Name = "data-private-${count.index}" }
}

// NAT for private egress
resource "aws_eip" "data_nat" {
  domain = "vpc"
  tags   = { Name = "data-nat-eip" }
}

resource "aws_nat_gateway" "data" {
  allocation_id = aws_eip.data_nat.id
  subnet_id     = aws_subnet.data_public[0].id
  tags          = { Name = "data-nat" }
}

// Public route table
resource "aws_route_table" "data_public" {
  vpc_id = aws_vpc.data.id
  tags   = { Name = "data-public-rt" }
}

resource "aws_route" "data_public_inet" {
  route_table_id         = aws_route_table.data_public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.data.id
}

resource "aws_route_table_association" "data_public_assoc" {
  count          = 2
  subnet_id      = aws_subnet.data_public[count.index].id
  route_table_id = aws_route_table.data_public.id
}

// Private route table
resource "aws_route_table" "data_private" {
  vpc_id = aws_vpc.data.id
  tags   = { Name = "data-private-rt" }
}

resource "aws_route" "data_private_nat" {
  route_table_id         = aws_route_table.data_private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.data.id
}

resource "aws_route_table_association" "data_private_assoc" {
  count          = 2
  subnet_id      = aws_subnet.data_private[count.index].id
  route_table_id = aws_route_table.data_private.id
}