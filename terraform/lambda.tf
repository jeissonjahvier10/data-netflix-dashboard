resource "aws_lambda_function" "data_processor" {
  function_name = "${var.project_name}-${var.environment}-data-processor"
  role          = aws_iam_role.lambda_role.arn
  handler       = "app.main_handler"
  runtime       = "python3.12"

  filename         = var.data_processor_zip_path
  source_code_hash = filebase64sha256(var.data_processor_zip_path)

  timeout     = 60
  memory_size = 512

  environment {
    variables = {
      DATA_BUCKET = aws_s3_bucket.data_bucket.bucket
      CSV_KEY     = var.csv_key
    }
  }
}

resource "aws_lambda_function" "api_dashboard" {
  function_name = "${var.project_name}-${var.environment}-api-dashboard"
  role          = aws_iam_role.lambda_role.arn
  handler       = "app.main_handler"
  runtime       = "python3.12"

  filename         = var.api_dashboard_zip_path
  source_code_hash = filebase64sha256(var.api_dashboard_zip_path)

  timeout     = 30
  memory_size = 256

  environment {
    variables = {
      DATA_BUCKET = aws_s3_bucket.data_bucket.bucket
    }
  }
}

resource "aws_lambda_permission" "allow_s3_to_invoke_processor" {
  statement_id  = "AllowS3InvokeProcessor"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.data_processor.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.data_bucket.arn
}

resource "aws_s3_bucket_notification" "data_bucket_notification" {
  bucket = aws_s3_bucket.data_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.data_processor.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "input/"
    filter_suffix       = ".csv"
  }

  depends_on = [
    aws_lambda_permission.allow_s3_to_invoke_processor
  ]
}