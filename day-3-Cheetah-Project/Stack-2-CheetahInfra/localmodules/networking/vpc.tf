locals {
  public_subnet_count  = var.public_subnet_count
  private_subnet_count = var.private_subnet_count
  az_names             = data.aws_availability_zones.azs.names
}

resource "aws_vpc" "cheetah_infra_vpc" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "cheetah-${var.env_name}-vpc"
  }
}

resource "aws_subnet" "public_subnets" {
  count = local.public_subnet_count

  vpc_id                  = aws_vpc.cheetah_infra_vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone       = local.az_names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "cheetah-${var.env_name}-pub-${count.index + 1}"
  }
}

resource "aws_subnet" "private_subnets" {
  count = local.private_subnet_count

  vpc_id            = aws_vpc.cheetah_infra_vpc.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + 10)
  availability_zone = local.az_names[count.index]

  tags = {
    Name = "cheetah-${var.env_name}-pri-${count.index + 1}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.cheetah_infra_vpc.id
  tags = {
    Name = "cheetah-${var.env_name}-igw"
  }
}

resource "aws_eip" "nat" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_subnets[0].id
  depends_on    = [aws_internet_gateway.igw]

  tags = {
    Name = "cheetah-${var.env_name}-nat-gateway"
  }
}

#Public Routing
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.cheetah_infra_vpc.id
  tags = {
    Name = "cheetah-${var.env_name}-pub-rt"
  }
}

resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public" {
  count          = local.public_subnet_count
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public_rt.id
}

#Private Routing
resource "aws_route_table" "private_rt_table" {
  vpc_id = aws_vpc.cheetah_infra_vpc.id
  tags = {
    Name = "cheetah-${var.env_name}-pri-rt"
  }
}

resource "aws_route" "private_route" {
  route_table_id         = aws_route_table.private_rt_table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

resource "aws_route_table_association" "private" {
  count          = local.private_subnet_count
  subnet_id      = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.private_rt_table.id
}