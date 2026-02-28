# VPC bearozz
resource "aws_vpc" "vpc_bearozz" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "vpc-${var.project_name}"
  }
}

# Subredes Públicas para el ALB
resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.vpc_bearozz.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-1-${var.project_name}"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.vpc_bearozz.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "${var.aws_region}b"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-2-${var.project_name}"
  }
}

# Subredes Privadas para ECS Fargate
resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.vpc_bearozz.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "${var.aws_region}a"

  tags = {
    Name = "private-subnet-1-${var.project_name}"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.vpc_bearozz.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "${var.aws_region}b"

  tags = {
    Name = "private-subnet-2-${var.project_name}"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw_bearozz" {
  vpc_id = aws_vpc.vpc_bearozz.id

  tags = {
    Name = "igw-${var.project_name}"
  }
}

# NAT Gateway (usamos uno solo para ahorrar costos)
resource "aws_eip" "nat_eip" {
  domain = "vpc"
  tags = {
    Name = "nat-eip-${var.project_name}"
  }
}

resource "aws_nat_gateway" "nat_gw_bearozz" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet_1.id

  tags = {
    Name = "nat-gw-${var.project_name}"
  }

  depends_on = [aws_internet_gateway.igw_bearozz]
}

# Tablas de Ruteo
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc_bearozz.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_bearozz.id
  }

  tags = {
    Name = "public-rt-${var.project_name}"
  }
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.vpc_bearozz.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw_bearozz.id
  }

  tags = {
    Name = "private-rt-${var.project_name}"
  }
}

# Asociaciones de Subredes
resource "aws_route_table_association" "public_1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "private_1" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_2" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private_rt.id
}
