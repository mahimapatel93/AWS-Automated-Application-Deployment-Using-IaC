output "fe_app_bucket" {
  value = aws_s3_bucket.mahi_fe_bucket.bucket
}

output "be_app_bucket" {
  value = aws_s3_bucket.mahi_be_bucket.bucket
}