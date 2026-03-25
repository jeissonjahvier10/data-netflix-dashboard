output "data_bucket_name" {
  value = aws_s3_bucket.data_bucket.bucket
}

output "frontend_bucket_name" {
  value = aws_s3_bucket.frontend_bucket.bucket
}

output "frontend_website_url" {
  value = aws_s3_bucket_website_configuration.frontend_website.website_endpoint
}

output "api_url" {
  value = aws_apigatewayv2_api.dashboard_api.api_endpoint
}

output "data_processor_lambda_name" {
  value = aws_lambda_function.data_processor.function_name
}

output "api_dashboard_lambda_name" {
  value = aws_lambda_function.api_dashboard.function_name
}