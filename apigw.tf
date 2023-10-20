resource "aws_lambda_permission" "apigw_aktlabs_api" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = "${resource.aws_lambda_function.api_lambda.function_name}"
  principal     = "apigateway.amazonaws.com"

  #--------------------------------------------------------------------------------
  # Per deployment
  #--------------------------------------------------------------------------------
  # The /*/*  grants access from any method on any resource within the deployment.
  # source_arn = "${aws_api_gateway_deployment.test.execution_arn}/*/*"

  #--------------------------------------------------------------------------------
  # Per API
  #--------------------------------------------------------------------------------
  # The /*/*/* part allows invocation from any stage, method and resource path
  # within API Gateway REST API.
  source_arn    = "${aws_api_gateway_rest_api.api-gateway.execution_arn}/*/*/*"
}


resource "aws_cloudwatch_log_group" "aktlabs-api-lg" {
  name              = "/aws/apigateway/loggroup/API-Gateway-Execution-Logs_${aws_api_gateway_rest_api.api-gateway.id}/${var.stage_name}"
  retention_in_days = 7
}

resource "aws_api_gateway_rest_api" "api-gateway" {
  name           = "${var.api_name}"
  description    = "API for AK target"
  api_key_source = "HEADER"
  body           = "${data.template_file.api_spec_file.rendered}"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

data "template_file" "api_spec_file" {
  template = "${file("api_spec.yaml")}"


  vars = {
    aktlabs_api_lambda_invoke_arn = "${resource.aws_lambda_function.api_lambda.invoke_arn}"
    aws_region              = var.aws_region
    audience                = var.client_id
    cognito_user_pool_arn   = var.cognito_user_pool_arn
  }

}

resource "aws_api_gateway_stage" "api_stage" {
  depends_on = [aws_api_gateway_account.aktlabs-api-acc]
  deployment_id = aws_api_gateway_deployment.apideployment.id
  rest_api_id   = aws_api_gateway_rest_api.api-gateway.id
  stage_name    = var.stage_name 
  access_log_settings {
    destination_arn = "${resource.aws_cloudwatch_log_group.aktlabs-api-lg.arn}"
    format = jsonencode({"requestId":"$context.requestId","extendedRequestId":"$context.extendedRequestId","ip":"$context.identity.sourceIp","caller":"$context.identity.caller","user":"$context.identity.user","requestTime":"$context.requestTime","httpMethod":"$context.httpMethod","resourcePath":"$context.resourcePath","status":"$context.status","protocol":"$context.protocol","responseLength":"$context.responseLength"})
  }
}

resource "aws_api_gateway_deployment" "apideployment" {
  rest_api_id = aws_api_gateway_rest_api.api-gateway.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.api-gateway.body))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_account" "aktlabs-api-acc" {
  cloudwatch_role_arn = aws_iam_role.aktlabs-api-cloudwatch.arn
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["apigateway.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "aktlabs-api-cloudwatch" {
  name               = "api_gateway_cloudwatch_global_${var.aws_region}"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "cloudwatch" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents",
      "logs:GetLogEvents",
      "logs:FilterLogEvents",
    ]

    resources = ["*"]
  }
}
resource "aws_iam_role_policy" "cloudwatch" {
  name   = "default"
  role   = aws_iam_role.aktlabs-api-cloudwatch.id
  policy = data.aws_iam_policy_document.cloudwatch.json
}