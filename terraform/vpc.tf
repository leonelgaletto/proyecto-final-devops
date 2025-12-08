##############################################
# Crear VPC mínima
##############################################

resource "aws_vpc" "proyecto_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "proyecto-diplomatura-vpc"
  }
}

##############################################
# Subnet pública
##############################################

resource "aws_subnet" "proyecto_subnet" {
  vpc_id                  = aws_vpc.proyecto_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

##############################################
# Internet Gateway
##############################################

resource "aws_internet_gateway" "proyecto_igw" {
  vpc_id = aws_vpc.proyecto_vpc.id
}

##############################################
# Route table pública
##############################################

resource "aws_route_table" "proyecto_rt" {
  vpc_id = aws_vpc.proyecto_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.proyecto_igw.id
  }
}

##############################################
# Asociar subnet a route table
##############################################

resource "aws_route_table_association" "proyecto_rt_assoc" {
  subnet_id      = aws_subnet.proyecto_subnet.id
  route_table_id = aws_route_table.proyecto_rt.id
}
