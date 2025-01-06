# Configure the backend S3 bucket for the terraform state file.

resource "aws_s3_bucket" "terraform_state_bucket" {
  bucket = "gonchquest-terraform-state-bucket"
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "terraform_state_bucket_versioning" {
  bucket = aws_s3_bucket.terraform_state_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_ownership_controls" "terraform_state_bucket" {
  bucket = aws_s3_bucket.terraform_state_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "terraform_state_bucket_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.terraform_state_bucket]
  bucket = aws_s3_bucket.terraform_state_bucket.bucket
  acl    = "private"
}