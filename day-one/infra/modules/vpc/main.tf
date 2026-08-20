locals {
  services = {
	"ecr-docker": {
		"name": "com.amazonaws.${var.vpc_region}.ecr.dkr"
	},
    "ecr-api": {
      "name": "com.amazonaws.${var.vpc_region}.ecr.api"
    },
    "logs-api": {
      "name": "com.amazonaws.${var.vpc_region}.logs"
    },
    "eks-api": {
      "name": "com.amazonaws.${var.vpc_region}.eks"
    }
    # "secrets-manager": {
    #   "name": "com.amazonaws.${var.vpc_region}.secretsmanager"
    # }
    # "secrets-manager-fips": {
    #   "name": "com.amazonaws.${var.vpc_region}.secretsmanager-fips"
    # }
  }
}

#VPC
resource "aws_vpc" "eks_vpc" {
  cidr_block = var.vpc_cidr
  enable_dns_support = true
  enable_dns_hostnames = true
}

resource "aws_subnet" "eks_public_subnet_A" {
  vpc_id     = aws_vpc.eks_vpc.id
  cidr_block = var.public_subnet_A_CIDR
  availability_zone = "${var.vpc_region}a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "eks_public_subnet_B" {
  vpc_id     = aws_vpc.eks_vpc.id
  cidr_block = var.public_subnet_B_CIDR
  availability_zone = "${var.vpc_region}b"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "eks_private_subnet_A" {
  vpc_id     = aws_vpc.eks_vpc.id
  cidr_block = var.private_subnet_A_CIDR
  availability_zone = "${var.vpc_region}a"
}

resource "aws_subnet" "eks_private_subnet_B" {
  vpc_id     = aws_vpc.eks_vpc.id
  cidr_block = var.private_subnet_B_CIDR
  availability_zone = "${var.vpc_region}b"
}

resource "aws_subnet" "eks_database_subnet_A" {
  vpc_id     = aws_vpc.eks_vpc.id
  cidr_block = var.database_subnet_A_CIDR
  availability_zone = "${var.vpc_region}a"
}

resource "aws_subnet" "eks_database_subnet_B" {
  vpc_id     = aws_vpc.eks_vpc.id
  cidr_block = var.database_subnet_B_CIDR
  availability_zone = "${var.vpc_region}b"
}

resource "aws_internet_gateway" "eks_ig" {
  vpc_id = aws_vpc.eks_vpc.id
}

resource "aws_nat_gateway" "eks_nat_gw" {
  vpc_id = aws_vpc.eks_vpc.id
  availability_mode = "regional"

  availability_zone_address {
    allocation_ids    = [var.eip_allocation_id_a]
    availability_zone = "${var.vpc_region}a"
  }
  availability_zone_address {
    allocation_ids    = [var.eip_allocation_id_b]
    availability_zone = "${var.vpc_region}b"
  }
}

resource "aws_route_table" "public_route" {
  vpc_id = aws_vpc.eks_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.eks_ig.id
  }
}

resource "aws_route_table" "private_route" {
  vpc_id = aws_vpc.eks_vpc.id

  route {
    cidr_block = var.vpc_cidr
    gateway_id = "local"
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.eks_nat_gw.id
  }
}

resource "aws_route_table_association" "public_assoc_A" {
  subnet_id      = aws_subnet.eks_public_subnet_A.id
  route_table_id = aws_route_table.public_route.id
}

resource "aws_route_table_association" "public_assoc_B" {
  subnet_id      = aws_subnet.eks_public_subnet_B.id
  route_table_id = aws_route_table.public_route.id
}

resource "aws_route_table_association" "private_assoc_A" {
  subnet_id      = aws_subnet.eks_private_subnet_A.id
  route_table_id = aws_route_table.private_route.id
}

resource "aws_route_table_association" "private_assoc_B" {
  subnet_id      = aws_subnet.eks_private_subnet_B.id
  route_table_id = aws_route_table.private_route.id
}

resource "aws_route_table_association" "database_subnet_private_route_assoc_A" {
  subnet_id      = aws_subnet.eks_database_subnet_A.id
  route_table_id = aws_route_table.private_route.id
}

resource "aws_route_table_association" "database_subnet_private_route_assoc_B" {
  subnet_id      = aws_subnet.eks_database_subnet_B.id
  route_table_id = aws_route_table.private_route.id
}

resource "aws_security_group" "eks_vpc_endpoint_sg" {
  name   = "vpc-endpoint-security_group"
  vpc_id = aws_vpc.eks_vpc.id

  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"] 
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}

resource "aws_vpc_endpoint" "eks_vpc_endpoint" {
	for_each = local.services

	vpc_id = aws_vpc.eks_vpc.id
	service_name = each.value.name
	vpc_endpoint_type = "Interface"
	security_group_ids = [aws_security_group.eks_vpc_endpoint_sg.id]
	private_dns_enabled = true
	ip_address_type = "ipv4"
	subnet_ids = [aws_subnet.eks_private_subnet_A.id, aws_subnet.eks_private_subnet_B.id]
}

resource "aws_vpc_endpoint" "s3_endpoint" {
	vpc_id = aws_vpc.eks_vpc.id
	service_name = "com.amazonaws.${var.vpc_region}.s3"
	vpc_endpoint_type = "Gateway"
	private_dns_enabled = false
	route_table_ids = [aws_route_table.private_route.id]
}

