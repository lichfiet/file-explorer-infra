##
## Variables
##
variable "vpc_name" {
    type = string
    description = "name of the vpc prefixed to all objects"
    default = "file-explorer"
}

variable "vpc_region" {
  type = string
  description = "aws region"
  default = "us-west-1"
}

variable "vpc_cidr" {
  type = string
  description = "CIDR block for the VPC"
  default = "10.0.0.0/16"
}