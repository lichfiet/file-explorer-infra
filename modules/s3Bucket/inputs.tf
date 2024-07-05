variable "bucket_name" {
    type = string
    description = "Name of the bucket"
    default = "s3-bucket"
}

variable "s3_bucket_policy_principals" {
    type = list(string)
    description = "Principals for the s3 bucket policy, takes array of ARNs"
    default = ["*"]
}

variable "bucket_force_destroy" {
    type = bool
    description = "Whether to force destroy the bucket"
    default = false
}

variable "region" {
    type = string
    description = "Region to deploy the bucket"
    default = "us-west-1"
  
}