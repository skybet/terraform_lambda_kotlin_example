#
# static
# Set up static html site in s3 for front-end
#

provider "aws" {
  region = "${var.aws_region}"
}

# create bucket
resource "aws_s3_bucket" "site_static" {
  bucket = "${var.site_bucket_name}"
  acl = "public-read"

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["PUT","POST"]
    allowed_origins = ["*"]
    expose_headers = ["ETag"]
    max_age_seconds = 3000
  }
  policy = <<EOF
{
  "Id": "bucket_policy_site_static",
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "bucket_policy_site_static_main",
      "Action": [
        "s3:GetObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${var.site_bucket_name}/*",
      "Principal": "*"
    }
  ]
}
EOF
  website {
      index_document = "index.html"
      error_document = "error.html"
  }
  tags {
  }
  force_destroy = true
}

# substitute post_target into index.html
data "template_file" "template_index" {
  template = "${file("${path.root}/../static/index.html")}"
  vars {
    post_target = "${var.post_target}"
  }
}

# upload files, only when bucket exists
resource "aws_s3_bucket_object" "index" {
  bucket = "${var.site_bucket_name}"
  key = "index.html"
  content = "${data.template_file.template_index.rendered}"
  # source = "${path.root}/../static/index.html"
  content_type = "text/html"
  # etag   = "${md5(file("${path.root}/../static/index.html"))}"
  depends_on = ["aws_s3_bucket.site_static"]
}

resource "aws_s3_bucket_object" "error" {
  bucket = "${var.site_bucket_name}"
  # bucket = "${aws_s3_bucket.site_static.bucket}"
  key = "error.html"
  source = "${path.root}/../static/error.html"
  content_type = "text/html"
  # etag   = "${md5(file("${path.root}/../static/error.html"))}"
  depends_on = ["aws_s3_bucket.site_static"]
}

