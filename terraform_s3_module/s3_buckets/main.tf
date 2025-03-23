module "create_s3_bucket" {
  source             = "../modules/s3_bucket"
  bucket_name        = "${var.bucket_name}-${var.environment}"
  assume_role_policy = var.assume_role_policy
  environment        = var.environment
}

resource "aws_s3_bucket_lifecycle_configuration" "s3_lifecycle" {
  bucket = module.create_s3_bucket.s3_bucket_id

  rule {
    id     = "lifecycle_rule"
    status = "Enabled"

    filter {
      prefix = "data/"
    }

    dynamic "expiration" {
      for_each = var.environment == "stg" ? [1] : []
      content {
        days = 30
      }
    }

    dynamic "transition" {
      for_each = var.environment == "prd" ? [1] : []
      content {
        days          = 30
        storage_class = "STANDARD_IA"
      }
    }
  }
}