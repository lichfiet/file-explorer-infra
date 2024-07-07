#================================================================================================

##
## Intialization
##

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

#================================================================================================

##
## Modules
## 

module "vpc" {
  source = "./modules/vpc"

  # resources of vpc will have -vpc, -subnet, -xxx added to the name
  vpc_name = "${var.project_name}"
  vpc_region = "${var.region}"
  vpc_cidr = "10.0.0.0/16"

  deploy_nat_gateway = false

  ## outputs
  # vpc = module.vpc.vpc_ids.vpc_id
  # subnet_ids = {
  #   public = module.vpc.vpc_ids.subnet_ids.public_subnet
  #   private = module.vpc.vpc_ids.subnet_ids.private_subnet
  # }
  # route_tables = {
  #   public = module.vpc.vpc_ids.route_tables.public_route_table
  #   private = module.vpc.vpc_ids.route_tables.private_route_table
  # }
  # nat_gateway_id = module.vpc.vpc_ids.nat_gateway
  # internet_gateway_id = module.vpc.vpc_ids.internet_gateway
}

module "s3Bucket" {
  source = "./modules/s3Bucket"

  bucket_force_destroy = true
  # resources of s3Bucket will have -s3-bucket added to the name
  bucket_name = "${var.project_name}"
  s3_bucket_policy_principals = ["*"]
  region = "${var.region}"

  ## outputs
  # bucket_arn = module.s3Bucket.s3_ids.bucket_arn
  # bucket_name = module.s3Bucket.s3_ids.bucket_name
  # bucket_id = module.s3Bucket.s3_ids.bucket_id
}