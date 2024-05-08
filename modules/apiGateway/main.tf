terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-west-1"
  #   access_key = local.envs["AWS_ACCESS_KEY_ID"]
  #   secret_key = local.envs["AWS_SECRET_ACCESS_KEY"]
}


resource "aws_api_gateway_rest_api" "apigateway" {
  name        = "${var.api_name}-api"
  description = "API Gateway for file explorer"
  fail_on_warnings = true
  tags = {
    name = "${var.api_name}-api"
  }
}
