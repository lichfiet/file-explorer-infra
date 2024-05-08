#
# Input variables
#

# role for accessing s3
variable "gateway_s3_role_arn" {
    type = string
    description = "arn of the role for the api gateway"
    default = "arn:aws:iam::123456789012:role/api-gateway-role"
}

# arn for api gateway
variable "gateway_arn" {
    type = string
    description = "arn of the api gateway"
    default = "arn:aws:apigateway:us-west-1::/restapis/123456789012"
}

# root id of the api gateway
variable "gateway_root_resource_id" {
    type = string
    description = "root id of the api gateway"
    default = "123456789012"
  
}

