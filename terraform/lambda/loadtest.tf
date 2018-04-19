#
# lambda
# Set up Lambda functions
#

# deploy lambda function using zip
data "archive_file" "loadtest" {
  type = "zip"
  # top-level folder contains /terraform, /docs etc. and critically /nodejs
  source_dir = "${path.root}/../nodejs/"
  output_path = "/tmp/loadtest.zip"
}

resource "aws_lambda_function" "loadtest_func" {
  description = "Node.js load test function for Kotlin form processor"
  function_name = "loadtest"
  filename = "/tmp/loadtest.zip"
  source_code_hash = "${data.archive_file.loadtest.output_base64sha256}"
  handler = "loadtest.handler"
  role = "${aws_iam_role.lambda_exec.arn}"
  runtime = "nodejs6.10"
  timeout = 30
}
