# main.tf

provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.0.0"

  name = var.vpc_name

  cidr = var.vpc_cidr

  azs             = ["${var.aws_region}a"]
  private_subnets = ["${cidrsubnet(var.vpc_cidr, 8, 1)}"]
  public_subnets  = ["${cidrsubnet(var.vpc_cidr, 8, 2)}"]

  enable_nat_gateway = true

  tags = var.tags
}

module "public_subnet" {
  source  = "terraform-aws-modules/subnet/aws"
  version = "2.0.0"

  vpc_id            = module.vpc.vpc_id
  cidr_block        = module.vpc.public_subnets[0]
  availability_zone = var.aws_region
  map_public_ip_on_launch = true

  tags = var.tags
}

module "private_subnet" {
  source  = "terraform-aws-modules/subnet/aws"
  version = "2.0.0"

  vpc_id            = module.vpc.vpc_id
  cidr_block        = module.vpc.private_subnets[0]
  availability_zone = var.aws_region

  tags = var.tags
}

module "public_route_table" {
  source  = "terraform-aws-modules/route-table/aws"
  version = "3.0.0"

  vpc_id = module.vpc.vpc_id

  routes = [
    {
      cidr_block = "0.0.0.0/0"
      gateway_id = module.vpc.internet_gateway_id
    }
  ]

  subnet_ids = [module.public_subnet.subnet_id]

  tags = var.tags
}

module "private_route_table" {
  source  = "terraform-aws-modules/route-table/aws"
  version = "3.0.0"

  vpc_id = module.vpc.vpc_id

  subnet_ids = [module.private_subnet.subnet_id]

  tags = var.tags
}
