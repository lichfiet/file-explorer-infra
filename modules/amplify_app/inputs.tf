variable "region" {
    type = string
    description = "Region to deploy the amplify app"
    default = "us-west-1"
}

variable "app_name" {
    type = string
    description = "Name of the amplify app"
    default = "amplify-app"
}

variable "app_domain_name" {
    type = string
    description = "Domain name of the amplify app"
}

variable "app_environment" {
    type = string
    description = "Environment of the amplify app"
    default = "dev"
}

variable "app_development_branches" {
    type = set(string)
    description = "Dev branches of the amplify app"
    default = ["dev"]
}

variable "app_staging_branches" {
    type = set(string)
    description = "Staging branches of the amplify app"
    default = []
}

variable "app_environment_variables" {
    type = map(string)
    description = "Environment variables of the amplify app"
    default = {}
  
}

variable "app_repository" {
    type = string
    description = "Repository of the amplify app"
    default = "https://github.com/lichfiet/file-explorer-web.git"
  
}

variable "app_build_spec" {
    type        = string
    description = "Build spec for the amplify app"
    default     = <<-EOT
    version: 1 
    frontend: 
      phases: 
        preBuild: 
          commands: 
            - npm ci --cache .npm --prefer-offline --force 
        build: 
          commands: 
          - npm run build 
      artifacts: 
        baseDirectory: dist
        files: 
        - '**/*' 
      cache: 
        paths:  
          - .npm/**/*   
    EOT
}

variable "domain_wait_for_verification" {
    type = bool
    description = "Wait for domain verification"
    default = true
  
}

variable "domain_enable_auto_sub_domain" {
    type = bool
    description = "Enable auto sub domain"
    default = true
  
}

variable "app_build_directory" {
    type = string
    description = "Build directory of the amplify app"
    default = "dist"
}

variable "app_repository_token" {
    type = string
    description = "Repository token of the amplify app"
    default = ""
    sensitive = true
}

