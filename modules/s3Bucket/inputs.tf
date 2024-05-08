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