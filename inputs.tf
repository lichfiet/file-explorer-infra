locals {
  envs = { for tuple in regexall("(.*)=(.*)", file(".env")) : tuple[0] => sensitive(tuple[1]) }
}

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