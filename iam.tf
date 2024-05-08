// -= define api gateway role and policy =-
resource "aws_iam_role" "gatewayrole" {
    name = "api-gateway-role"
    assume_role_policy = jsonencode({
        "Version": "2012-10-17",
        "Statement": [
                {
                        "Effect": "Allow",
                        "Principal": {
                                "Service": [
                                        "apigateway.amazonaws.com"
                                ]
                        },
                        "Action": "sts:AssumeRole"
                }
        ]
    })
}

// Policy to enable s3 access
resource "aws_iam_policy" "gatewaypolicy" {
    name        = "api-gateway-policy"
    description = "Policy for API Gateway to access S3"
    policy      = jsonencode({
        "Version": "2012-10-17",
        "Statement": [
            {
                "Action"   : ["s3:ListBucket", "s3:PutObject", "s3:GetObject", "s3:DeleteObject"], // enables delete, list, and uploading files to bucket resource
                "Effect"   : "Allow",
                "Resource" : "${aws_s3_bucket.s3bucket.arn}/*" // allows access to the bucket setup in ./s3.tf
            }
        ]
    })

    depends_on = [aws_iam_role.gatewayrole]
}

// attach policy to role
resource "aws_iam_role_policy_attachment" "gatewaypolicyattachment" {
    role       = aws_iam_role.gatewayrole.name
    policy_arn = aws_iam_policy.gatewaypolicy.arn
}

//define policy for api gateway access to S3, attached to bucket in ./s3.tf
data "aws_iam_policy_document" "s3bucketpolicy" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["${aws_iam_role.gatewayrole.arn}"]
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