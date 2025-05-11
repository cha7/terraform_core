locals {
  account_id = data.aws_caller_identity.current.account_id
  region = data.aws_region.current.name
  security_group_list = split(",", data.aws_ssm_parameter.security_group_list.value)
  subnet_list =  split(",", data.aws_ssm_parameter.subnet_list.value)

}

resource "aws_lambda_alias" "stable" {
  depends_on = [module.lambda_function]
  name             = "stable"
  description      = "stable version"
  function_name    = module.lambda_function.lambda_function_qualified_arn
  function_version = module.lambda_function.lambda_function_version
  
}

module "lambda_function" {
  depends_on = [data.aws_ssm_parameter.security_group_list, data.aws_ssm_parameter.subnet_list]
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 4.0"

  function_name = var.lambda_function_name
  description   = var.lambda_function_description
  handler       = "run.sh"
  runtime       = "nodejs20.x"
  publish       = true
  layers        = ["arn:aws:lambda:${local.region}:753240598075:layer:LambdaAdapterLayerX86:23"]

  vpc_security_group_ids = [local.security_group_list[0]]
  vpc_subnet_ids         = [local.subnet_list[0], local.subnet_list[1]]
  attach_network_policy  = true

  role_permissions_boundary = "arn:aws:iam::${local.account_id}:policy/test-boundary"
  
  attach_policy_json     = true
  policy_json            = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:CreateNetworkInterface",
                "sns:Publish",
                "secretsmanager:GetSecretValue",
                "ecs:RunTask",
                "ec2:DescribeNetworkInterfaces",
                "ec2:DeleteNetworkInterface"
            ],
            "Resource": "*"
        }
    ]
  })
  
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

data "aws_ssm_parameter" "security_group_list" {
  name = "security-group-list"
}

data "aws_ssm_parameter" "subnet_list" {
  name = "subnet-list"
}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "region" {
  value = data.aws_region.current.name
}