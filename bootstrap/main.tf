resource "random_id" "bucket_suffix" {
  byte_length = 4
}
resource "aws_s3_bucket" "terraform_state" {
  lifecycle {
    prevent_destroy = true
  }
  bucket = lower(replace("${random_id.bucket_suffix.hex}-${var.project_name}", "_", "-"))
  tags = {
    "Name" = "${var.project_name}-terraform-state-${var.environment}"
  }
  region = var.aws_region

}

resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket                  = aws_s3_bucket.terraform_state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
