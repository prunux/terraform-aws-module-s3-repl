resource "aws_iam_role" "replication_role" {
  name = "s3-replication-role-${var.bucket_name}"

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

########## POLICY DOCS ############
data "aws_iam_policy_document" "s3_access_policy" {
  statement {
    effect = "Allow"

    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation",
      "s3:ListBucketMultipartUploads",
    ]

    resources = [
      "${aws_s3_bucket.s3-bucket.arn}",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject",
      "s3:ListMultipartUploadParts",
    ]

    resources = [
      "${aws_s3_bucket.s3-bucket.arn}/*",
    ]
  }
}

data "aws_iam_policy_document" "replica_access_policy" {
  statement {
    effect = "Allow"

    actions = [
      "s3:GetReplicationConfiguration",
      "s3:ListBucket",
    ]

    resources = [
      "${aws_s3_bucket.s3-bucket.arn}",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:GetObjectVersion",
      "s3:GetObjectVersionAcl",
    ]

    resources = [
      "${aws_s3_bucket.s3-bucket.arn}/*",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:ReplicateObject",
      "s3:ReplicateDelete",
    ]

    resources = [
      "${aws_s3_bucket.repl-s3-bucket.arn}/*",
    ]
  }
}

resource "aws_iam_policy" "bucket_policy" {
  name   = "s3-${var.bucket_name}-policy"
  policy = "${data.aws_iam_policy_document.s3_access_policy.json}"
}

resource "aws_iam_policy" "replication_policy" {
  name   = "s3-${var.repl_bucket_name}-policy"
  policy = "${data.aws_iam_policy_document.replica_access_policy.json}"
}

resource "aws_iam_policy_attachment" "s3_attach" {
  name       = "${var.bucket_name}-policy-attachment"
  users      = ["${var.bucket_access_user_names}"]
  roles      = ["${var.bucket_access_role_names}"]
  policy_arn = "${aws_iam_policy.bucket_policy.arn}"
}

resource "aws_iam_policy_attachment" "replication_attach" {
  name       = "${var.repl_bucket_name}-policy-attachment"
  roles      = ["${aws_iam_role.replication_role.name}"]
  policy_arn = "${aws_iam_policy.replication_policy.arn}"
}
