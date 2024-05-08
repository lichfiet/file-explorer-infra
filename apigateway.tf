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
      "url" : "https://xxx.execute-api.us-east-1.amazonaws.com/{basePath}",
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
            "404" : {
              "description" : "404 response",
              "content" : {}
            },
            "200" : {
              "description" : "200 response",
              "content" : {
                "application/json" : {
                  "schema" : {
                    "$ref" : "#/components/schemas/Empty"
                  }
                }
              }
            },
            "403" : {
              "description" : "403 response",
              "content" : {}
            }
          },
          "x-amazon-apigateway-integration" : {
            "type" : "aws",
            "credentials" : "${aws_iam_role.gatewayrole.arn}",
            "httpMethod" : "DELETE",
            "uri" : "arn:aws:apigateway:us-west-1:s3:path/{bucket}/{object}",
            "responses" : {
              "default" : {
                "statusCode" : "200"
              },
              "403" : {
                "statusCode" : "403"
              },
              "404" : {
                "statusCode" : "404"
              }
            },
            "requestParameters" : {
              "integration.request.path.object" : "method.request.path.fileName",
              "integration.request.path.bucket" : "method.request.path.bucket"
            },
            "passthroughBehavior" : "when_no_match"
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

  depends_on = [aws_iam_role.gatewayrole]
}

// default stage
resource "aws_api_gateway_deployment" "apigatewaydeployment" {
  rest_api_id = aws_api_gateway_rest_api.apigateway.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.apigateway.body))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "apigatewaystage" {
  stage_name    = "dev"
  rest_api_id   = aws_api_gateway_rest_api.apigateway.id
  deployment_id = aws_api_gateway_deployment.apigatewaydeployment.id
}


# Outputs
#====================================================================================================
output "API_Gateway_URL" {
  value = "${aws_api_gateway_deployment.apigatewaydeployment.invoke_url}${aws_api_gateway_stage.apigatewaystage.stage_name}"
}

# output "API_Gateway_API_Key" {
#   value = "Will add api key auth here later, in prod will be over VPC so there will be no need for api key"
# }