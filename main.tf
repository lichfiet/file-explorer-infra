// Define providers
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
  region     = "us-west-1"
  access_key = local.envs["AWS_ACCESS_KEY_ID"]
  secret_key = local.envs["AWS_SECRET_ACCESS_KEY"]
}


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

// define s3 bucket policy
resource "aws_s3_bucket_policy" "s3bucketpolicy" {
  bucket = aws_s3_bucket.s3bucket.id
  policy = data.aws_iam_policy_document.s3bucketpolicy.json
}

//define data for s3 bucket policy
data "aws_iam_policy_document" "s3bucketpolicy" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["${aws_iam_role.gatewayrole.arn}"]
    }
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:ListBucket"
    ]
    resources = [
      aws_s3_bucket.s3bucket.arn,
    "${aws_s3_bucket.s3bucket.arn}/*"]
  }
}

//
// define api gateway
//

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

resource "aws_iam_policy" "gatewaypolicy" {
    name        = "api-gateway-policy"
    description = "Policy for API Gateway to access S3"
    policy      = jsonencode({
        "Version": "2012-10-17",
        "Statement": [
            {
                "Action"   : ["s3:ListBucket", "s3:PutObject", "s3:GetObject"],
                "Effect"   : "Allow",
                "Resource" : "${aws_s3_bucket.s3bucket.arn}/*"
            }
        ]
    })

    depends_on = [aws_iam_role.gatewayrole]
}

resource "aws_iam_role_policy_attachment" "gatewaypolicyattachment" {
    role       = aws_iam_role.gatewayrole.name
    policy_arn = aws_iam_policy.gatewaypolicy.arn
}

resource "aws_api_gateway_rest_api" "apigateway" {
  name        = "file-explorer-api"
  description = "API for file explorer"
  body = jsonencode({
    "openapi" : "3.0.1",
    "info" : {
      "title" : "file-conv-api",
      "version" : "2024-01-13T23:01:41Z"
    },
    "servers" : [{
      "url" : "https://dl4z61qaj4.execute-api.us-east-1.amazonaws.com/{basePath}",
      "variables" : {
        "basePath" : {
          "default" : "dev"
        }
      }
    }],
    "paths" : {
      "/listFiles/{bucket}" : {
        "get" : {
          "parameters" : [{
            "name" : "bucket",
            "in" : "path",
            "required" : true,
            "schema" : {
              "type" : "string"
            }
          }],
          "responses" : {
            "200" : {
              "description" : "200 response",
              "content" : {
                "application/json" : {
                  "schema" : {
                    "$ref" : "#/components/schemas/Empty"
                  }
                }
              }
            }
          },
          "x-amazon-apigateway-integration" : {
            "credentials" : "${aws_iam_role.gatewayrole.arn}",
            "httpMethod" : "GET",
            "uri" : "arn:aws:apigateway:us-west-1:s3:path/{bucket}",
            "responses" : {
              "default" : {
                "statusCode" : "200"
              }
            },
            "requestParameters" : {
              "integration.request.path.bucket" : "method.request.path.bucket"
            },
            "passthroughBehavior" : "when_no_match",
            "type" : "aws"
          }
        }
      },
      "/deleteFile/{bucket}/{fileName}" : {
        "delete" : {
          "parameters" : [{
            "name" : "fileName",
            "in" : "path",
            "required" : true,
            "schema" : {
              "type" : "string"
            }
            }, {
            "name" : "bucket",
            "in" : "path",
            "required" : true,
            "schema" : {
              "type" : "string"
            }
          }],
          "responses" : {
            "200" : {
              "description" : "200 response",
              "content" : {
                "application/json" : {
                  "schema" : {
                    "$ref" : "#/components/schemas/Empty"
                  }
                }
              }
            }
          },
          "x-amazon-apigateway-integration" : {
            "credentials" : "${aws_iam_role.gatewayrole.arn}",
            "httpMethod" : "DELETE",
            "uri" : "arn:aws:apigateway:us-west-1:s3:path/{bucket}/{object}", // url path parameters
            "responses" : {
              "default" : {
                "statusCode" : "200"
              }
            },
            "requestParameters" : {
              "integration.request.path.object" : "method.request.path.fileName", // ${fileName} path parameter
              "integration.request.path.bucket" : "method.request.path.bucket" // ${bucket} path parameter
            },
            "passthroughBehavior" : "when_no_match",
            "type" : "aws"
          }
        }
      },
      "/getFile/{bucket}/{fileName}" : {
        "get" : {
          "parameters" : [{
            "name" : "fileName",
            "in" : "path",
            "required" : true,
            "schema" : {
              "type" : "string"
            }
            }, {
            "name" : "bucket",
            "in" : "path",
            "required" : true,
            "schema" : {
              "type" : "string"
            }
          }],
          "responses" : {
            "200" : {
              "description" : "200 response",
              "content" : {
                "application/json" : {
                  "schema" : {
                    "$ref" : "#/components/schemas/Empty"
                  }
                }
              }
            }
          },
          "x-amazon-apigateway-integration" : {
            "credentials" : "${aws_iam_role.gatewayrole.arn}",
            "httpMethod" : "GET",
            "uri" : "arn:aws:apigateway:us-west-1:s3:path/{bucket}/{object}",
            "responses" : {
              "default" : {
                "statusCode" : "200"
              }
            },
            "requestParameters" : {
              "integration.request.path.object" : "method.request.path.fileName",
              "integration.request.path.bucket" : "method.request.path.bucket"
            },
            "passthroughBehavior" : "when_no_match",
            "type" : "aws"
          }
        }
      },
      "/uploadFile/{bucket}/{fileName}" : {
        "put" : {
          "parameters" : [{
            "name" : "fileName",
            "in" : "path",
            "required" : true,
            "schema" : {
              "type" : "string"
            }
            }, {
            "name" : "bucket",
            "in" : "path",
            "required" : true,
            "schema" : {
              "type" : "string"
            }
          }],
          "responses" : {
            "200" : {
              "description" : "200 response",
              "content" : {
                "application/json" : {
                  "schema" : {
                    "$ref" : "#/components/schemas/Empty"
                  }
                }
              }
            }
          },
          "x-amazon-apigateway-integration" : {
            "credentials" : "${aws_iam_role.gatewayrole.arn}",
            "httpMethod" : "PUT",
            "uri" : "arn:aws:apigateway:us-west-1:s3:path/{bucket}/{object}",
            "responses" : {
              "default" : {
                "statusCode" : "200"
              }
            },
            "requestParameters" : {
              "integration.request.path.object" : "method.request.path.fileName",
              "integration.request.path.bucket" : "method.request.path.bucket"
            },
            "passthroughBehavior" : "when_no_match",
            "type" : "aws"
          }
        }
      }
    },
    "components" : {
      "schemas" : {
        "Empty" : {
          "title" : "Empty Schema",
          "type" : "object"
        }
      }
    },
    "x-amazon-apigateway-binary-media-types" : ["*/*"]
  })
}

//
// define ec2 instance
//
# resource "aws_instance" "ec2instance" {
#   ami           = "ami-07619059e86eaaaa2" // Amazon Linux 2023 AMI
#   instance_type = "t2.micro"              // Smallest free tier instance type

#   tags = {
#     Name = "${var.project_name}-ec2-instance"
#   }
# }
