# ── Shared assume-role policy for all Lambda functions ────────────────────────

data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

# ── Shared CloudWatch Logs policy ─────────────────────────────────────────────

data "aws_iam_policy_document" "cloudwatch_logs" {
  statement {
    effect  = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["arn:aws:logs:*:*:*"]
  }
}

resource "aws_iam_policy" "cloudwatch_logs" {
  name   = "${local.prefix}-cloudwatch-logs"
  policy = data.aws_iam_policy_document.cloudwatch_logs.json
}

# ── create Lambda — least-privilege: PutItem only ─────────────────────────────

resource "aws_iam_role" "create_lambda" {
  name               = "${local.prefix}-create-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

data "aws_iam_policy_document" "create_lambda" {
  statement {
    effect    = "Allow"
    actions   = ["dynamodb:PutItem"]
    resources = [aws_dynamodb_table.bookmarks.arn]
  }
}

resource "aws_iam_role_policy" "create_lambda" {
  name   = "dynamodb-put"
  role   = aws_iam_role.create_lambda.id
  policy = data.aws_iam_policy_document.create_lambda.json
}

resource "aws_iam_role_policy_attachment" "create_logs" {
  role       = aws_iam_role.create_lambda.name
  policy_arn = aws_iam_policy.cloudwatch_logs.arn
}

# ── get Lambda — least-privilege: GetItem only ────────────────────────────────

resource "aws_iam_role" "get_lambda" {
  name               = "${local.prefix}-get-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

data "aws_iam_policy_document" "get_lambda" {
  statement {
    effect    = "Allow"
    actions   = ["dynamodb:GetItem"]
    resources = [aws_dynamodb_table.bookmarks.arn]
  }
}

resource "aws_iam_role_policy" "get_lambda" {
  name   = "dynamodb-get"
  role   = aws_iam_role.get_lambda.id
  policy = data.aws_iam_policy_document.get_lambda.json
}

resource "aws_iam_role_policy_attachment" "get_logs" {
  role       = aws_iam_role.get_lambda.name
  policy_arn = aws_iam_policy.cloudwatch_logs.arn
}

# ── list Lambda — least-privilege: Query on GSI only ─────────────────────────

resource "aws_iam_role" "list_lambda" {
  name               = "${local.prefix}-list-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

data "aws_iam_policy_document" "list_lambda" {
  statement {
    effect    = "Allow"
    actions   = ["dynamodb:Query", "dynamodb:Scan"]
    resources = [
      aws_dynamodb_table.bookmarks.arn,
      "${aws_dynamodb_table.bookmarks.arn}/index/*",
    ]
  }
}

resource "aws_iam_role_policy" "list_lambda" {
  name   = "dynamodb-query"
  role   = aws_iam_role.list_lambda.id
  policy = data.aws_iam_policy_document.list_lambda.json
}

resource "aws_iam_role_policy_attachment" "list_logs" {
  role       = aws_iam_role.list_lambda.name
  policy_arn = aws_iam_policy.cloudwatch_logs.arn
}

# ── delete Lambda — least-privilege: DeleteItem + GetItem (ownership check) ──

resource "aws_iam_role" "delete_lambda" {
  name               = "${local.prefix}-delete-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

data "aws_iam_policy_document" "delete_lambda" {
  statement {
    effect    = "Allow"
    actions   = ["dynamodb:DeleteItem", "dynamodb:GetItem"]
    resources = [aws_dynamodb_table.bookmarks.arn]
  }
}

resource "aws_iam_role_policy" "delete_lambda" {
  name   = "dynamodb-delete"
  role   = aws_iam_role.delete_lambda.id
  policy = data.aws_iam_policy_document.delete_lambda.json
}

resource "aws_iam_role_policy_attachment" "delete_logs" {
  role       = aws_iam_role.delete_lambda.name
  policy_arn = aws_iam_policy.cloudwatch_logs.arn
}
