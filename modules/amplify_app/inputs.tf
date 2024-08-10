variable "region" {
    type = string
    description = "Region to deploy the amplify app"
    default = "us-west-1"
}

variable "name" {
    type = string
    description = "Name of the amplify app" 
    default = "amplify-app"
}

variable "domain_name" {
    type = string
    description = "Domain name of the amplify app"
}

variable "development_branches" {
    type = set(string)
    description = "Dev branches of the amplify app"
    default = ["dev"]
}

variable "staging_branches" {
    type = set(string)
    description = "Staging branches of the amplify app"
    default = []
}

variable "environment_variables" {
    type = map(string)
    description = "Environment variables of the amplify app"
    default = {}
  
}

variable "repository" {
    type = string
    description = "Repository of the amplify app"
}

variable "build_spec" {
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
    description = "Wait for domain verification on creation"
    default = true
  
}

variable "domain_enable_auto_sub_domain" {
    type = bool
    description = "Enable auto sub domain"
    default = true
  
}

variable "build_directory" {
    type = string
    description = "Build directory of the amplify app"
    default = "dist"
}

variable "auto_branch_creation" {
    type = bool
    description = "Enable auto branch creation"
    default = true
}

variable "repository_token" {
    type = string
    description = "Repository token of the amplify app"
    default = ""
    sensitive = true
}

variable "main_branch_prefix" {
    type = string
    description = "Main branch domain prefix of the amplify app"
    default = "main"
  
}
