provider "aws" {
  region = "us-west-2"
}

module "api_gateway" {

  source  = "terraform-aws-modules/apigateway-v2/aws"
  version = "5.2.1"

  name          = var.api_gateway_name
  description   = var.api_gateway_description
  protocol_type = "HTTP"

  create_domain_name = false
  create_domain_records = false
  create_certificate    = false

  

  cors_configuration = {
    allow_headers = ["content-type", "x-amz-date", "authorization", "x-api-key", "x-amz-security-token", "x-amz-user-agent"]
    allow_methods = ["*"]
    allow_origins = ["*"]
  }

  routes = {
    "ANY /" = {
      integration = {
        uri             = var.lambda_function_arn
        payload_format_version = "2.0"
      }
    }

    "ANY /_next/{proxy+}" = {
      integration = {
        uri         = "http://${var.s3_bucket_website_endpoint}/_next"
        type                    = "HTTP_PROXY"
        method                  = "ANY"
        payload_format_version  = "1.0"
        timeout_milliseconds    = "30000"
        request_parameters      = {
          "overwrite:header.referer" = "${module.api_gateway.api_id}"
          "overwrite:path"           = "$request.path"
        }
      }
    }

    "ANY /public/{proxy+}" = {
      integration = {
        uri         = "http://${var.s3_bucket_website_endpoint}/public"
        type                    = "HTTP_PROXY"
        method                  = "ANY"
        payload_format_version  = "1.0"
        timeout_milliseconds    = "30000"
        request_parameters      = {
          "overwrite:header.referer" = "${module.api_gateway.api_id}"
          "overwrite:path"           = "$request.path"
        }
      }
    }
  }

  tags = {
    Pattern = "terraform-apigw-http-lambda"
    Module  = "api_gateway"
  }
}