# Define variables
variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "aws_region" {
  description = "The AWS region where resources will be created"
  default     = "us-east-1"
}

# Define networks variable for subnet_cidrs module
variable "networks" {
  description = "Networks to split into subnets"
  type        = list(object({
    cidr_block        = string
    availability_zone = string
  }))
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
  base_cidr_block = var.vpc_cidr_block  # Assuming VPC CIDR block as the base CIDR block
  networks        = var.networks
}

