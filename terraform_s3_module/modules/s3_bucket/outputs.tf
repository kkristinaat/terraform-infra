output "s3_bucket_name" {
  value = aws_s3_bucket.s3_bucket.id
}

output "iam_role_arn" {
  value = aws_iam_role.s3_access_role.arn
}

output "s3_bucket_id" {
  value = aws_s3_bucket.s3_bucket.id
}