### S3 Bucket ###
variable "bucket_name" {
  type        = "string"
  description = "bucket name"
}

variable "bucket_region" {
  type        = "string"
  description = "AWS region of the S3"
}

variable "bucket_provider" {
  type        = "string"
  description = "AWS provider of region"
}

variable "bucket_storage_class" {
  type        = "string"
  description = "storage class for S3 bucket"
  default     = "STANDARD"
}

variable "bucket_access_user_names" {
  type        = "list"
  description = "list of user names that need access to the buckets"
  default     = []
}

variable "bucket_access_role_names" {
  type        = "list"
  description = "list of role names that need access to the buckets"
  default     = []
}

variable "bucket_force_destroy" {
  type        = "string"
  description = "S3 bucket force destroy"
  default     = false
}

### S3 Replication Bucket ####
variable "repl_bucket_name" {
  type        = "string"
  description = "bucket name"
}

variable "repl_bucket_region" {
  type        = "string"
  description = "AWS region of the S3 replica"
}

variable "repl_bucket_provider" {
  type        = "string"
  description = "AWS provider of region replica"
}

variable "repl_bucket_storage_class" {
  type        = "string"
  description = "storage class for S3 bucket replica"
  default     = "STANDARD"
}

variable "repl_bucket_force_destroy" {
  type        = "string"
  description = "S3 bucket replica force destroy"
  default     = false
}

### Extra Tags ###

variable "extra_tags" {
  type        = "map"
  description = "A map of additional tags to add to the S3 buckets. Each element in the map must have the key = value format"

  # example:
  # extra_tags = {
  #   "Environment" = "Dev",
  #   "Squad" = "Ops"  
  # }

  default = {}
}

# credentials
variable "access_key" {
  type        = "string"
  description = "AWS access key"
}

variable "secret_key" {
  type        = "string"
  description = "AWS secret key"
}
