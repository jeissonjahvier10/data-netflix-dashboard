resource "aws_s3_object" "frontend_index" {
  bucket       = aws_s3_bucket.frontend_bucket.bucket
  key          = "index.html"
  source       = "../frontend/index.html"
  content_type = "text/html"
  etag         = filemd5("../frontend/index.html")
}

resource "aws_s3_object" "frontend_app_js" {
  bucket       = aws_s3_bucket.frontend_bucket.bucket
  key          = "app.js"
  source       = "../frontend/app.js"
  content_type = "application/javascript"
  etag         = filemd5("../frontend/app.js")
}

resource "aws_s3_object" "frontend_style_css" {
  bucket       = aws_s3_bucket.frontend_bucket.bucket
  key          = "style.css"
  source       = "../frontend/style.css"
  content_type = "text/css"
  etag         = filemd5("../frontend/style.css")
}

resource "aws_s3_object" "frontend_config_js" {
  bucket       = aws_s3_bucket.frontend_bucket.bucket
  key          = "config.js"
  source       = local_file.frontend_config.filename
  content_type = "application/javascript"

  depends_on = [
    local_file.frontend_config
  ]
}

resource "aws_s3_object" "input_csv" {
  bucket       = aws_s3_bucket.data_bucket.bucket
  key          = var.csv_key
  source       = "../data/netflix_user_behavior_dataset.csv"
  content_type = "text/csv"
  etag         = filemd5("../data/netflix_user_behavior_dataset.csv")

  depends_on = [
    aws_s3_bucket_notification.data_bucket_notification
  ]
}