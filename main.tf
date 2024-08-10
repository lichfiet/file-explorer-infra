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

module "vpc" {
  source = "./modules/vpc"

  # resources of vpc will have -vpc, -subnet, -xxx added to the name
  vpc_name = "${var.project_name}"
  vpc_region = "${var.region}"
  vpc_cidr = "10.0.0.0/16"

  deploy_nat_gateway = false
}



module "s3Bucket" {
  source = "./modules/s3Bucket"

  # resources of s3Bucket will have -s3-bucket added to the name
  bucket_name = "${var.project_name}"

  bucket_force_destroy = true
  s3_bucket_policy_principals = ["*"]
  region = "${var.region}"
}



module "amplify_app" {
  source = "./modules/amplify_app"
  region = "${var.region}"

  name = "${var.project_name}"
  domain_name = "trevorlichfield.com"
  main_branch = "main"
  main_branch_prefix = "files"

  # Dev & Stage Branches to build & Deploy (Main is built by default)
  auto_branch_creation = false
  development_branches = ["dev"]
  staging_branches = []

  # Repository & Build Settings
  repository = "https://github.com/lichfiet/file-explorer-web"
  repository_token = var.github_token
  environment_variables = {
    "VITE_API_URL" = "https://explorer.trevorlichfield.com"
  }
  # build_spec = var.build_spec
}