variable  "apigatewayv2_api_execution_arn" {
  description = "The URI of the API"
}

variable "lambda_function_name" {
  description = "The name of the Lambda Function"
}

variable "lambda_function_description" {
  description = "The description of the Lambda Function"
}

variable "subnet_list" {
  description = "The subnet list of the Lambda Function"
}

variable "security_group_list" {
  description = "The SG list of the Lambda Function"
}