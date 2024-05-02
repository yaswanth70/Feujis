variable "aws_region" {
  description = "AWS region to use"
  type        = string
  default     = "us-east-1" # Default region can be specified here if needed
}

variable "aws_access_key" {
  description = "AWS Access Key ID for the target AWS account"
  type        = string
}

variable "aws_secret_key" {
  description = "AWS Secret Key for the target AWS account"
  type        = string
}

variable "aws_session_token" {
  description = "AWS Session Token for the target AWS account. Required only if authenticating using temporary credentials"
  type        = string
  default     = ""
}

