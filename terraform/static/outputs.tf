#
# Output variables for other modules to use
#

output "site_url" {
  value = "http://${aws_s3_bucket.site_static.bucket}.s3-website.${var.aws_region}.amazonaws.com"
}