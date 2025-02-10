output "api_endpoint" {
  description = "Base URL for the bookmarks API"
  value       = aws_apigatewayv2_stage.prod.invoke_url
}

output "dynamodb_table_name" {
  description = "DynamoDB table name"
  value       = aws_dynamodb_table.bookmarks.name
}

output "lambda_functions" {
  description = "Lambda function names"
  value = {
    create = aws_lambda_function.create.function_name
    get    = aws_lambda_function.get.function_name
    list   = aws_lambda_function.list.function_name
    delete = aws_lambda_function.delete.function_name
  }
}
