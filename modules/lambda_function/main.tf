locals {
  account_id = data.aws_caller_identity.current.account_id
  region = data.aws_region.current.name
  security-group-list = data.aws_ssm_parameter.security-group-list.value
  subnet-list = data.aws_ssm_parameter.subnet-list.subnet-list.value
}

variable "security-group-list" {
 }

variable "subnet-list" {
 }

data "aws_ssm_parameter" "security-group-list" {
  name = var.security-group-list
}

data "aws_ssm_parameter" "subnet-list" {
  name = var.subnet-list
}

module "lambda_function" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 4.0"

  function_name = var.lambda_function_name
  description   = var.lambda_function_description
  handler       = "run.sh"
  runtime       = "nodejs20.x"
  publish       = true
  layers        = ["arn:aws:lambda:${local.region}:753240598075:layer:LambdaAdapterLayerX86:23"]

  vpc_subnet_ids         = local.subnet-list
  vpc_security_group_ids = local.security-group-list
  attach_network_policy = true
  
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

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "region" {
  value = data.aws_region.current.name
}