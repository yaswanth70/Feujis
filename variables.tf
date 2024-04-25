# variables.tf

variable "aws_region" {
  description = "AWS region where the resources will be provisioned"
  default     = "us-west-2" # Change this to your desired region
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16" # Change this to your desired VPC CIDR block
}

variable "vpc_name" {
  description = "Name for the VPC"
  default     = "my-vpc" # Change this to your desired VPC name
}

variable "tags" {
  description = "Tags to apply to AWS resources"
  type        = map(string)
  default     = {
    Environment = "Production"
  }
}
