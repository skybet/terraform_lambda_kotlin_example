#
# root module
# Creates an array of examples to demonstrate the tools
# hacked together by Alex Stanhope
#

# add a Lambda function to field HTTP requests
module "lambda" {
  source = "./lambda"
  aws_region = "${var.aws_region}"
}
#output "test_kardapi_loadtest" {
#  value = "aws lambda invoke --invocation-type RequestResponse --function-name ${module.lambda.kardapi_lambda_loadtest} --region=eu-west-2 --log-type Tail --payload '{}' outputfile.txt && cat outputfile.txt && rm outputfile.txt"
#}

output "test_kardapi_deploy" {
  value = "curl -X POST -d 'name=MR.+T.+TESTER' ${module.lambda.kardapi_gateway_deployment_invoke_url}/card/add"
}

# create a semi-unique name for the S3 bucket to avoid collisions
resource "random_string" "uniqueness" {
  length = 16
  lower = true
  number = true
  upper = false
  special = false
}

# create a static site in S3
module "static" {
  source = "./static"
  site_bucket_name = "paypoc-static-${random_string.uniqueness.result}"
  aws_region = "${var.aws_region}"
  post_target = "${module.lambda.kardapi_gateway_deployment_invoke_url}/card/add"
}
output "static_url" {
  value = "${module.static.site_url}"
}

