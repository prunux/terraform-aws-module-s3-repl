variable "bucket_name" {

}

variable "repl_bucket_name" {

}

variable "bucket_region" {

}

variable "repl_bucket_region" {

}



resource "aws_s3_bucket" "s3-bucket" {
  bucket = "${var.bucket_name}"
  acl    = "private"

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
    role = "${aws_iam_role.replication.arn}"

    rules {
      id     = "replica"
      prefix = ""
      status = "Enabled"

      destination {
        bucket        = "${aws_s3_bucket.replication.arn}"
        storage_class = "STANDARD"
      }
    }
  }

  tags {
    Name = "${var.bucket_name}"
  }
}

resource "aws_iam_user" "s3-bucket-user" {
  name = "s3-bucket-user-${var.bucket_name}"
  path = "/"
}

resource "aws_iam_user_policy" "s3-bucket-user-policy" {
  name = "s3-bucket-user-${var.bucket_name}-policy"
  user = "${aws_iam_user.s3-bucket-user.name}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket",
        "s3:GetBucketLocation",
        "s3:ListBucketMultipartUploads"
      ],
      "Resource": ["arn:aws:s3:::s3-bucket"]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetObject",
        "s3:DeleteObject",
        "s3:ListMultipartUploadParts"
      ],
      "Resource": [
        "arn:aws:s3:::s3-bucket/*"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_access_key" "s3-bucket-key" {
  user = "${aws_iam_user.s3-bucket-user.name}"
}

output "iam_registry_secret_key" {
  value = "${aws_iam_access_key.s3-bucket-key.secret}"
}

output "iam_registry_access_key" {
  value = "${aws_iam_access_key.s3-bucket-key.id}"
}

resource "aws_iam_role" "replication" {
  name = "s3-replication-${var.bucket_name}"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "s3.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
}

resource "aws_iam_policy" "replication" {
  name = "s3-replication-${var.bucket_name}-policy"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:GetReplicationConfiguration",
        "s3:ListBucket"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_s3_bucket.s3-bucket.arn}"
      ]
    },
    {
      "Action": [
        "s3:GetObjectVersion",
        "s3:GetObjectVersionAcl"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_s3_bucket.s3-bucket.arn}/*"
      ]
    },
    {
      "Action": [
        "s3:ReplicateObject",
        "s3:ReplicateDelete"
      ],
      "Effect": "Allow",
      "Resource": "${aws_s3_bucket.repl-s3-bucket.arn}/*"
    }
  ]
}
POLICY
}

resource "aws_iam_policy_attachment" "replication" {
  name       = "replication-policy-attachment"
  roles      = ["${aws_iam_role.replication.name}"]
  policy_arn = "${aws_iam_policy.replication.arn}"
}

resource "aws_s3_bucket" "repl-s3-bucket" {
  provider = "aws.s3-replication-region"
  region   = "${var.aws_region_replica}"
  bucket   = "${var.repl_bucket_name}"
  acl      = "private"

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

  tags {
    Name = "${var.repl_bucket_name}"
  }
}
