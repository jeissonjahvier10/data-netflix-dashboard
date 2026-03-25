resource "aws_apigatewayv2_api" "dashboard_api" {
  name          = "${var.project_name}-${var.environment}-api"
  protocol_type = "HTTP"

  cors_configuration {
    allow_headers = ["content-type"]
    allow_methods = ["GET", "OPTIONS"]
    allow_origins = ["*"]
    max_age       = 300
  }
}

resource "aws_apigatewayv2_integration" "api_lambda_integration" {
  api_id                 = aws_apigatewayv2_api.dashboard_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.api_dashboard.invoke_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "health_route" {
  api_id    = aws_apigatewayv2_api.dashboard_api.id
  route_key = "GET /health"
  target    = "integrations/${aws_apigatewayv2_integration.api_lambda_integration.id}"
}

resource "aws_apigatewayv2_route" "kpis_route" {
  api_id    = aws_apigatewayv2_api.dashboard_api.id
  route_key = "GET /kpis"
  target    = "integrations/${aws_apigatewayv2_integration.api_lambda_integration.id}"
}

resource "aws_apigatewayv2_route" "charts_route" {
  api_id    = aws_apigatewayv2_api.dashboard_api.id
  route_key = "GET /charts"
  target    = "integrations/${aws_apigatewayv2_integration.api_lambda_integration.id}"
}

resource "aws_apigatewayv2_route" "filters_route" {
  api_id    = aws_apigatewayv2_api.dashboard_api.id
  route_key = "GET /filters"
  target    = "integrations/${aws_apigatewayv2_integration.api_lambda_integration.id}"
}

resource "aws_apigatewayv2_stage" "default_stage" {
  api_id      = aws_apigatewayv2_api.dashboard_api.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_lambda_permission" "allow_api_gateway_to_invoke_api_lambda" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.api_dashboard.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.dashboard_api.execution_arn}/*/*"
}