# variables.tf

# Define variables
variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "aws_region" {
  description = "The AWS region where resources will be created"
  default     = "us-east-1"
}

# Fetch available AZs
data "aws_availability_zones" "available" {
  state = "available"
}

# Select an AZ
locals {
  selected_az = data.aws_availability_zones.available.names[0]
}

# Use hashicorp/subnets/cidr module to calculate subnet CIDRs
module "subnet_cidrs" {
  source          = "hashicorp/subnets/cidr"
  version         = "~> 1.0"
  vpc_cidr        = var.vpc_cidr_block
  subnet_count    = 2
  azs             = [local.selected_az]
  netmask_lengths = [24, 24]
}

# Create public subnet
resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
  cidr_block = module.subnet_cidrs.ipv4_subnet_cidrs[0]

  # Use the selected AZ
  availability_zone = local.selected_az

  tags = {
    Name = module.label.public_subnet_name
    # Add other tags as necessary
  }
}

# Create private subnet
resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.main.id
  cidr_block = module.subnet_cidrs.ipv4_subnet_cidrs[1]

  # Use the selected AZ
  availability_zone = local.selected_az

  tags = {
    Name = module.label.private_subnet_name
    # Add other tags as necessary
  }
}

# Create internet gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = module.label.internet_gateway_name
    # Add other tags as necessary
  }
}

# Create route table for public subnet
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    gateway_id     = aws_internet_gateway.gw.id
  }

  tags = {
    Name = module.label.public_route_table_name
    # Add other tags as necessary
  }
}

# Associate public subnet with the route table
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Create a null label for naming resources
module "label" {
  source = "cloudposse/label/null"
  # Pass appropriate labels and tags
  # Example:
  namespace             = "mycompany"
  stage                 = "prod"
  name                  = "vpc"
  attributes            = ["private", "public"]
  delimiter             = "-"
  tags                  = {} # Add tags here
}

# Output the selected Availability Zone
output "selected_availability_zone" {
  value = local.selected_az
}
