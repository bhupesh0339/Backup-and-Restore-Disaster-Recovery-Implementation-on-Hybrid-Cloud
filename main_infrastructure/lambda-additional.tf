
resource "aws_iam_role" "lambda_execution_role" {
  name = "lambda_execution_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com",
        },
      },
    ],
  })
}
resource "aws_iam_policy_attachment" "lambda_execution_role_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  name = "lambda_role_policy_attachment"
  roles      = [aws_iam_role.lambda_execution_role.name]
  depends_on = [ aws_iam_role.lambda_execution_role ]
}


resource "aws_iam_role" "lambda_invoke_schedular_role" {
  name = "lambda_invoke_schedular_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "scheduler.amazonaws.com",
        },
      },
    ],
  })
}
resource "aws_iam_policy" "lambda-invoke-policy" {
  name        = "lambdainvoke-policy"
  path        = "/"
  description = "lambdainvoke-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "lambda:InvokeFunction",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}
resource "aws_iam_policy_attachment" "lambda_invoke_policy_attachment" {
  policy_arn = aws_iam_policy.lambda-invoke-policy.arn
  name = "lambda_invoke_policy_attachment"
  roles      = [aws_iam_role.lambda_invoke_schedular_role.name]
  depends_on = [ aws_iam_role.lambda_invoke_schedular_role, aws_iam_policy.lambda-invoke-policy ]
}
