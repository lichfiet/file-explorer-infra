output "s3_ids" {
  value = {
    bucket_id = aws_s3_bucket.s3bucket.id
    bucket_arn = aws_s3_bucket.s3bucket.arn
    bucket_name = aws_s3_bucket.s3bucket.bucket
  }
}