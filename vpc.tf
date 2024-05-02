variable "aws_region" {
  description = "AWS region to use"
  type        = string
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "subnet_cidr_prefix" {
  description = "The prefix for the subnet CIDR block"
  type        = number
  default     = 24
}

resource "aws_vpc" "my_vpc" {
  cidr_block = var.vpc_cidr_block
}

resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = cidrsubnet(var.vpc_cidr_block, var.subnet_cidr_prefix, 0)
  availability_zone = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "PublicSubnet"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = cidrsubnet(var.vpc_cidr_block, var.subnet_cidr_prefix, 1)
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "PrivateSubnet"
  }
}

data "aws_availability_zones" "available" {}

provider "aws" {
  region = var.aws_region
}
