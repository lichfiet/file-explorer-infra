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
  region = "us-west-1"
  #   access_key = local.envs["AWS_ACCESS_KEY_ID"]
  #   secret_key = local.envs["AWS_SECRET_ACCESS_KEY"]
}

############################################################################################################

##
## S3 Bucket
##

resource "aws_s3_bucket" "s3bucket" {
  bucket = "${var.bucket_name}-s3-bucket"

  tags = {
    name = "${var.bucket_name}-s3-bucket"
  }
}

resource "aws_s3_bucket_public_access_block" "s3bucketpublicaccessblock" {
  bucket = aws_s3_bucket.s3bucket.id

  block_public_acls       = true
  block_public_policy     = false
  ignore_public_acls      = true
  restrict_public_buckets = true
}

############################################################################################################

##
## S3 Bucket Policy
##
data "aws_iam_policy_document" "s3bucketpolicy_document" {
  statement {
    principals {
      type        = "AWS"
      # identifiers = ["*"] by default unless specified
      identifiers = var.s3_bucket_policy_principals
    }
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:ListBucket",
      "s3:DeleteObject"
    ]
    resources = [
      aws_s3_bucket.s3bucket.arn,
    "${aws_s3_bucket.s3bucket.arn}/*"]
  }
}

resource "aws_s3_bucket_policy" "s3bucketpolicy" {
  bucket = aws_s3_bucket.s3bucket.id
  policy = data.aws_iam_policy_document.s3bucketpolicy_document.json
}
