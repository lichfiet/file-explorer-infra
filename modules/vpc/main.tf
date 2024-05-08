terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-west-1"
  #   access_key = local.envs["AWS_ACCESS_KEY_ID"]
  #   secret_key = local.envs["AWS_SECRET_ACCESS_KEY"]
}

############################################################################################################

##
## VPC And Internet Gateway
##
resource "aws_vpc" "vpc" {
  cidr_block = "${var.vpc_cidr}"
  tags = {
    Name = "${var.vpc_name}-vpc"
  }
}

resource "aws_internet_gateway" "internet-gateway" {
  depends_on = [aws_vpc.vpc]
  vpc_id     = aws_vpc.vpc.id
  tags = {
    Name = "${var.vpc_name}-internet-gateway"
  }
}

##
## Public Subnet And Route Table
##
resource "aws_subnet" "public_subnet" {
  # public subnet
  depends_on        = [aws_vpc.vpc]
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "${var.vpc_region}a"
  tags = {
    Name = "${var.vpc_name}-public-subnet"
  }
}

resource "aws_route_table" "public_route_table" {
  # public route table
  depends_on = [aws_internet_gateway.internet-gateway]
  vpc_id     = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet-gateway.id
  }
  tags = {
    Name = "${var.vpc_name}-route-table"
  }
}

resource "aws_route_table_association" "learning_route_table_association" {
  # associate public route table with public subnet
  depends_on     = [aws_route_table.public_route_table]
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

# change default route table to public route table
resource "aws_main_route_table_association" "main_route_table_association" {
  # associate public route table with vpc
  vpc_id = aws_vpc.vpc.id
  route_table_id = aws_route_table.public_route_table.id
  
}

##
## Private Route Table
##
resource "aws_subnet" "private_subnet" {
  depends_on        = [aws_vpc.vpc]
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "${var.vpc_region}a"
  tags = {
    Name = "${var.vpc_name}-private-subnet"
  }
}

# Elastic IP For NAT Gateway
resource "aws_eip" "nat_eip" {
  vpc = true
}

resource "aws_nat_gateway" "nat_gateway" {
  depends_on = [aws_internet_gateway.internet-gateway]
  allocation_id = aws_eip.nat_eip.id
  subnet_id = aws_subnet.public_subnet.id
  tags = {
    Name = "${var.vpc_name}-nat-gateway"
  }
}

resource "aws_route_table" "private_route_table" {
  depends_on = [aws_internet_gateway.internet-gateway]
  vpc_id     = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }
  tags = {
    Name = "${var.vpc_name}-route-table"
  }
}

resource "aws_route_table_association" "private_route_table_association" {
  depends_on     = [aws_route_table.private_route_table]
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_route_table.id
}