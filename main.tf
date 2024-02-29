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


//
// define ec2 instance
//
# resource "aws_instance" "ec2instance" {
#   ami           = "ami-07619059e86eaaaa2" // Amazon Linux 2023 AMI
#   instance_type = "t2.micro"              // Smallest free tier instance type

#   tags = {
#     Name = "${var.project_name}-ec2-instance"
#   }
# }
