#
# Output variables for other modules to use
#

output "kardapi_lambda_loadtest" {
  value = "${aws_lambda_function.loadtest_func.function_name}"
}

output "kardapi_gateway_deployment_invoke_url" {
  value = "${aws_api_gateway_deployment.kardapi_deploy_alpha.invoke_url}"
}
