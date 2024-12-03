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
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}


##
## VPC
##

# VPC
resource "aws_vpc" "vpc" {
  cidr_block = "${var.vpc_cidr}"
  tags = {
    Name = "${var.vpc_name}-vpc"
  }
}

resource "aws_internet_gateway" "internet_gateway" {
  depends_on = [aws_vpc.vpc]
  vpc_id     = aws_vpc.vpc.id
  tags = {
    Name = "${var.vpc_name}-internet-gateway"
  }
}




############################################################################################################
## Public Subnets, IGWs And Route Tables
############################################################################################################


### PUB SUBNET 1
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

resource "aws_route_table" "public_subnet_1_route_table" {
  # public route table 1
  depends_on = [aws_internet_gateway.internet_gateway, aws_vpc.vpc]
  vpc_id     = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
  tags = {
    Name = "${var.vpc_name}-route-table-1"
  }
}

resource "aws_route_table_association" "public_subnet_1_route_table_association_1" {
  # associate public route table with public subnet
  depends_on     = [aws_route_table.public_subnet_1_route_table]
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_subnet_1_route_table.id
}

### PUB SUBNET 2

resource "aws_subnet" "public_subnet_2" {
  # public subnet 2
  depends_on        = [aws_vpc.vpc]
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "${var.vpc_region}b"
  tags = {
    Name = "${var.vpc_name}-public-subnet-2"
  }
}

resource "aws_route_table" "public_subnet_2_route_table" {
  # public route table 2
  depends_on = [aws_internet_gateway.internet_gateway, aws_vpc.vpc]
  vpc_id     = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
  tags = {
    Name = "${var.vpc_name}-route-table-2"
  }
}

resource "aws_route_table_association" "public_subnet_2_route_table_association_2" {
  # associate public route table with public subnet
  depends_on     = [aws_route_table.public_subnet_2_route_table]
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_subnet_2_route_table.id
}

# change default route table to public route table
resource "aws_main_route_table_association" "main_route_table_association" {
  depends_on = [ aws_vpc.vpc ]
  # associate public route table with vpc
  vpc_id = aws_vpc.vpc.id
  route_table_id = aws_route_table.public_subnet_1_route_table.id
  
}

############################################################################################################
## Private Subnets, NAT Gateways and Route Tables
############################################################################################################

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

  depends_on = [aws_internet_gateway.internet_gateway]
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

############################################################################################################
## Security Groups
############################################################################################################

# Security Group For Public Subnet
resource "aws_security_group" "public_subnet_sg" {
  depends_on = [aws_vpc.vpc]
  vpc_id     = aws_vpc.vpc.id
  name       = "${var.vpc_name}-public-subnet-sg"
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}