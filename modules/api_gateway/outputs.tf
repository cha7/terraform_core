output "apigatewayv2_api_execution_arn" {
  description = "The URI of the API"
  value       = module.api_gateway.api_execution_arn
}

output "api_id" {
  description = "API GW ID"
  value       = module.api_gateway.api_id
}