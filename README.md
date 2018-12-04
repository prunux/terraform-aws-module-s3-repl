# S3 Buckets with Replication for Customers
This module creates S3 Buckets with Replication, Versioning,  Lifecycle and CORS for customers.


## Minimal Example 
Create a S3 Bucket in singapore and create a backup replication S3 Bucket in Frankfurt:

```terraform
module "bucket-ap-southeast-1-prod" {
  source                   = "git::ssh://git@gitlab.com/rplessl-terraform-aws-modules/s3-repl.git?ref=v1.0.6"
  bucket_name              = "bucket-ap-southeast-1-prod"
  bucket_region            = "ap-southeast-1"
  repl_bucket_name         = "backup-bucket-ap-southeast-1-prod"
  repl_bucket_region       = "eu-central-1"
  bucket_access_user_names = ["bucket-prod-user"]
  access_key               = "${module.common.access_keys[var.customer_account]}"
  secret_key               = "${module.common.secret_keys[var.customer_account]}"

  providers = {
    aws.src  = "aws.singapore"
    aws.dest = "aws.frankfurt"
  }
}
```



## More Enhanced Example with all arguments

```terraform
module "bucket-northeast-1-prod" {
  source                    = "git::ssh://git@gitlab.com/rplessl-terraform-aws-modules/s3-repl.git?ref=v1.0.6"
  bucket_name               = "bucket-ap-northeast-1-prod"
  bucket_region             = "ap-northeast-1"
  bucket_storage_class      = "STANDARD"
  bucket_access_user_names  = ["bucket-prod-user"]
  bucket_access_roles_names = ["bucket-prod-role"]
  bucket_force_destroy      = false
  repl_bucket_name          = "backup-bucket-ap-northeast-1-prod"
  repl_bucket_region        = "eu-central-1"
  repl_bucket_storage_class = "STANDARD"
  repl_bucket_force_destroy = false
  access_key                = "${module.common.access_keys[var.customer_account]}"
  secret_key                = "${module.common.secret_keys[var.customer_account]}"

  cors_allowed_headers = ["*"]
  cors_allowed_methods = ["GET", "POST", "HEAD"]
  cors_allowed_origins = ["*"]
  cors_max_age_seconds = 28800

  providers = {
    aws.src  = "aws.tokyo"
    aws.dest = "aws.frankfurt"
  }

  extra_tags = {
    "Environment" = "Dev",
    "Squad"       = "Ops"  
  }

}
```

All Parmeters:

* `bucket_name`: S3 bucket name
* `bucket_region`: AWS region of S3 bucket
* `bucket_storage_class`: storage class of S3 bucket
* `bucket_access_user_names`: a list of user names that need access to the buckets
* `bucket_access_role_names`: a list of role names that need access to the buckets
* `bucket_force_destroy`: S3 bucket force destroy on destruction
* `repl_bucket_name`: Replication S3 bucket name
* `repl_bucket_region`: AWS region of S3 replication bucket
* `repl_bucket_storage_class`: storage class of S3 replicaion bucket
* `repl_bucket_force_destroy`: S3 bucket force destroy on destruction
* `access_key`: Programatic Access to AWS account
* `secret_key`: Programatic Access to AWS account

* `cors_*`: parameters to set CORS for bucket

* `providers`: used to pass different AWS regions


## Add IAM user for access
```terraform
resource "aws_iam_user" "bucket-prod" {
  name = "bucket-prod"
}

resource "aws_iam_access_key" "bucket-prod" {
  user = "${aws_iam_user.bucket-prod.name}"
}

output "s3-bucket-prod_key_id" {
  value = "${aws_iam_access_key.bucket-prod.id}"
}

output "s3-bucket-prod_secret_key" {
  value = "${aws_iam_access_key.bucket-prod.secret}"
}
```

Get the credentials and send them to the customer.

```
$ terraform output -module=s3-repl
[...]
s3-bucket-prod_key_id = AKIAJUO6HXXXXXXX
s3-bucket-prod_secret_key = 9kOFcvujIlWcXXXXXXXgVDOxV8gPhiO31Hb8
```

## Lifecyle

The following lifecycle is activated

```terraform
 lifecycle_rule {
    prefix  = ""
    enabled = true

    noncurrent_version_expiration {
      days = 30
    }
  }
```

## Encryption

All create S3 Buckets are using the AWS-KMS encryption

```terraform
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "aws:kms"
      }
    }
  }
```
## CORS

All created S3 Buckets are using this "default" CORS values
```xml
<?xml version="1.0" encoding="UTF-8"?>
<CORSConfiguration xmlns="http://s3.amazonaws.com/doc/2006-03-01/">
<CORSRule>
    <AllowedOrigin>*</AllowedOrigin>
    <AllowedMethod>GET</AllowedMethod>
    <AllowedMethod>HEAD</AllowedMethod>
    <MaxAgeSeconds>3000</MaxAgeSeconds>
</CORSRule>
</CORSConfiguration>
```