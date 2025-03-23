variable "bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
}

variable "environment" {
  description = "The environment (stg or prd)"
  type        = string
}

variable "assume_role_policy" {
  type = any
}