# IAM Role for Lambda
resource "aws_iam_role" "iam_for_lambda" {
  name               = "${var.deployment_name}-${random_string.unique_id.result}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# IAM Policy to Attach to the Role
resource "aws_iam_policy" "lambda_execution_policy" {
  name = "${var.deployment_name}_lambda_policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "lambda:CreateFunction",
        "lambda:UpdateFunctionCode",
        "lambda:UpdateFunctionConfiguration",
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "s3:GetObject"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

# Attach policy to the role
resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_execution_policy.arn
}

# Lambda Function
resource "aws_lambda_function" "analysis_lambda" {
  filename         = "${path.root}/resources/lambda_function_payload.zip"
  function_name    = "${var.deployment_name}-${random_string.unique_id.result}"
  role             = aws_iam_role.iam_for_lambda.arn
  handler          = "lambda_function_payload.lambda_handler"
  layers           = [ "arn:aws:lambda:us-east-1:108863513136:layer:requests-layer:7" ]
  source_code_hash = filebase64sha256("${path.root}/resources/lambda_function_payload.zip")
  runtime          = "python3.9"

  # Environment variables (Avoid plain-text secrets)
  environment {
    variables = {
      access_key = var.access_key
      secret_key = var.secret_key
    }
  }
}

# Random string resource to generate unique id for resources
resource "random_string" "unique_id" {
  length  = 8
  special = false
}
