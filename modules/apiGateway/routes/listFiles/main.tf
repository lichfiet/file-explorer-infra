#
# Input variables
#
variable "gateway_role_arn" {
    type = string
    description = "arn of the role for the api gateway"
    default = "arn:aws:iam::123456789012:role/api-gateway-role"
}

variable "gateway_arn" {
    type = string
    description = "arn of the api gateway"
    default = "arn:aws:apigateway:us-west-1::/restapis/123456789012"
}

variable "gateway_root_resource_id" {
    type = string
    description = "root id of the api gateway"
    default = "123456789012"
  
}


## API Gateway Resources

# Create a resource for the API Gateway
resource "api_gateway_resource" "apigateway_resource_listFiles" {
  rest_api_id = var.gateway_arn
  parent_id = var.gateway_root_resource_id
  path_part = "listFiles"
}


# Create a method for the API Gateway
resource "aws_api_gateway_method" "apigateway_method" {
  rest_api_id = var.gateway_arn
  resource_id = api_gateway_resource.apigateway_resource_listFiles.id
  http_method = "GET"
  authorization = "NONE"
}

resource "aws_apigateway_integration" "api_integration" {
    type = "AWS"

    credentials = var.gateway_role_arn # input variable

    rest_api_id = var.gateway_arn
    resource_id = api_gateway_resource.apigateway_resource_listFiles.id
    
    http_method = aws_api_gateway_method.apigateway_method.http_method
    integration_http_method = "GET"

    uri = "arn:aws:apigateway:us-west-1:s3:path/{bucket}"
    request_parameters = {
        "integration.request.path.bucket" = "method.request.path.bucket"
    }
    pass_through_behavior = "when_no_match"
}

## 200 Response

resource "aws_apigateway_integration_response" "aws_apigateway_integration_response" {
    rest_api_id = var.gateway_arn
    resource_id = api_gateway_resource.apigateway_resource.id
    http_method = aws_api_gateway_method.apigateway_method.http_method
    status_code = aws_apigateway_integration.api_integration.status_code
    response_templates = {
        "application/json" = ""
    }
  
}

resource "aws_apigateway_method_response" "aws_apigateway_method_response" {
    rest_api_id = var.gateway_arn
    resource_id = api_gateway_resource.apigateway_resource.id
    http_method = aws_api_gateway_method.apigateway_method.http_method
    status_code = aws_apigateway_integration_response.aws_apigateway_integration_response.status_code
    response_models = {
        "application/json" = "Empty"
    }
}

# Output variables
output "api_gateway_resource_id" {
    value = api_gateway_resource.apigateway_resource_listFiles.id
}



