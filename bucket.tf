resource "aws_s3_bucket" "foundry_artifacts" {
  acl           = "private"
  bucket_prefix = "foundry-server-artifacts-${terraform.workspace}"
  region        = local.region
  tags          = local.tags_rendered

  dynamic "cors_rule" {
    for_each = var.artifacts_bucket_public ? [{}] : []
    content {
      allowed_headers = ["*"]
      allowed_methods = ["GET", "POST", "HEAD"]
      allowed_origins = ["*"]
      max_age_seconds = 3000
    }
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "aws:kms"
      }
    }
  }

  lifecycle_rule {
    enabled = true
    id      = "remove-old-data"
    prefix  = "data/"
    noncurrent_version_expiration {
      days = var.artifacts_data_expiration_days
    }
  }

  versioning {
    enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "foundry_artifacts_private" {
  count = var.artifacts_bucket_public ? 0 : 1

  block_public_acls       = true
  block_public_policy     = true
  bucket                  = aws_s3_bucket.foundry_artifacts.id
  ignore_public_acls      = true
  restrict_public_buckets = true
}

output artifacts_bucket_name {
  description = "The name of the S3 bucket holding versioned Foundry data."
  value       = aws_s3_bucket.foundry_artifacts.id
}

output artifacts_bucket_arn {
  description = "The ARN of the S3 bucket holding versioned Foundry data."
  value       = aws_s3_bucket.foundry_artifacts.arn
}
