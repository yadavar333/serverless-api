# ── HTTP API (API Gateway v2) ─────────────────────────────────────────────────

resource "aws_apigatewayv2_api" "bookmarks" {
  name          = "${local.prefix}-api"
  protocol_type = "HTTP"
  description   = "Bookmarks serverless REST API"

  cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["GET", "POST", "DELETE", "OPTIONS"]
    allow_headers = ["Content-Type", "Authorization"]
    max_age       = 300
  }
}

# ── $default stage with auto-deploy ──────────────────────────────────────────

resource "aws_apigatewayv2_stage" "prod" {
  api_id      = aws_apigatewayv2_api.bookmarks.id
  name        = "prod"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gateway.arn
  }
}

# ── Lambda integrations ───────────────────────────────────────────────────────

resource "aws_apigatewayv2_integration" "create" {
  api_id                 = aws_apigatewayv2_api.bookmarks.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.create.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_integration" "get" {
  api_id                 = aws_apigatewayv2_api.bookmarks.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.get.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_integration" "list" {
  api_id                 = aws_apigatewayv2_api.bookmarks.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.list.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_integration" "delete" {
  api_id                 = aws_apigatewayv2_api.bookmarks.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.delete.invoke_arn
  payload_format_version = "2.0"
}

# ── Routes ────────────────────────────────────────────────────────────────────

resource "aws_apigatewayv2_route" "create" {
  api_id    = aws_apigatewayv2_api.bookmarks.id
  route_key = "POST /bookmarks"
  target    = "integrations/${aws_apigatewayv2_integration.create.id}"
}

resource "aws_apigatewayv2_route" "get" {
  api_id    = aws_apigatewayv2_api.bookmarks.id
  route_key = "GET /bookmarks/{id}"
  target    = "integrations/${aws_apigatewayv2_integration.get.id}"
}

resource "aws_apigatewayv2_route" "list" {
  api_id    = aws_apigatewayv2_api.bookmarks.id
  route_key = "GET /bookmarks"
  target    = "integrations/${aws_apigatewayv2_integration.list.id}"
}

resource "aws_apigatewayv2_route" "delete" {
  api_id    = aws_apigatewayv2_api.bookmarks.id
  route_key = "DELETE /bookmarks/{id}"
  target    = "integrations/${aws_apigatewayv2_integration.delete.id}"
}

# ── Lambda permissions — allow API Gateway to invoke each function ─────────────

resource "aws_lambda_permission" "create" {
  statement_id  = "AllowAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.create.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.bookmarks.execution_arn}/*/*"
}

resource "aws_lambda_permission" "get" {
  statement_id  = "AllowAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.bookmarks.execution_arn}/*/*"
}

resource "aws_lambda_permission" "list" {
  statement_id  = "AllowAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.list.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.bookmarks.execution_arn}/*/*"
}

resource "aws_lambda_permission" "delete" {
  statement_id  = "AllowAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.delete.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.bookmarks.execution_arn}/*/*"
}
