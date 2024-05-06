module "label_vpc" {
  source     = "cloudposse/label/null"
  version    = "0.25.0"
  context    = module.base_label.context
  name       = "vpc"
  attributes = ["main"]
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = module.label_vpc.tags
}

data "aws_availability_zone" "subnet_az" {
  name = "us-east-1c"
}

module "subnet_addrs" {
  source          = "hashicorp/subnets/cidr"
  base_cidr_block = var.vpc_cidr
  networks = [
    { name = "private", new_bits = 4 },
    { name = "public", new_bits = 4 }
  ]
}

resource "aws_subnet" "subnet" {
  count                  = length(module.subnet_addrs.networks)
  vpc_id                 = aws_vpc.main.id
  cidr_block             = module.subnet_addrs.networks[count.index].cidr_block
  map_public_ip_on_launch = module.subnet_addrs.networks[count.index].name == "public"
  tags = merge(module.label_vpc.tags, {
    "Name" = "${module.subnet_addrs.networks[count.index].name}_subnet"
  })
  availability_zone = data.aws_availability_zone.subnet_az.name
}

resource "aws_internet_gateway" "public_iGW" {
  vpc_id = aws_vpc.main.id
  tags = merge(module.label_vpc.tags, {
    "Name" = "public_iGW"
  })
}

resource "aws_route_table" "rt" {
  count = 2

  vpc_id = aws_vpc.main.id
  route {
    cidr_block = count.index == 0 ? "0.0.0.0/0" : "0.0.0.0/1"
    gateway_id = aws_internet_gateway.public_iGW.id
  }
  tags = merge(module.label_vpc.tags, {
    "Name" = count.index == 0 ? "public_route_table" : "private_route_table"
  })
}

resource "aws_route_table_association" "rt_association" {
  count = 2

  subnet_id      = aws_subnet.subnet[count.index].id
  route_table_id = aws_route_table.rt[count.index].id
}

resource "aws_nat_gateway" "nat-GW" {
  allocation_id = aws_eip.elastic-ip-nat-GW.id
  subnet_id     = aws_subnet.subnet[0].id
  depends_on    = [aws_eip.elastic-ip-nat-GW]
  tags = merge(module.label_vpc.tags, {
    "Name" = "Nat-Gateway"
  })
}

resource "aws_eip" "elastic-ip-nat-GW" {
  domain = "vpc"
  tags = merge(module.label_vpc.tags, {
    "Name" = "elastic-IP"
  })
}

resource "aws_route" "nat-GW-route" {
  route_table_id         = aws_route_table.rt[1].id
  nat_gateway_id         = aws_nat_gateway.nat-GW.id
  destination_cidr_block = aws_subnet.subnet[1].cidr_block
}
