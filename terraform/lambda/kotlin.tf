#
# lambda - kotlin
# Set up Kotlin Lambda functions
#

#
# Generic/shared resources
#

resource "aws_api_gateway_rest_api" "kardapi" {
  name        = "Card API in Kotlin"
  description = "Terraform with AWS Lambda"
}

resource "aws_api_gateway_resource" "kardapi_resource_proxy" {
  rest_api_id = "${aws_api_gateway_rest_api.kardapi.id}"
  parent_id   = "${aws_api_gateway_rest_api.kardapi.root_resource_id}"
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "kardapi_method_proxy" {
  rest_api_id   = "${aws_api_gateway_rest_api.kardapi.id}"
  resource_id   = "${aws_api_gateway_resource.kardapi_resource_proxy.id}"
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_cloudwatch_log_group" "kardapi" {
  name = "/aws/lambda/kardapi"
}

#
# Function-specific resources
#

# now using terragrunt to build kotlin fat JAR before deployment
# resource "null_resource" "kardapi_build_kotlin" {
#   provisioner "local-exec" {
#     working_dir = "${path.root}/../kotlin/"
#     command = "./gradlew shadowjar"
#   }
# }
# depends_on = ["null_resource.kardapi_build_kotlin"]

resource "aws_lambda_function" "kardapi_func" {
  description = "Kotlin CardAPI HTTP request handler"
  function_name = "kardapi"
  filename = "${path.root}/../kotlin/build/libs/paypoc-kotlin-0.1-all.jar"
  source_code_hash = "${base64sha256(file("${path.root}/../kotlin/build/libs/paypoc-kotlin-0.1-all.jar"))}"
  handler = "com.skybettingandgaming.demos.paypoc.kotlin.Handler::handleRequest"
  role = "${aws_iam_role.lambda_exec.arn}"
  runtime = "java8"
  timeout = 30
  memory_size = 256
}

resource "aws_api_gateway_integration" "kardapi_integ" {
  rest_api_id = "${aws_api_gateway_rest_api.kardapi.id}"
  resource_id = "${aws_api_gateway_method.kardapi_method_proxy.resource_id}"
  http_method = "${aws_api_gateway_method.kardapi_method_proxy.http_method}"
  integration_http_method = "POST"
  type = "AWS_PROXY"
  uri = "${aws_lambda_function.kardapi_func.invoke_arn}"
}

resource "aws_api_gateway_deployment" "kardapi_deploy_alpha" {
  depends_on = [
    "aws_api_gateway_integration.kardapi_integ",
  ]
  rest_api_id = "${aws_api_gateway_rest_api.kardapi.id}"
  stage_name  = "alpha"
}

resource "aws_lambda_permission" "kardapi_gw_perm" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.kardapi_func.arn}"
  principal     = "apigateway.amazonaws.com"
  # The /*/* portion grants access from any method on any resource
  # within the API Gateway "REST API".
  source_arn = "${aws_api_gateway_deployment.kardapi_deploy_alpha.execution_arn}/*/*"
}

# create DynamoDB table to store cards in
resource "aws_dynamodb_table" "kard_table" {
  name           = "Kards"
  read_capacity  = 2
  write_capacity = 200
  hash_key       = "UserId"
  attribute {
    name = "UserId"
    type = "S"
  }
}

resource "aws_iam_role_policy" "lambda_dynamo_kard_access" {
  name = "DynamoDB-access"
  role = "${aws_iam_role.lambda_exec.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Action": [
        "dynamodb:DeleteItem",
        "dynamodb:GetItem",
        "dynamodb:PutItem",
        "dynamodb:UpdateItem"
      ],
      "Resource": "${aws_dynamodb_table.kard_table.arn}"
    }
  ]
}
EOF
}
