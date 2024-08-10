terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.67"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-west-1"
}

############################################################################################################

#
# APP SETUP
#

resource "aws_amplify_app" "this" {
  name = "${var.app_name} ${var.app_environment}"
  repository = var.app_repository
  access_token = var.app_repository_token

  # BUILD SETTINGS
  build_spec = var.app_build_spec != null ? var.app_build_spec : var.app_build_spec
  environment_variables = var.app_environment_variables

  # AUTO BUILD & DEPLOY
  enable_auto_branch_creation = true
  auto_branch_creation_patterns = [
    "*",
    "*/**",
  ]
  auto_branch_creation_config {
    enable_auto_build = true
  }
}

############################################################################################################

#
# BRANCH DEFINITIONS
#

resource "aws_amplify_branch" "main" {
  branch_name = "main"
  app_id = aws_amplify_app.this.id

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_amplify_branch" "development" {
  for_each = var.app_development_branches

  branch_name = each.key
  app_id = aws_amplify_app.this.id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_amplify_branch" "Staging" {
  for_each = var.app_staging_branches

  branch_name = each.key
  app_id = aws_amplify_app.this.id

  lifecycle {
    create_before_destroy = true
  }
}

############################################################################################################

#
# DOMAIN SETUP
#

resource "aws_amplify_domain_association" "this" {
  app_id = aws_amplify_app.this.id
  domain_name = var.app_domain_name
  wait_for_verification = true

  # DOMAIN SETTINGS
  enable_auto_sub_domain = true

  sub_domain {
    prefix = "main"
    branch_name = "main"
  }

  lifecycle {
    create_before_destroy = true
  }
}