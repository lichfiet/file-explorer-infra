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
  region = "${var.vpc_region}"
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
## Public Subnets And Route Table
##
resource "aws_subnet" "public_subnet_1" {
  # public subnet 1
  depends_on        = [aws_vpc.vpc]
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "${var.vpc_region}a"
  tags = {
    Name = "${var.vpc_name}-public-subnet-1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  # public subnet 1
  depends_on        = [aws_vpc.vpc]
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "${var.vpc_region}b"
  tags = {
    Name = "${var.vpc_name}-public-subnet-2"
  }
}

resource "aws_route_table" "public_route_table" {
  # public route table 1
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

resource "aws_route_table" "public_route_table2" {
  # public route table 1
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

resource "aws_route_table_association" "public_route_table_association" {
  # associate public route table with public subnet
  depends_on     = [aws_route_table.public_route_table]
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_route_table_association2" {
  # associate public route table with public subnet
  depends_on     = [aws_route_table.public_route_table2]
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_route_table2.id
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
  count = var.deploy_nat_gateway == true ? 1 : 0
  vpc = true
}

resource "aws_nat_gateway" "nat_gateway" {
  count = var.deploy_nat_gateway == true ? 1 : 0

  depends_on = [aws_eip.nat_eip]
  allocation_id = aws_eip.nat_eip[0].id
  subnet_id = aws_subnet.public_subnet_1
  tags = {
    Name = "${var.vpc_name}-nat-gateway"
  }
}

resource "aws_route_table" "private_route_table" {
  count = var.deploy_nat_gateway == true ? 1 : 0

  depends_on = [aws_internet_gateway.internet-gateway]
  vpc_id     = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway[0].id
  }
  tags = {
    Name = "${var.vpc_name}-route-table"
  }
}

resource "aws_route_table_association" "private_route_table_association" {
  count = var.deploy_nat_gateway == true ? 1 : 0

  depends_on     = [aws_route_table.private_route_table]
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_route_table[0].id
}