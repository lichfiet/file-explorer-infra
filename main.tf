// Define providers
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
  region     = "us-west-1"
  access_key = local.envs["AWS_ACCESS_KEY_ID"]
  secret_key = local.envs["AWS_SECRET_ACCESS_KEY"]
}


module "vpc" {
  source = "./modules/vpc"

  # Outputs of vpc will have -vpc, -subnet, -xxx added to the name
  vpc_name = "${var.project_name}"
  vpc_region = "us-west-1"
  vpc_cidr = "10.0.0.0/16"
}
