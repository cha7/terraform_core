variable "bucket_name" {
  description = "The bucket name for static files"
}

variable "api_id" {
  description = "API GW ID"
}

variable  "apigatewayv2_api_execution_arn" {
  description = "The URI of the API"
}

variable "lambda_function_name" {
  description = "The name of the Lambda Function"
}

variable "lambda_function_description" {
  description = "The name of the Lambda Function"
}

variable "lambda_function_arn" {
  description = "The ARN of the Lambda Function"
}

variable "api_gateway_name" {
  description = "The name of the APIGW"
}

variable "api_gateway_description" {
  description = "The name of the APIGW"
}

variable "s3_bucket_website_endpoint" {
  description = "Bucket web endpoint"
}