# ── Archive each Lambda handler ───────────────────────────────────────────────

data "archive_file" "create" {
  type        = "zip"
  source_dir  = "${path.module}/../src/lambdas/create"
  output_path = "${path.module}/../builds/create.zip"
}

data "archive_file" "get" {
  type        = "zip"
  source_dir  = "${path.module}/../src/lambdas/get"
  output_path = "${path.module}/../builds/get.zip"
}

data "archive_file" "list" {
  type        = "zip"
  source_dir  = "${path.module}/../src/lambdas/list"
  output_path = "${path.module}/../builds/list.zip"
}

data "archive_file" "delete" {
  type        = "zip"
  source_dir  = "${path.module}/../src/lambdas/delete"
  output_path = "${path.module}/../builds/delete.zip"
}

# ── Lambda functions ──────────────────────────────────────────────────────────

locals {
  lambda_runtime = "python3.11"
  lambda_timeout = 10
  lambda_memory  = 128
}

resource "aws_lambda_function" "create" {
  function_name    = "${local.prefix}-create"
  role             = aws_iam_role.create_lambda.arn
  runtime          = local.lambda_runtime
  handler          = "handler.handler"
  filename         = data.archive_file.create.output_path
  source_code_hash = data.archive_file.create.output_base64sha256
  timeout          = local.lambda_timeout
  memory_size      = local.lambda_memory
  layers           = [aws_lambda_layer_version.utils.arn]

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.bookmarks.name
    }
  }
}

resource "aws_lambda_function" "get" {
  function_name    = "${local.prefix}-get"
  role             = aws_iam_role.get_lambda.arn
  runtime          = local.lambda_runtime
  handler          = "handler.handler"
  filename         = data.archive_file.get.output_path
  source_code_hash = data.archive_file.get.output_base64sha256
  timeout          = local.lambda_timeout
  memory_size      = local.lambda_memory
  layers           = [aws_lambda_layer_version.utils.arn]

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.bookmarks.name
    }
  }
}

resource "aws_lambda_function" "list" {
  function_name    = "${local.prefix}-list"
  role             = aws_iam_role.list_lambda.arn
  runtime          = local.lambda_runtime
  handler          = "handler.handler"
  filename         = data.archive_file.list.output_path
  source_code_hash = data.archive_file.list.output_base64sha256
  timeout          = local.lambda_timeout
  memory_size      = local.lambda_memory
  layers           = [aws_lambda_layer_version.utils.arn]

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.bookmarks.name
    }
  }
}

resource "aws_lambda_function" "delete" {
  function_name    = "${local.prefix}-delete"
  role             = aws_iam_role.delete_lambda.arn
  runtime          = local.lambda_runtime
  handler          = "handler.handler"
  filename         = data.archive_file.delete.output_path
  source_code_hash = data.archive_file.delete.output_base64sha256
  timeout          = local.lambda_timeout
  memory_size      = local.lambda_memory
  layers           = [aws_lambda_layer_version.utils.arn]

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.bookmarks.name
    }
  }
}
