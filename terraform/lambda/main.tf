#
# lambda
# Set up Lambda functions
#

#
# Generic/shared resources
#

# set up AWS resources
provider "aws" {
  region = "${var.aws_region}"
}

# capture current user
data "aws_caller_identity" "current" {}

# create iam role to empower the function(s) to do stuff
resource "aws_iam_role" "lambda_exec" {
  name = "cardapi"
  assume_role_policy = "${data.aws_iam_policy_document.lambda_exec-role-policy.json}"
}

data "aws_iam_policy_document" "lambda_exec-role-policy" {
  statement {
    actions = [ "sts:AssumeRole" ]

    principals {
      type = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    effect = "Allow"
    sid = ""
  }

  # can't give Lambda log access here, so use attachment
  # statement {
  #   actions = [
  #     "logs:CreateLogGroup",
  #     "logs:CreateLogStream",
}

resource "aws_iam_policy_attachment" "lambda_exec-role-policy-attachment" {
  name       = "policy_atchmt"
  roles      = ["${aws_iam_role.lambda_exec.name}"]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaDynamoDBExecutionRole"
}

