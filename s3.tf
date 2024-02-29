//
// define s3 bucket and policy
//

// define s3 bucket
resource "aws_s3_bucket" "s3bucket" {
  bucket = "${var.project_name}-s3-bucket"

  tags = {
    Name        = "${var.project_name}-s3-bucket"
    Environment = "${var.environment}"
  }
}

// define s3 bucket public access
resource "aws_s3_bucket_public_access_block" "s3bucketpublicaccessblock" {
  bucket = aws_s3_bucket.s3bucket.id

  block_public_acls       = true
  block_public_policy     = false
  ignore_public_acls      = true
  restrict_public_buckets = true
}

// define s3 bucket policy, attach from ./iam.tf
resource "aws_s3_bucket_policy" "s3bucketpolicy" {
  bucket = aws_s3_bucket.s3bucket.id
  policy = data.aws_iam_policy_document.s3bucketpolicy.json
}

