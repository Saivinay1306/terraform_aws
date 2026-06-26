resource "aws_s3_bucket" "s3" {
  bucket = "{var.environment}-{var.region}-{var.bucket_name}"
   tags = {
    Name = "{var.environment}-{var.region}-{var.bucket_name}"
  }
}

# Block Public Access
resource "aws_s3_bucket_public_access_block" "s3" {
  bucket = aws_s3_bucket.s3.id
  block_public_acls   = true
  block_public_policy = true
  restrict_public_buckets=true
  ignore_public_acls= true
}


# S3 Bucket Encryption with default kms key
resource "aws_s3_bucket_server_side_encryption_configuration" "example" {
  bucket = aws_s3_bucket.s3.bucket
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "AES256"
    }
  }
}

resource "aws_s3_bucket_acl" "s3" {
  bucket = aws_s3_bucket.s3.id
  acl    = "private"
}

resource "aws_s3_bucket_policy" "deny_public_access" {
  bucket = aws_s3_bucket.s3.id
  policy = data.aws_iam_policy_document.deny_public_access.json
}


data "aws_iam_policy_document" "deny_public_access" {
  statement {
    sid       = "DenyInsecureTransport"
    effect    = "Deny"
    actions   = ["s3:*"]
    resources = ["${aws_s3_bucket.s3.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}