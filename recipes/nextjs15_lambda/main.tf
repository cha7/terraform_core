
variable "input_region" {
  type = string
}

provider "aws" {
  region = var.input_region
}

locals {
  application_name                  = "test-app"
  application_description           = "just a test"

  # Do not modify
  account_id                        = data.aws_caller_identity.current.account_id
  region                            = data.aws_region.current.name
}




module "lambda_function" {
    # Do not modify
    source                          = "git::https://github.com/cha7/terraform_core//modules/lambda_function"
    lambda_function_name            = local.application_name
    lambda_function_description     = local.application_description
    apigatewayv2_api_execution_arn  = module.api_gateway.apigatewayv2_api_execution_arn
}

module "api_gateway" {
    # Do not modify
    source                          = "git::https://github.com/cha7/terraform_core//modules/api_gateway"
    lambda_function_arn             = module.lambda_function.lambda_function_arn
    api_gateway_name                = local.application_name
    api_gateway_description         = local.application_description
    s3_bucket_website_endpoint      = module.s3_bucket.s3_bucket_website_endpoint
}

module "s3_bucket" {
    # Do not modify
    source                          = "git::https://github.com/cha7/terraform_core//modules/s3_bucket"
    bucket_name                     = "${local.application_name}-${local.account_id}-${local.region}-static"
    api_id                          = module.api_gateway.api_id
}



data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

output "account_id" {
  value                             = data.aws_caller_identity.current.account_id
}

output "region" {
  value                             = data.aws_region.current.name
}
