resource "random_id" "frontend_suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "frontend" {
  bucket = "${local.prefix}-${random_id.frontend_suffix.hex}-frontend"

  tags = merge(local.tags, {
    Name = "${local.prefix}-frontend-bucket"
  })
}

resource "aws_s3_bucket_server_side_encryption_configuration" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_website_configuration" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

resource "aws_s3_bucket_public_access_block" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "frontend_public_read" {
  count  = var.allow_public_frontend ? 1 : 0
  bucket = aws_s3_bucket.frontend.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadForGetBucketObjects"
        Effect    = "Allow"
        Principal = "*"
        Action    = ["s3:GetObject"]
        Resource  = ["${aws_s3_bucket.frontend.arn}/*"]
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.frontend]
}

resource "aws_s3_object" "frontend_files" {
  for_each = {
    "index.html"        = "${path.root}/../../frontend/index.html"
    "styles.css"        = "${path.root}/../../frontend/styles.css"
    "app.js"            = "${path.root}/../../frontend/app.js"
    "config.example.js" = "${path.root}/../../frontend/config.example.js"
  }

  bucket = aws_s3_bucket.frontend.id
  key    = each.key
  source = each.value
  etag   = filemd5(each.value)
  content_type = lookup({
    "index.html"        = "text/html"
    "styles.css"        = "text/css"
    "app.js"            = "application/javascript"
    "config.example.js" = "application/javascript"
  }, each.key, "text/plain")
}

resource "aws_s3_object" "frontend_config" {
  bucket       = aws_s3_bucket.frontend.id
  key          = "config.js"
  content_type = "application/javascript"
  content = <<-EOT
window.APP_CONFIG = {
  apiBaseUrl: "http://${aws_lb.app.dns_name}"
};
EOT
}
