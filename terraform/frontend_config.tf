resource "local_file" "frontend_config" {
  filename = "../frontend/config.js"
  content  = <<-EOT
window.APP_CONFIG = {
  apiUrl: "${aws_apigatewayv2_api.dashboard_api.api_endpoint}"
};
EOT
}