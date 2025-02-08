# ── Zip the shared utils layer ────────────────────────────────────────────────

data "archive_file" "layer" {
  type        = "zip"
  source_dir  = "${path.module}/../src/layer"
  output_path = "${path.module}/../builds/layer.zip"
}

resource "aws_lambda_layer_version" "utils" {
  layer_name          = "${local.prefix}-utils"
  filename            = data.archive_file.layer.output_path
  source_code_hash    = data.archive_file.layer.output_base64sha256
  compatible_runtimes = ["python3.11"]
  description         = "Shared utils: generate_id, response helpers, body parser"
}
