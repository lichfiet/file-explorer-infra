variable "aws_access_key" {
    type = string
    description = "AWS access key"
}

variable "aws_secret_key" {
    type = string
    description = "AWS secret key"
}

##
## Variables
##
variable "vpc_name" {
    type = string
    description = "name of the vpc, all objects get prefixed with this"
    default = "file-explorer"
}

variable "vpc_region" {
  type = string
  description = "aws region vpc deploys in"
  default = "us-west-1"
}

variable "vpc_cidr" {
  type = string
  description = "CIDR block for the VPC"
  default = "10.0.0.0/16"
}

variable "deploy_nat_gateway" {
  type = bool
  description = "whether to create a nat gateway"
  default = true
}