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
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

data "terraform_remote_state" "this" {
  backend = "remote"

  config = {
    organization = "trevors-projects"
    workspaces = {
      name = "file-explorer-infra"
    }
  }
}

#================================================================================================ 

module "vpc" {
  source         = "./modules/vpc"
  aws_access_key = var.aws_access_key
  aws_secret_key = var.aws_secret_key

  # resources of vpc will have -vpc, -subnet, -xxx added to the name
  vpc_name   = var.project_name
  vpc_region = var.region
  vpc_cidr   = "10.0.0.0/16"

  deploy_nat_gateway = false
}



module "s3Bucket" {
  source         = "./modules/s3Bucket"
  aws_access_key = var.aws_access_key
  aws_secret_key = var.aws_secret_key

  bucket_name = var.project_name

  bucket_force_destroy        = true
  s3_bucket_policy_principals = ["*"]
  region                      = var.region
}



module "amplify_app" {
  source         = "./modules/amplify_app"
  region         = var.region
  aws_access_key = var.aws_access_key
  aws_secret_key = var.aws_secret_key

  name               = var.project_name
  domain_name        = "trevorlichfield.com"
  main_branch        = "main"
  main_branch_prefix = "files"

  # Dev & Stage Branches to build & Deploy (Main is built by default)
  auto_branch_creation = false
  development_branches = ["dev"]
  staging_branches     = []

  # Repository & Build Settings
  repository       = var.frontend_repository_url
  repository_token = var.github_token
  environment_variables = {
    "VITE_API_URL" = "https://explorer.trevorlichfield.com"
  }
  # build_spec = var.build_spec
}

#================================================================================================

##
## EC2 Instance with K3s
##

resource "aws_instance" "k3s" {
  ami                         = "ami-038bba9a164eb3dc1"
  instance_type               = "t3.medium"
  key_name                    = "low-security"
  vpc_security_group_ids      = [module.vpc.vpc_ids.vpc.security_groups.public.id]
  subnet_id                   = module.vpc.vpc_ids.vpc.subnets.public1.id
  associate_public_ip_address = true
  tags = {
    Name = "k3s-server"
  }

}
