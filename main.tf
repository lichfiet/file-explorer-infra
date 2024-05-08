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

  # resources of vpc will have -vpc, -subnet, -xxx added to the name
  vpc_name = "${var.project_name}"
  vpc_region = "us-west-1"
  vpc_cidr = "10.0.0.0/16"
}

module "s3Bucket" {
  source = "./modules/s3Bucket"

  # resources of s3Bucket will have -s3-bucket added to the name
  bucket_name = "${var.project_name}"
  s3_bucket_policy_principals = ["*"]
}