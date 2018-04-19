variable "aws_region" {}

variable "site_bucket_name" {
  description = "Name to assign to the public S3 bucket that holds the static site"
  default = "paypoc-static"
}

variable "post_target" {}
