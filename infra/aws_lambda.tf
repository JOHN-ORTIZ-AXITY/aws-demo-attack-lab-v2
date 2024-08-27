resource "aws_lambda_function" "checkov_lambda" {
  filename         = "s3://johnortizlab/ terraform.tfstate"
  function_name    = "checkov_lambda"
  role             = aws_iam_role.lambda_execution_role.arn
  handler          = "lambda_function_payload.lambda_handler"
  runtime          = "python3.9"
  memory_size      = 256
  timeout          = 10
}

resource "aws_iam_role" "lambda_execution_role" {
  name = "checkov_lambda_role"
  assume_role_policy = jsonencode({
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
  })
}
