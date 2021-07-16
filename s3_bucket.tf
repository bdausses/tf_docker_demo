# Add a sample s3 bucket
resource "aws_s3_bucket" "data" {
  # bucket is public
  # bucket is not encrypted
  # bucket does not have access logs
  # bucket does not have versioning
  bucket        = "tfdemo-data"
  acl           = "public-read"
  force_destroy = true
}
