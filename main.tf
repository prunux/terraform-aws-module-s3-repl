resource "aws_s3_bucket" "s3-bucket" {
  bucket        = "${var.bucket_name}"
  region        = "${var.bucket_region}"
  acl           = "private"
  force_destroy = "${var.bucket_force_destroy}"

  # Enable versioning so that files can be replicated
  versioning {
    enabled = true
  }

  # Remove old versions of images after 30 days
  lifecycle_rule {
    prefix  = ""
    enabled = true

    noncurrent_version_expiration {
      days = 30
    }
  }

  replication_configuration {
    role = "${aws_iam_role.replication_role.arn}"

    rules {
      id     = "replica"
      prefix = ""
      status = "Enabled"

      destination {
        bucket        = "${aws_s3_bucket.repl-s3-bucket.arn}"
        storage_class = "${var.repl_bucket_storage_class}"
      }
    }
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "aws:kms"
      }
    }
  }

  tags = "${merge(map("Name", var.bucket_name), var.extra_tags)}"
}

provider "aws" {
  region     = "${var.repl_bucket_region}"
  alias      = "s3-replication-region"
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
}

resource "aws_s3_bucket" "repl-s3-bucket" {
  provider      = "aws.s3-replication-region"
  bucket        = "${var.repl_bucket_name}"
  acl           = "private"
  force_destroy = "${var.repl_bucket_force_destroy}"

  # Enable versioning so that files can be replicated
  versioning {
    enabled = true
  }

  # Remove old versions of images after 15 days
  lifecycle_rule {
    prefix  = ""
    enabled = true

    noncurrent_version_expiration {
      days = 30
    }
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "aws:kms"
      }
    }
  }

  tags = "${merge(map("Name", var.repl_bucket_name), var.extra_tags)}"
}
