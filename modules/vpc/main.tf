terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.81.0"
    }
  }
}
resource "aws_vpc" "main" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name        = "${var.env}-${var.name}-igw"
    Environment = var.env
  }
}

resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  map_public_ip_on_launch = true
  availability_zone       = var.azs[count.index]
  cidr_block              = var.public_subnet_cidrs[count.index]
  tags = {
    Name                     = "${var.env}-${var.name}-public_subnet-${count.index + 1}"
    "kubernetes.io/role/elb" = "1"
    Environment              = var.env
  }
}

resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.azs[count.index]
  tags = {
    Name                              = "${var.env}-${var.name}-private_subnet-${count.index + 1}"
    "kubernetes.io/role/internal-elb" = "1"
    Environment                       = var.env
  }
}
