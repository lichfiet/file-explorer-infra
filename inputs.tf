variable "environment" {
  type = string
  description = "environment of the project"
  default = "dev"
}

variable "project_name" {
    type = string
    description = "name of the project"
    default = "file-explorer"
}

variable "region" {
    type = string
    description = "region of the project"
    default = "us-west-1"  
}

variable "app_name" {
    type = string
    description = "Name of the amplify app"
    default = "amplify-app"
}

variable "github_token" {
    type = string
    description = "Github token"
}