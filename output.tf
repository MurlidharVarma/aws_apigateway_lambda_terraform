output api_lambda{
    value = resource.aws_lambda_function.api_lambda
}

output api_lambda_role{
    value = resource.aws_iam_role.iam_for_lambda
}

output "apigw_invoke_url" {
  value = "${aws_api_gateway_deployment.apideployment.invoke_url}/"
}

output "custom_domain_api" {
  value = "https://${aws_api_gateway_domain_name.api.domain_name}"
}
