resource "aws_s3_bucket" "s3_bucket" {
  bucket = var.bucket_name

  lifecycle {
    prevent_destroy = false #set to true
  }
}

resource "aws_s3_object" "default_s3_object" {
  bucket = aws_s3_bucket.s3_bucket.id
  key    = "${var.default_key}/"
}

resource "aws_iam_role" "s3_access_role" {
  name = "${var.environment}-s3-access-role"

  assume_role_policy = jsonencode(var.assume_role_policy)
  # assume_role_policy = jsonencode({
  #   Version = "2012-10-17"
  #   Statement = [{
  #     Effect = "Allow"
  #     Principal = {
  #       Service = "ec2.amazonaws.com"
  #     }
  #     Action = "sts:AssumeRole"
  #   }]
  # })
}

resource "aws_iam_policy" "s3_access_policy" {
  name        = "${var.environment}-s3-access-policy"
  description = "Policy for accessing S3 bucket in ${var.environment}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject",
        "s3:ListBucket"
      ]
      Resource = [
        aws_s3_bucket.s3_bucket.arn,
        "${aws_s3_bucket.s3_bucket.arn}/*"
      ]
    }]
  })
}

resource "aws_iam_role_policy_attachment" "attach" {
  role       = aws_iam_role.s3_access_role.name
  policy_arn = aws_iam_policy.s3_access_policy.arn
}