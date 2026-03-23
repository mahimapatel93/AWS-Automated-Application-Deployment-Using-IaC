resource "aws_s3_bucket" "mahi_fe_bucket" {
  bucket = "mahi-${var.env_name}-fe-bucket"
}
resource "aws_s3_bucket" "mahi_be_bucket" {
  bucket = "mahi-${var.env_name}-be-bucket"
}