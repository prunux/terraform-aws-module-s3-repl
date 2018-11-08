### S3 Bucket ###
variable "bucket_name" {
  type        = "string"
  description = "bucket name"
}

variable "bucket_region" {
  type        = "string"
  description = "AWS region of the S3"
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

### S3 Bucket Cors ###
# see also https://docs.aws.amazon.com/AmazonS3/latest/dev/cors.html
variable "cors_allowed_headers" {
  type        = "list"
  description = "The AllowedHeader element specifies which headers are allowed in a preflight request through the Access-Control-Request-Headers header. Each AllowedHeader string in the rule can contain at most one * wildcard character"
  default     = []
}

variable "cors_allowed_methods" {
  type        = "list"
  description = "AllowedMethods Element: 1-n out of 'GET','PUT','POST','DELETE','HEAD'"
  default     = []
}

variable "cors_allowed_origins" {
  type        = "list"
  description = "AllowedOrigin Element (i.e. You can optionally specify * as the origin to enable all the origins to send cross-origin requests)"
  default     = []
}

variable "cors_expose_headers" {
  type        = "list"
  description = "Each ExposeHeader element identifies a header in the response that you want customers to be able to access from their applications (for example, from a JavaScript XMLHttpRequest object)."
  default     = []
}

variable "cors_max_age_seconds" {
  description = "The MaxAgeSeconds element specifies the time in seconds that your browser can cache the response for a preflight request as identified by the resource, the HTTP method, and the origin."
  default     = 3000
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
