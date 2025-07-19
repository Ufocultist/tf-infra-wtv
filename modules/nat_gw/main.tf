terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.81.0"
    }
  }
}

resource "aws_eip" "nat" {
  count  = 2
  domain = "vpc"
  tags = {
    Name        = "${var.env}-${var.name}-eip-${count.index + 1}"
    Environment = var.env
  }
}

resource "aws_nat_gateway" "ng" {
  count             = 2
  allocation_id     = aws_eip.nat[count.index].id
  subnet_id         = var.public_subnet_ids[count.index]
  connectivity_type = "public"
  tags = {
    Name        = "${var.env}-${var.name}-nat-gw-${count.index + 1}"
    Environment = var.env
  }
}

# resource "aws_internet_gateway" "igw" {
#   vpc_id = var.vpc_id
#
#   tags = {
#     Name        = "${var.env}-${var.name}-igw"
#     Environment = var.env
#   }
# }

resource "aws_route_table" "private_rt" {
  count  = 2
  vpc_id = var.vpc_id

  tags = {
    Name        = "${var.env}-${var.name}-private-rt-${count.index + 1}"
    Environment = var.env
  }
}

resource "aws_route" "private_ng" {
  count                  = 2
  route_table_id         = aws_route_table.private_rt[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.ng[count.index].id
}

resource "aws_route_table_association" "private" {
  count          = length(var.private_subnet_ids)
  subnet_id      = var.private_subnet_ids[count.index]
  route_table_id = aws_route_table.private_rt[count.index % 2].id
}

resource "aws_route_table" "public_rt" {
  vpc_id = var.vpc_id

  tags = {
    Name        = "${var.env}-${var.name}-public-rt"
    Environment = var.env
  }
}

resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = var.igw_id
  # gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public" {
  count          = length(var.public_subnet_ids)
  subnet_id      = var.public_subnet_ids[count.index]
  route_table_id = aws_route_table.public_rt.id
}
