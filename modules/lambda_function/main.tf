locals {
  account_id = data.aws_caller_identity.current.account_id
  region = data.aws_region.current.name
}

module "lambda_function" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 4.0"

  function_name = var.lambda_function_name
  description   = var.lambda_function_description
  handler       = "run.sh"
  runtime       = "nodejs20.x"
  publish       = true
  layers        = ["arn:aws:lambda:${local.region}:${local.account_id}:layer:LambdaAdapterLayerX86:23"]
  environment_variables = {
    PORT = "8000"
    AWS_LAMBDA_EXEC_WRAPPER = "/opt/bootstrap"
    RUST_LOG = "info"
  }

  create_package         = false
  local_existing_package = "./../lambda.zip"

  allowed_triggers = {
    AllowExecutionFromAPIGateway = {
      service    = "apigateway"
      source_arn = "${var.apigatewayv2_api_execution_arn}/*/*"
    }
  }

  tags = {
    Pattern = "terraform-apigw-http-lambda"
    Module  = "lambda_function"
  }
}

resource "null_resource" "always_run" {
  triggers = {
    timestamp = "${timestamp()}"
  }
}
resource "null_resource" "s3_sync" {
    depends_on = [module.lambda_function.aws_lambda_function]
    provisioner "local-exec" {
        command = "aws s3 sync ../public/ s3://test-app-${local.account_id}-${local.region}-static/public/ && aws s3 sync ../.next/static/ s3://test-app-${local.account_id}-${local.region}-static/_next/static/"
    }
    
    lifecycle {
      replace_triggered_by = [
        null_resource.always_run
      ]
    }
}