locals {
  s3_bucket_name = "my-bucket-${var.profile}-${random_id.random_id.hex}"
}

resource "random_id" "random_id" {
  byte_length = 4
}

resource "aws_s3_bucket" "s3_bucket" {
  bucket = local.s3_bucket_name
  acl    = "private"

  server_side_encryption_configuration {
    rule {


      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  lifecycle_rule {
    id      = "transition_to_standard_ia"
    enabled = true

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
    noncurrent_version_transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
  }

  force_destroy = true
}