provider "aws" {
  alias = "src"
}

provider "aws" {
  alias = "dest"
}

locals {
  has_bucket_cors = "${var.cors_allowed_origin[0] ? true : false }"

  allowed_headers = "${local.has_bucket_cors ? var.cors_allowed_headers : ""}"
  allowed_methods = "${local.has_bucket_cors ? var.cors_allowed_methods : ""}"
  allowed_origins = "${local.has_bucket_cors ? var.cors_allowed_origins : ""}"
  expose_headers  = "${local.has_bucket_cors ? var.cors_expose_headers : ""}"
  max_age_seconds = "${local.has_bucket_cors ? var.cors_max_age_seconds : ""}"
}

resource "aws_s3_bucket" "s3-bucket" {
  bucket        = "${var.bucket_name}"
  region        = "${var.bucket_region}"
  provider      = "aws.src"
  acl           = "private"
  force_destroy = "${var.bucket_force_destroy}"

  cors_rule {
    allowed_headers = "${local.allowed_headers}"
    allowed_methods = "${local.allowed_methods}"
    allowed_origins = "${local.allowed_origins}"
    expose_headers  = "${local.expose_headers}"
    max_age_seconds = "${local.max_age_seconds}"
  }

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

resource "aws_s3_bucket" "repl-s3-bucket" {
  provider      = "aws.dest"
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
