// -----------------------------
// App VPC (will host ALB + private EC2 instances)
// -----------------------------
resource "aws_vpc" "app" {
  cidr_block           = var.app_vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = { Name = "app-vpc" }
}

// -----------------------------
// Derive subnet CIDRs (locals)
// -----------------------------
// Create 4 subnets from the /16
// First two = PUBLIC, next two = PRIVATE
locals {
  app_subnets         = cidrsubnets(var.app_vpc_cidr, 4, 4, 4, 4)
  app_public_subnets  = slice(local.app_subnets, 0, 2)
  app_private_subnets = slice(local.app_subnets, 2, 4)
}

// -----------------------------
// Internet Gateway (for public subnets)
// -----------------------------
resource "aws_internet_gateway" "app" {
  vpc_id = aws_vpc.app.id
  tags   = { Name = "app-igw" }
}

// -----------------------------
// Public subnets (2 AZs)
// -----------------------------
resource "aws_subnet" "app_public" {
  count                   = 2
  vpc_id                  = aws_vpc.app.id
  availability_zone       = var.azs[count.index]
  cidr_block              = local.app_public_subnets[count.index]
  map_public_ip_on_launch = true
  tags = { Name = "app-public-${count.index}" }
}

// -----------------------------
// Private subnets (2 AZs)
// -----------------------------
resource "aws_subnet" "app_private" {
  count             = 2
  vpc_id            = aws_vpc.app.id
  availability_zone = var.azs[count.index]
  cidr_block        = local.app_private_subnets[count.index]
  tags = { Name = "app-private-${count.index}" }
}

// -----------------------------
// NAT Gateway (for private egress)
// -----------------------------
// Needs an Elastic IP in one public subnet
resource "aws_eip" "app_nat" {
  domain = "vpc"
  tags   = { Name = "app-nat-eip" }
}

resource "aws_nat_gateway" "app" {
  allocation_id = aws_eip.app_nat.id
  subnet_id     = aws_subnet.app_public[0].id
  tags          = { Name = "app-nat" }
}

// -----------------------------
// Public route table
// -----------------------------
resource "aws_route_table" "app_public" {
  vpc_id = aws_vpc.app.id
  tags   = { Name = "app-public-rt" }
}

resource "aws_route" "app_public_inet" {
  route_table_id         = aws_route_table.app_public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.app.id
}

resource "aws_route_table_association" "app_public_assoc" {
  count          = 2
  subnet_id      = aws_subnet.app_public[count.index].id
  route_table_id = aws_route_table.app_public.id
}

// -----------------------------
// Private route table
// -----------------------------
resource "aws_route_table" "app_private" {
  vpc_id = aws_vpc.app.id
  tags   = { Name = "app-private-rt" }
}

resource "aws_route" "app_private_nat" {
  route_table_id         = aws_route_table.app_private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.app.id
}

resource "aws_route_table_association" "app_private_assoc" {
  count          = 2
  subnet_id      = aws_subnet.app_private[count.index].id
  route_table_id = aws_route_table.app_private.id
}
