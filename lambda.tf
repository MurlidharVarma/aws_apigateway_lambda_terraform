data "aws_iam_policy_document" "lm_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "${var.api_name}_lambda_role"
  assume_role_policy = data.aws_iam_policy_document.lm_assume_role.json
  inline_policy {
    name = "inline_policy"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action   = ["logs:CreateLogGroup","logs:CreateLogStream","logs:PutLogEvents"]
          Effect   = "Allow"
          Resource = "arn:aws:logs:*:*:*"
        },
      ]
    })
  }
}

resource "aws_cloudwatch_log_group" "api_lambda_lg" {
  name              = "/aws/lambda/aktlabs-api_api_lambda"
  retention_in_days = 7
}

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "aktlabs_api_lambda.js"
  output_path = "aktlabs_api_lambda_function_payload.zip"
}

resource "aws_lambda_function" "api_lambda" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename      = "aktlabs_api_lambda_function_payload.zip"
  function_name = "${var.api_name}_api_lambda"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "aktlabs_api_lambda.handler"

  source_code_hash = data.archive_file.lambda.output_base64sha256

  runtime = "nodejs18.x"

  environment {
    variables = {
      region = var.aws_region
    }
  }
}