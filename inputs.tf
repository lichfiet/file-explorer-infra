variable "environment" {
  type        = string
  description = "environment of the project"
  default     = "dev"
}

variable "project_name" {
  type        = string
  description = "name of the project"
  default     = "file-explorer"
}

variable "region" {
  type        = string
  description = "region of the project"
  default     = "us-west-1"
}

variable "app_name" {
  type        = string
  description = "Name of the amplify app"
  default     = "amplify-app"
}

variable "github_token" {
  type        = string
  description = "Github token"
}

variable "frontend_repository_url" {
  type        = string
  description = "Frontend repository url"
}

variable "aws_access_key" {
  type        = string
  description = "AWS access key"
}

variable "aws_secret_key" {
  type        = string
  description = "AWS secret key"
}