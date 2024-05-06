module "label_vpc1" {
  source     = "cloudposse/label/null"
  version    = "0.25.0"
  context    = module.base_label.context
  name       = "vpc1"
  attributes = ["main"]

}

#Selectivite to choce bit count 4 or 8 ( if selevetivie 8 the create difference 2 VPC in smae AZ VPC1 4 bit and VPC2 8 bit )
module "subnet_addrs" {
  source = "hashicorp/subnets/cidr"

  base_cidr_block = var.vpc1_cidr
  networks = [
    {
      name     = "private"
      new_bits = 4
    },
    {
      name     = "public"
      new_bits = 4
    }
  ]
}

resource "aws_vpc1" "main" {
  cidr_block           = var.vpc1_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = module.label_vpc1.tags
}

data "aws_availability_zone" "subnet_az" {
  name = "us-east-1c"
}

# =========================
# Create your subnets here Same AZ-us-east-1c and Same region us-east-1c
# =========================

resource "aws_subnet" "public_subnet" {
  vpc1_id                  = aws_vpc1.main.id
  cidr_block              = module.subnet_addrs.network_cidr_blocks["public"]
  map_public_ip_on_launch = true
  tags = merge(module.label_vpc1.tags, {
    "Name" = "public_subnet"
  })
  availability_zone = data.aws_availability_zone.subnet_az.name
}

resource "aws_subnet" "private_subnet" {
  vpc1_id     = aws_vpc1.main.id
  cidr_block = module.subnet_addrs.network_cidr_blocks["private"]
  tags = merge(module.label_vpc1.tags, {
    "Name" = "private_subnet"
  })
  availability_zone = data.aws_availability_zone.subnet_az.name

}

#internet gateway & route tables

resource "aws_internet_gateway" "public_iGW" {

  vpc1_id = aws_vpc1.main.id
  tags = merge(module.label_vpc1.tags, {
    "Name" = "public_iGW"
  })
}

resource "aws_route_table" "public_rt" {

  vpc1_id = aws_vpc1.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.public_iGW.id
  }
  tags = merge(module.label_vpc1.tags, {
    "Name" = "public_route_table"
  })
}

resource "aws_route_table_association" "public_rt_association" {

  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id

}

resource "aws_route_table" "private_rt" {

  vpc1_id = aws_vpc1.main.id
  tags = merge(module.label_vpc1.tags, {
    "Name" = "private_route_table"
  })
}

resource "aws_route_table_association" "private_rt_association" {

  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_rt.id

}
resource "aws_nat_gateway" "nat-GW" {

  allocation_id = aws_eip.elastic-ip-nat-GW.id
  subnet_id     = aws_subnet.public_subnet.id

  depends_on = [aws_eip.elastic-ip-nat-GW]
  tags = merge(module.label_vpc1.tags, {
    "Name" = "Nat-Gateway"
  })
}

resource "aws_eip" "elastic-ip-nat-GW" {
  domain = "vpc1"
  tags = merge(module.label_vpc1.tags, {
    "Name" = "elastic-IP"
  })
}
resource "aws_route" "nat-GW-route" {
  route_table_id         = aws_route_table.private_rt.id
  nat_gateway_id         = aws_nat_gateway.nat-GW.id
  destination_cidr_block = aws_subnet.public_subnet.cidr_block
}
