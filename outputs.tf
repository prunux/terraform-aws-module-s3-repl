output "s3_bucket_arn" {
  description = "The bucket arn of s3 bucket."
  value       = "${aws_s3_bucket.s3-bucket.arn}"
}

output "s3_bucket_name" {
  description = "The bucket name of s3 bucket."
  value       = "${var.bucket_name}"
}
