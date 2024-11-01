# Create the S3 bucket

resource "aws_s3_bucket" "s3-zeus-files" {
  
  bucket        = "zeus-ec2ssm-logsbu"
  force_destroy = true
  tags          = var.tags
}
resource "aws_s3_bucket_ownership_controls" "s3-zeus-files" {
  bucket = aws_s3_bucket.s3-zeus-files.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "s3-zeus-files" {
  depends_on = [aws_s3_bucket_ownership_controls.s3-zeus-files]

  bucket = aws_s3_bucket.s3-zeus-files.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "s3-zeus-files" {
  bucket = aws_s3_bucket.s3-zeus-files.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3-zeus-files" {
  bucket = aws_s3_bucket.s3-zeus-files.id

  rule {
    apply_server_side_encryption_by_default {
      #sse_algorithm     = "AES256"
      kms_master_key_id = var.kms_key_id
      sse_algorithm     = "aws:kms"
    }
    bucket_key_enabled  =true
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "s3-zeus-files" {
  bucket = aws_s3_bucket.s3-zeus-files.id

  rule {
    id     = "archive_after_X_days"
    status = "Enabled"

    transition {
      days          = var.log_archive_days
      storage_class = "GLACIER"
    }

    expiration {
      days = var.log_expire_days
    }
  }
}



resource "aws_s3_bucket_public_access_block" "s3-zeus-files" {
  bucket                  = aws_s3_bucket.s3-zeus-files.id
  block_public_acls       = true    # block new acls that allow public access
  block_public_policy     = true    # block bucket policy that allow public access
  ignore_public_acls      = true    # ignore existing acls that have been allowing pu access
  restrict_public_buckets = true    #
}

