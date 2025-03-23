variable "bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
}

variable "environment" {
  description = "The environment (stg or prd)"
  type        = string
}

variable "default_key" {
  type    = string
  default = "data"
}

variable "assume_role_policy" {
  type = any
  default = {
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  }
}