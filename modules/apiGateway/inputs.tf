variable "api_name" {
  type = string
  description = "name of the api prefixed to all objects"
  default = "file-explorer"
  
}

variable "api_region" {
  type = string
  description = "aws region"
  default = "us-west-2"
  
}

variable "api_methods" {
    type = list(string)
    description = "methods for the api"
    default = ["GET", "POST", "PUT", "DELETE", "OPTIONS"]
}

variable "gateway_role_arn" {
    type = string
    description = "arn of the role for the api gateway"
    default = "arn:aws:iam::123456789012:role/api-gateway-role"
  
}