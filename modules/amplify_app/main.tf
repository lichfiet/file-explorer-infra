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

  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

############################################################################################################

#
# APP SETUP
#

resource "aws_amplify_app" "this" {
  name = "${var.name}"
  repository = var.repository
  access_token = var.repository_token

  # BUILD SETTINGS
  build_spec = var.build_spec != null ? var.build_spec : var.build_spec
  environment_variables = var.environment_variables

  # AUTO BUILD & DEPLOY
  enable_auto_branch_creation = var.auto_branch_creation
  auto_branch_creation_patterns = [
    "*",
    "*/**",
  ]
  auto_branch_creation_config {
    enable_auto_build = var.auto_branch_creation
  }
}

############################################################################################################

#
# BRANCH DEFINITIONS
#

resource "aws_amplify_branch" "main" {
  app_id = aws_amplify_app.this.id

  branch_name = "main"
  stage = "PRODUCTION"

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_amplify_branch" "development" {
  for_each = var.development_branches

  app_id = aws_amplify_app.this.id

  branch_name = each.key
  stage = "DEVELOPMENT"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_amplify_branch" "Staging" {
  for_each = var.staging_branches

  app_id = aws_amplify_app.this.id

  branch_name = each.key
  stage = "DEVELOPMENT"

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
  domain_name = var.domain_name
  wait_for_verification = true

  # DOMAIN SETTINGS
  enable_auto_sub_domain = true

  sub_domain {
    prefix = var.main_branch_prefix
    branch_name = "main"
  }

  dynamic "sub_domain" {
    for_each = var.development_branches
    content {
      prefix = sub_domain.key
      branch_name = sub_domain.value
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}