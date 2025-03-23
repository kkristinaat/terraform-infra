bucket_name = "my-s-s3-bucket"

assume_role_policy = {
  Version = "2012-10-17"
  Statement = [{
    Effect = "Allow"
    Principal = {
      Service = "ec2.amazonaws.com"
    }
    Action = "sts:AssumeRole"
  }]
}