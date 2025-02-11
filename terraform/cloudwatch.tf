# ── CloudWatch Log Groups — one per Lambda + one for API Gateway ──────────────

resource "aws_cloudwatch_log_group" "create" {
  name              = "/aws/lambda/${aws_lambda_function.create.function_name}"
  retention_in_days = local.log_retention
}

resource "aws_cloudwatch_log_group" "get" {
  name              = "/aws/lambda/${aws_lambda_function.get.function_name}"
  retention_in_days = local.log_retention
}

resource "aws_cloudwatch_log_group" "list" {
  name              = "/aws/lambda/${aws_lambda_function.list.function_name}"
  retention_in_days = local.log_retention
}

resource "aws_cloudwatch_log_group" "delete" {
  name              = "/aws/lambda/${aws_lambda_function.delete.function_name}"
  retention_in_days = local.log_retention
}

resource "aws_cloudwatch_log_group" "api_gateway" {
  name              = "/aws/apigateway/${aws_apigatewayv2_api.bookmarks.name}"
  retention_in_days = local.log_retention
}
